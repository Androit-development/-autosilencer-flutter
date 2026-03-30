// ═══════════════════════════════════════════════════════════════════════════
// main.dart — AutoSilencer
// SE 3242: Android Application Development | ICT University Yaoundé
// Student: Erwan (KFJerwan) | Instructor: Engr. Daniel MOUNE
//
// MODULES:
//   Module 1  → views/splash_screen.dart         Splash / Onboarding
//   Module 2  → views/home_screen.dart           Main status (safe + alert)
//   Module 3  → views/history_screen.dart        Session history list
//   Module 4  → views/settings_screen.dart       Language & preferences
//   Module 5  → viewmodels/driving_viewmodel.dart Core MVVM state
//   Module 6  → viewmodels/language_viewmodel.dart EN/FR switching
//   Module 7  → models/driving_log.dart          Data class
//   Module 8  → logic/driving_detector.dart      Detection algorithm (Sprint 1)
//   Module 9  → services/sensor_manager.dart     Sensor abstraction (Sprint 1)
//   Module 10 → services/supabase_service.dart   Cloud database (Sprint 2)
//   Module 11 → app_theme.dart                   "Sentinel Glow" design system
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// ── Module imports ────────────────────────────────────────────────────────
import 'app_theme.dart';                              // Module 11
import 'viewmodels/driving_viewmodel.dart';           // Module 5
import 'viewmodels/language_viewmodel.dart';          // Module 6
import 'views/splash_screen.dart';                    // Module 1
import 'views/home_screen.dart';                      // Module 2
import 'views/history_screen.dart';                   // Module 3
import 'views/settings_screen.dart';                  // Module 4

// ── Entry point ───────────────────────────────────────────────────────────
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DrivingViewModel()..loadSampleLogs()),
        ChangeNotifierProvider(create: (_) => LanguageViewModel()),
      ],
      child: const AutoSilencerApp(),
    ),
  );
}

// ── Root app ──────────────────────────────────────────────────────────────
class AutoSilencerApp extends StatelessWidget {
  const AutoSilencerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageViewModel>();

    return MaterialApp(
      title: 'AutoSilencer',
      debugShowCheckedModeBanner: false,
      locale: lang.locale,
      supportedLocales: const [Locale('en'), Locale('fr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgLowest,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.tertiary,
          surface: AppColors.bgCardHigh,
          error: AppColors.error,
        ),
      ),
      // Named routes — Navigation pattern from lecturer's slides
      initialRoute: '/splash',
      routes: {
        '/splash':   (_) => const SplashScreen(),
        '/home':     (_) => const AppShell(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}

// ── App Shell — hosts bottom nav + screens ────────────────────────────────
class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),    // Module 2
    HistoryScreen(), // Module 3
  ];

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageViewModel>();

    return Scaffold(
      backgroundColor: AppColors.bgLowest,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _BottomNavPod(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        homeLabel:    lang.t('HOME', 'HOME'),
        historyLabel: lang.t('HISTORY', 'HISTORIQUE'),
        settingsLabel: lang.t('SETTINGS', 'RÉGLAGES'),
        onSettingsTap: () => Navigator.pushNamed(context, '/settings'),
      ),
    );
  }
}

// ── Floating glass bottom nav "pod" — from Stitch design ─────────────────
class _BottomNavPod extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String homeLabel, historyLabel, settingsLabel;
  final VoidCallback onSettingsTap;

  const _BottomNavPod({
    required this.currentIndex, required this.onTap,
    required this.homeLabel, required this.historyLabel,
    required this.settingsLabel, required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.bgCardHighest.withOpacity(0.70),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4),
              blurRadius: 24, offset: const Offset(0, 8)),
          BoxShadow(color: AppColors.primary.withOpacity(0.06),
              blurRadius: 12),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBtn(icon: Icons.home_rounded,        label: homeLabel,
              selected: currentIndex == 0, onTap: () => onTap(0)),
          _NavBtn(icon: Icons.history_rounded,     label: historyLabel,
              selected: currentIndex == 1, onTap: () => onTap(1)),
          _NavBtn(icon: Icons.settings_outlined,   label: settingsLabel,
              selected: false, onTap: onSettingsTap),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavBtn({required this.icon, required this.label,
      required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
              color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
              size: 22),
            const SizedBox(height: 3),
            Text(label,
              style: AppText.label(
                color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
                size: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}