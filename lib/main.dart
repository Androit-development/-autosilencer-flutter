import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'viewmodels/driving_viewmodel.dart';
import 'viewmodels/language_viewmodel.dart';
import 'services/background_service.dart';
import 'views/splash_screen.dart';
import 'views/home_screen.dart';
import 'views/history_screen.dart';
import 'views/settings_screen.dart';
import 'viewmodels/driver_mode_viewmodel.dart';


// ── Colors ────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();
  static const bgLowest         = Color(0xFF060E1E);
  static const bgCardHigh       = Color(0xFF222A3B);
  static const bgCardHighest    = Color(0xFF2D3546);
  static const primary          = Color(0xFFB0C6FF);
  static const primaryContainer = Color(0xFF558DFF);
  static const tertiary         = Color(0xFF00E475);
  static const error            = Color(0xFFFFB4AB);
  static const errorContainer   = Color(0xFF93000A);
  static const onSurface        = Color(0xFFDBE2F9);
  static const onSurfaceVariant = Color(0xFFC2C6D7);
  static const outline          = Color(0xFF8C90A0);
  static const outlineVariant   = Color(0xFF424655);

  static Color primaryGlow(double o)  => const Color(0xFFB0C6FF).withOpacity(o);
  static Color tertiaryGlow(double o) => const Color(0xFF00E475).withOpacity(o);
  static Color errorGlow(double o)    => const Color(0xFFFFB4AB).withOpacity(o);
}

// ── Text styles ───────────────────────────────────────────────────────
class AppText {
  AppText._();
  static TextStyle headline({Color color = AppColors.onSurface, double size = 28}) =>
      GoogleFonts.spaceGrotesk(fontSize: size, fontWeight: FontWeight.w700, color: color, letterSpacing: -0.5);
  static TextStyle label({Color color = AppColors.onSurfaceVariant, double size = 11}) =>
      GoogleFonts.spaceGrotesk(fontSize: size, fontWeight: FontWeight.w600, color: color, letterSpacing: 2.0);
  static TextStyle body({Color color = AppColors.onSurfaceVariant, double size = 14}) =>
      GoogleFonts.manrope(fontSize: size, fontWeight: FontWeight.w400, color: color, height: 1.5);
  static TextStyle bodyBold({Color color = AppColors.onSurface, double size = 14}) =>
      GoogleFonts.manrope(fontSize: size, fontWeight: FontWeight.w600, color: color);
  static TextStyle number({Color color = AppColors.primary, double size = 28}) =>
      GoogleFonts.spaceGrotesk(fontSize: size, fontWeight: FontWeight.w700, color: color);
  static TextStyle display({Color color = AppColors.onSurface, double size = 44}) =>
      GoogleFonts.spaceGrotesk(fontSize: size, fontWeight: FontWeight.w800, color: color, letterSpacing: -1.5);
}

// ── Glass card ────────────────────────────────────────────────────────
BoxDecoration glassCard({Color? leftBorderColor}) {
  const bc = AppColors.outlineVariant;
  return BoxDecoration(
    color: AppColors.bgCardHigh.withOpacity(0.4),
    borderRadius: BorderRadius.circular(16),
    border: leftBorderColor != null
        ? Border(
            left:   BorderSide(color: leftBorderColor.withOpacity(0.6), width: 4),
            right:  BorderSide(color: bc.withOpacity(0.15)),
            top:    BorderSide(color: bc.withOpacity(0.15)),
            bottom: BorderSide(color: bc.withOpacity(0.15)),
          )
        : Border.all(color: bc.withOpacity(0.15)),
  );
}

// ══════════════════════════════════════════════════════════════════════
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url:     dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Initialize background service for passive driving detection
  BackgroundServiceManager.initialize();

  final drivingVM = DrivingViewModel()..loadSampleLogs();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => drivingVM),
        ChangeNotifierProvider(create: (_) => LanguageViewModel()),
        ChangeNotifierProvider(create: (_) => DriverModeViewModel()),
      ],
      child: const AutoSilencerApp(),
    ),
  );

  // Auto-start ONLY the background service — it passively monitors
  // sensors and silences the phone when driving is detected.
  // The UI "Start Monitoring" button is separate (for visual feedback).
  _startBackgroundDetection(drivingVM);
}

/// Start the background service that passively detects driving
/// and silences the phone automatically. Also hooks up data
/// callbacks so the UI stays in sync with background detections.
Future<void> _startBackgroundDetection(DrivingViewModel vm) async {
  // Small delay to let permissions settle after splash screen
  await Future.delayed(const Duration(seconds: 2));
  await BackgroundServiceManager.startService();

  // Listen for background service data so the UI reflects driving state
  BackgroundServiceManager.addDataListener((data) {
    if (data is Map) {
      final isDriving = data['isDriving'] as bool? ?? false;
      final motion    = (data['motion'] as num?)?.toDouble() ?? 0.0;
      final noise     = (data['noise']  as num?)?.toDouble() ?? 0.0;
      vm.updateFromBackground(
        isDriving: isDriving,
        motion: motion,
        noise: noise,
      );
    }
  });

  debugPrint('🚀 Background driving detection started');
}

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
        // Smooth page transitions throughout the app
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/home':   (_) => const AppShell(),
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// AppShell — smooth tab navigation between Home, History, Settings
// ══════════════════════════════════════════════════════════════════════
class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => AppShellState();
}

// PUBLIC state class so HomeScreen can find it with findAncestorStateOfType
class AppShellState extends State<AppShell> {
  int _idx = 0;

  // Called by HomeScreen STOP button to switch to history tab
  void switchToHistory() {
    setState(() => _idx = 1);
    // Also load fresh data from Supabase
    context.read<DrivingViewModel>().loadLogs();
  }

  // All three screens live inside the IndexedStack for smooth switching
  final List<Widget> _screens = const [
    HomeScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageViewModel>();
    return Scaffold(
      backgroundColor: AppColors.bgLowest,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.03, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(_idx),
          child: _screens[_idx],
        ),
      ),
      bottomNavigationBar: _BottomNav(
        idx: _idx,
        onTap: (i) {
          setState(() => _idx = i);
          if (i == 1) context.read<DrivingViewModel>().loadLogs();
        },
        homeLabel:     lang.t('HOME',     'HOME'),
        historyLabel:  lang.t('HISTORY',  'HISTORIQUE'),
        settingsLabel: lang.t('SETTINGS', 'RÉGLAGES'),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int idx;
  final Function(int) onTap;
  final String homeLabel, historyLabel, settingsLabel;
  const _BottomNav({required this.idx, required this.onTap,
    required this.homeLabel, required this.historyLabel,
    required this.settingsLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.bgCardHighest.withOpacity(0.70),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Btn(icon: Icons.home_rounded,      label: homeLabel,     sel: idx==0, onTap: ()=>onTap(0)),
          _Btn(icon: Icons.history_rounded,    label: historyLabel,  sel: idx==1, onTap: ()=>onTap(1)),
          _Btn(icon: Icons.settings_outlined,  label: settingsLabel, sel: idx==2, onTap: ()=>onTap(2)),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon; final String label; final bool sel; final VoidCallback onTap;
  const _Btn({required this.icon, required this.label, required this.sel, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: sel ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: sel ? AppColors.primary : AppColors.onSurfaceVariant, size: 22),
        const SizedBox(height: 3),
        Text(label, style: AppText.label(color: sel ? AppColors.primary : AppColors.onSurfaceVariant, size: 9)),
      ]),
    ),
  );
}