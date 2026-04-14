// ═══════════════════════════════════════════════════════════════════
// lib/views/driver_mode_screen.dart
//
// The Driver Mode screen allows taxi/Yango drivers to:
//  1. Enable "Driver Mode" so their order apps still work
//  2. Set availability status (Available / Busy / Offline)
//  3. Choose which apps bypass silence when driving
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../viewmodels/driver_mode_viewmodel.dart';
import '../viewmodels/language_viewmodel.dart';

class DriverModeScreen extends StatelessWidget {
  const DriverModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm   = context.watch<DriverModeViewModel>();
    final lang = context.watch<LanguageViewModel>();

    return Scaffold(
      backgroundColor: AppColors.bgLowest,
      body: Stack(
        children: [
          // Ambient glow
          Positioned(top: 100, right: -60,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  blurRadius: 200,
                )],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [

                // ── App bar ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                  child: Row(children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          color: AppColors.onSurface),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang.t('Driver Mode', 'Mode Chauffeur'),
                          style: AppText.headline(size: 20),
                        ),
                        Text(
                          lang.t('For taxi & delivery drivers',
                                 'Pour chauffeurs et livreurs'),
                          style: AppText.body(size: 12),
                        ),
                      ],
                    ),
                  ]),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [

                      // ── Driver mode toggle card ──────────────────────
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: vm.isDriverMode
                                ? [
                                    AppColors.primary.withOpacity(0.2),
                                    AppColors.primaryContainer.withOpacity(0.1),
                                  ]
                                : [
                                    AppColors.bgCardHigh.withOpacity(0.5),
                                    AppColors.bgCardHigh.withOpacity(0.3),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: vm.isDriverMode
                                ? AppColors.primary.withOpacity(0.4)
                                : Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: Row(children: [
                          // Icon
                          Container(
                            width: 52, height: 52,
                            decoration: BoxDecoration(
                              color: vm.isDriverMode
                                  ? AppColors.primary.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Text('🚖',
                              style: TextStyle(fontSize: 26),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang.t('Driver Mode', 'Mode Chauffeur'),
                                  style: AppText.bodyBold(size: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  lang.t(
                                    'Yango & order apps stay active\nwhile your phone is silenced',
                                    'Yango & apps de commande restent actifs\npendant que le téléphone est silencieux',
                                  ),
                                  style: AppText.body(size: 12),
                                ),
                              ],
                            ),
                          ),

                          // Toggle switch
                          Switch(
                            value: vm.isDriverMode,
                            onChanged: (_) => vm.toggleDriverMode(),
                            activeColor: AppColors.primary,
                            activeTrackColor:
                                AppColors.primary.withOpacity(0.3),
                            inactiveTrackColor:
                                Colors.white.withOpacity(0.1),
                            inactiveThumbColor: AppColors.onSurfaceVariant,
                          ),
                        ]),
                      ),

                      // ── Only show rest when driver mode is ON ────────
                      if (vm.isDriverMode) ...[

                        const SizedBox(height: 24),

                        // ── Status section ─────────────────────────────
                        Text(
                          lang.t('MY STATUS', 'MON STATUT'),
                          style: AppText.label(size: 11),
                        ),
                        const SizedBox(height: 12),

                        Row(children: [
                          Expanded(child: _StatusButton(
                            emoji: '🟢',
                            label: lang.t('Available', 'Disponible'),
                            selected: vm.status == DriverStatus.available,
                            color: AppColors.tertiary,
                            onTap: () => vm.setStatus(DriverStatus.available),
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: _StatusButton(
                            emoji: '🔴',
                            label: lang.t('Busy', 'Occupé'),
                            selected: vm.status == DriverStatus.busy,
                            color: AppColors.error,
                            onTap: () => vm.setStatus(DriverStatus.busy),
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: _StatusButton(
                            emoji: '⚫',
                            label: lang.t('Offline', 'Hors ligne'),
                            selected: vm.status == DriverStatus.offline,
                            color: AppColors.onSurfaceVariant,
                            onTap: () => vm.setStatus(DriverStatus.offline),
                          )),
                        ]),

                        const SizedBox(height: 24),

                        // ── Whitelist section ──────────────────────────
                        Row(children: [
                          Expanded(
                            child: Text(
                              lang.t(
                                'ALLOWED APPS WHEN DRIVING',
                                'APPS AUTORISÉES EN CONDUITE',
                              ),
                              style: AppText.label(size: 11),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${vm.enabledCount} ${lang.t("active", "actives")}',
                              style: AppText.label(
                                  color: AppColors.primary, size: 10),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        Text(
                          lang.t(
                            'These apps will still notify you even when your phone is silenced',
                            'Ces apps vous notifieront même quand le téléphone est silencieux',
                          ),
                          style: AppText.body(size: 12),
                        ),

                        const SizedBox(height: 14),

                        // App list grouped by category
                        ...vm.appsByCategory.entries.map((entry) =>
                          _AppCategorySection(
                            category: entry.key,
                            apps: entry.value,
                            vm: vm,
                            lang: lang,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Info box ───────────────────────────────────
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.2)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  color: AppColors.primary, size: 16),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  lang.t(
                                    'Driver Mode uses Android\'s Do Not Disturb with app exceptions. '
                                    'You may need to grant special permissions in your phone settings.',
                                    'Le Mode Chauffeur utilise le Ne Pas Déranger d\'Android avec des exceptions. '
                                    'Vous devrez peut-être accorder des permissions spéciales dans les paramètres.',
                                  ),
                                  style: AppText.body(size: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // ── When driver mode is OFF ────────────────────────
                      if (!vm.isDriverMode) ...[
                        const SizedBox(height: 32),
                        Center(
                          child: Column(children: [
                            const Text('🚖', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 16),
                            Text(
                              lang.t(
                                'Are you a Yango, inDrive\nor Uber driver?',
                                'Êtes-vous chauffeur Yango,\ninDrive ou Uber?',
                              ),
                              textAlign: TextAlign.center,
                              style: AppText.bodyBold(size: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              lang.t(
                                'Enable Driver Mode so your order\nnotifications still come through.',
                                'Activez le Mode Chauffeur pour que\nvos notifications de commandes passent.',
                              ),
                              textAlign: TextAlign.center,
                              style: AppText.body(size: 14),
                            ),
                          ]),
                        ),
                      ],

                      const SizedBox(height: 40),
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
}

// ── Status button ─────────────────────────────────────────────────────────────
class _StatusButton extends StatelessWidget {
  final String emoji, label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _StatusButton({
    required this.emoji, required this.label,
    required this.selected, required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? color.withOpacity(0.15)
              : AppColors.bgCardHigh.withOpacity(0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color.withOpacity(0.5) : Colors.white.withOpacity(0.08),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(label,
              style: AppText.label(
                color: selected ? color : AppColors.onSurfaceVariant,
                size: 10,
              )),
        ]),
      ),
    );
  }
}

// ── App category section ──────────────────────────────────────────────────────
class _AppCategorySection extends StatelessWidget {
  final String category;
  final List<WhitelistedApp> apps;
  final DriverModeViewModel vm;
  final LanguageViewModel lang;

  const _AppCategorySection({
    required this.category, required this.apps,
    required this.vm, required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            category.toUpperCase(),
            style: AppText.label(color: AppColors.onSurfaceVariant, size: 10),
          ),
        ),
        Container(
          decoration: glassCard(),
          child: Column(
            children: apps.asMap().entries.map((entry) {
              final i   = entry.key;
              final app = entry.value;
              final isLast = i == apps.length - 1;

              return Column(children: [
                _AppTile(app: app, vm: vm, lang: lang),
                if (!isLast)
                  Divider(
                    color: Colors.white.withOpacity(0.05),
                    height: 1,
                    indent: 58,
                  ),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Individual app tile ───────────────────────────────────────────────────────
class _AppTile extends StatelessWidget {
  final WhitelistedApp app;
  final DriverModeViewModel vm;
  final LanguageViewModel lang;

  const _AppTile({
    required this.app, required this.vm, required this.lang});

  @override
  Widget build(BuildContext context) {
    final isEssential = app.category == 'Essential';

    return InkWell(
      onTap: isEssential ? null : () => vm.toggleApp(app.id),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          // Emoji icon
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: app.isEnabled
                  ? AppColors.primary.withOpacity(0.12)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(app.emoji,
                  style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 14),

          // App name + category
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(app.name,
                  style: AppText.bodyBold(
                    color: app.isEnabled
                        ? AppColors.onSurface
                        : AppColors.onSurfaceVariant,
                    size: 14,
                  )),
              if (isEssential)
                Text(
                  lang.t('Always allowed', 'Toujours autorisé'),
                  style: AppText.body(color: AppColors.tertiary, size: 11),
                ),
            ],
          )),

          // Checkbox or lock
          if (isEssential)
            Icon(Icons.lock_outline_rounded,
                color: AppColors.tertiary, size: 18)
          else
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: app.isEnabled
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: app.isEnabled
                      ? AppColors.primary
                      : AppColors.outlineVariant.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: app.isEnabled
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
        ]),
      ),
    );
  }
}