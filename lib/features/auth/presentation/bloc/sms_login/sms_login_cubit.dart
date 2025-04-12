import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_credentials.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/usecases/login_with_verification_code.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/usecases/send_verification_code.dart';
import 'package:injectable/injectable.dart';
import 'dart:async';

import 'sms_login_state.dart';

@injectable
class SmsLoginCubit extends Cubit<SmsLoginState> {
  final SendVerificationCodeUseCase sendVerificationCodeUseCase;
  final LoginWithVerificationCodeUseCase loginWithVerificationCodeUseCase;
  static const int _countdownSeconds = 60;

  SmsLoginCubit({
    required this.sendVerificationCodeUseCase,
    required this.loginWithVerificationCodeUseCase,
  }) : super(SmsLoginInitial());

  Future<void> sendCode(String phone) async {
    emit(SmsLoginCodeSending());
    final params = SendVerificationCodeParams(phone: phone);
    final result = await sendVerificationCodeUseCase(params);
    result.fold(
      (failure) => emit(SmsLoginCodeSendFailure(failure)),
      (_) {
        emit(SmsLoginCodeSentSuccess());
        Future.delayed(const Duration(seconds: _countdownSeconds), () {
          if (state is SmsLoginCodeSentSuccess) {
            print('Countdown finished, resetting SMS login state.');
            emit(SmsLoginInitial());
          }
        });
      },
    );
  }

  Future<void> login(String phone, String code) async {
    emit(SmsLoginLoading());
    final credentials = VerificationCodeCredentials(phone: phone, code: code);
    final result = await loginWithVerificationCodeUseCase(credentials);
    result.fold(
      (failure) => emit(SmsLoginFailure(failure)),
      (user) => emit(SmsLoginSuccess(user)),
    );
  }
}
