import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/game_constants.dart';
import '../core/utils/helpers.dart';
import '../models/ball.dart';
import '../models/match_result.dart';
import '../models/player.dart';
import '../models/team.dart';
import 'ai_service.dart';

enum GameState {
  ready,
  playing,
  goal,
  paused,
  finished,
}

class GameEngine extends ChangeNotifier {
  // Teams
  final Team playerTeam;
  final Team opponentTeam;

  // Game state
  GameState _state = GameState.ready;
  GameState get state => _state;

  // Score
  int _playerScore = 0;
  int _opponentScore = 0;
  int get playerScore => _playerScore;
  int get opponentScore => _opponentScore;

  // Timer
  int _matchDuration = GameConstants.defaultDuration;
  int _timeRemaining = GameConstants.defaultDuration;
  int get timeRemaining => _timeRemaining;

  // Players
  List<Player> _playerTeamPlayers = [];
  List<Player> _opponentTeamPlayers = [];
  List<Player> get playerTeamPlayers => _playerTeamPlayers;
  List<Player> get opponentTeamPlayers => _opponentTeamPlayers;

  // Ball
  late Ball _ball;
  Ball get ball => _ball;

  // Active player (controlled by user)
  Player? _activePlayer;
  Player? get activePlayer => _activePlayer;

  // Joystick direction
  double _joystickDx = 0;
  double _joystickDy = 0;
  bool _isSprinting = false;

  // Field dimensions (set by the widget)
  double _fieldWidth = GameConstants.fieldWidth;
  double _fieldHeight = GameConstants.fieldHeight;
  double get fieldWidth => _fieldWidth;
  double get fieldHeight => _fieldHeight;

  // Game loop timer
  Timer? _gameTimer;
  Timer? _countdownTimer;

  // AI
  late AiService _aiService;

  // Goal state
  String _lastGoalScorer = '';
  String get lastGoalScorer => _lastGoalScorer;

  // Kickoff direction: true = player kicks off, false = opponent
  bool _playerKickoff = true;

  GameEngine({
    required this.playerTeam,
    required this.opponentTeam,
    int? matchDuration,
  }) {
    _matchDuration = matchDuration ?? GameConstants.defaultDuration;
    _timeRemaining = _matchDuration;
    _ball = Ball(x: _fieldWidth / 2, y: _fieldHeight / 2);
    _aiService = AiService(engine: this);
    _initializePlayers();
  }

  void setFieldSize(double width, double height) {
    _fieldWidth = width;
    _fieldHeight = height;
    _initializePlayers();
    notifyListeners();
  }

  void _initializePlayers() {
    _playerTeamPlayers = _createTeamPlayers(
      teamId: playerTeam.id,
      isTop: false, // Player attacks upward
    );
    _opponentTeamPlayers = _createTeamPlayers(
      teamId: opponentTeam.id,
      isTop: true, // Opponent attacks downward
    );
    _activePlayer = _playerTeamPlayers.firstWhere(
      (p) => p.role == PlayerRole.forward,
    );
    _ball = Ball(x: _fieldWidth / 2, y: _fieldHeight / 2);
  }

