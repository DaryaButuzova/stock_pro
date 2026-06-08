import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ui_kit/ui_kit.dart';

import '../domain/profile_cubit.dart';

final _getIt = GetIt.instance;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _getIt<ProfileCubit>(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUnauthenticated) {
            context.router.replacePath('/login');
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
            ProfileLoaded(:final email) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Добро пожаловать', style: AppTextStyles.headingMedium),
                  const SizedBox(height: 8),
                  Text(email, style: AppTextStyles.bodyLarge),
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
