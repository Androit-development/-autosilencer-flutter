// ═══════════════════════════════════════════════════════════════════
// lib/viewmodels/language_viewmodel.dart
// Controls the app language (English or French).
// When language changes, the WHOLE app rebuilds in the new language.
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class LanguageViewModel extends ChangeNotifier {

  // Start in French (default for Cameroon)
  Locale _locale = const Locale('fr');

  // ── Read the current language ────────────────────────────────────
  Locale get locale     => _locale;
  bool   get isEnglish  => _locale.languageCode == 'en';
  String get langLabel  => isEnglish ? 'EN' : 'FR';

  // ── Helper: returns EN text or FR text based on current language ─
  // Usage: lang.t('Hello', 'Bonjour')
  String t(String en, String fr) => isEnglish ? en : fr;

  // ── Switch to English ────────────────────────────────────────────
  void setEnglish() {
    _locale = const Locale('en');
    notifyListeners(); // tells all screens to rebuild
  }

  // ── Switch to French ─────────────────────────────────────────────
  void setFrench() {
    _locale = const Locale('fr');
    notifyListeners();
  }

  // ── Toggle between the two ───────────────────────────────────────
  void toggle() {
    isEnglish ? setFrench() : setEnglish();
  }
}