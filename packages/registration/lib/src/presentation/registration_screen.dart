import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ui_kit/ui_kit.dart';

import '../domain/models/registration_data.dart';
import 'package:profile_feature/profile_feature.dart';
import '../domain/registration_cubit.dart';

final _getIt = GetIt.instance;

/// Called when registration completes.
/// [hasSession] is true when the user is signed in immediately.
typedef OnRegistrationSuccess = void Function({required bool hasSession});

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({
    required this.onRegistrationSuccess,
    required this.onNavigateToLogin,
    super.key,
  });

  final OnRegistrationSuccess onRegistrationSuccess;
  final VoidCallback onNavigateToLogin;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _getIt<RegistrationCubit>(),
      child: _RegistrationView(
        onRegistrationSuccess: onRegistrationSuccess,
        onNavigateToLogin: onNavigateToLogin,
      ),
    );
  }
}

class _RegistrationView extends StatefulWidget {
  const _RegistrationView({
    required this.onRegistrationSuccess,
    required this.onNavigateToLogin,
  });

  final OnRegistrationSuccess onRegistrationSuccess;
  final VoidCallback onNavigateToLogin;

  @override
  State<_RegistrationView> createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<_RegistrationView> {
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  UserRole _role = UserRole.staff;

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<RegistrationCubit>().register(
        RegistrationData(
          lastName: _lastNameController.text,
          firstName: _firstNameController.text,
          middleName: _middleNameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          role: _role,
        ),
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
            widget.onRegistrationSuccess(hasSession: state.hasSession);
          } else if (state is RegistrationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Фамилия',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: _requiredValidator('Введите фамилию'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'Имя',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: _requiredValidator('Введите имя'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _middleNameController,
                    decoration: const InputDecoration(
                      labelText: 'Отчество',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: _requiredValidator('Введите отчество'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: _requiredValidator('Введите email'),
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
                  const SizedBox(height: 16),
                  DropdownButtonFormField<UserRole>(
                    initialValue: _role,
                    decoration: const InputDecoration(
                      labelText: 'Роль',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final role in UserRole.values)
                        DropdownMenuItem(
                          value: role,
                          child: Text(role.label),
                        ),
                    ],
                    onChanged: state is RegistrationLoading
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _role = value);
                            }
                          },
                  ),
                  const SizedBox(height: 24),
                  if (state is RegistrationLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    AppButton(
                      text: 'Зарегистрироваться',
                      onPressed: () => _register(context),
                    ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: widget.onNavigateToLogin,
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

  String? Function(String?) _requiredValidator(String message) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      return null;
    };
  }
}
