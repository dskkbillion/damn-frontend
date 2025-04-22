import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_favorites_repository.dart';

/// 添加收藏用例
class AddToFavoritesUseCase implements UseCase<void, AddToFavoritesParams> {
  final IFavoritesRepository repository;

  /// 构造函数
  const AddToFavoritesUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddToFavoritesParams params) async {
    return await repository.addToFavorites(
      params.type,
      params.objectId,
      params.feature,
    );
  }
}

/// 添加收藏参数
class AddToFavoritesParams extends Equatable {
  /// 收藏类型，如"org_product"（服务项目）、"org"（服务机构/卖家）等
  final String type;
  
  /// 收藏对象ID
  final int objectId;
  
  /// 收藏对象的特征信息（可选）
  final Map<String, dynamic>? feature;

  /// 构造函数
  const AddToFavoritesParams({
    required this.type,
    required this.objectId,
    this.feature,
  });

  /// 创建服务收藏参数
  factory AddToFavoritesParams.service(int serviceId) {
    return AddToFavoritesParams(
      type: 'org_product',
      objectId: serviceId,
    );
  }

  /// 创建卖家收藏参数
  factory AddToFavoritesParams.seller(int sellerId) {
    return AddToFavoritesParams(
      type: 'org',
      objectId: sellerId,
    );
  }

  @override
  List<Object?> get props => [type, objectId, feature];
}