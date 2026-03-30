// ═══════════════════════════════════════════════════════════════════════════
// Module 1: views/splash_screen.dart
// "The Sentinel Glow" — particle field, shield logo, animated entrance
// ═══════════════════════════════════════════════════════════════════════════
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../viewmodels/language_viewmodel.dart';

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

  late final Animation<double> _fadeAnim;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _floatAnim;

  // Generate 35 random particles once
  final List<_Particle> _particles = List.generate(35, (_) {
    final rng = math.Random();
    return _Particle(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      r: rng.nextDouble() * 1.5 + 1.0,
      opacity: rng.nextDouble() * 0.5 + 0.15,
    );
  });

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.10)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8.0, end: 8.0)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageViewModel>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.bgLowest,
      body: Stack(
        children: [
          // ── Particle field background ─────────────────────────────────────
          CustomPaint(
            painter: _ParticlePainter(_particles),
            size: size,
          ),

          // ── Ambient glow blobs ────────────────────────────────────────────
          Positioned(top: size.height * 0.25, left: -40,
            child: _GlowBlob(color: AppColors.primary, radius: 160, opacity: 0.12)),
          Positioned(bottom: size.height * 0.2, right: -40,
            child: _GlowBlob(color: AppColors.tertiary, radius: 140, opacity: 0.08)),

          // ── Main content ──────────────────────────────────────────────────
          FadeTransition(
            opacity: _fadeAnim,
            child: SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // Shield logo with float + pulse
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

                  // App name
                  Text(
                    'AutoSilencer',
                    style: AppText.display(
                      color: AppColors.onSurface,
                      size: 44,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tagline
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      lang.t(
                        'Drive Focused. Stay Safe.',
                        'Conduisez concentré. Restez en sécurité.',
                      ),
                      textAlign: TextAlign.center,
                      style: AppText.body(
                        color: AppColors.onSurfaceVariant,
                        size: 16,
                      ),
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

                  // CTA button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _GradientButton(
                      label: lang.t('Get Started →', 'Commencer →'),
                      onTap: () => Navigator.pushReplacementNamed(context, '/home'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    lang.t('No account required • Free',
                           'Pas de compte requis • Gratuit'),
                    style: AppText.label(
                      color: AppColors.onSurfaceVariant.withOpacity(0.5),
                      size: 11,
                    ),
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

// ── Shield logo widget ────────────────────────────────────────────────────────
class _ShieldLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140, height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow platform
          Container(
            width: 140, height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Outer shield
          Icon(Icons.shield_rounded, size: 110,
              color: const Color(0xFF0D2A5E)),
          // Inner shield glow
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryContainer],
            ).createShader(bounds),
            child: Icon(Icons.shield_rounded, size: 80,
                color: Colors.white),
          ),
          // Car icon
          const Icon(Icons.directions_car_rounded,
              size: 36, color: Colors.white),
        ],
      ),
    );
  }
}

// ── Feature pill ──────────────────────────────────────────────────────────────
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: AppText.label(color: Colors.white, size: 11)),
        ],
      ),
    );
  }
}

// ── Gradient CTA button ───────────────────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GradientButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryContainer],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
        ),
        child: Center(
          child: Text(label,
            style: AppText.bodyBold(color: Colors.white, size: 18)),
        ),
      ),
    );
  }
}

// ── Glow blob ────────────────────────────────────────────────────────────────
class _GlowBlob extends StatelessWidget {
  final Color color;
  final double radius;
  final double opacity;
  const _GlowBlob({required this.color, required this.radius, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2, height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withOpacity(opacity), blurRadius: radius * 1.5,
              spreadRadius: radius * 0.3),
        ],
      ),
    );
  }
}

// ── Particle painter ──────────────────────────────────────────────────────────
class _Particle {
  final double x, y, r, opacity;
  const _Particle({required this.x, required this.y, required this.r, required this.opacity});
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  const _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.r,
        Paint()..color = Colors.white.withOpacity(p.opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => false;
}