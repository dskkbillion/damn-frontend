import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/liked_story.dart';
import '../repositories/i_liked_story_repository.dart';

/// 获取用户点赞的笔记/内容列表
class GetLikedStoriesUseCase implements UseCase<List<LikedStory>, GetLikedStoriesParams> {
  final ILikedStoryRepository repository;

  GetLikedStoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<LikedStory>>> call(GetLikedStoriesParams params) {
    return repository.getLikedStories(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

/// 获取点赞笔记列表的参数
class GetLikedStoriesParams extends Equatable {
  final int page;
  final int pageSize;

  const GetLikedStoriesParams({
    this.page = 1,
    this.pageSize = 10,
  });

  @override
  List<Object> get props => [page, pageSize];
}
