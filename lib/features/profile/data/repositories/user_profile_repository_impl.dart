import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/i_user_profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart'
    show ProfileRemoteDataSource, ServerException;

/// 用户个人资料仓库实现
@Injectable(as: IUserProfileRepository)
class UserProfileRepositoryImpl implements IUserProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  UserProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserProfile>> getUserProfile() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUserProfile = await remoteDataSource.getUserProfile();
        localDataSource.cacheUserProfile(remoteUserProfile);
        return Right(remoteUserProfile.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(GeneralFailure(message: e.toString()));
      }
    } else {
      try {
        final localUserProfile = await localDataSource.getLastUserProfile();
        return Right(localUserProfile.toEntity());
      } on CacheException {
        return const Left(CacheFailure(message: '未能从本地缓存加载用户资料'));
      } catch (e) {
        return Left(GeneralFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserProfile(UserProfileUpdateData data) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedProfile = await remoteDataSource.updateUserProfile(
          nickName: data.nickName,  // 不再有默认值
          avatar: data.avatar,      // 添加头像参数
          onlineFlag: data.onlineFlag,
        );
        localDataSource.cacheUserProfile(updatedProfile);
        return Right(updatedProfile.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(GeneralFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: '无网络连接'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(File imageFile) async {
    if (await networkInfo.isConnected) {
      try {
        final avatarUrl = await remoteDataSource.uploadAvatar(
          imageFilePath: imageFile.path,
        );
        return Right(avatarUrl);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(GeneralFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: '无网络连接'));
    }
  }
}
