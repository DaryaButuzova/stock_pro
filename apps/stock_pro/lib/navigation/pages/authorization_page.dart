import 'package:authorization_feature/authorization_feature.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:stock_pro/navigation/extensions/app_router_extension.dart';

/// Navigation wrapper for [AuthorizationScreen].
@RoutePage()
class AuthorizationPage extends StatelessWidget {
  /// Creates the authorization page.
  const AuthorizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthorizationScreen(
      onAuthSuccess: context.router.replaceWithAuthorized,
      onNavigateToRegistration: context.router.pushRegistration,
    );
  }
}
