import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/liked_story.dart';

/// 定义点赞笔记相关的数据访问接口（由 Story 模块提供实现）
abstract class ILikedStoryRepository {
  /// 获取点赞笔记列表
  ///
  /// [page] 分页页码，从 1 开始
  /// [pageSize] 每页数量
  /// 返回 [LikedStory] 列表或 [Failure]
  Future<Either<Failure, List<LikedStory>>> getLikedStories({
    int page = 1,
    int pageSize = 10,
  });
}
