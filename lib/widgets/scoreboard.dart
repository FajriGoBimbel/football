import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/helpers.dart';
import '../models/team.dart';

class Scoreboard extends StatelessWidget {
  final Team playerTeam;
  final Team opponentTeam;
  final int playerScore;
  final int opponentScore;
  final int timeRemaining;
  final VoidCallback? onPause;

  const Scoreboard({
    super.key,
    required this.playerTeam,
    required this.opponentTeam,
    required this.playerScore,
    required this.opponentScore,
    required this.timeRemaining,
    this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Player team
          _buildTeamScore(playerTeam, playerScore),

          // Timer
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Helpers.formatTime(timeRemaining),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.white,
                  fontFamily: 'monospace',
                ),
              ),
              const Text(
                'TIME',
                style: TextStyle(
                  fontSize: 9,
                  color: AppTheme.grey,
                ),
              ),
            ],
          ),

          // Opponent team
          _buildTeamScore(opponentTeam, opponentScore),

          // Pause button
          if (onPause != null)
            IconButton(
              onPressed: onPause,
              icon: const Icon(Icons.pause, color: AppTheme.white, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }

  Widget _buildTeamScore(Team team, int score) {
    return Row(
      children: [
        Text(
          team.flag,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              team.shortName,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
              ),
            ),
            Text(
              score.toString(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppTheme.yellow,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
