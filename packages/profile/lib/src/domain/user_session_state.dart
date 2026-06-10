part of 'user_session_cubit.dart';

sealed class UserSessionState extends Equatable {
  const UserSessionState();

  @override
  List<Object?> get props => [];
}

final class UserSessionInitial extends UserSessionState {
  const UserSessionInitial();
}

final class UserSessionLoading extends UserSessionState {
  const UserSessionLoading();
}

final class UserSessionReady extends UserSessionState {
  const UserSessionReady({required this.profile});

  final UserProfile profile;

  @override
  List<Object?> get props => [profile];
}

final class UserSessionUnauthenticated extends UserSessionState {
  const UserSessionUnauthenticated();
}

final class UserSessionFailure extends UserSessionState {
  const UserSessionFailure(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}
