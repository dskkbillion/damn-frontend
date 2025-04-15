import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dskk_flutter_refactor/core/platform/token_validator.dart';

import 'token_validator_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late TokenValidator tokenValidator;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    tokenValidator = TokenValidatorImpl(mockDio);
  });

  group('validateToken', () {
    // 有效Token
    test('should return valid when the token is valid', () async {
      // Arrange
      const token = 'valid.token.123';

      when(mockDio.get(
        any,
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        data: {'code': 200, 'data': {'id': 1}},
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ));

      // Act
      final result = await tokenValidator.validateToken(token);

      // Assert
      expect(result, TokenValidationResult.valid);
    });

    // 过期Token
    test('should return expired when the token is expired', () async {
      // Arrange
      const token = 'expired.token.123';

      when(mockDio.get(
        any,
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        data: {'code': 401, 'msg': 'token已过期'},
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ));

      // Act
      final result = await tokenValidator.validateToken(token);

      // Assert
      expect(result, TokenValidationResult.expired);
    });

    // 无效Token
    test('should return invalid when the token is invalid', () async {
      // Arrange
      const token = 'invalid.token';

      when(mockDio.get(
        any,
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        data: {'code': 401, 'msg': '无效的token'},
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ));

      // Act
      final result = await tokenValidator.validateToken(token);

      // Assert
      expect(result, TokenValidationResult.invalid);
    });

    // 格式错误的Token
    test('should return invalid when the token has invalid format', () async {
      // Arrange
      const token = 'invalidtoken';

      // Act
      final result = await tokenValidator.validateToken(token);

      // Assert
      expect(result, TokenValidationResult.invalid);
    });

    // 空Token
    test('should return invalid when the token is empty', () async {
      // Arrange
      const token = '';

      // Act
      final result = await tokenValidator.validateToken(token);

      // Assert
      expect(result, TokenValidationResult.invalid);
    });

    // HTTP错误
    test('should return error when there is a HTTP error', () async {
      // Arrange
      const token = 'valid.token.123';

      when(mockDio.get(
        any,
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        data: null,
        statusCode: 500,
        requestOptions: RequestOptions(path: ''),
      ));

      // Act
      final result = await tokenValidator.validateToken(token);

      // Assert
      expect(result, TokenValidationResult.error);
    });

    // 网络异常
    test('should return error when there is a network exception', () async {
      // Arrange
      const token = 'valid.token.123';

      when(mockDio.get(
        any,
        options: anyNamed('options'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'Network error',
      ));

      // Act
      final result = await tokenValidator.validateToken(token);

      // Assert
      expect(result, TokenValidationResult.error);
    });

    // 401错误
    test('should return expired when there is a 401 error', () async {
      // Arrange
      const token = 'valid.token.123';

      when(mockDio.get(
        any,
        options: anyNamed('options'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: ''),
        ),
      ));

      // Act
      final result = await tokenValidator.validateToken(token);

      // Assert
      expect(result, TokenValidationResult.expired);
    });
  });
}
