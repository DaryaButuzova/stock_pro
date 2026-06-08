part of 'profile_cubit.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

final class ProfileUnauthenticated extends ProfileState {}

final class ProfileFailure extends ProfileState {
  const ProfileFailure(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}
