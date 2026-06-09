import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'models/user_profile.dart';
import 'repositories/profile_repository.dart';

part 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._profileRepository) : super(ProfileInitial()) {
    loadProfile();
  }

  final ProfileRepository _profileRepository;

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final userId = await _profileRepository.getCurrentUserId();
      if (userId == null) {
        emit(ProfileUnauthenticated());
        return;
      }

      final profile = await _profileRepository.getProfile(userId);
      if (profile == null) {
        emit(
          const ProfileFailure(
            'Профиль не найден. Попробуйте выйти и войти снова.',
          ),
        );
        return;
      }

      emit(ProfileLoaded(profile: profile));
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(ProfileLoading());
    try {
      await _profileRepository.signOut();
      emit(ProfileUnauthenticated());
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }
}
