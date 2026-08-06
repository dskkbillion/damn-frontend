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
  int _operationGeneration = 0;

  SmsLoginCubit({
    required this.sendVerificationCodeUseCase,
    required this.loginWithVerificationCodeUseCase,
    this.sendCodeTimeout = _defaultSendCodeTimeout,
    this.loginTimeout = _defaultLoginTimeout,
  }) : super(SmsLoginInitial());

  Future<void> sendCode(String phone) async {
    final operationGeneration = ++_operationGeneration;
    if (isClosed) return;
    emit(SmsLoginCodeSending());
    final params = SendVerificationCodeParams(phone: phone);
    try {
      final result = await sendVerificationCodeUseCase(params).timeout(
        sendCodeTimeout,
      );
      if (!_isCurrentOperation(operationGeneration)) return;
      result.fold(
        (failure) {
          if (_isCurrentOperation(operationGeneration)) {
            emit(SmsLoginCodeSendFailure(failure));
          }
        },
        (_) {
          if (!_isCurrentOperation(operationGeneration)) return;
          emit(SmsLoginCodeSentSuccess());
          Future.delayed(const Duration(seconds: _countdownSeconds), () {
            if (_isCurrentOperation(operationGeneration) &&
                state is SmsLoginCodeSentSuccess) {
              AppLogger.d('Countdown finished, resetting SMS login state.');
              emit(SmsLoginInitial());
            }
          });
        },
      );
    } on TimeoutException {
      if (!_isCurrentOperation(operationGeneration)) return;
      AppLogger.d('Send-code use case timed out.');
      emit(const SmsLoginCodeSendFailure(
          NetworkFailure(message: '验证码请求超时，请稍后重试', code: 'TIMEOUT')));
    } catch (error) {
      if (!_isCurrentOperation(operationGeneration)) return;
      // Keep an unexpected send-code failure from leaving the button loading.
      AppLogger.d(
          'Send-code use case failed unexpectedly: ${error.runtimeType}');
      emit(const SmsLoginCodeSendFailure(
          UnknownFailure(message: '发送验证码失败，请稍后重试')));
    }
  }

  Future<void> login(String phone, String code) async {
    final operationGeneration = ++_operationGeneration;
    if (isClosed) return;
    emit(SmsLoginLoading());
    final credentials = VerificationCodeCredentials(phone: phone, code: code);
    try {
      final result =
          await loginWithVerificationCodeUseCase(credentials).timeout(
        loginTimeout,
      );
      if (!_isCurrentOperation(operationGeneration)) return;
      result.fold(
        (failure) {
          if (_isCurrentOperation(operationGeneration)) {
            emit(SmsLoginFailure(failure));
          }
        },
        (user) {
          if (_isCurrentOperation(operationGeneration)) {
            emit(SmsLoginSuccess(user));
          }
        },
      );
    } on TimeoutException {
      if (!_isCurrentOperation(operationGeneration)) return;
      AppLogger.d('Login use case timed out.');
      emit(const SmsLoginFailure(
          NetworkFailure(message: '登录请求超时，请稍后重试', code: 'TIMEOUT')));
    } catch (error) {
      if (!_isCurrentOperation(operationGeneration)) return;
      // Keep an unexpected use-case failure from leaving the button in the
      // loading state forever. Do not expose exception details to the UI.
      AppLogger.d('Login use case failed unexpectedly: ${error.runtimeType}');
      emit(const SmsLoginFailure(UnknownFailure(message: '登录失败，请稍后重试')));
    }
  }

  bool _isCurrentOperation(int generation) {
    return !isClosed && generation == _operationGeneration;
  }
}
