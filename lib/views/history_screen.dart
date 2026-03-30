// ═══════════════════════════════════════════════════════════════════════════
// Module 3: views/history_screen.dart
// Matches Stitch screenshot exactly:
//   - Summary pills row (Trajets / Temps / Silences)
//   - Filter chips (Toutes / Aujourd'hui / Cette semaine)
//   - Session cards with left colored border + progress bar
//   - Animate-ping dot on active card
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../viewmodels/driving_viewmodel.dart';
import '../viewmodels/language_viewmodel.dart';
import '../models/driving_log.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {

  int _filterIndex = 0; // 0=All, 1=Today, 2=This week

  // Staggered entrance animation
  late final AnimationController _staggerCtrl;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm   = context.watch<DrivingViewModel>();
    final lang = context.watch<LanguageViewModel>();

    return Scaffold(
      backgroundColor: AppColors.bgLowest,
      body: Stack(
        children: [
          // Ambient glow blobs
          Positioned(top: 60, right: -40,
            child: _blob(AppColors.primary, 180, 0.08)),
          Positioned(bottom: 160, left: -40,
            child: _blob(AppColors.tertiary, 160, 0.06)),

          SafeArea(
            child: Column(
              children: [
                // ── Top App Bar ───────────────────────────────────────────
                _HistoryTopBar(lang: lang),

                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [

                      // ── Header ──────────────────────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lang.t('Driving Sessions',
                                             'Sessions de conduite'),
                                      style: AppText.headline(size: 32),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      lang.t('Your recent activity',
                                             'Votre activité récente'),
                                      style: AppText.body(),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.bgCardHigh.withOpacity(0.4),
                                  border: Border.all(
                                    color: AppColors.outlineVariant.withOpacity(0.3)),
                                ),
                                child: Icon(Icons.analytics_outlined,
                                    color: AppColors.primary, size: 20),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Summary pills ────────────────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Row(
                            children: [
                              Expanded(child: _SummaryPill(
                                icon: Icons.directions_car_filled_rounded,
                                iconColor: AppColors.primary,
                                value: '${vm.totalTrips}',
                                label: lang.t('TRIPS', 'TRAJETS'),
                              )),
                              const SizedBox(width: 10),
                              Expanded(child: _SummaryPill(
                                icon: Icons.timer_rounded,
                                iconColor: AppColors.primary,
                                value: vm.totalTimeLabel,
                                label: lang.t('TIME', 'TEMPS'),
                              )),
                              const SizedBox(width: 10),
                              Expanded(child: _SummaryPill(
                                icon: Icons.notifications_off_rounded,
                                iconColor: AppColors.tertiary,
                                value: '${vm.totalSilences}',
                                label: lang.t('SILENCES', 'SILENCES'),
                                valueColor: AppColors.tertiary,
                              )),
                            ],
                          ),
                        ),
                      ),

                      // ── Filter chips ──────────────────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _FilterChip(
                                  label: lang.t('All ▾', 'Toutes ▾'),
                                  active: _filterIndex == 0,
                                  onTap: () => setState(() => _filterIndex = 0),
                                ),
                                const SizedBox(width: 8),
                                _FilterChip(
                                  label: lang.t("Today", "Aujourd'hui"),
                                  active: _filterIndex == 1,
                                  onTap: () => setState(() => _filterIndex = 1),
                                ),
                                const SizedBox(width: 8),
                                _FilterChip(
                                  label: lang.t('This week', 'Cette semaine'),
                                  active: _filterIndex == 2,
                                  onTap: () => setState(() => _filterIndex = 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ── Session cards list ────────────────────────────────
                      vm.logs.isEmpty
                          ? SliverFillRemaining(child: _EmptyState(lang: lang))
                          : SliverPadding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    // Staggered entrance
                                    final delay = index * 0.12;
                                    final start = delay.clamp(0.0, 1.0);
                                    final end = (delay + 0.4).clamp(0.0, 1.0);
                                    final anim = CurvedAnimation(
                                      parent: _staggerCtrl,
                                      curve: Interval(start, end, curve: Curves.easeOut),
                                    );
                                    return AnimatedBuilder(
                                      animation: anim,
                                      builder: (_, __) => FadeTransition(
                                        opacity: anim,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0, 0.3),
                                            end: Offset.zero,
                                          ).animate(anim),
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: _SessionCard(
                                              log: vm.logs[index],
                                              lang: lang,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  childCount: vm.logs.length,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
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

// ── Top bar ───────────────────────────────────────────────────────────────────
class _HistoryTopBar extends StatelessWidget {
  final LanguageViewModel lang;
  const _HistoryTopBar({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_rounded, color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          Text('AutoSilencer',
            style: AppText.headline(size: 18, color: AppColors.onSurface)),
          const Spacer(),
          GestureDetector(
            onTap: lang.toggle,
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
          Icon(Icons.settings_outlined, color: AppColors.onSurfaceVariant, size: 20),
        ],
      ),
    );
  }
}

// ── Summary pill ──────────────────────────────────────────────────────────────
class _SummaryPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Color? valueColor;

  const _SummaryPill({
    required this.icon, required this.iconColor,
    required this.value, required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCardHigh.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(value, style: AppText.number(
              color: valueColor ?? AppColors.primary, size: 18)),
          const SizedBox(height: 3),
          Text(label, style: AppText.label(size: 9)),
        ],
      ),
    );
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primaryContainer.withOpacity(0.85)
              : AppColors.bgCardHigh.withOpacity(0.4),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: active
                ? Colors.transparent
                : AppColors.outlineVariant.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: AppText.label(
            color: active ? AppColors.onSurface : AppColors.onSurfaceVariant,
            size: 11,
          ),
        ),
      ),
    );
  }
}

