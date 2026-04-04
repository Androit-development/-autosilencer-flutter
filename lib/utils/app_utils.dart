import 'package:flutter/material.dart';
import '../theme/index.dart';

/// String formatting utilities
class StringUtils {
  StringUtils._();

  /// Format time from minutes to readable format
  /// Example: 90 → "1h 30"
  static String formatTime(int minutes) {
    if (minutes < 60) return '${minutes}min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins > 0 ? '${hours}h ${mins}min' : '${hours}h';
  }

  /// Format sensor value with unit
  static String formatMotion(double value) => '${value.toStringAsFixed(1)} m/s²';

  static String formatNoise(double value) => '${value.toStringAsFixed(0)} dB';
}

/// Dialog utilities
class DialogUtils {
  DialogUtils._();

  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCardHigh,
        title: Text('Error', style: AppText.headline()),
        content: Text(message, style: AppText.body()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: AppText.bodyBold(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCardHigh,
        title: Text(title, style: AppText.headline()),
        content: Text(message, style: AppText.body()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: AppText.body()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText, style: AppText.bodyBold(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

/// Animation utilities
class AnimationUtils {
  AnimationUtils._();

  /// Create a staggered animation for list items
  static Animation<double> createStaggeredAnimation(
    AnimationController controller, {
    required int index,
    required int totalItems,
    required double beginInterval,
  }) {
    final interval = beginInterval + (index / totalItems) * (1 - beginInterval);
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(interval, 1.0, curve: Curves.easeOut),
      ),
    );
  }
}

/// Size utilities
class SizeUtils {
  SizeUtils._();

  /// Get responsive padding based on screen width
  static double getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 16;
    if (width < 1200) return 24;
    return 32;
  }

  /// Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return mobile;
    if (width < 1200) return tablet ?? mobile;
    return desktop ?? mobile;
  }
}
