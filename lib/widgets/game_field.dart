import 'package:flutter/material.dart';
import '../core/constants/game_constants.dart';
import '../core/theme/app_theme.dart';

class GameFieldPainter extends CustomPainter {
  final double fieldWidth;
  final double fieldHeight;

  GameFieldPainter({
    required this.fieldWidth,
    required this.fieldHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fieldPaint = Paint()
      ..color = AppTheme.fieldGreen
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw field background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      fieldPaint,
    );

    // Draw field stripes
    final stripePaint = Paint()
      ..color = AppTheme.darkGreen.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final stripeHeight = size.height / 10;
    for (int i = 0; i < 10; i += 2) {
      canvas.drawRect(
        Rect.fromLTWH(0, i * stripeHeight, size.width, stripeHeight),
        stripePaint,
      );
    }

    // Draw border
    canvas.drawRect(
      Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
      linePaint,
    );

    // Draw center line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      linePaint,
    );

    // Draw center circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      50,
      linePaint,
    );

    // Draw center dot
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      4,
      dotPaint,
    );

    // Draw goal areas
    const goalWidth = GameConstants.goalWidth;
    final goalLeft = (size.width - goalWidth) / 2;

    // Top goal (opponent)
    final topGoalRect = Rect.fromLTWH(
      goalLeft,
      0,
      goalWidth,
      GameConstants.goalHeight,
    );
    canvas.drawRect(topGoalRect, linePaint);

    // Top goal net effect
    final goalNetPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawRect(topGoalRect, goalNetPaint);

    // Bottom goal (player)
    final bottomGoalRect = Rect.fromLTWH(
      goalLeft,
      size.height - GameConstants.goalHeight,
      goalWidth,
      GameConstants.goalHeight,
    );
    canvas.drawRect(bottomGoalRect, linePaint);
    canvas.drawRect(bottomGoalRect, goalNetPaint);

    // Draw penalty areas
    const penaltyWidth = goalWidth + 60;
    final penaltyLeft = (size.width - penaltyWidth) / 2;
    const penaltyHeight = 60.0;

    // Top penalty area
    canvas.drawRect(
      Rect.fromLTWH(penaltyLeft, 0, penaltyWidth, penaltyHeight),
      linePaint,
    );

    // Bottom penalty area
    canvas.drawRect(
      Rect.fromLTWH(
        penaltyLeft,
        size.height - penaltyHeight,
        penaltyWidth,
        penaltyHeight,
      ),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
