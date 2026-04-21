// ═══════════════════════════════════════════════════════════════════
// lib/services/permissions_service.dart
// Centralized permission management for microphone and sensors
// ═══════════════════════════════════════════════════════════════════

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  PermissionsService._();

  // ── Request all required permissions ─────────────────────────────
  static Future<bool> requestAllPermissions() async {
    try {
      final results = await <Permission>[
        Permission.microphone,
        Permission.sensors,
      ].request();

      debugPrint('📱 Permissions requested: $results');

      // Check if all critical permissions were granted
      return results[Permission.microphone]?.isGranted ?? false;
    } catch (e) {
      debugPrint('❌ Error requesting permissions: $e');
      return false;
    }
  }

  // ── Request microphone permission specifically ────────────────────
  static Future<PermissionStatus> requestMicrophonePermission() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final status = await Permission.microphone.request();
        debugPrint('🎤 Microphone permission: $status');
        return status;
      }
      return PermissionStatus.granted;
    } catch (e) {
      debugPrint('❌ Error requesting microphone: $e');
      return PermissionStatus.denied;
    }
  }

  // ── Request sensor permission ────────────────────────────────────
  static Future<PermissionStatus> requestSensorPermission() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final status = await Permission.sensors.request();
        debugPrint('📊 Sensor permission: $status');
        return status;
      }
      return PermissionStatus.granted;
    } catch (e) {
      debugPrint('❌ Error requesting sensors: $e');
      return PermissionStatus.denied;
    }
  }

  // ── Check if microphone is permitted ─────────────────────────────
  static Future<bool> isMicrophoneGranted() async {
    try {
      final status = await Permission.microphone.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  // ── Check if sensors are permitted ──────────────────────────────
  static Future<bool> isSensorsGranted() async {
    try {
      final status = await Permission.sensors.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  // ── Open app settings if user denies permanently ─────────────────
  static Future<void> openAppSettings() async {
    try {
      await openAppSettings();
      debugPrint('🔧 Opening app settings...');
    } catch (e) {
      debugPrint('❌ Error opening settings: $e');
    }
  }

  // ── Check permission status ──────────────────────────────────────
  static Future<Map<String, bool>> checkAllPermissions() async {
    try {
      return {
        'microphone': await isMicrophoneGranted(),
        'sensors': await isSensorsGranted(),
      };
    } catch (e) {
      return {'microphone': false, 'sensors': false};
    }
  }
}
