import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_favorites_repository.dart';

/// 检查对象是否已收藏用例
class CheckIsFavoriteUseCase implements UseCase<Map<int, bool>, CheckIsFavoriteParams> {
  final IFavoritesRepository repository;

  /// 构造函数
  const CheckIsFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, Map<int, bool>>> call(CheckIsFavoriteParams params) async {
    return await repository.checkIsFavorite(
      params.type,
      params.objectIds,
    );
  }
}

/// 检查对象是否已收藏参数
class CheckIsFavoriteParams extends Equatable {
  /// 收藏类型，如"org_product"（服务项目）、"org"（服务机构/卖家）等
  final String type;
  
  /// 收藏对象ID列表
  final List<int> objectIds;

  /// 构造函数
  const CheckIsFavoriteParams({
    required this.type,
    required this.objectIds,
  });

  /// 创建检查服务是否已收藏参数
  factory CheckIsFavoriteParams.services(List<int> serviceIds) {
    return CheckIsFavoriteParams(
      type: 'org_product',
      objectIds: serviceIds,
    );
  }

  /// 创建检查单个服务是否已收藏参数
  factory CheckIsFavoriteParams.singleService(int serviceId) {
    return CheckIsFavoriteParams(
      type: 'org_product',
      objectIds: [serviceId],
    );
  }

  /// 创建检查卖家是否已收藏参数
  factory CheckIsFavoriteParams.sellers(List<int> sellerIds) {
    return CheckIsFavoriteParams(
      type: 'org',
      objectIds: sellerIds,
    );
  }

  /// 创建检查单个卖家是否已收藏参数
  factory CheckIsFavoriteParams.singleSeller(int sellerId) {
    return CheckIsFavoriteParams(
      type: 'org',
      objectIds: [sellerId],
    );
  }

  @override
  List<Object> get props => [type, objectIds];
}