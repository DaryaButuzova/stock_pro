import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:profile_feature/profile_feature.dart';

import 'models/registration_data.dart';
import 'repositories/registration_repository.dart';

part 'registration_state.dart';

@injectable
class RegistrationCubit extends Cubit<RegistrationState> {
  RegistrationCubit(
    this._registrationRepository,
    this._profileRepository,
  ) : super(RegistrationInitial());

  final RegistrationRepository _registrationRepository;
  final ProfileRepository _profileRepository;

  Future<void> register(RegistrationData data) async {
    emit(RegistrationLoading());
    try {
      final result = await _registrationRepository.register(data);

      if (result.hasSession) {
        await _profileRepository.createProfile(
          userId: result.userId,
          creds: data.creds,
          email: data.email.trim(),
          password: data.password,
          role: data.role.value,
        );
      }

      emit(RegistrationSuccess(hasSession: result.hasSession));
    } catch (e) {
      emit(RegistrationFailure(e.toString()));
    }
  }
}
