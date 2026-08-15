class Ball {
  double x;
  double y;
  double vx;
  double vy;
  String? ownerId;

  Ball({
    required this.x,
    required this.y,
    this.vx = 0,
    this.vy = 0,
    this.ownerId,
  });

  void reset(double startX, double startY) {
    x = startX;
    y = startY;
    vx = 0;
    vy = 0;
    ownerId = null;
  }

  bool get isFree => ownerId == null;

  bool get isMoving => vx.abs() > 0.1 || vy.abs() > 0.1;
}
