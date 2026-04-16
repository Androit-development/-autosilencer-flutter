// ═══════════════════════════════════════════════════════════════════
// lib/services/auto_start_service.dart
//
// Handles AUTOMATIC start of monitoring.
// The Yango driver never needs to open the app — it starts by itself.
//
// HOW IT WORKS:
//   1. Phone boots → BootReceiver fires → background service starts
//   2. App opens for first time → we ask permission + start service
//   3. Service runs forever → detects driving → silences phone
//   4. Driver never touches the app again
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';
import 'background_service.dart' show backgroundCallback;

class AutoStartService {

  // ── Request all needed permissions at first launch ───────────────
  // Called once when user first opens the app
  static Future<bool> requestAllPermissions(BuildContext context) async {

    // 1. Microphone permission (needed for noise detection)
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      debugPrint('❌ Microphone permission denied');
      return false;
    }

    // 2. Notification permission (needed to show the persistent notification)
    final notifStatus = await Permission.notification.request();
    if (!notifStatus.isGranted) {
      debugPrint('⚠️ Notification permission denied — service may not work');
    }

    // 3. Battery optimization exemption
    // This is THE most important one — without it Android kills our service
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    // 4. Do Not Disturb access (for silent mode)
    // Opens system settings if not granted
    await _requestDndAccess(context);

    debugPrint('✅ All permissions granted');
    return true;
  }

  // ── Request Do Not Disturb access ────────────────────────────────
  static Future<void> _requestDndAccess(BuildContext context) async {
    const channel = MethodChannel('autosilencer/audio');
    try {
      final bool hasAccess = await channel.invokeMethod('hasDndAccess');
      if (!hasAccess) {
        // Show dialog explaining why we need DND access
        if (context.mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              backgroundColor: const Color(0xFF222A3B),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text('Permission Required',
                  style: TextStyle(color: Colors.white)),
              content: const Text(
                'AutoSilencer needs "Do Not Disturb" access to silence '
                'your phone when driving is detected.\n\n'
                'On the next screen, find AutoSilencer and enable it.',
                style: TextStyle(color: Color(0xFFC2C6D7)),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.pop(_);
                    await channel.invokeMethod('openDndSettings');
                  },
                  child: const Text('Open Settings',
                      style: TextStyle(color: Color(0xFFB0C6FF))),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('DND check error: $e');
    }
  }

  // ── Start monitoring automatically ───────────────────────────────
  // Call this on app start — it checks if service is running
  // and starts it if not
  static Future<void> ensureRunning() async {
    final isRunning = await FlutterForegroundTask.isRunningService;
    if (!isRunning) {
      debugPrint('🚀 Auto-starting monitoring service...');
      await _startService();
    } else {
      debugPrint('✅ Service already running');
    }
  }

  static Future<void> _startService() async {
    try {
      await FlutterForegroundTask.startService(
        serviceId:         256,
        notificationTitle: '✅ AutoSilencer — Active',
        notificationText:  'Monitoring automatically. You are protected.',
        notificationButtons: [],
        callback: backgroundCallback, // Task handler from background_service.dart
      );
      debugPrint('✅ Background service started');
    } catch (e) {
      debugPrint('❌ Failed to start service: $e');
    }
  }

  // ── Stop service ──────────────────────────────────────────────────
  static Future<void> stop() async {
    await FlutterForegroundTask.stopService();
    debugPrint('🛑 Service stopped');
  }
}