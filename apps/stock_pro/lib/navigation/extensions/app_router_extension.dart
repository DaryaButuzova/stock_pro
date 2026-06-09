import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:stock_pro/navigation/routes/app_routes.dart';

/// Typed navigation helpers for [StackRouter].
extension AppRouterNavigation on StackRouter {
  /// Replaces the current route with authorization.
  void replaceWithAuthorization() {
    unawaited(replacePath(AppRoutes.authorization));
  }

  /// Replaces the current route with registration.
  void replaceWithRegistration() {
    unawaited(replacePath(AppRoutes.registration));
  }

  /// Pushes registration on top of the current route.
  void pushRegistration() {
    unawaited(pushPath(AppRoutes.registration));
  }

  /// Replaces the current route with profile.
  void replaceWithProfile() {
    unawaited(replacePath(AppRoutes.profile));
  }

  /// Replaces the current route with UI Kit showcase.
  void replaceWithShowcase() {
    unawaited(replacePath(AppRoutes.showcase));
  }
}
