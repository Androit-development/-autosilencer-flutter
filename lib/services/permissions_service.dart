import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class PermissionsService {
  PermissionsService._();

  static List<ph.Permission> _requiredPermissions() {
    final permissions = <ph.Permission>[
      ph.Permission.microphone,
      ph.Permission.notification,
    ];

    if (Platform.isAndroid) {
      permissions.add(ph.Permission.activityRecognition);
      permissions.add(ph.Permission.sensors);
      permissions.add(ph.Permission.bodySensors);
    } else if (Platform.isIOS) {
      permissions.add(ph.Permission.sensors);
    }

    return permissions;
  }

  static Future<bool> requestAllPermissions() async {
    try {
      final results = await _requiredPermissions().request();
      debugPrint('Permissions requested: $results');
      for (final entry in results.entries) {
        debugPrint('${entry.key.toString()}: ${entry.value.toString()}');
      }
      return _hasCriticalPermissions(results);
    } catch (e) {
      debugPrint('❌ Error requesting permissions: $e');
      return false;
    }
  }

  static Future<ph.PermissionStatus> requestMicrophonePermission() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final status = await ph.Permission.microphone.request();
        debugPrint('Microphone permission: $status');
        return status;
      }
      return ph.PermissionStatus.granted;
    } catch (e) {
      debugPrint('Error requesting microphone: $e');
      return ph.PermissionStatus.denied;
    }
  }

  static Future<ph.PermissionStatus> requestMotionPermission() async {
    try {
      if (Platform.isAndroid) {
        // Request both activity recognition and body sensors for accelerometer
        final actStatus = await ph.Permission.activityRecognition.request();
        final bodySensorStatus = await ph.Permission.bodySensors.request();
        final sensorStatus = await ph.Permission.sensors.request();
        debugPrint('Activity recognition: $actStatus, Body sensors: $bodySensorStatus, Sensors: $sensorStatus');
        return actStatus.isGranted && bodySensorStatus.isGranted ? ph.PermissionStatus.granted : ph.PermissionStatus.denied;
      }
      if (Platform.isIOS) {
        final status = await ph.Permission.sensors.request();
        debugPrint('Motion sensor permission: $status');
        return status;
      }
      return ph.PermissionStatus.granted;
    } catch (e) {
      debugPrint('❌ Error requesting motion permission: $e');
      return ph.PermissionStatus.denied;
    }
  }

  static Future<ph.PermissionStatus> requestSensorPermission() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final status = await ph.Permission.sensors.request();
        debugPrint('Sensor permission: $status');
        return status;
      }
      return ph.PermissionStatus.granted;
    } catch (e) {
      debugPrint('❌ Error requesting sensors: $e');
      return ph.PermissionStatus.denied;
    }
  }

  static Future<bool> isMicrophoneGranted() async {
    try {
      final status = await ph.Permission.microphone.status;
      debugPrint('Microphone permission status: $status');
      return status.isGranted;
    } catch (e) {
      debugPrint('❌ Error checking microphone: $e');
      return false;
    }
  }

  static Future<bool> isMotionGranted() async {
    try {
      if (Platform.isAndroid) {
        final activity = await ph.Permission.activityRecognition.status;
        final bodySensors = await ph.Permission.bodySensors.status;
        final sensors = await ph.Permission.sensors.status;
        final granted = activity.isGranted && bodySensors.isGranted && sensors.isGranted;
        debugPrint('Motion permissions - Activity: $activity, BodySensors: $bodySensors, Sensors: $sensors = $granted');
        return granted;
      }
      if (Platform.isIOS) {
        final sensors = await ph.Permission.sensors.status;
        debugPrint('iOS Motion permission: $sensors');
        return sensors.isGranted;
      }
      return true;
    } catch (e) {
      debugPrint('❌ Error checking motion permission: $e');
      return false;
    }
  }

  static Future<bool> isNotificationGranted() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final status = await ph.Permission.notification.status;
        return status.isGranted;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> openPermissionSettings() async {
    try {
      await ph.openAppSettings();
      debugPrint('Opening app settings...');
    } catch (e) {
      debugPrint('Error opening settings: $e');
    }
  }

  static const MethodChannel _audioChannel =
      MethodChannel('autosilencer/audio');

  static Future<bool> hasDndAccess() async {
    if (!Platform.isAndroid) return true;
    try {
      final result = await _audioChannel.invokeMethod<bool>('hasDndAccess');
      debugPrint('DND access: ${result ?? false}');
      return result ?? false;
    } catch (e) {
      debugPrint('❌ Error checking DND access: $e');
      return false;
    }
  }

  static Future<void> openDndSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _audioChannel.invokeMethod('openDndSettings');
      debugPrint('✅ Opened DND settings');
    } catch (e) {
      debugPrint('❌ Error opening DND settings: $e');
    }
  }

  static Future<Map<String, bool>> checkAllPermissions() async {
    try {
      final results = {
        'microphone': await isMicrophoneGranted(),
        'motion': await isMotionGranted(),
        'notification': await isNotificationGranted(),
      };
      debugPrint('All permissions: $results');
      return results;
    } catch (e) {
      debugPrint('❌ Error checking permissions: $e');
      return {
        'microphone': false,
        'motion': false,
        'notification': false,
      };
    }
  }

  static bool _hasCriticalPermissions(
    Map<ph.Permission, ph.PermissionStatus> results,
  ) {
    final micGranted = results[ph.Permission.microphone]?.isGranted ?? false;
    debugPrint('Microphone granted: $micGranted');
    
    if (!Platform.isAndroid && !Platform.isIOS) {
      debugPrint('Non-mobile platform, returning microphone status only');
      return micGranted;
    }

    bool motionGranted = false;
    if (Platform.isAndroid) {
      final activityGranted = results[ph.Permission.activityRecognition]?.isGranted ?? false;
      final sensorsGranted = results[ph.Permission.sensors]?.isGranted ?? false;
      final bodySensorsGranted = results[ph.Permission.bodySensors]?.isGranted ?? false;
      motionGranted = activityGranted || sensorsGranted || bodySensorsGranted;
      debugPrint('Android motion - Activity: $activityGranted, Sensors: $sensorsGranted, BodySensors: $bodySensorsGranted = $motionGranted');
    } else if (Platform.isIOS) {
      motionGranted = results[ph.Permission.sensors]?.isGranted ?? false;
      debugPrint('iOS motion: $motionGranted');
    }

    final critical = micGranted && motionGranted;
    debugPrint('Critical permissions granted: $critical');
    return critical;
  }
}
