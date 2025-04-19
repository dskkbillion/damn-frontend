import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/platform/token_validator.dart';
import 'package:dskk_flutter_refactor/core/usecases/validate_token_usecase.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';

import 'validate_token_usecase_test.mocks.dart';

@GenerateMocks([TokenValidator])
void main() {
  late ValidateTokenUseCase useCase;
  late MockTokenValidator mockTokenValidator;

  setUp(() {
    mockTokenValidator = MockTokenValidator();
    useCase = ValidateTokenUseCase(mockTokenValidator);
  });

  const tToken = 'test.token.123';
  final tParams = ValidateTokenParams(tToken);

  test('should return true when token is valid', () async {
    // Arrange
    when(mockTokenValidator.validateToken(tToken))
        .thenAnswer((_) async => TokenValidationResult.valid);

    // Act
    final result = await useCase(tParams);

    // Assert
    expect(result, const Right(true));
    verify(mockTokenValidator.validateToken(tToken));
    verifyNoMoreInteractions(mockTokenValidator);
  });

  test('should return AuthenticationFailure when token is expired', () async {
    // Arrange
    when(mockTokenValidator.validateToken(tToken))
        .thenAnswer((_) async => TokenValidationResult.expired);

    // Act
    final result = await useCase(tParams);

    // Assert
    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure, isA<AuthenticationFailure>()),
      (_) => fail('Should return a failure'),
    );
    verify(mockTokenValidator.validateToken(tToken));
    verifyNoMoreInteractions(mockTokenValidator);
  });

  test('should return AuthenticationFailure when token is invalid', () async {
    // Arrange
    when(mockTokenValidator.validateToken(tToken))
        .thenAnswer((_) async => TokenValidationResult.invalid);

    // Act
    final result = await useCase(tParams);

    // Assert
    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure, isA<AuthenticationFailure>()),
      (_) => fail('Should return a failure'),
    );
    verify(mockTokenValidator.validateToken(tToken));
    verifyNoMoreInteractions(mockTokenValidator);
  });

  test('should return ServerFailure when there is an error validating token', () async {
    // Arrange
    when(mockTokenValidator.validateToken(tToken))
        .thenAnswer((_) async => TokenValidationResult.error);

    // Act
    final result = await useCase(tParams);

    // Assert
    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure, isA<ServerFailure>()),
      (_) => fail('Should return a failure'),
    );
    verify(mockTokenValidator.validateToken(tToken));
    verifyNoMoreInteractions(mockTokenValidator);
  });

  test('should return UnknownFailure when an exception is thrown', () async {
    // Arrange
    when(mockTokenValidator.validateToken(tToken))
        .thenThrow(Exception('Unexpected error'));

    // Act
    final result = await useCase(tParams);

    // Assert
    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure, isA<UnknownFailure>()),
      (_) => fail('Should return a failure'),
    );
    verify(mockTokenValidator.validateToken(tToken));
    verifyNoMoreInteractions(mockTokenValidator);
  });
}
