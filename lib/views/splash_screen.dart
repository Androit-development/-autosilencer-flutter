// ═══════════════════════════════════════════════════════════════════
// lib/views/splash_screen.dart
// Updated: requests all permissions on first launch
// then auto-starts the background monitoring service
// The Yango driver NEVER needs to tap anything after this
// ═══════════════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/index.dart';
import '../viewmodels/language_viewmodel.dart';
import '../services/auto_start_service.dart';
import '../services/supabase_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late final AnimationController _fadeCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _floatCtrl;
  late final Animation<double>   _fadeAnim;
  late final Animation<double>   _pulseAnim;
  late final Animation<double>   _floatAnim;

  bool _permissionsGranted = false;
  bool _checking = false;

  final List<_Particle> _particles = List.generate(35, (_) {
    final rng = math.Random();
    return _Particle(
      x: rng.nextDouble(), y: rng.nextDouble(),
      r: rng.nextDouble() * 1.5 + 1.0,
      opacity: rng.nextDouble() * 0.5 + 0.15,
    );
  });

  @override
  void initState() {
    super.initState();
    _fadeCtrl  = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1400))..forward();
    _fadeAnim  = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _pulseCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.10)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _floatCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 3000))..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8.0, end: 8.0)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    // Auto-check permissions after logo animation loads
    Future.delayed(const Duration(milliseconds: 1500), _checkAndStart);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  // ── Check permissions + auto-start service ────────────────────────
  Future<void> _checkAndStart() async {
    setState(() => _checking = true);

    // Request all permissions
    final granted = await AutoStartService.requestAllPermissions(context);

    if (granted) {
      // Auto-start background monitoring
      await AutoStartService.ensureRunning();
      setState(() {
        _permissionsGranted = true;
        _checking = false;
      });
      
      // After permissions are granted, check authentication
      Future.delayed(const Duration(milliseconds: 500), _navigateAfterAuth);
    } else {
      setState(() => _checking = false);
    }
  }

  // ── Navigate based on authentication status ────────────────────────
  Future<void> _navigateAfterAuth() async {
    if (!mounted) return;
    
    // Check if user is already authenticated
    final isAuthenticated = SupabaseService.isLoggedIn;
    
    if (isAuthenticated) {
      // User is logged in → go to home
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // User is NOT logged in → go to login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageViewModel>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.bgLowest,
      body: Stack(
        children: [
          // Particle field
          CustomPaint(
            painter: _ParticlePainter(_particles),
            size: size,
          ),

          // Glow blobs
          Positioned(top: size.height * 0.25, left: -40,
            child: _GlowBlob(color: AppColors.primary, r: 160, o: 0.12)),
          Positioned(bottom: size.height * 0.2, right: -40,
            child: _GlowBlob(color: AppColors.tertiary, r: 140, o: 0.08)),

          FadeTransition(
            opacity: _fadeAnim,
            child: SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // Floating shield logo
                  AnimatedBuilder(
                    animation: Listenable.merge([_pulseCtrl, _floatCtrl]),
                    builder: (_, __) => Transform.translate(
                      offset: Offset(0, _floatAnim.value),
                      child: Transform.scale(
                        scale: _pulseAnim.value,
                        child: _ShieldLogo(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  Text('AutoSilencer',
                    style: AppText.headline(size: 44)),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      lang.t('Drive Focused. Stay Safe.',
                             'Conduisez concentré. Restez en sécurité.'),
                      textAlign: TextAlign.center,
                      style: AppText.body(size: 16),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Feature pills
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _FeaturePill(icon: Icons.volume_off_rounded,
                          label: lang.t('Auto-Silence', 'Auto-Silence')),
                      const SizedBox(width: 8),
                      _FeaturePill(icon: Icons.sensors_rounded,
                          label: lang.t('AI Sensors', 'Capteurs IA')),
                      const SizedBox(width: 8),
                      _FeaturePill(icon: Icons.cloud_outlined,
                          label: lang.t('Cloud Logs', 'Cloud Logs')),
                    ],
                  ),

                  const Spacer(flex: 4),

                  // Status indicator while checking permissions
                  if (_checking)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            lang.t(
                              'Setting up automatic detection...',
                              'Configuration de la détection automatique...',
                            ),
                            textAlign: TextAlign.center,
                            style: AppText.body(size: 13),
                          ),
                        ],
                      ),
                    )

                  // CTA button — shows when permissions are ready
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // Auto-protect notice
                          Container(
                            padding: const EdgeInsets.all(14),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppColors.tertiary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppColors.tertiary.withOpacity(0.25)),
                            ),
                            child: Row(children: [
                              Icon(
                                _permissionsGranted
                                    ? Icons.shield_rounded
                                    : Icons.shield_outlined,
                                color: _permissionsGranted
                                    ? AppColors.tertiary
                                    : AppColors.onSurfaceVariant,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _permissionsGranted
                                      ? lang.t(
                                          '✅ AutoSilencer will protect you automatically — even when the app is closed.',
                                          '✅ AutoSilencer vous protège automatiquement — même si l\'app est fermée.',
                                        )
                                      : lang.t(
                                          'Permissions needed to detect driving automatically.',
                                          'Permissions requises pour détecter la conduite automatiquement.',
                                        ),
                                  style: AppText.body(
                                    color: _permissionsGranted
                                        ? AppColors.tertiary
                                        : AppColors.onSurfaceVariant,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ]),
                          ),

                          // Main button
                          _GradientButton(
                            label: _permissionsGranted
                                ? lang.t('Get Started →', 'Commencer →')
                                : lang.t('Grant Permissions →',
                                         'Accorder les permissions →'),
                            color1: _permissionsGranted
                                ? AppColors.primary
                                : AppColors.error,
                            color2: _permissionsGranted
                                ? AppColors.primaryContainer
                                : AppColors.errorContainer,
                            onTap: () async {
                              if (!_permissionsGranted) {
                                await _checkAndStart();
                              } else {
                                // Navigate based on auth status
                                await _navigateAfterAuth();
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  Text(
                    lang.t(
                      'Secure authentication • Runs automatically',
                      'Authentification sécurisée • Fonctionne automatiquement',
                    ),
                    style: AppText.label(
                        color: AppColors.onSurfaceVariant.withOpacity(0.5),
                        size: 11),
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _ShieldLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140, height: 140,
      child: Stack(alignment: Alignment.center, children: [
        Container(
          width: 140, height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              AppColors.primary.withOpacity(0.2),
              Colors.transparent,
            ]),
          ),
        ),
        Icon(Icons.shield_rounded, size: 110,
            color: const Color(0xFF0D2A5E)),
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryContainer],
          ).createShader(b),
          child: Icon(Icons.shield_rounded, size: 80, color: Colors.white),
        ),
        const Icon(Icons.directions_car_rounded,
            size: 36, color: Colors.white),
      ]),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCardHigh.withOpacity(0.5),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(label, style: AppText.label(color: Colors.white, size: 11)),
      ]),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final Color color1, color2;
  final VoidCallback onTap;
  const _GradientButton({required this.label, required this.color1,
      required this.color2, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [color1, color2],
          ),
          boxShadow: [
            BoxShadow(color: color1.withOpacity(0.35),
                blurRadius: 24, offset: const Offset(0, 8)),
          ],
        ),
        child: Center(
          child: Text(label,
              style: AppText.bodyBold(color: Colors.white, size: 18)),
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double r, o;
  const _GlowBlob({required this.color, required this.r, required this.o});
  @override
  Widget build(BuildContext context) => Container(
    width: r*2, height: r*2,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [BoxShadow(color: color.withOpacity(o),
          blurRadius: r*1.5, spreadRadius: r*0.3)],
    ),
  );
}

class _Particle {
  final double x, y, r, opacity;
  const _Particle({required this.x, required this.y,
      required this.r, required this.opacity});
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  const _ParticlePainter(this.particles);
  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height), p.r,
        Paint()..color = Colors.white.withOpacity(p.opacity),
      );
    }
  }
  @override
  bool shouldRepaint(_ParticlePainter old) => false;
}