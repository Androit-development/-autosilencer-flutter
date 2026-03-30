// ═══════════════════════════════════════════════════════════════════════════
// Module 5: viewmodels/driving_viewmodel.dart
// Core MVVM ViewModel — manages all driving detection state.
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/foundation.dart';
import '../models/driving_log.dart';

class DrivingViewModel extends ChangeNotifier {
  bool   _isMonitoring = false;
  bool   _isDriving    = false;
  double _motionLevel  = 0.0;
  double _noiseLevel   = 0.0;
  List<DrivingLog> _logs = [];

  bool   get isMonitoring => _isMonitoring;
  bool   get isDriving    => _isDriving;
  double get motionLevel  => _motionLevel;
  double get noiseLevel   => _noiseLevel;
  List<DrivingLog> get logs => List.unmodifiable(_logs);

  // Total stats for summary pills
  int get totalTrips    => _logs.length;
  int get totalMinutes  => _logs.fold(0, (s, l) => s + l.durationMinutes);
  int get totalSilences => _logs.where((l) => l.status == DrivingStatus.driving).length;

  String get totalTimeLabel {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return h > 0 ? '${h}h ${m.toString().padLeft(2,"0")}' : '${m}min';
  }

  void startMonitoring() {
    _isMonitoring = true;
    _isDriving    = false;
    notifyListeners();
  }

  void stopMonitoring() {
    _isMonitoring = false;
    _isDriving    = false;
    _motionLevel  = 0.0;
    _noiseLevel   = 0.0;
    notifyListeners();
  }

  void updateSensorData({required double motion, required double noise}) {
    _motionLevel = motion;
    _noiseLevel  = noise;
    final was = _isDriving;
    _isDriving = motion > 1.5 && noise > 60.0;
    if (was != _isDriving) _saveLog();
    notifyListeners();
  }

  void _saveLog() {
    _logs.insert(0, DrivingLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      status: _isDriving ? DrivingStatus.driving : DrivingStatus.notDriving,
      motionLevel: _motionLevel,
      noiseLevel: _noiseLevel,
      durationMinutes: 0,
    ));
    notifyListeners();
  }

  void loadSampleLogs() {
    _logs = [
      DrivingLog(id:'1', timestamp:DateTime(2026,3,18,8,30),
        status:DrivingStatus.driving,      motionLevel:2.4, noiseLevel:68, durationMinutes:24),
      DrivingLog(id:'2', timestamp:DateTime(2026,3,18,7,15),
        status:DrivingStatus.notDriving,   motionLevel:0.3, noiseLevel:42, durationMinutes:12),
      DrivingLog(id:'3', timestamp:DateTime(2026,3,17,18,45),
        status:DrivingStatus.sessionEnded, motionLevel:0.1, noiseLevel:35, durationMinutes:45),
      DrivingLog(id:'4', timestamp:DateTime(2026,3,17,9,12),
        status:DrivingStatus.shortTrip,    motionLevel:1.8, noiseLevel:62, durationMinutes:8),
    ];
    notifyListeners();
  }
}