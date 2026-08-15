import 'dart:math';

class Helpers {
  static final Random _random = Random();

  /// Format seconds into MM:SS
  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Calculate distance between two points
  static double distance(double x1, double y1, double x2, double y2) {
    return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
  }

  /// Normalize a vector
  static List<double> normalize(double dx, double dy) {
    final length = sqrt(dx * dx + dy * dy);
    if (length == 0) return [0, 0];
    return [dx / length, dy / length];
  }

  /// Get a random double within range
  static double randomRange(double min, double max) {
    return min + _random.nextDouble() * (max - min);
  }

  /// Clamp a value between min and max
  static double clamp(double value, double min, double max) {
    return value.clamp(min, max);
  }

  /// Calculate angle between two points
  static double angle(double x1, double y1, double x2, double y2) {
    return atan2(y2 - y1, x2 - x1);
  }
}
