import 'package:flutter/material.dart';
import '../../theme/index.dart';
import '../../constants/app_constants.dart';

/// Blob glow background widget
class GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;
  final Offset position;

  const GlowBlob({
    super.key,
    required this.color,
    required this.size,
    required this.opacity,
    required this.position,
  });

  @override
  Widget build(BuildContext context) => Positioned(
        top: position.dy,
        left: position.dx,
        child: Container(
          width: size * 2,
          height: size * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(opacity),
                blurRadius: size * 1.5,
                spreadRadius: size * 0.2,
              ),
            ],
          ),
        ),
      );
}

/// Animated ping dot indicator
class PingDot extends StatelessWidget {
  final Color color;
  final bool animate;

  const PingDot({
    super.key,
    required this.color,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      );
}

/// Glass morphism card container
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? leftBorderColor;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(UISizes.paddingLg),
    this.leftBorderColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        padding: padding,
        decoration: glassCard(leftBorderColor: leftBorderColor),
        child: child,
      );
}

/// Action button with state support
class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UISizes.cornerRadiusLg),
            ),
          ),
          child: isLoading
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: textColor ?? Colors.black),
                      const SizedBox(width: UISizes.paddingMd),
                    ],
                    Text(label, style: AppText.bodyBold(color: textColor ?? Colors.black)),
                  ],
                ),
        ),
      );
}

/// Top app bar with language toggle
class TopAppBar extends StatelessWidget {
  final String title;
  final GestureTapCallback? onLanguageTap;
  final String? langLabel;
  final VoidCallback? onSettingsTap;

  const TopAppBar({
    super.key,
    required this.title,
    this.onLanguageTap,
    this.langLabel,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(
          UISizes.paddingXl,
          UISizes.paddingMd,
          UISizes.paddingXl,
          UISizes.paddingMd,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.shield_rounded, color: AppColors.primary, size: UISizes.iconMd),
            const SizedBox(width: UISizes.paddingMd),
            Text(title, style: AppText.headline(size: 18, color: AppColors.onSurface)),
            const Spacer(),
            if (onLanguageTap != null && langLabel != null) ...[
              GestureDetector(
                onTap: onLanguageTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UISizes.paddingMd,
                    vertical: UISizes.paddingSm / 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bgCardHigh.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(UISizes.cornerRadiusSm),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Text(langLabel!, style: AppText.label(size: 11)),
                ),
              ),
              const SizedBox(width: UISizes.paddingMd),
            ],
            if (onSettingsTap != null) ...[
              Text('PRO MODE', style: AppText.label(size: 11)),
              const SizedBox(width: UISizes.paddingMd),
              GestureDetector(
                onTap: onSettingsTap,
                child: Icon(IconData(0xe8b8, fontFamily: 'MaterialIcons'),
                    color: AppColors.onSurfaceVariant, size: UISizes.iconSm),
              ),
            ],
          ],
        ),
      );
}

/// Bottom navigation bar
class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String homeLabel;
  final String historyLabel;
  final String settingsLabel;
  final VoidCallback onSettingsTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.homeLabel,
    required this.historyLabel,
    required this.settingsLabel,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(UISizes.paddingXl, 0, UISizes.paddingXl, 24),
        height: UISizes.bottomNavHeight,
        decoration: BoxDecoration(
          color: AppColors.bgCardHighest.withOpacity(0.70),
          borderRadius: BorderRadius.circular(UISizes.cornerRadiusLg),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavButton(
              icon: Icons.home_rounded,
              label: homeLabel,
              selected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavButton(
              icon: Icons.history_rounded,
              label: historyLabel,
              selected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _NavButton(
              icon: Icons.settings_outlined,
              label: settingsLabel,
              selected: false,
              onTap: onSettingsTap,
            ),
          ],
        ),
      );
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AnimationDurations.fadeAnimation,
          padding: const EdgeInsets.symmetric(
            horizontal: UISizes.paddingLg,
            vertical: UISizes.paddingSm,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
                size: UISizes.iconMd,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: AppText.label(
                  color: selected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  size: 9,
                ),
              ),
            ],
          ),
        ),
      );
}
