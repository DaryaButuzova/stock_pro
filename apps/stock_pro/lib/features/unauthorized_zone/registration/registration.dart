import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:registration_feature/registration_feature.dart';

/// App route wrapper for the registration feature screen.
@RoutePage()
class AppRegistrationScreen extends StatelessWidget {
  /// Creates the registration route.
  const AppRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RegistrationScreen(
      onRegistrationSuccess: ({required hasSession}) {
        if (hasSession) {
          unawaited(context.router.replacePath('/profile'));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Подтвердите email, затем войдите'),
            ),
          );
          unawaited(context.router.replacePath('/login'));
        }
      },
      onNavigateToLogin: () =>
          unawaited(context.router.replacePath('/login')),
    );
  }
}
