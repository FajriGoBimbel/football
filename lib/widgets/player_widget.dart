import 'package:flutter/material.dart';
import '../core/constants/game_constants.dart';
import '../models/player.dart';

class PlayerWidget extends StatelessWidget {
  final Player player;
  final Color teamColor;
  final bool isActive;
  final bool isOpponent;

  const PlayerWidget({
    super.key,
    required this.player,
    required this.teamColor,
    this.isActive = false,
    this.isOpponent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: player.x - GameConstants.playerSize / 2,
      top: player.y - GameConstants.playerSize / 2,
      child: Container(
        width: GameConstants.playerSize,
        height: GameConstants.playerSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: teamColor,
          border: Border.all(
            color: isActive
                ? Colors.yellow
                : Colors.white.withOpacity(0.8),
            width: isActive ? 3 : 1.5,
          ),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: Colors.yellow.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: player.role == PlayerRole.goalkeeper
              ? const Icon(Icons.shield, color: Colors.white, size: 14)
              : Text(
                  isOpponent ? '▼' : '▲',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
