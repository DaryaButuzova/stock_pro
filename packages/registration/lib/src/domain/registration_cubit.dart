import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_feature/supabase_feature.dart';

part 'registration_state.dart';

@injectable
class RegistrationCubit extends Cubit<RegistrationState> {
  RegistrationCubit(this._supabaseService) : super(RegistrationInitial());

  final SupabaseService _supabaseService;

  Future<void> register(String email, String password) async {
    emit(RegistrationLoading());
    try {
      final response = await _supabaseService.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        emit(RegistrationSuccess(hasSession: response.session != null));
      } else {
        emit(RegistrationFailure('Не удалось зарегистрироваться'));
      }
    } catch (e) {
      emit(RegistrationFailure(e.toString()));
    }
  }
}
