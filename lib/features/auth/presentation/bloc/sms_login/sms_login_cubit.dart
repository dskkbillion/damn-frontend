import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
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
    try {
      final result = await sendVerificationCodeUseCase(params);
      result.fold(
        (failure) => emit(SmsLoginCodeSendFailure(failure)),
        (_) {
          emit(SmsLoginCodeSentSuccess());
          Future.delayed(const Duration(seconds: _countdownSeconds), () {
            if (state is SmsLoginCodeSentSuccess) {
              AppLogger.d('Countdown finished, resetting SMS login state.');
              emit(SmsLoginInitial());
            }
          });
        },
      );
    } catch (error) {
      // Keep an unexpected send-code failure from leaving the button loading.
      AppLogger.d(
          'Send-code use case failed unexpectedly: ${error.runtimeType}');
      emit(const SmsLoginCodeSendFailure(
          UnknownFailure(message: '发送验证码失败，请稍后重试')));
    }
  }

  Future<void> login(String phone, String code) async {
    emit(SmsLoginLoading());
    final credentials = VerificationCodeCredentials(phone: phone, code: code);
    try {
      final result = await loginWithVerificationCodeUseCase(credentials);
      result.fold(
        (failure) => emit(SmsLoginFailure(failure)),
        (user) => emit(SmsLoginSuccess(user)),
      );
    } catch (error) {
      // Keep an unexpected use-case failure from leaving the button in the
      // loading state forever. Do not expose exception details to the UI.
      AppLogger.d('Login use case failed unexpectedly: ${error.runtimeType}');
      emit(const SmsLoginFailure(UnknownFailure(message: '登录失败，请稍后重试')));
    }
  }
}
