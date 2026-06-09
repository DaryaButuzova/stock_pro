import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:registration_feature/registration_feature.dart';
import 'package:stock_pro/navigation/extensions/app_router_extension.dart';

/// Navigation wrapper for [RegistrationScreen].
@RoutePage()
class RegistrationPage extends StatelessWidget {
  /// Creates the registration page.
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RegistrationScreen(
      onRegistrationSuccess: ({required hasSession}) {
        if (hasSession) {
          context.router.replaceWithProfile();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Подтвердите email, затем войдите'),
            ),
          );
          context.router.replaceWithAuthorization();
        }
      },
      onNavigateToLogin: context.router.replaceWithAuthorization,
    );
  }
}
