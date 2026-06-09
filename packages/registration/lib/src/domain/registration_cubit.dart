import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'models/registration_data.dart';
import 'repositories/registration_repository.dart';

part 'registration_state.dart';

@injectable
class RegistrationCubit extends Cubit<RegistrationState> {
  RegistrationCubit(this._registrationRepository) : super(RegistrationInitial());

  final RegistrationRepository _registrationRepository;

  Future<void> register(RegistrationData data) async {
    emit(RegistrationLoading());
    try {
      final result = await _registrationRepository.register(data);
      emit(RegistrationSuccess(hasSession: result.hasSession));
    } catch (e) {
      emit(RegistrationFailure(e.toString()));
    }
  }
}
