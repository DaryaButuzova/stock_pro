import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ui_kit/ui_kit.dart';

import '../domain/authorization_cubit.dart';

final _getIt = GetIt.instance;

class AuthorizationScreen extends StatelessWidget {
  const AuthorizationScreen({
    required this.onAuthSuccess,
    required this.onNavigateToRegistration,
    super.key,
  });

  final VoidCallback onAuthSuccess;
  final VoidCallback onNavigateToRegistration;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _getIt<AuthorizationCubit>(),
      child: _AuthorizationView(
        onAuthSuccess: onAuthSuccess,
        onNavigateToRegistration: onNavigateToRegistration,
      ),
    );
  }
}

class _AuthorizationView extends StatefulWidget {
  const _AuthorizationView({
    required this.onAuthSuccess,
    required this.onNavigateToRegistration,
  });

  final VoidCallback onAuthSuccess;
  final VoidCallback onNavigateToRegistration;

  @override
  State<_AuthorizationView> createState() => _AuthorizationViewState();
}

class _AuthorizationViewState extends State<_AuthorizationView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _authorization(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthorizationCubit>().authorization(
        _emailController.text,
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Авторизация')),
      body: BlocConsumer<AuthorizationCubit, AuthorizationState>(
        listener: (context, state) {
          if (state is AuthorizationSuccess) {
            widget.onAuthSuccess();
          } else if (state is AuthorizationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Пароль',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите пароль';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  state is AuthorizationLoading
                      ? const CircularProgressIndicator()
                      : AppButton(
                          text: 'Войти',
                          variant: AppButtonVariant.primary,
                          onPressed: () => _authorization(context),
                        ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: widget.onNavigateToRegistration,
                    child: const Text('Нет аккаунта? Зарегистрироваться'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
