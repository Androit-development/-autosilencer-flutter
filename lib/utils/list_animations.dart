import 'package:flutter/material.dart';

/// Animation utilities for list items
class ListAnimations {
  /// Calculate staggered animation for a list item at index
  static Animation<double> staggeredAnimation(
    AnimationController controller,
    int index, {
    double interval = 0.1,
    double duration = 0.4,
  }) {
    final start = (index * interval).clamp(0.0, 1.0);
    final end = (start + duration).clamp(0.0, 1.0);

    return CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  /// Build staggered list item with fade and slide animation
  static Widget buildAnimatedListItem(
    int index,
    Animation<double> animation,
    Widget child, {
    double slideDistance = 0.2,
  }) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, slideDistance),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  /// Build animated scale transition
  static Widget buildScaleAnimation(
    Animation<double> animation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: animation,
      child: child,
    );
  }
}
