// ═══════════════════════════════════════════════════════════════════
// lib/utils/sensor_optimization.dart
// Sensor sensitivity tips and best practices
// ═══════════════════════════════════════════════════════════════════

import 'dart:io';


class SensorOptimization {
  SensorOptimization._();

  /// Current sensor configuration
  static const sensorConfig = '''
  ACCELEROMETER:
    - Sampling: 250ms (4x per second) 
    - Threshold: 1.5 m/s²
    - Axis: X, Y, Z acceleration
  
  MICROPHONE:
    - Sampling: Continuous
    - Threshold: 60.0 dB
    - Type: Mean ambient noise level
  
  FUSION:
    - Logic: AND (both required)
    - Stability: 1 second evaluation window
    - Drop-out time: 2 seconds
  ''';

  /// Get platform-specific sensor strengths
  static String getPlatformSensorInfo() {
    final platform = Platform.isAndroid ? 'Android' : 
                     Platform.isIOS ? 'iOS' : 
                     'Unknown';
    
    return '''
    Platform: $platform
    
    ${Platform.isAndroid ? _androidSensorInfo() : _iosSensorInfo()}
    ''';
  }

  static String _androidSensorInfo() {
    return '''
    ANDROID SENSORS:
    ✅ Accelerometer: Excellent (varies by device)
    ✅ Microphone: Good (RECORD_AUDIO permission required)
    ⚠️ Background: Requires FOREGROUND_SERVICE
    ⚠️ Battery: May use 2-5% per hour of monitoring
    
    To improve:
    1. Use newest API levels (33+)
    2. Request RECORD_AUDIO at runtime
    3. Use foreground service for reliability
    4. Test on different OEM devices
    ''';
  }

  static String _iosSensorInfo() {
    return '''
    iOS SENSORS:
    ✅ Accelerometer: Excellent (all devices)
    ✅ Microphone: Very good (requires permission)
    ⚠️ Background: Limited (needs special setup)
    ⚠️ Battery: 1-3% per hour when active
    
    To improve:
    1. Add NSMicrophoneUsageDescription to Info.plist ✅
    2. Add NSMotionUsageDescription to Info.plist ✅
    3. Request permissions in Settings app
    4. Use background modes carefully
    ''';
  }

  /// Recommended thresholds for different scenarios
  static const Map<String, Map<String, double>> thresholdProfiles = {
    'sensitive': {
      'motion': 1.2,      // More sensitive to movement
      'noise': 55.0,      // Lower noise threshold
    },
    'balanced': {
      'motion': 1.5,      // Default
      'noise': 60.0,      // Default
    },
    'stable': {
      'motion': 2.0,      // More stable, fewer false positives
      'noise': 65.0,      // Higher noise threshold
    },
  };

  /// Diagnostic: Check sensor quality
  static String getSensorDiagnostics({
    required double recentMotion,
    required double recentNoise,
    required bool isDriving,
  }) {
    return '''
    SENSOR DIAGNOSTICS:
    • Motion Level: ${recentMotion.toStringAsFixed(2)} m/s²
    • Noise Level: ${recentNoise.toStringAsFixed(1)} dB
    • Status: ${isDriving ? '🚗 DRIVING' : '🚶 NOT DRIVING'}
    
    Quality Checks:
    ${recentMotion > 0 ? '✅' : '❌'} Accelerometer active
    ${recentNoise > 0 ? '✅' : '❌'} Microphone active
    ${isDriving ? '✅' : '⚠️'} Driving detection working
    ''';
  }
}
