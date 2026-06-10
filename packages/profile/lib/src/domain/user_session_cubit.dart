import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'models/user_profile.dart';
import 'repositories/profile_repository.dart';

part 'user_session_state.dart';

/// Loads the signed-in user profile once for the authorized shell.
@injectable
class UserSessionCubit extends Cubit<UserSessionState> {
  UserSessionCubit(this._profileRepository) : super(const UserSessionInitial()) {
    load();
  }

  final ProfileRepository _profileRepository;

  Future<void> load() async {
    emit(const UserSessionLoading());
    try {
      final userId = await _profileRepository.getCurrentUserId();
      if (userId == null) {
        emit(const UserSessionUnauthenticated());
        return;
      }

      final profile = await _profileRepository.getProfile(userId);
      if (profile == null) {
        emit(
          const UserSessionFailure(
            'Профиль не найден. Попробуйте выйти и войти снова.',
          ),
        );
        return;
      }

      emit(UserSessionReady(profile: profile));
    } catch (e) {
      emit(UserSessionFailure(e.toString()));
    }
  }
}
