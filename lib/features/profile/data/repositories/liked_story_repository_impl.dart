import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/liked_story.dart';
import '../../domain/repositories/i_liked_story_repository.dart';
import '../datasources/profile_remote_data_source.dart';

/// 点赞笔记仓库实现
class LikedStoryRepositoryImpl implements ILikedStoryRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  LikedStoryRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<LikedStory>>> getLikedStories({
    int page = 1,
    int pageSize = 10,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final likedStories = await remoteDataSource.getLikedStories(
          page: page,
          pageSize: pageSize,
        );
        return Right(likedStories.map((story) => story.toEntity()).toList());
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