  List<Player> _createTeamPlayers({
    required String teamId,
    required bool isTop,
  }) {
    final midX = _fieldWidth / 2;
    final players = <Player>[];

    if (isTop) {
      // Opponent: attacks downward (their goal is at top)
      players.add(Player(
        id: '${teamId}_gk',
        teamId: teamId,
        role: PlayerRole.goalkeeper,
        speed: GameConstants.goalkeeperSpeed,
        x: midX,
        y: _fieldHeight * 0.06,
      ));
      players.add(Player(
        id: '${teamId}_def1',
        teamId: teamId,
        role: PlayerRole.defender,
        speed: GameConstants.aiSpeed,
        x: midX - _fieldWidth * 0.2,
        y: _fieldHeight * 0.2,
      ));
      players.add(Player(
        id: '${teamId}_def2',
        teamId: teamId,
        role: PlayerRole.defender,
        speed: GameConstants.aiSpeed,
        x: midX + _fieldWidth * 0.2,
        y: _fieldHeight * 0.2,
      ));
      players.add(Player(
        id: '${teamId}_mid',
        teamId: teamId,
        role: PlayerRole.midfielder,
        speed: GameConstants.aiSpeed,
        x: midX,
        y: _fieldHeight * 0.35,
      ));
      players.add(Player(
        id: '${teamId}_fwd',
        teamId: teamId,
        role: PlayerRole.forward,
        speed: GameConstants.aiSpeed + 0.3,
        x: midX,
        y: _fieldHeight * 0.45,
      ));
    } else {
      // Player: attacks upward (their goal is at bottom)
      players.add(Player(
        id: '${teamId}_gk',
        teamId: teamId,
        role: PlayerRole.goalkeeper,
        speed: GameConstants.goalkeeperSpeed,
        x: midX,
        y: _fieldHeight * 0.94,
      ));
      players.add(Player(
        id: '${teamId}_def1',
        teamId: teamId,
        role: PlayerRole.defender,
        speed: GameConstants.playerSpeed,
        x: midX - _fieldWidth * 0.2,
        y: _fieldHeight * 0.8,
      ));
      players.add(Player(
        id: '${teamId}_def2',
        teamId: teamId,
        role: PlayerRole.defender,
        speed: GameConstants.playerSpeed,
        x: midX + _fieldWidth * 0.2,
        y: _fieldHeight * 0.8,
      ));
      players.add(Player(
        id: '${teamId}_mid',
        teamId: teamId,
        role: PlayerRole.midfielder,
        speed: GameConstants.playerSpeed,
        x: midX,
        y: _fieldHeight * 0.65,
      ));
      players.add(Player(
        id: '${teamId}_fwd',
        teamId: teamId,
        role: PlayerRole.forward,
        speed: GameConstants.playerSpeed + 0.3,
        x: midX,
        y: _fieldHeight * 0.5,
      ));
    }
    return players;
  }

  // --- Game Control ---

  void startGame() {
    if (_state == GameState.ready || _state == GameState.paused) {
      _state = GameState.playing;
      _startGameLoop();
      _startCountdown();
      notifyListeners();
    }
  }

  void pauseGame() {
    if (_state == GameState.playing) {
      _state = GameState.paused;
      _stopGameLoop();
      _stopCountdown();
      notifyListeners();
    }
  }

  void resumeGame() {
    if (_state == GameState.paused) {
      _state = GameState.playing;
      _startGameLoop();
      _startCountdown();
      notifyListeners();
    }
  }

