import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ui_kit/ui_kit.dart';

import 'domain/registration_cubit.dart';

final _getIt = GetIt.instance;

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _getIt<RegistrationCubit>(),
      child: const _RegistrationView(),
    );
  }
}

class _RegistrationView extends StatefulWidget {
  const _RegistrationView();

  @override
  State<_RegistrationView> createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<_RegistrationView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<RegistrationCubit>().register(
        _emailController.text,
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: BlocConsumer<RegistrationCubit, RegistrationState>(
        listener: (context, state) {
          if (state is RegistrationSuccess) {
            if (state.hasSession) {
              context.router.replacePath('/profile');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Подтвердите email, затем войдите'),
                ),
              );
              context.router.replacePath('/login');
            }
          } else if (state is RegistrationFailure) {
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
                      if (value.length < 6) {
                        return 'Минимум 6 символов';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  state is RegistrationLoading
                      ? const CircularProgressIndicator()
                      : AppButton(
                          text: 'Зарегистрироваться',
                          onPressed: () => _register(context),
                        ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () =>
                        context.router.replacePath('/login'),
                    child: const Text('Уже есть аккаунт? Войти'),
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
