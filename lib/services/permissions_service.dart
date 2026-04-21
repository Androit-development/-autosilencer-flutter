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
    } else if (Platform.isIOS) {
      permissions.add(ph.Permission.sensors);
    }

    return permissions;
  }

  static Future<bool> requestAllPermissions() async {
    try {
      final results = await _requiredPermissions().request();
      debugPrint('Permissions requested: $results');
      return _hasCriticalPermissions(results);
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
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
        final status = await ph.Permission.activityRecognition.request();
        debugPrint('Activity recognition permission: $status');
        return status;
      }
      if (Platform.isIOS) {
        final status = await ph.Permission.sensors.request();
        debugPrint('Motion sensor permission: $status');
        return status;
      }
      return ph.PermissionStatus.granted;
    } catch (e) {
      debugPrint('Error requesting motion permission: $e');
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
      debugPrint('Error requesting sensors: $e');
      return ph.PermissionStatus.denied;
    }
  }

  static Future<bool> isMicrophoneGranted() async {
    try {
      final status = await ph.Permission.microphone.status;
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isMotionGranted() async {
    try {
      if (Platform.isAndroid) {
        final activity = await ph.Permission.activityRecognition.status;
        final sensors = await ph.Permission.sensors.status;
        return activity.isGranted || sensors.isGranted;
      }
      if (Platform.isIOS) {
        final sensors = await ph.Permission.sensors.status;
        return sensors.isGranted;
      }
      return true;
    } catch (_) {
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
      return await _audioChannel.invokeMethod<bool>('hasDndAccess') ?? false;
    } catch (e) {
      debugPrint('Error checking DND access: $e');
      return false;
    }
  }

  static Future<void> openDndSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _audioChannel.invokeMethod('openDndSettings');
    } catch (e) {
      debugPrint('Error opening DND settings: $e');
    }
  }

  static Future<Map<String, bool>> checkAllPermissions() async {
    try {
      return {
        'microphone': await isMicrophoneGranted(),
        'motion': await isMotionGranted(),
        'notification': await isNotificationGranted(),
      };
    } catch (_) {
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
    if (!Platform.isAndroid && !Platform.isIOS) {
      return micGranted;
    }

    final motionGranted = Platform.isAndroid
        ? (results[ph.Permission.activityRecognition]?.isGranted ?? false) ||
            (results[ph.Permission.sensors]?.isGranted ?? false)
        : (results[ph.Permission.sensors]?.isGranted ?? false);

    return micGranted && motionGranted;
  }
}
