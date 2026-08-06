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
  static const Duration _defaultSendCodeTimeout = Duration(seconds: 30);
  static const Duration _defaultLoginTimeout = Duration(seconds: 45);
  final Duration sendCodeTimeout;
  final Duration loginTimeout;

  SmsLoginCubit({
    required this.sendVerificationCodeUseCase,
    required this.loginWithVerificationCodeUseCase,
    this.sendCodeTimeout = _defaultSendCodeTimeout,
    this.loginTimeout = _defaultLoginTimeout,
  }) : super(SmsLoginInitial());

  Future<void> sendCode(String phone) async {
    emit(SmsLoginCodeSending());
    final params = SendVerificationCodeParams(phone: phone);
    try {
      final result = await sendVerificationCodeUseCase(params).timeout(
        sendCodeTimeout,
      );
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
    } on TimeoutException {
      AppLogger.d('Send-code use case timed out.');
      emit(const SmsLoginCodeSendFailure(
          NetworkFailure(message: '验证码请求超时，请稍后重试', code: 'TIMEOUT')));
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
      final result =
          await loginWithVerificationCodeUseCase(credentials).timeout(
        loginTimeout,
      );
      result.fold(
        (failure) => emit(SmsLoginFailure(failure)),
        (user) => emit(SmsLoginSuccess(user)),
      );
    } on TimeoutException {
      AppLogger.d('Login use case timed out.');
      emit(const SmsLoginFailure(
          NetworkFailure(message: '登录请求超时，请稍后重试', code: 'TIMEOUT')));
    } catch (error) {
      // Keep an unexpected use-case failure from leaving the button in the
      // loading state forever. Do not expose exception details to the UI.
      AppLogger.d('Login use case failed unexpectedly: ${error.runtimeType}');
      emit(const SmsLoginFailure(UnknownFailure(message: '登录失败，请稍后重试')));
    }
  }
}
