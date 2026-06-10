import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/ui_kit.dart';

import '../domain/models/user_role.dart';
import '../domain/user_session_cubit.dart';

/// Builds [staff] or [admin] content based on the current user role.
class RoleGate extends StatelessWidget {
  const RoleGate({
    required this.staff,
    required this.admin,
    super.key,
  });

  final Widget staff;
  final Widget admin;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserSessionCubit, UserSessionState>(
      builder: (context, state) {
        return switch (state) {
          UserSessionInitial() || UserSessionLoading() => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          UserSessionReady(:final profile) => switch (profile.roleEnum) {
            UserRole.admin => admin,
            UserRole.staff => staff,
          },
          UserSessionUnauthenticated() => const Scaffold(
            body: Center(
              child: Text('Сессия не найдена'),
            ),
          ),
          UserSessionFailure(:final error) => Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(error, style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Повторить',
                    onPressed: () => context.read<UserSessionCubit>().load(),
                  ),
                ],
              ),
            ),
          ),
        };
      },
    );
  }
}
