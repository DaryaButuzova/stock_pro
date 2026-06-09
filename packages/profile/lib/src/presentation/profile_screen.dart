import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ui_kit/ui_kit.dart';

import '../domain/profile_cubit.dart';

final _getIt = GetIt.instance;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    required this.onUnauthenticated,
    super.key,
  });

  final VoidCallback onUnauthenticated;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _getIt<ProfileCubit>(),
      child: _ProfileView(onUnauthenticated: onUnauthenticated),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({required this.onUnauthenticated});

  final VoidCallback onUnauthenticated;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUnauthenticated) {
            onUnauthenticated();
          } else if (state is ProfileFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            ProfileInitial() || ProfileLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            ProfileLoaded(:final profile) => SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Добро пожаловать', style: AppTextStyles.headingMedium),
                  const SizedBox(height: 24),
                  _ProfileField(label: 'ФИО', value: profile.creds),
                  const SizedBox(height: 16),
                  _ProfileField(label: 'Email', value: profile.email),
                  const SizedBox(height: 16),
                  _ProfileField(label: 'Роль', value: profile.roleLabel),
                  const SizedBox(height: 32),
                  AppButton(
                    text: 'Выйти',
                    variant: AppButtonVariant.outlined,
                    onPressed: () => context.read<ProfileCubit>().logout(),
                  ),
                ],
              ),
            ),
            ProfileUnauthenticated() => const SizedBox.shrink(),
            ProfileFailure() => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.bodyLarge),
      ],
    );
  }
}
