import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:noise_meter/noise_meter.dart';
import '../constants/app_constants.dart';

// TOP-LEVEL callback — MUST be outside any class
@pragma('vm:entry-point')
void backgroundCallback() {
  FlutterForegroundTask.setTaskHandler(AutoSilencerTaskHandler());
}

// TASK HANDLER — the actual logic that runs every second in background
@pragma('vm:entry-point')
class AutoSilencerTaskHandler extends TaskHandler {
  double _motion = 0.0;
  double _noise = 0.0;
  bool _isDriving = false;

  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<NoiseReading>? _noiseSub;
  NoiseMeter? _noiseMeter;

  static const _channel = MethodChannel(AppStrings.methodChannel);

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    debugPrint('🚀 AutoSilencer service started');
    _startSensors();
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    final bool was = _isDriving;
    _isDriving = _motion > SensorThresholds.motionThreshold &&
        _noise > SensorThresholds.noiseThreshold;

    if (was != _isDriving) {
      if (_isDriving) {
        await _setSilent(true);
        FlutterForegroundTask.updateService(
          notificationTitle: '🚗 Driving Detected',
          notificationText: 'Phone silenced. Drive safely!',
        );
      } else {
        await _setSilent(false);
        FlutterForegroundTask.updateService(
          notificationTitle: '✅ AutoSilencer Active',
          notificationText: 'Monitoring... Volume restored.',
        );
      }
    }

    FlutterForegroundTask.sendDataToMain({
      'motion': _motion,
      'noise': _noise,
      'isDriving': _isDriving,
    });
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isForce) async {
    await _accelSub?.cancel();
    await _noiseSub?.cancel();
    await _setSilent(false);
    debugPrint('🛑 AutoSilencer service stopped');
  }

  void _startSensors() {
    _accelSub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 250), // 4x per second for better sensitivity
    ).listen(
      (e) {
        final mag = sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
        _motion = (mag - 9.8).abs();
      },
      onError: (_) => _motion = 0.0,
    );

    try {
      _noiseMeter = NoiseMeter();
      _noiseSub = _noiseMeter!.noise.listen(
        (e) => _noise = e.meanDecibel,
        onError: (_) => _noise = 0.0,
      );
    } catch (_) {
      _noise = 0.0;
    }
  }

  Future<void> _setSilent(bool silent) async {
    try {
      await _channel.invokeMethod('setSilentMode', {'silent': silent});
    } catch (e) {
      debugPrint('Silent mode error: $e');
    }
  }
}

// MANAGER — call this from main.dart and DrivingViewModel
class BackgroundServiceManager {
  static void initialize() {
    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: AppStrings.channelId,
        channelName: AppStrings.channelName,
        channelDescription: 'AutoSilencer is monitoring your driving',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(
          SensorThresholds.backgroundTaskInterval.inMilliseconds,
        ),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  static Future<void> startService() async {
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    if (await FlutterForegroundTask.isRunningService) return;

    await FlutterForegroundTask.startService(
      serviceId: 256,
      notificationTitle: '✅ AutoSilencer Active',
      notificationText: 'Monitoring your driving silently...',
      notificationIcon: null,
      notificationButtons: [],
      callback: backgroundCallback,
    );
  }

  static Future<void> stopService() async {
    await FlutterForegroundTask.stopService();
  }

  static void addDataListener(Function(Object) listener) {
    FlutterForegroundTask.addTaskDataCallback(listener);
  }

  static void removeDataListener(Function(Object) listener) {
    FlutterForegroundTask.removeTaskDataCallback(listener);
  }
}