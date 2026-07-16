import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/home_feed_item.dart';
import '../repositories/home_repository.dart';

/// 获取首页信息流的后续分页数据
class GetHomeFeedUseCase implements UseCase<List<HomeFeedItem>, HomeFeedParams> {
  final IHomeRepository repository;

  GetHomeFeedUseCase(this.repository);

  /// 执行用例，获取信息流分页数据
  /// 
  /// [params] 包含页码和每页数量
  /// 
  /// 返回 [List<HomeFeedItem>] 包含分页的信息流数据
  /// 或者返回 [Failure] 表示获取数据失败
  @override
  Future<Either<Failure, List<HomeFeedItem>>> call(HomeFeedParams params) async {
    return await repository.getHomeFeed(params.page, params.limit, seed: params.seed, feedId: params.feedId);
  }
}

/// 获取信息流分页数据的参数
class HomeFeedParams extends Equatable {
  /// 页码，从1开始
  final int page;

  /// 每页数量
  final int limit;

  /// #384 随机排序种子（loadMore 复用首屏 seed 保持分页稳定）
  final int? seed;

  /// 模型端首页推荐会话，存在时优先于旧的随机 seed 分页。
  final String? feedId;

  const HomeFeedParams({
    required this.page,
    required this.limit,
    this.seed,
    this.feedId,
  });

  HomeFeedParams copyWith({
    int? page,
    int? limit,
    int? seed,
    String? feedId,
  }) {
    return HomeFeedParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      seed: seed ?? this.seed,
      feedId: feedId ?? this.feedId,
    );
  }

  @override
  List<Object?> get props => [page, limit, seed, feedId];
}
