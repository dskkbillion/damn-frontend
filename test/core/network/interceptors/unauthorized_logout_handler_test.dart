import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/network/interceptors/unauthorized_logout_handler.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_credentials.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_status.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/authenticated_user.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class _FakeAuthRepository implements IAuthRepository {
  int logoutCount = 0;

  @override
  Stream<AuthStatus> get authStatus => const Stream<AuthStatus>.empty();

  @override
  Either<Failure, AuthenticatedUser?> getLoggedInUserSync() =>
      const Right(null);

  @override
  Future<Either<Failure, AuthenticatedUser>> loginWithVerificationCode(
    VerificationCodeCredentials credentials,
  ) async {
    return const Left(AuthFailure(message: 'not implemented'));
  }

  @override
  Future<Either<Failure, void>> logout() async {
    logoutCount += 1;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> sendVerificationCode(
      {required String phone}) async {
    return const Left(AuthFailure(message: 'not implemented'));
  }
}

void main() {
  final getIt = GetIt.instance;

  group('UnauthorizedLogoutHandler', () {
    setUp(() async {
      await getIt.reset();
    });

    tearDown(() async {
      await getIt.reset();
    });

    test('handles HTTP 401 errors for protected endpoints', () {
      final error = DioException(
        requestOptions:
            RequestOptions(path: '/api/shop/order-refund/case-detail'),
        response: Response(
          statusCode: 401,
          requestOptions:
              RequestOptions(path: '/api/shop/order-refund/case-detail'),
        ),
      );

      expect(UnauthorizedLogoutHandler.shouldHandleError(error), isTrue);
    });

    test('ignores auth endpoints for HTTP 401 errors', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/api/auth/login'),
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: '/api/auth/login'),
        ),
      );

      expect(UnauthorizedLogoutHandler.shouldHandleError(error), isFalse);
    });

    test('handles body code 401 on protected endpoints', () {
      final response = Response(
        data: {
          'code': 401,
          'msg': '请求访问：/error，认证失败，无法访问系统资源 http://localhost:8187',
        },
        statusCode: 200,
        requestOptions:
            RequestOptions(path: '/api/shop/order-refund/case-detail'),
      );

      expect(UnauthorizedLogoutHandler.shouldHandleResponse(response), isTrue);
    });

    test('ignores auth endpoints when body code is 401', () {
      final response = Response(
        data: {'code': 401, 'msg': 'token expired'},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/api/common/send-code/login'),
      );

      expect(UnauthorizedLogoutHandler.shouldHandleResponse(response), isFalse);
    });

    test('ignores successful payloads', () {
      final response = Response(
        data: {
          'code': 200,
          'data': {'id': 1},
        },
        statusCode: 200,
        requestOptions:
            RequestOptions(path: '/api/shop/order-refund/case-detail'),
      );

      expect(UnauthorizedLogoutHandler.shouldHandleResponse(response), isFalse);
    });

    test('logs out when protected response body carries code 401', () async {
      final authRepository = _FakeAuthRepository();
      getIt.registerSingleton<IAuthRepository>(authRepository);

      final response = Response(
        data: {'code': 401, 'msg': 'token expired'},
        statusCode: 200,
        requestOptions:
            RequestOptions(path: '/api/shop/order-refund/case-detail'),
      );

      await UnauthorizedLogoutHandler.handleResponse(response);

      expect(authRepository.logoutCount, 1);
    });
  });
}
