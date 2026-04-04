import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'config/index.dart';
import 'theme/index.dart';
import 'widgets/common/index.dart';
import 'viewmodels/driving_viewmodel.dart';
import 'viewmodels/language_viewmodel.dart';
import 'services/background_service.dart';
import 'views/splash_screen.dart';
import 'views/home_screen.dart';
import 'views/history_screen.dart';
import 'views/settings_screen.dart';

// ══════════════════════════════════════════════════════════════════════
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  // Only initialize background service on native platforms (not web)
  if (!kIsWeb) {
    BackgroundServiceManager.initialize();
  }
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

// ══════════════════════════════════════════════════════════════════════
class AutoSilencerApp extends StatelessWidget {
  const AutoSilencerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageViewModel>();
    return MaterialApp(
      title: 'AutoSilencer',
      debugShowCheckedModeBanner: false,
      locale: lang.locale,
      supportedLocales: AppThemeConfig.supportedLocales,
      localizationsDelegates: AppThemeConfig.localizationDelegates,
      theme: AppThemeConfig.darkTheme,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.home: (_) => const AppShell(),
        AppRoutes.settings: (_) => const SettingsScreen(),
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final List<Widget> _screens = const [HomeScreen(), HistoryScreen()];

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageViewModel>();
    return WithForegroundTask(
      child: Scaffold(
        backgroundColor: AppColors.bgLowest,
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: BottomNav(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          homeLabel: lang.t('HOME', 'HOME'),
          historyLabel: lang.t('HISTORY', 'HISTORIQUE'),
          settingsLabel: lang.t('SETTINGS', 'RÉGLAGES'),
          onSettingsTap: () => Navigator.pushNamed(context, AppRoutes.settings),
        ),
      ),
    );
  }
}
