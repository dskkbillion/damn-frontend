import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:dskk_flutter_refactor/core/error/exceptions.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/platform/network_info.dart';
import 'package:dskk_flutter_refactor/core/storage/secure_storage_repository.dart';

import 'package:dskk_flutter_refactor/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:dskk_flutter_refactor/features/auth/data/models/authenticated_user_model.dart';
import 'package:dskk_flutter_refactor/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_credentials.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/authenticated_user.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/user_info.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_user_info_repository.dart';
import 'package:dskk_flutter_refactor/core/platform/token_validator.dart';

import 'auth_repository_impl_test.mocks.dart'; // 导入生成的mock文件

@GenerateMocks([
  AuthRemoteDataSource,
  IUserInfoRepository,
  ISecureStorageRepository,
  NetworkInfo,
  TokenValidator,
])
void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockIUserInfoRepository mockUserInfoRepository;
  late MockISecureStorageRepository mockSecureStorage;
  late MockNetworkInfo mockNetworkInfo;
  late MockTokenValidator mockTokenValidator;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockUserInfoRepository = MockIUserInfoRepository();
    mockSecureStorage = MockISecureStorageRepository();
    mockNetworkInfo = MockNetworkInfo();
    mockTokenValidator = MockTokenValidator();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      userInfoRepository: mockUserInfoRepository,
      secureStorage: mockSecureStorage,
      networkInfo: mockNetworkInfo,
      tokenValidator: mockTokenValidator,
    );

    // Mock _initializeAuthStatus to avoid interference during login tests
    // We assume it reads null initially for simplicity in login tests
    when(mockSecureStorage.getInt(any)).thenAnswer((_) async => null);
    when(mockSecureStorage.getString(any)).thenAnswer((_) async => null);
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      body();
    });
  }

  void runTestsOffline(Function body) {
     group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      body();
    });
  }

  group('loginWithVerificationCode', () {
    const tPhone = '1234567890';
    const tCode = '123456';
    const tCredentials = VerificationCodeCredentials(phone: tPhone, code: tCode);
    const tToken = 'sample_token';
    const tUserId = 101;
    final tAuthenticatedUserModel = AuthenticatedUserModel(token: tToken, code: 200); // 假设有 code
    final tUserInfo = UserInfo(id: tUserId, mobile: tPhone, nickName: 'Test User');
    final tAuthenticatedUser = AuthenticatedUser(id: tUserId, token: tToken);

    runTestsOnline(() {
      test(
        'should return AuthenticatedUser when all calls are successful',
        () async {
          // arrange
          when(mockRemoteDataSource.loginWithVerificationCode(any))
              .thenAnswer((_) async => tAuthenticatedUserModel);
          when(mockUserInfoRepository.fetchUserInfo(tToken))
              .thenAnswer((_) async => Right(tUserInfo));
          when(mockSecureStorage.saveInt('user_id', tUserId)).thenAnswer((_) async => Future.value());
          when(mockSecureStorage.saveString('auth_token', tToken)).thenAnswer((_) async => Future.value());
          // act
          final result = await repository.loginWithVerificationCode(tCredentials);
          // assert
          expect(result, Right(tAuthenticatedUser));
          verify(mockRemoteDataSource.loginWithVerificationCode(tCredentials));
          verify(mockUserInfoRepository.fetchUserInfo(tToken));
          verify(mockSecureStorage.saveInt('user_id', tUserId));
          verify(mockSecureStorage.saveString('auth_token', tToken));
          verifyNoMoreInteractions(mockRemoteDataSource);
          verifyNoMoreInteractions(mockUserInfoRepository);
          // Allow interactions with secure storage from _initializeAuthStatus in setUp
          // verifyNoMoreInteractions(mockSecureStorage);
        },
      );

      test(
        'should return ServerFailure when login remote call fails',
        () async {
          // arrange
          when(mockRemoteDataSource.loginWithVerificationCode(any))
              .thenThrow(ServerException(message: 'Login failed'));
          // act
          final result = await repository.loginWithVerificationCode(tCredentials);
          // assert
          expect(result, Left(ServerFailure(message: 'Login failed')));
          verify(mockRemoteDataSource.loginWithVerificationCode(tCredentials));
          verifyNoMoreInteractions(mockUserInfoRepository);
          verifyNoMoreInteractions(mockSecureStorage);
        },
      );

       test(
        'should return ServerFailure when fetchUserInfo call fails',
        () async {
          // arrange
          when(mockRemoteDataSource.loginWithVerificationCode(any))
              .thenAnswer((_) async => tAuthenticatedUserModel);
          when(mockUserInfoRepository.fetchUserInfo(tToken))
              .thenAnswer((_) async => Left(ServerFailure(message: 'Fetch user failed')));
          // act
          final result = await repository.loginWithVerificationCode(tCredentials);
          // assert
          expect(result, Left(ServerFailure(message: 'Fetch user failed')));
          verify(mockRemoteDataSource.loginWithVerificationCode(tCredentials));
          verify(mockUserInfoRepository.fetchUserInfo(tToken));
          verifyNoMoreInteractions(mockSecureStorage); // Storage should not be called if fetch fails
        },
      );

      test(
        'should return CacheFailure when saving credentials fails',
        () async {
          // arrange
          when(mockRemoteDataSource.loginWithVerificationCode(any))
              .thenAnswer((_) async => tAuthenticatedUserModel);
          when(mockUserInfoRepository.fetchUserInfo(tToken))
              .thenAnswer((_) async => Right(tUserInfo));
          when(mockSecureStorage.saveInt(any, any))
              .thenThrow(CacheException(message: 'Save failed'));
           // Assume saveString would also fail or not be reached, test focuses on the first failure
          // act
          final result = await repository.loginWithVerificationCode(tCredentials);
          // assert
          // It returns Left, but the user state in memory might be updated.
          expect(result, Left(CacheFailure(message: 'Login succeeded but failed to save credentials.')));
          verify(mockRemoteDataSource.loginWithVerificationCode(tCredentials));
          verify(mockUserInfoRepository.fetchUserInfo(tToken));
          verify(mockSecureStorage.saveInt('user_id', tUserId));
          // Depending on exact implementation, saveString might or might not be called
          // verify(mockSecureStorage.saveString('auth_token', tToken));
        },
      );

    });

    runTestsOffline(() {
       test(
        'should return NetworkFailure when device is offline',
        () async {
          // act
          final result = await repository.loginWithVerificationCode(tCredentials);
          // assert
          expect(result, Left(NetworkFailure()));
          verifyNoMoreInteractions(mockRemoteDataSource);
          verifyNoMoreInteractions(mockUserInfoRepository);
          verifyNoMoreInteractions(mockSecureStorage);
        },
      );
    });
  });

  group('logout', () {
     test(
        'should clear secure storage and return Right(null)',
        () async {
          // arrange
          when(mockSecureStorage.delete('user_id')).thenAnswer((_) async => Future.value());
          when(mockSecureStorage.delete('auth_token')).thenAnswer((_) async => Future.value());
          // act
          final result = await repository.logout();
          // assert
          expect(result, const Right(null));
          verify(mockSecureStorage.delete('user_id'));
          verify(mockSecureStorage.delete('auth_token'));
          verifyNoMoreInteractions(mockSecureStorage);
        },
      );

      test(
        'should return Right(null) even if clearing storage fails',
        () async {
          // arrange
           when(mockSecureStorage.delete(any)).thenThrow(CacheException());
          // act
          final result = await repository.logout();
          // assert
          expect(result, const Right(null));
          verify(mockSecureStorage.delete('user_id'));
          verify(mockSecureStorage.delete('auth_token')); // Both should be attempted
        },
      );
  });

  // TODO: Add tests for sendVerificationCode
  // TODO: Add tests for _initializeAuthStatus (might need separate setup)
  // TODO: Add tests for getLoggedInUserSync

  group('sendVerificationCode', () {
    const tPhone = '1234567890';

    runTestsOnline(() {
      test(
        'should call remoteDataSource.sendVerificationCode when successful',
        () async {
          // arrange
          when(mockRemoteDataSource.sendVerificationCode(phone: anyNamed('phone')))
              .thenAnswer((_) async => Future.value());
          // act
          final result = await repository.sendVerificationCode(phone: tPhone);
          // assert
          expect(result, const Right(null));
          verify(mockRemoteDataSource.sendVerificationCode(phone: tPhone));
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );

      test(
        'should return ServerFailure when remoteDataSource throws ServerException',
        () async {
          // arrange
          when(mockRemoteDataSource.sendVerificationCode(phone: anyNamed('phone')))
              .thenThrow(ServerException(message: 'Failed to send code'));
          // act
          final result = await repository.sendVerificationCode(phone: tPhone);
          // assert
          expect(result, Left(ServerFailure(message: 'Failed to send code')));
          verify(mockRemoteDataSource.sendVerificationCode(phone: tPhone));
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );
    });

     runTestsOffline(() {
       test(
        'should return NetworkFailure when device is offline',
        () async {
          // act
          final result = await repository.sendVerificationCode(phone: tPhone);
          // assert
          expect(result, Left(NetworkFailure()));
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );
    });

  });

  group('_initializeAuthStatus', () {
    const tUserId = 123;
    const tToken = 'test.token.123';
    final tAuthenticatedUser = AuthenticatedUser(id: tUserId, token: tToken);

    test('should initialize with Authenticated status when token is valid', () async {
      // Arrange - Mock all the calls used in _initializeAuthStatus
      when(mockSecureStorage.getInt('user_id')).thenAnswer((_) async => tUserId);
      when(mockSecureStorage.getString('auth_token')).thenAnswer((_) async => tToken);
      when(mockTokenValidator.validateToken(tToken))
          .thenAnswer((_) async => TokenValidationResult.valid);

      // Act - Create a new repository instance to trigger _initializeAuthStatus
      final repo = AuthRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        networkInfo: mockNetworkInfo,
        secureStorage: mockSecureStorage,
        userInfoRepository: mockUserInfoRepository,
        tokenValidator: mockTokenValidator,
      );

      // Assert - Get the first emitted status
      final authStatus = await repo.authStatus.first;
      expect(authStatus, isA<Authenticated>());
      if (authStatus is Authenticated) {
        expect(authStatus.user.id, equals(tUserId));
        expect(authStatus.user.token, equals(tToken));
      }

      // Verify
      verify(mockSecureStorage.getInt('user_id'));
      verify(mockSecureStorage.getString('auth_token'));
      verify(mockTokenValidator.validateToken(tToken));
    });

    test('should initialize with Unauthenticated status when token is expired', () async {
      // Arrange
      when(mockSecureStorage.getInt('user_id')).thenAnswer((_) async => tUserId);
      when(mockSecureStorage.getString('auth_token')).thenAnswer((_) async => tToken);
      when(mockTokenValidator.validateToken(tToken))
          .thenAnswer((_) async => TokenValidationResult.expired);
      when(mockSecureStorage.delete('user_id')).thenAnswer((_) async => Future.value());
      when(mockSecureStorage.delete('auth_token')).thenAnswer((_) async => Future.value());

      // Act
      final repo = AuthRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        networkInfo: mockNetworkInfo,
        secureStorage: mockSecureStorage,
        userInfoRepository: mockUserInfoRepository,
        tokenValidator: mockTokenValidator,
      );

      // Assert
      final authStatus = await repo.authStatus.first;
      expect(authStatus, isA<Unauthenticated>());

      // Verify
      verify(mockSecureStorage.getInt('user_id'));
      verify(mockSecureStorage.getString('auth_token'));
      verify(mockTokenValidator.validateToken(tToken));
      verify(mockSecureStorage.delete('user_id'));
      verify(mockSecureStorage.delete('auth_token'));
    });

    test('should initialize with Unauthenticated status when token is invalid', () async {
      // Arrange
      when(mockSecureStorage.getInt('user_id')).thenAnswer((_) async => tUserId);
      when(mockSecureStorage.getString('auth_token')).thenAnswer((_) async => tToken);
      when(mockTokenValidator.validateToken(tToken))
          .thenAnswer((_) async => TokenValidationResult.invalid);
      when(mockSecureStorage.delete('user_id')).thenAnswer((_) async => Future.value());
      when(mockSecureStorage.delete('auth_token')).thenAnswer((_) async => Future.value());

      // Act
      final repo = AuthRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        networkInfo: mockNetworkInfo,
        secureStorage: mockSecureStorage,
        userInfoRepository: mockUserInfoRepository,
        tokenValidator: mockTokenValidator,
      );

      // Assert
      final authStatus = await repo.authStatus.first;
      expect(authStatus, isA<Unauthenticated>());

      // Verify
      verify(mockSecureStorage.getInt('user_id'));
      verify(mockSecureStorage.getString('auth_token'));
      verify(mockTokenValidator.validateToken(tToken));
      verify(mockSecureStorage.delete('user_id'));
      verify(mockSecureStorage.delete('auth_token'));
    });

    test('should assume token is valid when validation encounters an error', () async {
      // Arrange
      when(mockSecureStorage.getInt('user_id')).thenAnswer((_) async => tUserId);
      when(mockSecureStorage.getString('auth_token')).thenAnswer((_) async => tToken);
      when(mockTokenValidator.validateToken(tToken))
          .thenAnswer((_) async => TokenValidationResult.error);

      // Act
      final repo = AuthRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        networkInfo: mockNetworkInfo,
        secureStorage: mockSecureStorage,
        userInfoRepository: mockUserInfoRepository,
        tokenValidator: mockTokenValidator,
      );

      // Assert
      final authStatus = await repo.authStatus.first;
      expect(authStatus, isA<Authenticated>());

      // Verify
      verify(mockSecureStorage.getInt('user_id'));
      verify(mockSecureStorage.getString('auth_token'));
      verify(mockTokenValidator.validateToken(tToken));
    });

    test('should initialize with Unauthenticated status when no token is found', () async {
      // Arrange
      when(mockSecureStorage.getInt('user_id')).thenAnswer((_) async => null);
      when(mockSecureStorage.getString('auth_token')).thenAnswer((_) async => null);
      when(mockSecureStorage.delete('user_id')).thenAnswer((_) async => Future.value());
      when(mockSecureStorage.delete('auth_token')).thenAnswer((_) async => Future.value());

      // Act
      final repo = AuthRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        networkInfo: mockNetworkInfo,
        secureStorage: mockSecureStorage,
        userInfoRepository: mockUserInfoRepository,
        tokenValidator: mockTokenValidator,
      );

      // Assert
      final authStatus = await repo.authStatus.first;
      expect(authStatus, isA<Unauthenticated>());

      // Verify
      verify(mockSecureStorage.getInt('user_id'));
      verify(mockSecureStorage.getString('auth_token'));
      verify(mockSecureStorage.delete('user_id'));
      verify(mockSecureStorage.delete('auth_token'));
      verifyZeroInteractions(mockTokenValidator); // 没有token就不会验证
    });

    test('should initialize with Unauthenticated status when storage throws an exception', () async {
      // Arrange
      when(mockSecureStorage.getInt('user_id')).thenThrow(Exception('Storage error'));
      when(mockSecureStorage.delete('user_id')).thenAnswer((_) async => Future.value());
      when(mockSecureStorage.delete('auth_token')).thenAnswer((_) async => Future.value());

      // Act
      final repo = AuthRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        networkInfo: mockNetworkInfo,
        secureStorage: mockSecureStorage,
        userInfoRepository: mockUserInfoRepository,
        tokenValidator: mockTokenValidator,
      );

      // Assert
      final authStatus = await repo.authStatus.first;
      expect(authStatus, isA<Unauthenticated>());

      // Verify
      verify(mockSecureStorage.getInt('user_id'));
      verify(mockSecureStorage.delete('user_id'));
      verify(mockSecureStorage.delete('auth_token'));
      verifyZeroInteractions(mockTokenValidator); // 出错就不会验证
    });
  });
}
