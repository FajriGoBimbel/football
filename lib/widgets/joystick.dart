import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class Joystick extends StatefulWidget {
  final Function(double dx, double dy) onDirectionChanged;
  final VoidCallback? onRelease;
  final double size;

  const Joystick({
    super.key,
    required this.onDirectionChanged,
    this.onRelease,
    this.size = 140,
  });

  @override
  State<Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
  double _dx = 0;
  double _dy = 0;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final knobSize = widget.size * 0.4;
    final maxDist = (widget.size - knobSize) / 2;

    return GestureDetector(
      onPanStart: (_) {
        setState(() => _isDragging = true);
      },
      onPanUpdate: (details) {
        final center = Offset(widget.size / 2, widget.size / 2);
        final position = details.localPosition;
        var delta = position - center;

        // Clamp to max distance
        if (delta.distance > maxDist) {
          delta = Offset.fromDirection(delta.direction, maxDist);
        }

        final normalizedDx = delta.dx / maxDist;
        final normalizedDy = delta.dy / maxDist;

        setState(() {
          _dx = normalizedDx;
          _dy = normalizedDy;
        });

        widget.onDirectionChanged(normalizedDx, normalizedDy);
      },
      onPanEnd: (_) {
        setState(() {
          _dx = 0;
          _dy = 0;
          _isDragging = false;
        });
        widget.onDirectionChanged(0, 0);
        widget.onRelease?.call();
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.black.withOpacity(0.3),
          border: Border.all(
            color: AppTheme.white.withOpacity(0.4),
            width: 2,
          ),
        ),
        child: Center(
          child: Transform.translate(
            offset: Offset(_dx * maxDist, _dy * maxDist),
            child: Container(
              width: knobSize,
              height: knobSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isDragging
                    ? AppTheme.yellow.withOpacity(0.9)
                    : AppTheme.white.withOpacity(0.7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
