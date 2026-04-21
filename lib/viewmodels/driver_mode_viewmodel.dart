// ═══════════════════════════════════════════════════════════════════
// lib/viewmodels/driver_mode_viewmodel.dart
// ViewModel for Driver Mode — manages driver status, whitelisted apps,
// and the driver mode toggle for taxi/delivery drivers.
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';

// ── Driver availability status ─────────────────────────────────────
enum DriverStatus { available, busy, offline }

// ── Whitelisted app model ──────────────────────────────────────────
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

// ── DriverModeViewModel ────────────────────────────────────────────
class DriverModeViewModel extends ChangeNotifier {

  bool _isDriverMode = false;
  DriverStatus _status = DriverStatus.available;

  // ── Getters ────────────────────────────────────────────────────
  bool         get isDriverMode => _isDriverMode;
  DriverStatus get status       => _status;
  int          get enabledCount => _apps.where((a) => a.isEnabled).length;

  // ── Apps grouped by category ───────────────────────────────────
  Map<String, List<WhitelistedApp>> get appsByCategory {
    final map = <String, List<WhitelistedApp>>{};
    for (final app in _apps) {
      map.putIfAbsent(app.category, () => []).add(app);
    }
    return map;
  }

  // ── Default whitelisted apps ───────────────────────────────────
  final List<WhitelistedApp> _apps = [
    // Essential — always allowed
    WhitelistedApp(
      id: 'phone', name: 'Phone', emoji: '📞',
      category: 'Essential', isEnabled: true,
    ),
    WhitelistedApp(
      id: 'maps', name: 'Google Maps', emoji: '🗺️',
      category: 'Essential', isEnabled: true,
    ),

    // Ride-hailing
    WhitelistedApp(
      id: 'yango', name: 'Yango', emoji: '🚕',
      category: 'Ride-hailing', isEnabled: true,
    ),
    WhitelistedApp(
      id: 'uber', name: 'Uber', emoji: '🚗',
      category: 'Ride-hailing', isEnabled: false,
    ),
    WhitelistedApp(
      id: 'indrive', name: 'inDrive', emoji: '🚙',
      category: 'Ride-hailing', isEnabled: false,
    ),
    WhitelistedApp(
      id: 'bolt', name: 'Bolt', emoji: '⚡',
      category: 'Ride-hailing', isEnabled: false,
    ),

    // Delivery
    WhitelistedApp(
      id: 'glovo', name: 'Glovo', emoji: '📦',
      category: 'Delivery', isEnabled: false,
    ),
    WhitelistedApp(
      id: 'jumia', name: 'Jumia Food', emoji: '🍔',
      category: 'Delivery', isEnabled: false,
    ),

    // Communication
    WhitelistedApp(
      id: 'whatsapp', name: 'WhatsApp', emoji: '💬',
      category: 'Communication', isEnabled: false,
    ),
    WhitelistedApp(
      id: 'telegram', name: 'Telegram', emoji: '✈️',
      category: 'Communication', isEnabled: false,
    ),
  ];

  // ── Actions ────────────────────────────────────────────────────
  void toggleDriverMode() {
    _isDriverMode = !_isDriverMode;
    if (!_isDriverMode) {
      _status = DriverStatus.available;
    }
    notifyListeners();
  }

  void setStatus(DriverStatus s) {
    _status = s;
    notifyListeners();
  }

  void toggleApp(String appId) {
    final app = _apps.firstWhere((a) => a.id == appId);
    if (app.category == 'Essential') return; // can't toggle essential apps
    app.isEnabled = !app.isEnabled;
    notifyListeners();
  }
}