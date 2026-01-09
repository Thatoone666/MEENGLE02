import 'package:flutter/material.dart';

class MessageAnimations {
  static Animation<Offset> slideInFromBottom(AnimationController controller) {
    return Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    ));
  }

  static Animation<double> fadeIn(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    ));
  }

  static Animation<double> scale(AnimationController controller) {
    return Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.elasticOut,
    ));
  }
}

class ReactionAnimations {
  static Animation<double> popScale(AnimationController controller) {
    return TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 60.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40.0,
      ),
    ]).animate(controller);
  }
}

class TypingIndicatorAnimations {
  static Animation<double> dotScale(AnimationController controller, int dotIndex) {
    final beginTime = 0.2 * dotIndex;
    return TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.5)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.5, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50.0,
      ),
    ]).animate(CurvedAnimation(
      parent: controller,
      curve: Interval(beginTime, beginTime + 0.6),
    ));
  }
}