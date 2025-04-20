import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/i_user_profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';

class CacheException implements Exception {}

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({required this.message, this.statusCode});
}

/// 用户个人资料仓库实现
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
        return Left(CacheFailure(message: '没有缓存的用户资料'));
      } catch (e) {
        return Left(GeneralFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserProfile(UserProfileUpdateData data) async {
    if (await networkInfo.isConnected) {
      try {
        final nickName = data.nickName ?? '用户';

        final updatedProfile = await remoteDataSource.updateUserProfile(
          nickName: nickName,
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
      return Left(NetworkFailure(message: '无网络连接'));
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
      return Left(NetworkFailure(message: '无网络连接'));
    }
  }
}
