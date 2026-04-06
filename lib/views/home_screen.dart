// ═══════════════════════════════════════════════════════════════════════════
// Module 2: views/home_screen.dart
// Two states: SAFE (green rings) and DRIVING DETECTED (red rings + alert)
// Animated concentric rings — "Status Rings" signature component
// ═══════════════════════════════════════════════════════════════════════════
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../viewmodels/driving_viewmodel.dart';
import '../viewmodels/language_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {

  // Outer ring slow rotation
  late final AnimationController _rotCtrl;
  // Inner ring breathe
  late final AnimationController _breatheCtrl;
  late final Animation<double> _breatheAnim;
  // Ping pulse (driving alert)
  late final AnimationController _pingCtrl;
  late final Animation<double> _pingAnim;
  // Color transition
  late final AnimationController _colorCtrl;

  @override
  void initState() {
    super.initState();

    _rotCtrl = AnimationController(vsync: this,
        duration: const Duration(seconds: 12))..repeat();

    _breatheCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _breatheAnim = Tween<double>(begin: 1.0, end: 1.06)
        .animate(CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOut));

    _pingCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1200))..repeat();
    _pingAnim = Tween<double>(begin: 1.0, end: 1.6)
        .animate(CurvedAnimation(parent: _pingCtrl, curve: Curves.easeOut));

    _colorCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 600));
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    _breatheCtrl.dispose();
    _pingCtrl.dispose();
    _colorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm   = context.watch<DrivingViewModel>();
    final lang = context.watch<LanguageViewModel>();

    // State-dependent colors
    final stateColor = vm.isDriving ? AppColors.error : AppColors.tertiary;
    final stateGlow  = vm.isDriving
        ? AppColors.errorGlow(0.20)
        : AppColors.tertiaryGlow(0.15);

    return Scaffold(
      backgroundColor: AppColors.bgLowest,
      body: Stack(
        children: [
          // ── Ambient glow blobs ──────────────────────────────────────────
          Positioned(top: 100, left: -60,
            child: _blob(AppColors.primary, 200, 0.08)),
          Positioned(bottom: 200, right: -60,
            child: _blob(stateColor, 200, 0.10)),

          SafeArea(
            child: Column(
              children: [
                // ── Top App Bar ───────────────────────────────────────────
                _TopBar(lang: lang),

                // ── Status header ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.t('CURRENT STATUS', 'STATUT ACTUEL'),
                        style: AppText.label(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lang.t('Drive safely,\nstay alert.',
                               'Conduisez en toute\nsécurité, restez vigilant.'),
                        style: AppText.headline(size: 24),
                      ),
                    ],
                  ),
                ),

                // ── Animated status ring ──────────────────────────────────
                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_rotCtrl, _breatheCtrl, _pingCtrl]),
                      builder: (_, __) => _StatusRing(
                        isDriving:    vm.isDriving,
                        isMonitoring: vm.isMonitoring,
                        stateColor:   stateColor,
                        stateGlow:    stateGlow,
                        rotValue:     _rotCtrl.value,
                        breatheScale: _breatheAnim.value,
                        pingScale:    _pingAnim.value,
                        lang:         lang,
                      ),
                    ),
                  ),
                ),

                // ── Stats row ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(child: _StatCard(
                        icon: Icons.bolt_rounded,
                        iconColor: AppColors.primary,
                        label: lang.t('MOTION', 'MOUVEMENT'),
                        value: '${vm.motionLevel.toStringAsFixed(1)} m/s²',
                        barHeights: const [4, 6, 5, 7, 4],
                        barColor: AppColors.primary,
                        chipLabel: lang.t('Normal', 'Normal'),
                        chipColor: AppColors.tertiary,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(
                        icon: Icons.graphic_eq_rounded,
                        iconColor: AppColors.tertiary,
                        label: lang.t('NOISE LEVEL', 'NIVEAU SONORE'),
                        value: '${vm.noiseLevel.toStringAsFixed(0)} dB',
                        barHeights: const [3, 8, 5, 10, 6, 9, 4, 7],
                        barColor: vm.isDriving ? AppColors.error : AppColors.tertiary,
                        chipLabel: lang.t('Calm', 'Calme'),
                        chipColor: vm.isDriving ? AppColors.error : AppColors.tertiary,
                      )),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Alert banner (only when driving) ─────────────────────
                if (vm.isDriving)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: _AlertBanner(lang: lang),
                  ),

                // ── Main action button ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _ActionButton(vm: vm, lang: lang),
                ),

                const SizedBox(height: 8),
                Text(
                  lang.t('Tap to activate detection',
                         'Appuyez pour activer la détection'),
                  style: AppText.body(size: 12),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(Color c, double r, double o) => Container(
    width: r*2, height: r*2,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [BoxShadow(color: c.withOpacity(o), blurRadius: r*1.5, spreadRadius: r*0.2)],
    ),
  );
}

