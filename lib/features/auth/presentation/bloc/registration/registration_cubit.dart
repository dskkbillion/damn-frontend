import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:damn_frontend/features/auth/domain/usecases/send_verification_code.dart';
import 'package:damn_frontend/features/auth/domain/usecases/register.dart'; // Import RegisterUseCase
import 'package:damn_frontend/features/auth/domain/entities/registration_details.dart';
import 'package:equatable/equatable.dart';
import 'package:damn_frontend/core/error/failures.dart';

// --- Registration State ---
part 'registration_state.dart';

class RegistrationCubit extends Cubit<RegistrationState> {
  final SendVerificationCodeUseCase sendVerificationCodeUseCase;
  final RegisterUseCase registerUseCase;

  RegistrationCubit({
    required this.sendVerificationCodeUseCase,
    required this.registerUseCase,
  }) : super(RegistrationInitial());

  Future<void> sendCode(String phone) async {
    emit(RegistrationCodeSending());
    // 调用 UseCase 时不再需要 purpose
    final params = SendVerificationCodeParams(phone: phone);
    final result = await sendVerificationCodeUseCase(params);
    result.fold(
      (failure) => emit(RegistrationCodeSendFailure(failure)),
      (_) => emit(const RegistrationCodeSentSuccess()),
    );
  }

  Future<void> register({
    required String phone,
    required String code,
    String? scene, // Optional based on final API confirmation
    String? inviterId, // Optional based on final API confirmation
  }) async {
    emit(RegistrationLoading());
    final details = RegistrationDetails(
      phone: phone,
      code: code,
      scene: scene, // Pass if needed
      inviterId: inviterId, // Pass if needed
    );
    final result = await registerUseCase(details);
    result.fold(
      (failure) => emit(RegistrationFailure(failure)),
      (_) => emit(RegistrationSuccess()), // Registration returns void on success
    );
  }
}
