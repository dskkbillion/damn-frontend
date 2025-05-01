import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_favorites_repository.dart';

/// 从收藏中移除用例
class RemoveFromFavoritesUseCase implements UseCase<void, RemoveFromFavoritesParams> {
  final IFavoritesRepository repository;

  /// 构造函数
  const RemoveFromFavoritesUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveFromFavoritesParams params) async {
    return await repository.removeFromFavorites(params.favoriteIds);
  }
}

/// 从收藏中移除参数
class RemoveFromFavoritesParams extends Equatable {
  /// 收藏记录ID列表
  final List<int> favoriteIds;

  /// 构造函数
  const RemoveFromFavoritesParams({
    required this.favoriteIds,
  });

  /// 创建单个收藏ID参数
  factory RemoveFromFavoritesParams.single(int favoriteId) {
    return RemoveFromFavoritesParams(favoriteIds: [favoriteId]);
  }

  /// 创建多个收藏ID参数
  factory RemoveFromFavoritesParams.multiple(List<int> favoriteIds) {
    return RemoveFromFavoritesParams(favoriteIds: favoriteIds);
  }

  @override
  List<Object> get props => [favoriteIds];
}