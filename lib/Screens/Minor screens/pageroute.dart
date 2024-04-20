import 'package:flutter/material.dart';

class ScaleTransitionRoute<T> extends MaterialPageRoute<T> {
  ScaleTransitionRoute({
    required super.builder,
    super.settings,
  });

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.5,
        end: 1.0,
      ).animate(animation),
      child: child,
    );
  }
}
