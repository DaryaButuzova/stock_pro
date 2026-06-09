import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:profile_feature/profile_feature.dart';
import 'package:stock_pro/navigation/extensions/app_router_extension.dart';

/// Navigation wrapper for [ProfileScreen].
@RoutePage()
class ProfilePage extends StatelessWidget {
  /// Creates the profile page.
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileScreen(
      onUnauthenticated: context.router.replaceWithAuthorization,
    );
  }
}
