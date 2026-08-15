import 'dart:math';
import '../core/constants/game_constants.dart';
import '../core/utils/helpers.dart';
import '../models/player.dart';
import 'game_engine.dart';

class AiService {
  final GameEngine engine;
  final Random _random = Random();
  int _tickCounter = 0;

  AiService({required this.engine});

  void update() {
    _tickCounter++;

    final opponents = engine.opponentTeamPlayers;

    // Determine if AI team has the ball
    final aiHasBall = opponents.any((p) => p.hasBall);
    final ballOwner = aiHasBall
        ? opponents.firstWhere((p) => p.hasBall)
        : null;

    for (final player in opponents) {
      if (player.role == PlayerRole.goalkeeper) {
        _updateGoalkeeper(player);
      } else if (player.hasBall) {
        _updateAttacker(player);
      } else if (aiHasBall) {
        _updateSupport(player, ballOwner!);
      } else {
        _updateDefender(player);
      }
    }
  }

  void _updateGoalkeeper(Player gk) {
    final ball = engine.ball;
    final goalCenterX = engine.fieldWidth / 2;
    final goalY = engine.fieldHeight * 0.06;

    // Track ball x-position but stay near goal
    final targetX = Helpers.clamp(
      ball.x,
      goalCenterX - GameConstants.goalkeeperRange,
      goalCenterX + GameConstants.goalkeeperRange,
    );
    final targetY = goalY;

    _moveToward(gk, targetX, targetY, GameConstants.goalkeeperSpeed * 0.7);

    // If ball is very close, try to grab it
    final dist = Helpers.distance(gk.x, gk.y, ball.x, ball.y);
    if (dist < GameConstants.ballPickupRange * 1.5 && ball.isFree) {
      _moveToward(gk, ball.x, ball.y, GameConstants.goalkeeperSpeed);
    }
  }

  void _updateAttacker(Player attacker) {
    // AI with ball: move toward player's goal (bottom) and shoot when close
    final goalY = engine.fieldHeight * 0.9;
    final goalX = engine.fieldWidth / 2;

    final distToGoal = Helpers.distance(
      attacker.x, attacker.y, goalX, goalY,
    );

    if (distToGoal < GameConstants.aiShootDistance) {
      // Shoot!
      if (_tickCounter % 30 == 0 || distToGoal < 80) {
        engine.aiShoot(attacker);
        return;
      }
    }

    // Move toward goal with some randomness
    final offsetX = (_random.nextDouble() - 0.5) * 40;
    _moveToward(
      attacker,
      goalX + offsetX,
      goalY,
      GameConstants.aiSpeed,
    );
  }

  void _updateSupport(Player player, Player ballOwner) {
    // Move to a supporting position
    final targetX = ballOwner.x + (_random.nextBool() ? 60 : -60);
    final targetY = ballOwner.y + 40;

    _moveToward(
      player,
      Helpers.clamp(targetX, 20, engine.fieldWidth - 20),
      Helpers.clamp(targetY, 20, engine.fieldHeight - 20),
      GameConstants.aiSpeed * 0.6,
    );
  }

  void _updateDefender(Player player) {
    final ball = engine.ball;
    final distToBall = Helpers.distance(player.x, player.y, ball.x, ball.y);

    // Only the nearest non-GK defender chases the ball
    final isNearest = _isNearestFieldPlayer(player);

    if (isNearest && distToBall < GameConstants.aiReactionDistance) {
      // Chase the ball
      _moveToward(player, ball.x, ball.y, GameConstants.aiSpeed);

      // Try to steal ball from player team
      if (distToBall < GameConstants.playerTackleRange) {
        _trySteal(player);
      }
    } else {
      // Return toward initial position with some variation
      final targetX = player.initialX + (_random.nextDouble() - 0.5) * 30;
      final targetY = player.initialY + (_random.nextDouble() - 0.5) * 30;
      _moveToward(player, targetX, targetY, GameConstants.aiSpeed * 0.4);
    }
  }

  bool _isNearestFieldPlayer(Player player) {
    final ball = engine.ball;
    final dist = Helpers.distance(player.x, player.y, ball.x, ball.y);

    for (final other in engine.opponentTeamPlayers) {
      if (other.id == player.id) continue;
      if (other.role == PlayerRole.goalkeeper) continue;
      final otherDist = Helpers.distance(other.x, other.y, ball.x, ball.y);
      if (otherDist < dist) return false;
    }
    return true;
  }

  void _trySteal(Player aiPlayer) {
    final ball = engine.ball;
    if (ball.ownerId == null) return;

    // Check if a player team member has the ball
    final playerWithBall = engine.playerTeamPlayers
        .where((p) => p.hasBall)
        .toList();

    if (playerWithBall.isEmpty) return;

    final target = playerWithBall.first;
    final dist = Helpers.distance(aiPlayer.x, aiPlayer.y, target.x, target.y);

    if (dist < GameConstants.playerTackleRange) {
      // Attempt steal with 30% chance per tick it's in range
      if (_random.nextDouble() < 0.02) {
        target.hasBall = false;
        aiPlayer.hasBall = true;
        ball.ownerId = aiPlayer.id;
        ball.vx = 0;
        ball.vy = 0;
      }
    }
  }

  void _moveToward(Player player, double targetX, double targetY, double speed) {
    final dx = targetX - player.x;
    final dy = targetY - player.y;
    final dist = Helpers.distance(player.x, player.y, targetX, targetY);

    if (dist < 2) return;

    final normalized = Helpers.normalize(dx, dy);
    final moveSpeed = min(speed, dist);

    player.x += normalized[0] * moveSpeed;
    player.y += normalized[1] * moveSpeed;

    // Keep in bounds
    player.x = Helpers.clamp(player.x, 0, engine.fieldWidth);
    player.y = Helpers.clamp(player.y, 0, engine.fieldHeight);

    // Move ball with AI player if they have it
    if (player.hasBall) {
      engine.ball.x = player.x;
      engine.ball.y = player.y + GameConstants.playerSize * 0.4;
    }
  }
}
