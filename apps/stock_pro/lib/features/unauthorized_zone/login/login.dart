import 'dart:async';

import 'package:authorization_feature/authorization_feature.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// App route wrapper for the authorization feature screen.
@RoutePage()
class LoginScreen extends StatelessWidget {
  /// Creates the login route.
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthorizationScreen(
      onAuthSuccess: () =>
          unawaited(context.router.replacePath('/profile')),
      onNavigateToRegistration: () =>
          unawaited(context.router.pushPath('/registration')),
    );
  }
}
