import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom page transition with fade effect
class FadePageTransition extends CustomTransitionPage<void> {
  const FadePageTransition({
    required super.child,
    required super.key,
    super.name,
    super.arguments,
    super.restorationId,
    super.transitionDuration,
  }) : super(transitionsBuilder: _fadeTransitionsBuilder);

  static Widget _fadeTransitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
      child: child,
    );
  }
}

/// Extension to easily create fade transitions for GoRoute
extension GoRouteFadeTransition on GoRoute {
  static GoRoute createWithFadeTransition({
    required String path,
    required Widget Function(BuildContext, GoRouterState) builder,
    String? name,
    List<RouteBase> routes = const <RouteBase>[],
    GoRouterRedirect? redirect,
  }) {
    return GoRoute(
      path: path,
      name: name,
      routes: routes,
      redirect: redirect,
      pageBuilder: (context, state) => FadePageTransition(
        key: state.pageKey,
        child: builder(context, state),
      ),
    );
  }
}
