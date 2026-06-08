import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:profile_feature/profile_feature.dart';

/// App route wrapper for the profile feature screen.
@RoutePage()
class ProfilePage extends StatelessWidget {
  /// Creates the profile route.
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}
