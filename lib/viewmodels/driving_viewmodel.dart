// ═══════════════════════════════════════════════════════════════════
// lib/viewmodels/driving_viewmodel.dart
// Real accelerometer + microphone sensors working correctly
// ═══════════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:noise_meter/noise_meter.dart';
import '../models/driving_log.dart';
import '../services/supabase_service.dart';

class DrivingViewModel extends ChangeNotifier {

  // ── State ────────────────────────────────────────────────────────
  bool   _isMonitoring = false;
  bool   _isDriving    = false;
  bool   _isLoading    = false;
  double _motion       = 0.0;
  double _noise        = 0.0;
  String _error        = '';
  List<DrivingLog> _logs = [];

  // Detection thresholds (adjustable from Settings)
  double _motionThreshold = 1.5;
  double _noiseThreshold  = 60.0;

  // Sensor subscriptions
  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<NoiseReading>?       _noiseSub;
  NoiseMeter? _noiseMeter;
  Timer?      _checkTimer;

  // ── Getters ──────────────────────────────────────────────────────
  bool   get isMonitoring => _isMonitoring;
  bool   get isDriving    => _isDriving;
  bool   get isLoading    => _isLoading;
  double get motionLevel  => _motion;
  double get noiseLevel   => _noise;
  String get error        => _error;
  List<DrivingLog> get logs => List.unmodifiable(_logs);

  int get totalTrips    => _logs.length;
  int get totalSilences =>
      _logs.where((l) => l.status == DrivingStatus.driving).length;
  int get totalMinutes  =>
      _logs.fold(0, (s, l) => s + l.durationMinutes);
  String get totalTimeLabel {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return h > 0 ? '${h}h ${m.toString().padLeft(2, "0")}' : '${m}min';
  }

  // Called from Settings screen sliders
  void updateThresholds({required double motion, required double noise}) {
    _motionThreshold = motion;
    _noiseThreshold  = noise;
    notifyListeners();
  }

  // ── Called from background service data callback ──────────────────
  // Updates UI state to reflect what the background service detects,
  // even when the user hasn't pressed "Start Monitoring".
  void updateFromBackground({
    required bool isDriving,
    required double motion,
    required double noise,
  }) {
    final changed = _isDriving != isDriving ||
        (_motion - motion).abs() > 0.1 ||
        (_noise - noise).abs() > 1.0;

    _isDriving = isDriving;
    _motion    = motion;
    _noise     = noise;

    // Mark as monitoring so the UI shows live sensor data
    if (!_isMonitoring && isDriving) {
      _isMonitoring = true;
    }

    if (changed) {
      notifyListeners();
    }
  }

  // ── START monitoring with REAL sensors ───────────────────────────
  Future<void> startMonitoring() async {
    if (_isMonitoring) return; // prevent double start

    _isMonitoring = true;
    _isDriving    = false;
    _error        = '';
    _motion       = 0.0;
    _noise        = 0.0;
    notifyListeners();

    // 1. Accelerometer — reads every 250ms (4x per second) for better sensitivity
    _accelSub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 250),
    ).listen(
      (AccelerometerEvent e) {
        // magnitude of total acceleration vector
        final mag = sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
        // subtract gravity (9.8 m/s²) to get net movement
        _motion = (mag - 9.8).abs();
        notifyListeners();
      },
      onError: (err) {
        debugPrint('Accelerometer error: $err');
        _motion = 0.0;
      },
      cancelOnError: false,
    );

    // 2. Microphone — reads noise level continuously
    try {
      _noiseMeter = NoiseMeter();
      _noiseSub   = _noiseMeter!.noise.listen(
        (NoiseReading reading) {
          // meanDecibel can sometimes return -inf or NaN, guard against that
          final db = reading.meanDecibel;
          _noise = (db.isFinite && db > 0) ? db : 0.0;
          notifyListeners();
        },
        onError: (err) {
          debugPrint('Microphone error: $err');
          _noise = 0.0;
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('Could not start microphone: $e');
      // App still works — just motion detection only
    }

    // 3. Check driving status every 1 second
    _checkTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _evaluateDrivingStatus();
    });
  }

  // ── STOP monitoring ───────────────────────────────────────────────
  Future<void> stopMonitoring() async {
    _isMonitoring = false;
    _isDriving    = false;
    _motion       = 0.0;
    _noise        = 0.0;

    _checkTimer?.cancel();
    _checkTimer = null;

    await _accelSub?.cancel();
    _accelSub = null;

    await _noiseSub?.cancel();
    _noiseSub   = null;
    _noiseMeter = null;

    notifyListeners();
  }

  // ── Core detection — runs every second ───────────────────────────
  void _evaluateDrivingStatus() {
    if (!_isMonitoring) return;

    final bool was       = _isDriving;
    final bool nowDriving =
        _motion > _motionThreshold && _noise > _noiseThreshold;

    if (was != nowDriving) {
      _isDriving = nowDriving;
      debugPrint(
          '🔄 Status changed → ${_isDriving ? "DRIVING" : "NOT DRIVING"} '
          '(motion: ${_motion.toStringAsFixed(2)}, noise: ${_noise.toStringAsFixed(0)} dB)');
      _onStatusChanged(); // save to Supabase
    }
  }

  // ── Save status change to Supabase ────────────────────────────────
  Future<void> _onStatusChanged() async {
    final log = DrivingLog(
      id:              DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp:       DateTime.now(),
      status:          _isDriving
                       ? DrivingStatus.driving
                       : DrivingStatus.notDriving,
      motionLevel:     _motion,
      noiseLevel:      _noise,
      durationMinutes: 0,
    );

    _logs.insert(0, log);
    notifyListeners();

    await SupabaseService.saveLog(log);
    debugPrint('📡 Saved to Supabase: ${log.status}');
  }

  // ── Load history from Supabase ────────────────────────────────────
  Future<void> loadLogs() async {
    _isLoading = true;
    _error     = '';
    notifyListeners();

    try {
      _logs = await SupabaseService.fetchLogs();
      debugPrint('📥 Loaded ${_logs.length} logs from Supabase');
    } catch (e) {
      _error = 'Could not load history.';
      debugPrint('❌ loadLogs error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteLog(String id) async {
    _logs.removeWhere((l) => l.id == id);
    notifyListeners();
    await SupabaseService.deleteLog(id);
  }

  // Sample data for UI testing without Supabase
  void loadSampleLogs() {
    _logs = [
      DrivingLog(id: '1', timestamp: DateTime(2026, 3, 18, 8, 30),
          status: DrivingStatus.driving,
          motionLevel: 2.4, noiseLevel: 68, durationMinutes: 24),
      DrivingLog(id: '2', timestamp: DateTime(2026, 3, 18, 7, 15),
          status: DrivingStatus.notDriving,
          motionLevel: 0.3, noiseLevel: 42, durationMinutes: 12),
      DrivingLog(id: '3', timestamp: DateTime(2026, 3, 17, 18, 45),
          status: DrivingStatus.sessionEnded,
          motionLevel: 0.1, noiseLevel: 35, durationMinutes: 45),
      DrivingLog(id: '4', timestamp: DateTime(2026, 3, 17, 9, 12),
          status: DrivingStatus.shortTrip,
          motionLevel: 1.8, noiseLevel: 62, durationMinutes: 8),
    ];
    notifyListeners();
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _noiseSub?.cancel();
    _checkTimer?.cancel();
    super.dispose();
  }
}