  void _startGameLoop() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(
      const Duration(milliseconds: GameConstants.gameTickMs),
      (_) => _gameTick(),
    );
  }

  void _stopGameLoop() {
    _gameTimer?.cancel();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (_timeRemaining > 0) {
          _timeRemaining--;
          if (_timeRemaining == 0) {
            _endMatch();
          }
          notifyListeners();
        }
      },
    );
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
  }

  void _endMatch() {
    _state = GameState.finished;
    _stopGameLoop();
    _stopCountdown();
    notifyListeners();
  }

  MatchResult getMatchResult() {
    return MatchResult(
      playerTeam: playerTeam,
      opponentTeam: opponentTeam,
      playerScore: _playerScore,
      opponentScore: _opponentScore,
    );
  }

  // --- Game Loop ---

  void _gameTick() {
    if (_state != GameState.playing) return;

    _updateActivePlayer();
    _updateBall();
    _checkBallPickup();
    _aiService.update();
    _checkGoal();
    notifyListeners();
  }

  // --- Player Control ---

  void setJoystickDirection(double dx, double dy) {
    _joystickDx = dx;
    _joystickDy = dy;
  }

  void setSprinting(bool sprinting) {
    _isSprinting = sprinting;
  }

  void _updateActivePlayer() {
    if (_activePlayer == null) return;

    final speed = _isSprinting
        ? GameConstants.playerSprintSpeed
        : _activePlayer!.speed;

    final newX = _activePlayer!.x + _joystickDx * speed;
    final newY = _activePlayer!.y + _joystickDy * speed;

    _activePlayer!.x = Helpers.clamp(newX, 0, _fieldWidth);
    _activePlayer!.y = Helpers.clamp(newY, 0, _fieldHeight);

    // If the active player has the ball, move ball with them
    if (_activePlayer!.hasBall) {
      _ball.x = _activePlayer!.x;
      _ball.y = _activePlayer!.y - GameConstants.playerSize * 0.4;
      _ball.ownerId = _activePlayer!.id;
    }
  }

  // --- Ball Logic ---

  void _updateBall() {
    if (_ball.ownerId != null) return; // Ball attached to a player

    _ball.x += _ball.vx;
    _ball.y += _ball.vy;
    _ball.vx *= GameConstants.ballFriction;
    _ball.vy *= GameConstants.ballFriction;

    // Bounce off side walls
    if (_ball.x <= 0 || _ball.x >= _fieldWidth) {
      _ball.vx = -_ball.vx;
      _ball.x = Helpers.clamp(_ball.x, 0, _fieldWidth);
    }

    // Ball goes out top/bottom but not in goal area
    final goalLeft = (_fieldWidth - GameConstants.goalWidth) / 2;
    final goalRight = goalLeft + GameConstants.goalWidth;

    if (_ball.y <= 0 || _ball.y >= _fieldHeight) {
      if (_ball.x < goalLeft || _ball.x > goalRight) {
        _ball.vy = -_ball.vy;
        _ball.y = Helpers.clamp(_ball.y, 0, _fieldHeight);
      }
    }

    // Stop ball if very slow
    if (_ball.vx.abs() < 0.1 && _ball.vy.abs() < 0.1) {
      _ball.vx = 0;
      _ball.vy = 0;
    }
  }

  void _checkBallPickup() {
    if (_ball.ownerId != null) return;
    if (_ball.isMoving && (_ball.vx.abs() > 1 || _ball.vy.abs() > 1)) return;

    // Check all players for ball pickup
    final allPlayers = [..._playerTeamPlayers, ..._opponentTeamPlayers];
    for (final player in allPlayers) {
      final dist = Helpers.distance(player.x, player.y, _ball.x, _ball.y);
      if (dist < GameConstants.ballPickupRange) {
        _giveBallToPlayer(player);
        break;
      }
    }
  }

  void _giveBallToPlayer(Player player) {
    // Remove ball from all players first
    for (final p in [..._playerTeamPlayers, ..._opponentTeamPlayers]) {
      p.hasBall = false;
    }
    player.hasBall = true;
    _ball.ownerId = player.id;
    _ball.vx = 0;
    _ball.vy = 0;

    // Switch active player if it's a player team member
    if (_playerTeamPlayers.contains(player)) {
      _activePlayer = player;
    }
  }

  // --- Actions ---

  void pass() {
    if (_state != GameState.playing) return;
    if (_activePlayer == null || !_activePlayer!.hasBall) return;

    // Find nearest teammate
    Player? nearestTeammate;
    double nearestDist = double.infinity;

    for (final player in _playerTeamPlayers) {
      if (player.id == _activePlayer!.id) continue;
      final dist = Helpers.distance(
        _activePlayer!.x, _activePlayer!.y,
        player.x, player.y,
      );
      if (dist < nearestDist) {
        nearestDist = dist;
        nearestTeammate = player;
      }
    }

    if (nearestTeammate != null) {
      _activePlayer!.hasBall = false;
      _ball.ownerId = null;

      final dir = Helpers.normalize(
        nearestTeammate.x - _activePlayer!.x,
        nearestTeammate.y - _activePlayer!.y,
      );
      _ball.vx = dir[0] * GameConstants.passSpeed;
      _ball.vy = dir[1] * GameConstants.passSpeed;
    }
  }

  void shoot() {
    if (_state != GameState.playing) return;
    if (_activePlayer == null || !_activePlayer!.hasBall) return;

    _activePlayer!.hasBall = false;
    _ball.ownerId = null;

    // Shoot toward opponent's goal (top of field)
    final goalCenterX = _fieldWidth / 2;
    final goalY = 0.0;

    final dir = Helpers.normalize(
      goalCenterX - _ball.x,
      goalY - _ball.y,
    );

    // Add some randomness to the shot
    final random = Random();
    final spread = (random.nextDouble() - 0.5) * 0.3;

    _ball.vx = (dir[0] + spread) * GameConstants.shootSpeed;
    _ball.vy = dir[1] * GameConstants.shootSpeed;
  }

  // AI shoot (towards bottom goal)
  void aiShoot(Player aiPlayer) {
    if (!aiPlayer.hasBall) return;

    aiPlayer.hasBall = false;
    _ball.ownerId = null;

    final goalCenterX = _fieldWidth / 2;
    final goalY = _fieldHeight;

    final dir = Helpers.normalize(
      goalCenterX - _ball.x,
      goalY - _ball.y,
    );

    final random = Random();
    final spread = (random.nextDouble() - 0.5) * 0.3;

    _ball.vx = (dir[0] + spread) * GameConstants.shootSpeed * 0.85;
    _ball.vy = dir[1] * GameConstants.shootSpeed * 0.85;
  }

  // AI pass
  void aiPass(Player from, Player to) {
    if (!from.hasBall) return;

    from.hasBall = false;
    _ball.ownerId = null;

    final dir = Helpers.normalize(
      to.x - from.x,
      to.y - from.y,
    );
    _ball.vx = dir[0] * GameConstants.passSpeed * 0.9;
    _ball.vy = dir[1] * GameConstants.passSpeed * 0.9;
  }

  // --- Tackle / steal ---

  void tryTackle() {
    if (_state != GameState.playing) return;
    if (_activePlayer == null) return;

    // Find opponent with ball
    for (final opponent in _opponentTeamPlayers) {
      if (opponent.hasBall) {
        final dist = Helpers.distance(
          _activePlayer!.x, _activePlayer!.y,
          opponent.x, opponent.y,
        );
        if (dist < GameConstants.playerTackleRange) {
          // Steal ball
          final random = Random();
          if (random.nextDouble() < 0.6) {
            // 60% success rate
            opponent.hasBall = false;
            _giveBallToPlayer(_activePlayer!);
          }
        }
        break;
      }
    }
  }

  // --- Goal Detection ---

  void _checkGoal() {
    final goalLeft = (_fieldWidth - GameConstants.goalWidth) / 2;
    final goalRight = goalLeft + GameConstants.goalWidth;

    // Opponent's goal (top)
    if (_ball.y <= 2 && _ball.x >= goalLeft && _ball.x <= goalRight) {
      _onGoalScored(isPlayerGoal: true);
      return;
    }

    // Player's goal (bottom)
    if (_ball.y >= _fieldHeight - 2 &&
        _ball.x >= goalLeft &&
        _ball.x <= goalRight) {
      _onGoalScored(isPlayerGoal: false);
      return;
    }
  }

  void _onGoalScored({required bool isPlayerGoal}) {
    _state = GameState.goal;
    _stopGameLoop();

    if (isPlayerGoal) {
      _playerScore++;
      _lastGoalScorer = playerTeam.name;
      _playerKickoff = false;
    } else {
      _opponentScore++;
      _lastGoalScorer = opponentTeam.name;
      _playerKickoff = true;
    }

    notifyListeners();

    // Resume after pause
    Future.delayed(
      const Duration(milliseconds: GameConstants.goalPauseDuration),
      () {
        if (_timeRemaining > 0) {
          _resetPositions();
          _state = GameState.playing;
          _startGameLoop();
          notifyListeners();
        } else {
          _endMatch();
        }
      },
    );
  }

  void _resetPositions() {
    for (final player in _playerTeamPlayers) {
      player.resetPosition();
    }
    for (final player in _opponentTeamPlayers) {
      player.resetPosition();
    }

    _ball.reset(_fieldWidth / 2, _fieldHeight / 2);

    // Give kickoff
    if (_playerKickoff) {
      final fwd = _playerTeamPlayers.firstWhere(
        (p) => p.role == PlayerRole.forward,
      );
      _giveBallToPlayer(fwd);
      _activePlayer = fwd;
    } else {
      final fwd = _opponentTeamPlayers.firstWhere(
        (p) => p.role == PlayerRole.forward,
      );
      _giveBallToPlayer(fwd);
    }
  }

  // --- Utility ---

  void switchActivePlayer() {
    if (_playerTeamPlayers.isEmpty) return;

    final currentIndex = _playerTeamPlayers.indexOf(_activePlayer!);
    final nextIndex = (currentIndex + 1) % _playerTeamPlayers.length;
    _activePlayer = _playerTeamPlayers[nextIndex];
    notifyListeners();
  }

  Player? findNearestPlayerTeamPlayer(double x, double y) {
    Player? nearest;
    double nearestDist = double.infinity;
    for (final player in _playerTeamPlayers) {
      final dist = Helpers.distance(player.x, player.y, x, y);
      if (dist < nearestDist) {
        nearestDist = dist;
        nearest = player;
      }
    }
    return nearest;
  }

  @override
  void dispose() {
    _stopGameLoop();
    _stopCountdown();
    super.dispose();
  }
}
