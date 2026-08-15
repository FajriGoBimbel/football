import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/team.dart';

class TeamCard extends StatelessWidget {
  final Team team;
  final bool isSelected;

  const TeamCard({
    super.key,
    required this.team,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppTheme.yellow : AppTheme.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            team.flag,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 8),
          Text(
            team.name.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.white,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
