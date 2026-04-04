import 'package:flutter/foundation.dart';
import '../models/driving_log.dart';
import '../services/supabase_service.dart';
import '../services/background_service.dart';

class DrivingViewModel extends ChangeNotifier {
  bool   _isMonitoring = false;
  bool   _isDriving    = false;
  bool   _isLoading    = false;
  double _motionLevel  = 0.0;
  double _noiseLevel   = 0.0;
  String _error        = '';
  List<DrivingLog> _logs = [];

  bool   get isMonitoring => _isMonitoring;
  bool   get isDriving    => _isDriving;
  bool   get isLoading    => _isLoading;
  double get motionLevel  => _motionLevel;
  double get noiseLevel   => _noiseLevel;
  String get error        => _error;
  List<DrivingLog> get logs => List.unmodifiable(_logs);

  int get totalTrips    => _logs.length;
  int get totalSilences => _logs.where((l) => l.status == DrivingStatus.driving).length;
  int get totalMinutes  => _logs.fold(0, (s, l) => s + l.durationMinutes);
  String get totalTimeLabel {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return h > 0 ? '${h}h ${m.toString().padLeft(2,"0")}' : '${m}min';
  }

  // Start monitoring — also starts background service
  Future<void> startMonitoring() async {
    _isMonitoring = true;
    _isDriving    = false;
    _error        = '';
    notifyListeners();
    // Start background service so it runs even if app is closed
    await BackgroundServiceManager.startService();
  }

  // Stop monitoring — also stops background service
  Future<void> stopMonitoring() async {
    _isMonitoring = false;
    _isDriving    = false;
    _motionLevel  = 0.0;
    _noiseLevel   = 0.0;
    notifyListeners();
    await BackgroundServiceManager.stopService();
  }

  // Called by background service with new sensor data
  Future<void> updateSensorData({
    required double motion,
    required double noise,
  }) async {
    _motionLevel = motion;
    _noiseLevel  = noise;
    final was = _isDriving;
    _isDriving = motion > 1.5 && noise > 60.0;
    if (was != _isDriving) await _onStatusChanged();
    notifyListeners();
  }

  Future<void> _onStatusChanged() async {
    final log = DrivingLog(
      id:              DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp:       DateTime.now(),
      status:          _isDriving ? DrivingStatus.driving : DrivingStatus.notDriving,
      motionLevel:     _motionLevel,
      noiseLevel:      _noiseLevel,
      durationMinutes: 0,
    );
    _logs.insert(0, log);
    notifyListeners();
    await SupabaseService.saveLog(log);
  }

  Future<void> loadLogs() async {
    _isLoading = true;
    _error     = '';
    notifyListeners();
    try {
      _logs = await SupabaseService.fetchLogs();
    } catch (_) {
      _error = 'Could not load history.';
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
      DrivingLog(id:'1', timestamp:DateTime(2026,3,18,8,30),
          status:DrivingStatus.driving, motionLevel:2.4, noiseLevel:68, durationMinutes:24),
      DrivingLog(id:'2', timestamp:DateTime(2026,3,18,7,15),
          status:DrivingStatus.notDriving, motionLevel:0.3, noiseLevel:42, durationMinutes:12),
      DrivingLog(id:'3', timestamp:DateTime(2026,3,17,18,45),
          status:DrivingStatus.sessionEnded, motionLevel:0.1, noiseLevel:35, durationMinutes:45),
      DrivingLog(id:'4', timestamp:DateTime(2026,3,17,9,12),
          status:DrivingStatus.shortTrip, motionLevel:1.8, noiseLevel:62, durationMinutes:8),
    ];
    notifyListeners();
  }
}