// ── Top App Bar ───────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final LanguageViewModel lang;
  const _TopBar({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_rounded, color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          Text('AutoSilencer',
            style: AppText.headline(size: 18, color: AppColors.onSurface)),
          const Spacer(),
          // Language toggle
          GestureDetector(
            onTap: () => lang.toggle(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.bgCardHigh.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Text(lang.langLabel,
                style: AppText.label(color: AppColors.primary, size: 11)),
            ),
          ),
          const SizedBox(width: 12),
          Text('PRO MODE',
            style: AppText.label(color: AppColors.primary, size: 11)),
          const SizedBox(width: 12),
          Icon(Icons.settings_outlined,
              color: AppColors.onSurfaceVariant, size: 20),
        ],
      ),
    );
  }
}

// ── Status Ring — the signature component ─────────────────────────────────────
class _StatusRing extends StatelessWidget {
  final bool isDriving;
  final bool isMonitoring;
  final Color stateColor;
  final Color stateGlow;
  final double rotValue;
  final double breatheScale;
  final double pingScale;
  final LanguageViewModel lang;

  const _StatusRing({
    required this.isDriving, required this.isMonitoring,
    required this.stateColor, required this.stateGlow,
    required this.rotValue, required this.breatheScale,
    required this.pingScale, required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240, height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ping pulse ring (only driving)
          if (isDriving)
            Transform.scale(
              scale: pingScale,
              child: Container(
                width: 240, height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: stateColor.withOpacity(0.3 * (1 - (pingScale - 1) / 0.6)),
                    width: 1.5,
                  ),
                ),
              ),
            ),

          // Outer dashed rotating ring
          Transform.rotate(
            angle: rotValue * 2 * math.pi,
            child: CustomPaint(
              size: const Size(230, 230),
              painter: _DashedRingPainter(
                color: stateColor.withOpacity(isMonitoring ? 0.30 : 0.12),
              ),
            ),
          ),

