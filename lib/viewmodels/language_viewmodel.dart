import 'package:flutter/material.dart';

class LanguageViewModel extends ChangeNotifier {
  Locale _locale = const Locale('fr'); // default French (matches Stitch design)

  Locale get locale    => _locale;
  bool get isEnglish   => _locale.languageCode == 'en';
  String get langLabel => isEnglish ? 'EN' : 'FR';

  void setEnglish() { _locale = const Locale('en'); notifyListeners(); }
  void setFrench()  { _locale = const Locale('fr'); notifyListeners(); }
  void toggle()     { isEnglish ? setFrench() : setEnglish(); }

  // Helper: returns the right string based on current language
  String t(String en, String fr) => isEnglish ? en : fr;
}