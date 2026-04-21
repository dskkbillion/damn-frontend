import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_credentials.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/authenticated_user.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/usecases/login_with_verification_code.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'login_with_verification_code_test.mocks.dart';

@GenerateMocks([IAuthRepository])
void main() {
  late LoginWithVerificationCodeUseCase usecase;
  late MockIAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockIAuthRepository();
    usecase = LoginWithVerificationCodeUseCase(mockAuthRepository);
  });

  const tPhone = '1234567890';
  const tCode = '123456';
  const tCredentials = VerificationCodeCredentials(phone: tPhone, code: tCode);
  const tUser = AuthenticatedUser(id: 1, token: 'abc');

  test(
    'should get authenticated user from the repository when login is successful',
    () async {
      // arrange
      when(mockAuthRepository.loginWithVerificationCode(any))
          .thenAnswer((_) async => const Right(tUser));
      // act
      final result = await usecase(tCredentials);
      // assert
      expect(result, const Right(tUser));
      verify(mockAuthRepository.loginWithVerificationCode(tCredentials));
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );

  test(
    'should return failure from the repository when login fails',
    () async {
      // arrange
      const tFailure = ServerFailure(message: 'Login Failed');
      when(mockAuthRepository.loginWithVerificationCode(any))
          .thenAnswer((_) async => const Left(tFailure));
      // act
      final result = await usecase(tCredentials);
      // assert
      expect(result, const Left(tFailure));
      verify(mockAuthRepository.loginWithVerificationCode(tCredentials));
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );
}
