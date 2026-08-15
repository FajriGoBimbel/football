class GameConstants {
  // Match duration options (in seconds)
  static const int durationShort = 60;
  static const int durationMedium = 90;
  static const int durationLong = 120;
  static const int defaultDuration = durationMedium;

  // Field dimensions (logical units)
  static const double fieldWidth = 360.0;
  static const double fieldHeight = 560.0;

  // Goal dimensions
  static const double goalWidth = 100.0;
  static const double goalHeight = 30.0;

  // Player settings
  static const double playerSize = 28.0;
  static const double playerSpeed = 2.5;
  static const double playerSprintSpeed = 4.0;
  static const double playerTackleRange = 30.0;

  // Ball settings
  static const double ballSize = 14.0;
  static const double ballSpeed = 5.0;
  static const double shootSpeed = 8.0;
  static const double passSpeed = 5.5;
  static const double ballFriction = 0.97;
  static const double ballPickupRange = 20.0;

  // AI settings
  static const double aiReactionDistance = 180.0;
  static const double aiShootDistance = 140.0;
  static const double aiPassDistance = 100.0;
  static const double aiSpeed = 2.2;

  // Goalkeeper settings
  static const double goalkeeperSpeed = 2.8;
  static const double goalkeeperRange = 60.0;

  // Team size
  static const int playersPerTeam = 5; // 1 GK + 4 outfield

  // Goal celebration pause (milliseconds)
  static const int goalPauseDuration = 2000;

  // Game tick rate (milliseconds)
  static const int gameTickMs = 16; // ~60fps
}
