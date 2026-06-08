part of 'registration_cubit.dart';

sealed class RegistrationState extends Equatable {
  const RegistrationState();

  @override
  List<Object?> get props => [];
}

final class RegistrationInitial extends RegistrationState {}

final class RegistrationLoading extends RegistrationState {}

final class RegistrationSuccess extends RegistrationState {
  const RegistrationSuccess({required this.hasSession});

  final bool hasSession;

  @override
  List<Object?> get props => [hasSession];
}

final class RegistrationFailure extends RegistrationState {
  const RegistrationFailure(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}
