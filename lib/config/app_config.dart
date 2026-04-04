import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../theme/index.dart';

/// Centralized app theme configuration
class AppThemeConfig {
  AppThemeConfig._();

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgLowest,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.tertiary,
          surface: AppColors.bgCardHigh,
          error: AppColors.error,
        ),
      );

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('fr'),
  ];

  static const List<LocalizationsDelegate> localizationDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}

/// App routes configuration
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String home = '/home';
  static const String settings = '/settings';
}
