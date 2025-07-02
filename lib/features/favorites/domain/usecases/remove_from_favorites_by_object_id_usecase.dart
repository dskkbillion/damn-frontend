import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_favorites_repository.dart';

/// 按商品ID从收藏中移除用例
class RemoveFromFavoritesByObjectIdUseCase implements UseCase<void, RemoveFromFavoritesByObjectIdParams> {
  final IFavoritesRepository repository;

  /// 构造函数
  const RemoveFromFavoritesByObjectIdUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveFromFavoritesByObjectIdParams params) async {
    print('[Debug] 按objectId删除收藏用例: type=${params.type}, objectId=${params.objectId}');
    
    // 直接调用repository的新方法
    return await repository.removeFromFavoritesByObjectId(params.type, params.objectId);
  }
}

/// 按商品ID从收藏中移除参数
class RemoveFromFavoritesByObjectIdParams extends Equatable {
  /// 收藏类型 ('org_product' 或 'org')
  final String type;
  
  /// 商品/卖家ID
  final int objectId;

  /// 构造函数
  const RemoveFromFavoritesByObjectIdParams({
    required this.type,
    required this.objectId,
  });

  @override
  List<Object> get props => [type, objectId];
}

/// 扩展方法：为可空列表提供firstOrNull方法
extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
} 