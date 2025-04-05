import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math.dart' as math;

import '../models/custom_alert_anim_type.dart';

/// Define Animation Type
class CustomAlertAnimate {
  /// Helper to calculate curved value
  static double _curvedOffset(Animation<double> animation) {
    return Curves.easeInOutBack.transform(animation.value) - 1.0;
  }

  /// scale Animation
  static Widget scale({
    required Widget child,
    required Animation<double> animation,
  }) {
    return Transform.scale(
      scale: animation.value,
      child: Opacity(
        opacity: animation.value,
        child: child,
      ),
    );
  }

  /// rotate Animation
  static Widget rotate({
    required Widget child,
    required Animation<double> animation,
  }) {
    return Transform.rotate(
      angle: math.radians(animation.value * 360),
      child: Opacity(
        opacity: animation.value,
        child: child,
      ),
    );
  }

  /// slideInDown Animation
  static Widget slideInDown({
    required Widget child,
    required Animation<double> animation,
  }) {
    final curvedValue = _curvedOffset(animation);
    return Transform(
      transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
      child: Opacity(
        opacity: animation.value,
        child: child,
      ),
    );
  }

  /// slideInUp Animation
  static Widget slideInUp({
    required Widget child,
    required Animation<double> animation,
  }) {
    final curvedValue = _curvedOffset(animation);
    return Transform(
      transform: Matrix4.translationValues(0.0, curvedValue * -200, 0.0),
      child: Opacity(
        opacity: animation.value,
        child: child,
      ),
    );
  }

  /// slideInLeft Animation
  static Widget slideInLeft({
    required Widget child,
    required Animation<double> animation,
  }) {
    final curvedValue = _curvedOffset(animation);
    return Transform(
      transform: Matrix4.translationValues(curvedValue * 200, 0.0, 0.0),
      child: Opacity(
        opacity: animation.value,
        child: child,
      ),
    );
  }

  /// slideInRight Animation
  static Widget slideInRight({
    required Widget child,
    required Animation<double> animation,
  }) {
    final curvedValue = _curvedOffset(animation);
    return Transform(
      transform: Matrix4.translationValues(curvedValue * -200, 0, 0),
      child: Opacity(
        opacity: animation.value,
        child: child,
      ),
    );
  }

  /// getByType Helper
  static Widget getByType(CustomAlertAnimType type, {
    required Widget child,
    required Animation<double> animation,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        switch (type) {
          case CustomAlertAnimType.scale:
            return scale(child: child, animation: animation);
          case CustomAlertAnimType.rotate:
            return rotate(child: child, animation: animation);
          case CustomAlertAnimType.slideInDown:
            return slideInDown(child: child, animation: animation);
          case CustomAlertAnimType.slideInUp:
            return slideInUp(child: child, animation: animation);
          case CustomAlertAnimType.slideInLeft:
            return slideInLeft(child: child, animation: animation);
          case CustomAlertAnimType.slideInRight:
            return slideInRight(child: child, animation: animation);
        }
      },
    );
  }
}