// ── Session card ──────────────────────────────────────────────────────────────
class _SessionCard extends StatelessWidget {
  final DrivingLog log;
  final LanguageViewModel lang;
  const _SessionCard({required this.log, required this.lang});

  @override
  Widget build(BuildContext context) {
    final color  = log.color;
    final isDriving = log.status == DrivingStatus.driving;
    final isMuted = log.status == DrivingStatus.sessionEnded ||
                    log.status == DrivingStatus.shortTrip;

    return Opacity(
      opacity: isMuted ? 0.75 : 1.0,
      child: Container(
        decoration: glassCard(leftBorderColor: color),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon box
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_iconFor(log.status), color: color, size: 22),
                  ),
                  const SizedBox(width: 14),

                  // Title + date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.label(lang.isEnglish),
                          style: AppText.bodyBold(color: AppColors.onSurface, size: 15)),
                        const SizedBox(height: 3),
                        Text(log.formattedDate(lang.isEnglish),
                          style: AppText.body(size: 12)),
                      ],
                    ),
                  ),

                  // Right: badge or ping dot
                  if (isDriving)
                    _PingDotSmall(color: color)
                  else if (log.status == DrivingStatus.notDriving)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        lang.t('SECURE', 'SÉCURISÉ'),
                        style: AppText.label(color: color, size: 9),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              // Progress bar + duration
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: log.progressFill,
                        backgroundColor: AppColors.bgCardHighest,
                        color: color,
                        minHeight: 5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    '${log.durationMinutes} min',
                    style: AppText.number(color: color, size: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(DrivingStatus s) {
    switch (s) {
      case DrivingStatus.driving:      return Icons.local_shipping_outlined;
      case DrivingStatus.notDriving:   return Icons.check_circle_outline_rounded;
      case DrivingStatus.sessionEnded: return Icons.history_rounded;
      case DrivingStatus.shortTrip:    return Icons.electric_car_outlined;
    }
  }
}

// ── Small ping dot ────────────────────────────────────────────────────────────
class _PingDotSmall extends StatefulWidget {
  final Color color;
  const _PingDotSmall({required this.color});
  @override
  State<_PingDotSmall> createState() => _PingDotSmallState();
}

class _PingDotSmallState extends State<_PingDotSmall>
    with SingleTickerProviderStateMixin {
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
    return SizedBox(width: 16, height: 16,
      child: Stack(alignment: Alignment.center, children: [
        AnimatedBuilder(animation: _a, builder: (_, __) =>
          Transform.scale(scale: 1 + _a.value,
            child: Container(
              width: 12, height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(0.35 * (1 - _a.value)),
              ),
            ),
          ),
        ),
        Container(width: 8, height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color)),
      ]),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final LanguageViewModel lang;
  const _EmptyState({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.smartphone_outlined,
              size: 64, color: AppColors.onSurfaceVariant.withOpacity(0.2)),
          const SizedBox(height: 20),
          Text(
            lang.t('No sessions yet', 'Aucune session'),
            style: AppText.bodyBold(
                color: AppColors.onSurfaceVariant, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            lang.t(
              'Start monitoring to record\nyour first session',
              'Démarrez la surveillance pour\nenregistrer votre première session',
            ),
            textAlign: TextAlign.center,
            style: AppText.body(
                color: AppColors.onSurfaceVariant.withOpacity(0.5), size: 13),
          ),
        ],
      ),
    );
  }
}