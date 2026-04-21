import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'background_service.dart' show backgroundCallback;
import 'permissions_service.dart';

class AutoStartService {
  static Future<bool> requestAllPermissions(BuildContext context) async {
    final granted = await PermissionsService.requestAllPermissions();
    if (!granted) {
      debugPrint('Core permissions denied');
      return false;
    }

    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    final hasDndAccess = await _requestDndAccess(context);
    debugPrint('Startup permissions completed');
    return hasDndAccess;
  }

  static Future<bool> _requestDndAccess(BuildContext context) async {
    try {
      final hasAccess = await PermissionsService.hasDndAccess();
      if (hasAccess || !context.mounted) return hasAccess;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: const Color(0xFF222A3B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Permission Required',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'AutoSilencer needs Do Not Disturb access to silence your phone '
            'when driving is detected.\n\nOn the next screen, find '
            'AutoSilencer and enable it.',
            style: TextStyle(color: Color(0xFFC2C6D7)),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await PermissionsService.openDndSettings();
              },
              child: const Text(
                'Open Settings',
                style: TextStyle(color: Color(0xFFB0C6FF)),
              ),
            ),
          ],
        ),
      );
      return await PermissionsService.hasDndAccess();
    } catch (e) {
      debugPrint('DND check error: $e');
      return false;
    }
  }

  static Future<void> ensureRunning() async {
    final isRunning = await FlutterForegroundTask.isRunningService;
    if (!isRunning) {
      await _startService();
    }
  }

  static Future<void> _startService() async {
    try {
      await FlutterForegroundTask.startService(
        serviceId: 256,
        notificationTitle: 'AutoSilencer Active',
        notificationText: 'Monitoring automatically. You are protected.',
        notificationButtons: [],
        callback: backgroundCallback,
      );
    } catch (e) {
      debugPrint('Failed to start service: $e');
    }
  }

  static Future<void> stop() async {
    await FlutterForegroundTask.stopService();
  }
}
