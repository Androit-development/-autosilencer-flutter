import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../models/driving_log.dart';
import '../services/supabase_service.dart';

class DrivingViewModel extends ChangeNotifier {
  static const MethodChannel _audioChannel =
      MethodChannel('autosilencer/audio');
  static const String stationaryMode = 'stationary';
  static const String walkingMode = 'walking';
  static const String drivingMode = 'driving';

  bool _isMonitoring = false;
  bool _isDriving = false;
  bool _isPhoneSilenced = false;
  bool _isLoading = false;
  double _motion = 0.0;
  double _noise = 0.0;
  String _travelMode = stationaryMode;
  String _error = '';
  List<DrivingLog> _logs = [];

  double _motionThreshold = 1.5;
  double _noiseThreshold = 52.0;
  int _drivingConfidence = 0;
  int _notDrivingConfidence = 0;

  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<NoiseReading>? _noiseSub;
  NoiseMeter? _noiseMeter;
  Timer? _checkTimer;

  bool get isMonitoring => _isMonitoring;
  bool get isDriving => _isDriving;
  bool get isPhoneSilenced => _isPhoneSilenced;
  bool get isLoading => _isLoading;
  double get motionLevel => _motion;
  double get noiseLevel => _noise;
  String get travelMode => _travelMode;
  String get error => _error;
  List<DrivingLog> get logs => List.unmodifiable(_logs);

  int get totalTrips => _logs.length;
  int get totalSilences =>
      _logs.where((l) => l.status == DrivingStatus.driving).length;
  int get totalMinutes => _logs.fold(0, (s, l) => s + l.durationMinutes);

  String get totalTimeLabel {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return h > 0 ? '${h}h ${m.toString().padLeft(2, "0")}' : '${m}min';
  }

  void updateThresholds({required double motion, required double noise}) {
    _motionThreshold = motion;
    _noiseThreshold = noise;
    notifyListeners();
  }

  void updateFromBackground({
    required bool isDriving,
    required double motion,
    required double noise,
    bool? isPhoneSilenced,
  }) {
    final changed = _isDriving != isDriving ||
        _isPhoneSilenced != (isPhoneSilenced ?? isDriving) ||
        (_motion - motion).abs() > 0.1 ||
        (_noise - noise).abs() > 1.0;

    _isDriving = isDriving;
    _isPhoneSilenced = isPhoneSilenced ?? isDriving;
    _motion = motion;
    _noise = noise;
    _travelMode = _classifyTravelMode(motion: motion, noise: noise);

    if (!_isMonitoring && (isDriving || motion > 0 || noise > 0)) {
      _isMonitoring = true;
    }

    if (changed) {
      notifyListeners();
    }
  }

