import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'auth_error_messages.dart';
import 'repositories/auth_repository.dart';

part 'authorization_state.dart';

@injectable
class AuthorizationCubit extends Cubit<AuthorizationState> {
  AuthorizationCubit(this._authRepository) : super(AuthorizationInitial());

  final AuthRepository _authRepository;

  Future<void> authorization(String email, String password) async {
    emit(AuthorizationLoading());
    try {
      await _authRepository.signIn(email: email, password: password);
      emit(AuthorizationSuccess());
    } catch (e) {
      emit(AuthorizationFailure(mapSignInError(e)));
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.signOut();
      emit(AuthorizationInitial());
    } catch (e) {
      emit(AuthorizationFailure(mapSignInError(e)));
    }
  }
}
