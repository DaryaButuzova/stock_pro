import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_feature/supabase_feature.dart';

part 'authorization_state.dart';

@injectable
class AuthorizationCubit extends Cubit<AuthorizationState> {
  final SupabaseService _supabaseService;

  AuthorizationCubit(this._supabaseService) : super(AuthorizationInitial());

  Future<void> authorization(String email, String password) async {
    emit(AuthorizationLoading());
    try {
      final response = await _supabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        emit(AuthorizationSuccess());
      } else {
        emit(AuthorizationFailure('Не удалось войти'));
      }
    } catch (e) {
      emit(AuthorizationFailure(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await _supabaseService.client.auth.signOut();
      emit(AuthorizationInitial());
    } catch (e) {
      emit(AuthorizationFailure(e.toString()));
    }
  }
}