  Future<void> startMonitoring() async {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _isDriving = false;
    _isPhoneSilenced = false;
    _error = '';
    _motion = 0.0;
    _noise = 0.0;
    _travelMode = stationaryMode;
    notifyListeners();

    _accelSub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 250),
    ).listen(
      (AccelerometerEvent e) {
        final mag = sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
        _motion = (mag - 9.8).abs();
        _travelMode = _classifyTravelMode(motion: _motion, noise: _noise);
        notifyListeners();
      },
      onError: (err) {
        debugPrint('Accelerometer error: $err');
        _motion = 0.0;
      },
      cancelOnError: false,
    );

    try {
      _noiseMeter = NoiseMeter();
      _noiseSub = _noiseMeter!.noise.listen(
        (NoiseReading reading) {
          final db = reading.meanDecibel;
          _noise = (db.isFinite && db > 0) ? db : 0.0;
          _travelMode = _classifyTravelMode(motion: _motion, noise: _noise);
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
    }

    _checkTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _evaluateDrivingStatus();
    });
  }

  Future<void> stopMonitoring() async {
    _isMonitoring = false;
    _isDriving = false;
    _isPhoneSilenced = false;
    _motion = 0.0;
    _noise = 0.0;
    _travelMode = stationaryMode;
    _drivingConfidence = 0;
    _notDrivingConfidence = 0;
    await _setSilentMode(false);

    _checkTimer?.cancel();
    _checkTimer = null;

    await _accelSub?.cancel();
    _accelSub = null;

    await _noiseSub?.cancel();
    _noiseSub = null;
    _noiseMeter = null;

    notifyListeners();
  }

  void _evaluateDrivingStatus() {
    if (!_isMonitoring) return;

    final was = _isDriving;
    final motionHigh = _motion > _motionThreshold;
    final noiseHigh = _noise > _noiseThreshold;
    final motionLow = _motion < (_motionThreshold * 0.65);
    final noiseLow = _noise < (_noiseThreshold - 8.0);

    if (motionHigh && noiseHigh) {
      _drivingConfidence++;
      _notDrivingConfidence = 0;
    } else if (motionLow || noiseLow) {
      _notDrivingConfidence++;
      _drivingConfidence = 0;
    }

    final nowDriving = _isDriving
        ? _notDrivingConfidence < 3
        : _drivingConfidence >= 2;
    _travelMode = _classifyTravelMode(motion: _motion, noise: _noise);

    if (was != nowDriving) {
      _isDriving = nowDriving;
      debugPrint(
        'Status changed -> ${_isDriving ? "DRIVING" : "NOT DRIVING"} '
        '(motion: ${_motion.toStringAsFixed(2)}, '
        'noise: ${_noise.toStringAsFixed(0)} dB)',
      );
      _setSilentMode(_isDriving);
      _onStatusChanged();
    } else {
      notifyListeners();
    }
  }

  String _classifyTravelMode({
    required double motion,
    required double noise,
  }) {
    if (motion > _motionThreshold && noise > _noiseThreshold) {
      return drivingMode;
    }
    if (motion > 0.55 && motion < _motionThreshold && noise < _noiseThreshold) {
      return walkingMode;
    }
    return stationaryMode;
  }

  Future<void> _onStatusChanged() async {
    final log = DrivingLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      status: _isDriving ? DrivingStatus.driving : DrivingStatus.notDriving,
      motionLevel: _motion,
      noiseLevel: _noise,
      durationMinutes: 0,
    );

    _logs.insert(0, log);
    notifyListeners();

    await SupabaseService.saveLog(log);
  }

  Future<void> _setSilentMode(bool silent) async {
    try {
      await _audioChannel.invokeMethod('setSilentMode', {
        'silent': silent,
      });
      _isPhoneSilenced = silent;
      notifyListeners();
    } catch (e) {
      debugPrint('Silent mode channel error: $e');
    }
  }

  Future<void> loadLogs() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _logs = await SupabaseService.fetchLogs();
    } catch (e) {
      _error = 'Could not load history.';
      debugPrint('loadLogs error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteLog(String id) async {
    _logs.removeWhere((l) => l.id == id);
    notifyListeners();
    await SupabaseService.deleteLog(id);
  }

  void loadSampleLogs() {
    _logs = [
      DrivingLog(
        id: '1',
        timestamp: DateTime(2026, 3, 18, 8, 30),
        status: DrivingStatus.driving,
        motionLevel: 2.4,
        noiseLevel: 68,
        durationMinutes: 24,
      ),
      DrivingLog(
        id: '2',
        timestamp: DateTime(2026, 3, 18, 7, 15),
        status: DrivingStatus.notDriving,
        motionLevel: 0.3,
        noiseLevel: 42,
        durationMinutes: 12,
      ),
      DrivingLog(
        id: '3',
        timestamp: DateTime(2026, 3, 17, 18, 45),
        status: DrivingStatus.sessionEnded,
        motionLevel: 0.1,
        noiseLevel: 35,
        durationMinutes: 45,
      ),
      DrivingLog(
        id: '4',
        timestamp: DateTime(2026, 3, 17, 9, 12),
        status: DrivingStatus.shortTrip,
        motionLevel: 1.8,
        noiseLevel: 62,
        durationMinutes: 8,
      ),
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
