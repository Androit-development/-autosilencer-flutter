import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DriverStatus { available, busy, offline }

class WhitelistedApp {
  final String id;
  final String name;
  final String emoji;
  final String category;
  bool isEnabled;

  WhitelistedApp({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    this.isEnabled = false,
  });
}

class DriverModeViewModel extends ChangeNotifier {
  static const _driverModeKey = 'driver_mode_enabled';
  static const _driverStatusKey = 'driver_mode_status';
  static const _driverPromptDoneKey = 'driver_mode_prompt_done';
  static const _isYangoDriverKey = 'driver_mode_is_yango_driver';
  static const _appPrefix = 'driver_mode_app_';

  bool _isDriverMode = false;
  bool _hasAnsweredDriverPrompt = false;
  bool _isYangoDriver = false;
  DriverStatus _status = DriverStatus.available;
  bool _isLoaded = false;

  bool get isDriverMode => _isDriverMode;
  bool get hasAnsweredDriverPrompt => _hasAnsweredDriverPrompt;
  bool get isYangoDriver => _isYangoDriver;
  bool get isLoaded => _isLoaded;
  DriverStatus get status => _status;
  int get enabledCount => _apps.where((a) => a.isEnabled).length;

  Map<String, List<WhitelistedApp>> get appsByCategory {
    final map = <String, List<WhitelistedApp>>{};
    for (final app in _apps) {
      map.putIfAbsent(app.category, () => []).add(app);
    }
    return map;
  }

  final List<WhitelistedApp> _apps = [
    WhitelistedApp(
      id: 'phone',
      name: 'Phone',
      emoji: '📞',
      category: 'Essential',
      isEnabled: true,
    ),
    WhitelistedApp(
      id: 'maps',
      name: 'Google Maps',
      emoji: '🗺️',
      category: 'Essential',
      isEnabled: true,
    ),
    WhitelistedApp(
      id: 'yango',
      name: 'Yango',
      emoji: '🚕',
      category: 'Ride-hailing',
      isEnabled: true,
    ),
    WhitelistedApp(
      id: 'whatsapp',
      name: 'WhatsApp',
      emoji: '💬',
      category: 'Communication',
      isEnabled: false,
    ),
  ];

  Future<void> load() async {
    if (_isLoaded) return;

    final prefs = await SharedPreferences.getInstance();
    _isDriverMode = prefs.getBool(_driverModeKey) ?? false;
    _hasAnsweredDriverPrompt = prefs.getBool(_driverPromptDoneKey) ?? false;
    _isYangoDriver = prefs.getBool(_isYangoDriverKey) ?? false;

    final savedStatus = prefs.getString(_driverStatusKey);
    _status = DriverStatus.values.firstWhere(
      (value) => value.name == savedStatus,
      orElse: () => DriverStatus.available,
    );

    for (final app in _apps) {
      final savedValue = prefs.getBool('$_appPrefix${app.id}');
      if (savedValue != null && app.category != 'Essential') {
        app.isEnabled = savedValue;
      }
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> toggleDriverMode() async {
    _isDriverMode = !_isDriverMode;
    if (!_isDriverMode) {
      _status = DriverStatus.available;
    }
    notifyListeners();
    await _persist();
  }

  Future<void> setStatus(DriverStatus status) async {
    _status = status;
    notifyListeners();
    await _persist();
  }

  Future<void> toggleApp(String appId) async {
    final app = _apps.firstWhere((item) => item.id == appId);
    if (app.category == 'Essential') return;
    app.isEnabled = !app.isEnabled;
    notifyListeners();
    await _persist();
  }

  Future<void> setYangoDriver(bool value) async {
    _hasAnsweredDriverPrompt = true;
    _isYangoDriver = value;
    if (value) {
      _isDriverMode = true;
      final yangoApp = _apps.firstWhere((app) => app.id == 'yango');
      yangoApp.isEnabled = true;
    }
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_driverModeKey, _isDriverMode);
    await prefs.setString(_driverStatusKey, _status.name);
    await prefs.setBool(_driverPromptDoneKey, _hasAnsweredDriverPrompt);
    await prefs.setBool(_isYangoDriverKey, _isYangoDriver);

    for (final app in _apps) {
      if (app.category != 'Essential') {
        await prefs.setBool('$_appPrefix${app.id}', app.isEnabled);
      }
    }
  }
}
