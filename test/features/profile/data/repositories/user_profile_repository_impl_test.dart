import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/network/network_info.dart';
import 'package:dskk_flutter_refactor/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:dskk_flutter_refactor/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:dskk_flutter_refactor/features/profile/data/models/user_profile_dto.dart';
import 'package:dskk_flutter_refactor/features/profile/data/repositories/user_profile_repository_impl.dart';
import 'package:dskk_flutter_refactor/features/profile/domain/entities/user_profile.dart';
import 'package:dskk_flutter_refactor/features/profile/domain/repositories/i_user_profile_repository.dart';

@GenerateMocks([ProfileRemoteDataSource, ProfileLocalDataSource, NetworkInfo])
import 'user_profile_repository_impl_test.mocks.dart';

void main() {
  late UserProfileRepositoryImpl repository;
  late MockProfileRemoteDataSource mockRemoteDataSource;
  late MockProfileLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockProfileRemoteDataSource();
    mockLocalDataSource = MockProfileLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = UserProfileRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  const tUserProfileDto = UserProfileDto(
    userId: '1',
    nickName: '测试用户',
    avatarUrl: 'assets/images/avatar_placeholder.png',
    onlineFlag: true,
  );

  const tUserProfile = UserProfile(
    userId: '1',
    nickName: '测试用户',
    avatarUrl: 'assets/images/avatar_placeholder.png',
    onlineFlag: true,
  );

  group('getUserProfile', () {
    test('应该检查设备是否在线', () async {
      // 安排
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getUserProfile())
          .thenAnswer((_) async => tUserProfileDto);

      // 行动
      await repository.getUserProfile();

      // 断言
      verify(mockNetworkInfo.isConnected);
    });

    group('设备在线', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('应该从远程数据源获取数据时设备在线', () async {
        // 安排
        when(mockRemoteDataSource.getUserProfile())
            .thenAnswer((_) async => tUserProfileDto);

        // 行动
        final result = await repository.getUserProfile();

        // 断言
        verify(mockRemoteDataSource.getUserProfile());
        expect(result, equals(const Right(tUserProfile)));
      });

      test('应该缓存数据到本地数据源', () async {
        // 安排
        when(mockRemoteDataSource.getUserProfile())
            .thenAnswer((_) async => tUserProfileDto);

        // 行动
        await repository.getUserProfile();

        // 断言
        verify(mockRemoteDataSource.getUserProfile());
        verify(mockLocalDataSource.cacheUserProfile(tUserProfileDto));
      });

      test('应该返回ServerFailure当远程调用失败时', () async {
        // 安排
        when(mockRemoteDataSource.getUserProfile())
            .thenThrow(ServerException(message: '服务器错误'));

        // 行动
        final result = await repository.getUserProfile();

        // 断言
        verify(mockRemoteDataSource.getUserProfile());
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, equals(Left(ServerFailure(message: '服务器错误'))));
      });
    });

    group('设备离线', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('应该从本地缓存获取数据当设备离线时', () async {
        // 安排
        when(mockLocalDataSource.getLastUserProfile())
            .thenAnswer((_) async => tUserProfileDto);

        // 行动
        final result = await repository.getUserProfile();

        // 断言
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastUserProfile());
        expect(result, equals(const Right(tUserProfile)));
      });

      test('应该返回CacheFailure当本地缓存不存在时', () async {
        // 安排
        when(mockLocalDataSource.getLastUserProfile())
            .thenThrow(CacheException(message: '没有缓存数据'));

        // 行动
        final result = await repository.getUserProfile();

        // 断言
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastUserProfile());
        expect(result, equals(Left(CacheFailure(message: '没有缓存的用户资料'))));
      });
    });
  });
}
