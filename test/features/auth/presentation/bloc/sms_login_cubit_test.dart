import 'package:bloc_test/bloc_test.dart';
import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/authenticated_user.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/usecases/login_with_verification_code.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/usecases/send_verification_code.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/bloc/sms_login/sms_login_cubit.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/bloc/sms_login/sms_login_state.dart';
import '../../domain/usecases/login_with_verification_code_test.mocks.dart';

void main() {
  late MockIAuthRepository authRepository;

  setUp(() {
    authRepository = MockIAuthRepository();
  });

  blocTest<SmsLoginCubit, SmsLoginState>(
    'recovers from an unexpected login exception instead of staying loading',
    build: () {
      when(authRepository.loginWithVerificationCode(any)).thenAnswer(
        (_) async => throw StateError('unexpected login failure'),
      );
      return SmsLoginCubit(
        sendVerificationCodeUseCase:
            SendVerificationCodeUseCase(authRepository),
        loginWithVerificationCodeUseCase:
            LoginWithVerificationCodeUseCase(authRepository),
      );
    },
    act: (cubit) => cubit.login('test@example.com', '123456'),
    expect: () => [
      SmsLoginLoading(),
      const SmsLoginFailure(
        UnknownFailure(message: '登录失败，请稍后重试'),
      ),
    ],
  );

  blocTest<SmsLoginCubit, SmsLoginState>(
    'recovers from a login timeout instead of staying loading',
    build: () {
      final pending = Completer<Either<Failure, AuthenticatedUser>>();
      when(authRepository.loginWithVerificationCode(any))
          .thenAnswer((_) => pending.future);
      return SmsLoginCubit(
        sendVerificationCodeUseCase:
            SendVerificationCodeUseCase(authRepository),
        loginWithVerificationCodeUseCase:
            LoginWithVerificationCodeUseCase(authRepository),
        loginTimeout: const Duration(milliseconds: 20),
      );
    },
    act: (cubit) => cubit.login('test@example.com', '123456'),
    expect: () => [
      SmsLoginLoading(),
      const SmsLoginFailure(
        NetworkFailure(message: '登录请求超时，请稍后重试', code: 'TIMEOUT'),
      ),
    ],
  );

  blocTest<SmsLoginCubit, SmsLoginState>(
    'recovers from an unexpected send-code exception instead of staying loading',
    build: () {
      when(authRepository.sendVerificationCode(phone: anyNamed('phone')))
          .thenAnswer((_) async => throw StateError('unexpected send failure'));
      return SmsLoginCubit(
        sendVerificationCodeUseCase:
            SendVerificationCodeUseCase(authRepository),
        loginWithVerificationCodeUseCase:
            LoginWithVerificationCodeUseCase(authRepository),
      );
    },
    act: (cubit) => cubit.sendCode('13800138000'),
    expect: () => [
      SmsLoginCodeSending(),
      const SmsLoginCodeSendFailure(
        UnknownFailure(message: '发送验证码失败，请稍后重试'),
      ),
    ],
  );

  blocTest<SmsLoginCubit, SmsLoginState>(
    'recovers from a send-code timeout instead of staying loading',
    build: () {
      final pending = Completer<Either<Failure, void>>();
      when(authRepository.sendVerificationCode(phone: anyNamed('phone')))
          .thenAnswer((_) => pending.future);
      return SmsLoginCubit(
        sendVerificationCodeUseCase:
            SendVerificationCodeUseCase(authRepository),
        loginWithVerificationCodeUseCase:
            LoginWithVerificationCodeUseCase(authRepository),
        sendCodeTimeout: const Duration(milliseconds: 20),
      );
    },
    act: (cubit) => cubit.sendCode('13800138000'),
    expect: () => [
      SmsLoginCodeSending(),
      const SmsLoginCodeSendFailure(
        NetworkFailure(message: '验证码请求超时，请稍后重试', code: 'TIMEOUT'),
      ),
    ],
  );
}
