import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_feature/supabase_feature.dart';

part 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._supabaseService) : super(ProfileInitial()) {
    loadProfile();
  }

  final SupabaseService _supabaseService;

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    final user = _supabaseService.client.auth.currentUser;
    if (user == null) {
      emit(ProfileUnauthenticated());
      return;
    }
    emit(ProfileLoaded(email: user.email ?? ''));
  }

  Future<void> logout() async {
    emit(ProfileLoading());
    try {
      await _supabaseService.client.auth.signOut();
      emit(ProfileUnauthenticated());
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }
}
