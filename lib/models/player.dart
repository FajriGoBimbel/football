enum PlayerRole {
  goalkeeper,
  defender,
  midfielder,
  forward,
}

class Player {
  final String id;
  final String teamId;
  final PlayerRole role;
  final double speed;
  double x;
  double y;
  double targetX;
  double targetY;
  double initialX;
  double initialY;
  bool hasBall;

  Player({
    required this.id,
    required this.teamId,
    required this.role,
    required this.speed,
    required this.x,
    required this.y,
    this.hasBall = false,
  })  : targetX = x,
        targetY = y,
        initialX = x,
        initialY = y;

  void resetPosition() {
    x = initialX;
    y = initialY;
    targetX = initialX;
    targetY = initialY;
    hasBall = false;
  }

  Player copyWith({
    String? id,
    String? teamId,
    PlayerRole? role,
    double? speed,
    double? x,
    double? y,
  }) {
    return Player(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      role: role ?? this.role,
      speed: speed ?? this.speed,
      x: x ?? this.x,
      y: y ?? this.y,
      hasBall: hasBall,
    );
  }
}
