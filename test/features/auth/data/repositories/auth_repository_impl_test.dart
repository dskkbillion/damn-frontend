import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:damn_frontend/core/error/exceptions.dart';
import 'package:damn_frontend/core/error/failures.dart';
import 'package:damn_frontend/core/network/network_info.dart';
import 'package:damn_frontend/core/storage/secure_storage_repository.dart';

import 'package:damn_frontend/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:damn_frontend/features/auth/data/models/authenticated_user_model.dart';
import 'package:damn_frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:damn_frontend/features/auth/domain/entities/auth_credentials.dart';
import 'package:damn_frontend/features/auth/domain/entities/authenticated_user.dart';
import 'package:damn_frontend/features/auth/domain/entities/user_info.dart';
import 'package:damn_frontend/features/auth/domain/repositories/i_user_info_repository.dart';

// 生成 Mock 文件命令: flutter pub run build_runner build --delete-conflicting-outputs
@GenerateMocks([
  AuthRemoteDataSource,
  IUserInfoRepository,
  ISecureStorageRepository,
  NetworkInfo,
])
import 'auth_repository_impl_test.mocks.dart'; // 需要生成 mocks 文件

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockIUserInfoRepository mockUserInfoRepository;
  late MockISecureStorageRepository mockSecureStorage;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockUserInfoRepository = MockIUserInfoRepository();
    mockSecureStorage = MockISecureStorageRepository();
    mockNetworkInfo = MockNetworkInfo();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      userInfoRepository: mockUserInfoRepository,
      secureStorage: mockSecureStorage,
      networkInfo: mockNetworkInfo,
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

}