          // Middle solid ring
          Container(
            width: 196, height: 196,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: stateColor.withOpacity(0.45), width: 1.5),
            ),
          ),

          // Inner glass circle with glow
          Transform.scale(
            scale: isMonitoring ? breatheScale : 1.0,
            child: Container(
              width: 162, height: 162,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    stateColor.withOpacity(0.12),
                    AppColors.bgCardHigh.withOpacity(0.9),
                  ],
                ),
                border: Border.all(color: stateColor.withOpacity(0.35), width: 1.5),
                boxShadow: [
                  BoxShadow(color: stateGlow, blurRadius: 40, spreadRadius: 8),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isDriving ? Icons.local_shipping_outlined
                              : Icons.directions_car_rounded,
                    size: 52,
                    color: stateColor,
                  ),
                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      isDriving
                          ? lang.t('DRIVING\nDETECTED', 'CONDUITE\nDÉTECTÉE')
                          : lang.t('ALL\nCLEAR', 'TOUT VA\nBIEN'),
                      key: ValueKey(isDriving),
                      textAlign: TextAlign.center,
                      style: AppText.label(color: stateColor, size: 10),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PingDot(color: stateColor, animate: isDriving),
                      const SizedBox(width: 5),
                      Text(
                        isDriving
                            ? lang.t('Silent mode ON', 'Mode silencieux')
                            : lang.t('Monitoring', 'En surveillance'),
                        style: AppText.body(color: stateColor, size: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final List<int> barHeights;
  final Color barColor;
  final String chipLabel;
  final Color chipColor;

  const _StatCard({
    required this.icon, required this.iconColor,
    required this.label, required this.value,
    required this.barHeights, required this.barColor,
    required this.chipLabel, required this.chipColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: glassCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 10),
          Text(label, style: AppText.label(size: 10)),
          const SizedBox(height: 4),
          Text(value, style: AppText.number(color: AppColors.onSurface, size: 22)),
          const SizedBox(height: 8),
          // Mini bar chart
          Row(
            children: barHeights.map((h) => Container(
              width: 5, height: h.toDouble(),
              margin: const EdgeInsets.only(right: 3),
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(2),
              ),
            )).toList(),
          ),
          const SizedBox(height: 8),
          // Status chip
          Row(
            children: [
              Container(
                width: 7, height: 7,
                decoration: BoxDecoration(
                  color: chipColor, shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(chipLabel,
                style: AppText.label(color: AppColors.onSurfaceVariant, size: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Alert banner ──────────────────────────────────────────────────────────────
class _AlertBanner extends StatelessWidget {
  final LanguageViewModel lang;
  const _AlertBanner({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: AppColors.error.withOpacity(0.6), width: 4),
          right: BorderSide(color: AppColors.error.withOpacity(0.15)),
          top: BorderSide(color: AppColors.error.withOpacity(0.15)),
          bottom: BorderSide(color: AppColors.error.withOpacity(0.15)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang.t('⚠️  Driving detected — Phone silenced',
                   '⚠️  Conduite détectée — Téléphone silencieux'),
            style: AppText.bodyBold(color: AppColors.onSurface, size: 13),
          ),
          const SizedBox(height: 3),
          Text(
            lang.t('Volume will be restored automatically when you stop.',
                   'Le son sera restauré automatiquement à l\'arrêt.'),
            style: AppText.body(size: 12),
          ),
        ],
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final DrivingViewModel vm;
  final LanguageViewModel lang;
  const _ActionButton({required this.vm, required this.lang});

  @override
  Widget build(BuildContext context) {
    final isOn = vm.isMonitoring;
    final c1 = isOn ? AppColors.error : AppColors.primary;
    final c2 = isOn ? AppColors.errorContainer : AppColors.primaryContainer;

    return GestureDetector(
      onTap: () => isOn ? vm.stopMonitoring() : vm.startMonitoring(),
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [c1, c2],
          ),
          boxShadow: [
            BoxShadow(color: c1.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 6)),
          ],
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.15))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isOn ? Icons.stop_circle_outlined : Icons.play_circle_outline_rounded,
                color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(
              isOn ? lang.t('STOP MONITORING',  'ARRÊTER LA SURVEILLANCE')
                   : lang.t('START MONITORING', 'DÉMARRER LA SURVEILLANCE'),
              style: AppText.label(color: Colors.white, size: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ping dot widget ───────────────────────────────────────────────────────────
class _PingDot extends StatefulWidget {
  final Color color;
  final bool animate;
  const _PingDot({required this.color, required this.animate});
  @override
  State<_PingDot> createState() => _PingDotState();
}

class _PingDotState extends State<_PingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _a = Tween<double>(begin: 0, end: 1).animate(_c);
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 12, height: 12,
      child: Stack(alignment: Alignment.center, children: [
        if (widget.animate)
          AnimatedBuilder(animation: _a, builder: (_, __) =>
            Transform.scale(scale: 1 + _a.value * 0.8,
              child: Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(0.4 * (1 - _a.value)),
                ),
              ),
            ),
          ),
        Container(width: 7, height: 7,
          decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color)),
      ]),
    );
  }
}

// ── Dashed ring painter ───────────────────────────────────────────────────────
class _DashedRingPainter extends CustomPainter {
  final Color color;
  const _DashedRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const dashCount = 24;
    const dashLength = math.pi * 2 / dashCount * 0.55;
    const gapLength  = math.pi * 2 / dashCount * 0.45;
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    double angle = 0;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        angle, dashLength, false, paint,
      );
      angle += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(_DashedRingPainter old) => old.color != color;
}