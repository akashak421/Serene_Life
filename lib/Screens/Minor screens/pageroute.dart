import 'package:flutter/material.dart';

class ScaleTransitionRoute<T> extends MaterialPageRoute<T> {
  ScaleTransitionRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(builder: builder, settings: settings);

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
