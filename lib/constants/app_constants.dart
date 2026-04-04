/// Animation duration constants
class AnimationDurations {
  AnimationDurations._();

  // Status ring animations
  static const Duration outerRotation = Duration(seconds: 12);
  static const Duration innerBreathe = Duration(milliseconds: 2000);
  static const Duration pingPulse = Duration(milliseconds: 1200);
  static const Duration colorTransition = Duration(milliseconds: 600);

  // UI transitions
  static const Duration switchAnimation = Duration(milliseconds: 400);
  static const Duration fadeAnimation = Duration(milliseconds: 200);
  static const Duration staggeredEntrance = Duration(milliseconds: 800);
}

/// Sensor thresholds
class SensorThresholds {
  SensorThresholds._();

  static const double motionThreshold = 1.5; // m/s²
  static const double noiseThreshold = 60.0; // dB
  static const Duration sensorSampling = Duration(milliseconds: 500);
  static const Duration backgroundTaskInterval = Duration(seconds: 1);
}

/// UI spacing and sizing
class UISizes {
  UISizes._();

  // Border radius
  static const double cornerRadiusSm = 8.0;
  static const double cornerRadiusMd = 16.0;
  static const double cornerRadiusLg = 40.0;

  // Icon sizes
  static const double iconSm = 20.0;
  static const double iconMd = 22.0;
  static const double iconLg = 52.0;

  // Status ring
  static const double statusRingSize = 240.0;
  static const double statusRingOuterSize = 230.0;
  static const double statusRingMiddleSize = 196.0;
  static const double statusRingInnerSize = 162.0;

  // Padding
  static const double paddingSm = 8.0;
  static const double paddingMd = 12.0;
  static const double paddingLg = 16.0;
  static const double paddingXl = 20.0;
  static const double paddingXxl = 24.0;

  // Height
  static const double bottomNavHeight = 68.0;
}

/// String constants
class AppStrings {
  AppStrings._();

  static const String appName = 'AutoSilencer';
  static const String channelId = 'autosilencer_channel';
  static const String channelName = 'AutoSilencer';
  static const String methodChannel = 'autosilencer/audio';
}
