import 'package:flutter/material.dart';
import '../core/constants/game_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/team.dart';
import '../services/game_engine.dart';
import '../widgets/action_button.dart';
import '../widgets/game_field.dart';
import '../widgets/joystick.dart';
import '../widgets/player_widget.dart';
import '../widgets/scoreboard.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameEngine _engine;
  bool _initialized = false;
  bool _isSprinting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final playerTeam = args['playerTeam'] as Team;
      final opponentTeam = args['opponentTeam'] as Team;

      _engine = GameEngine(
        playerTeam: playerTeam,
        opponentTeam: opponentTeam,
      );
      _engine.addListener(_onGameUpdate);
      _initialized = true;
    }
  }

  void _onGameUpdate() {
    if (mounted) {
      setState(() {});

      // Check if match is finished
      if (_engine.state == GameState.finished) {
        _navigateToResult();
      }
    }
  }

  void _navigateToResult() {
    Future.microtask(() {
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/result',
          arguments: _engine.getMatchResult(),
        );
      }
    });
  }

  @override
  void dispose() {
    _engine.removeListener(_onGameUpdate);
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Scoreboard
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Scoreboard(
                playerTeam: _engine.playerTeam,
                opponentTeam: _engine.opponentTeam,
                playerScore: _engine.playerScore,
                opponentScore: _engine.opponentScore,
                timeRemaining: _engine.timeRemaining,
                onPause: _engine.state == GameState.playing
                    ? _showPauseMenu
                    : null,
              ),
            ),

            // Game Field
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final fieldWidth = constraints.maxWidth;
                  final fieldHeight = constraints.maxHeight;

                  // Update engine field size
                  if (_engine.fieldWidth != fieldWidth ||
                      _engine.fieldHeight != fieldHeight) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _engine.setFieldSize(fieldWidth, fieldHeight);
                    });
                  }

                  return GestureDetector(
                    onTap: () {
                      if (_engine.state == GameState.ready) {
                        _engine.startGame();
                      }
                    },
                    child: Stack(
                      children: [
                        // Field
                        CustomPaint(
                          size: Size(fieldWidth, fieldHeight),
                          painter: GameFieldPainter(
                            fieldWidth: fieldWidth,
                            fieldHeight: fieldHeight,
                          ),
                        ),

                        // Players - Opponent team
                        ..._engine.opponentTeamPlayers.map(
                          (player) => PlayerWidget(
                            player: player,
                            teamColor: _engine.opponentTeam.primaryColor,
                            isOpponent: true,
                          ),
                        ),

                        // Players - Player team
                        ..._engine.playerTeamPlayers.map(
                          (player) => PlayerWidget(
                            player: player,
                            teamColor: _engine.playerTeam.primaryColor,
                            isActive: player.id == _engine.activePlayer?.id,
                          ),
                        ),

                        // Ball
                        Positioned(
                          left: _engine.ball.x - GameConstants.ballSize / 2,
                          top: _engine.ball.y - GameConstants.ballSize / 2,
                          child: Container(
                            width: GameConstants.ballSize,
                            height: GameConstants.ballSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.black45,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                '⚽',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                        ),

                        // Ready state overlay
                        if (_engine.state == GameState.ready)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.black.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                'TAP TO START',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.yellow,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),

                        // Goal celebration overlay
                        if (_engine.state == GameState.goal)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 24,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.black.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppTheme.yellow,
                                  width: 3,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    '⚽ GOAL! ⚽',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.yellow,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _engine.lastGoalScorer.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Controls
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.black.withOpacity(0.8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Joystick
                  Joystick(
                    size: 120,
                    onDirectionChanged: (dx, dy) {
                      _engine.setJoystickDirection(dx, dy);
                    },
                    onRelease: () {
                      _engine.setJoystickDirection(0, 0);
                    },
                  ),

                  // Action buttons
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          ActionButton(
                            label: 'PASS',
                            icon: Icons.swap_horiz,
                            onPressed: () => _engine.pass(),
                            color: Colors.blue,
                            size: 54,
                          ),
                          const SizedBox(width: 12),
                          ActionButton(
                            label: 'SHOOT',
                            icon: Icons.sports_soccer,
                            onPressed: () => _engine.shoot(),
                            color: AppTheme.red,
                            size: 54,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Sprint button
                          GestureDetector(
                            onTapDown: (_) {
                              _isSprinting = true;
                              _engine.setSprinting(true);
                            },
                            onTapUp: (_) {
                              _isSprinting = false;
                              _engine.setSprinting(false);
                            },
                            onTapCancel: () {
                              _isSprinting = false;
                              _engine.setSprinting(false);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _isSprinting
                                    ? AppTheme.yellow
                                    : Colors.orange.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.directions_run,
                                    color: AppTheme.black,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'SPRINT',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Switch player
                          GestureDetector(
                            onTap: () => _engine.switchActivePlayer(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.teal.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.swap_vert,
                                    color: AppTheme.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'SWITCH',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPauseMenu() {
    _engine.pauseGame();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'PAUSED',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _engine.resumeGame();
                },
                child: const Text('RESUME'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.white,
                  side: const BorderSide(color: AppTheme.white),
                ),
                child: const Text('QUIT'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
