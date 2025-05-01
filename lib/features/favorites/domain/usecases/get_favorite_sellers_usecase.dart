import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/favorite_seller.dart';
import '../repositories/i_favorites_repository.dart';

/// 获取收藏的卖家列表用例
class GetFavoriteSellersUseCase implements UseCase<List<FavoriteSeller>, GetFavoriteSellersParams> {
  final IFavoritesRepository repository;

  /// 构造函数
  const GetFavoriteSellersUseCase(this.repository);

  @override
  Future<Either<Failure, List<FavoriteSeller>>> call(GetFavoriteSellersParams params) async {
    return await repository.getFavoriteSellers(
      pageNum: params.pageNum,
      pageSize: params.pageSize,
    );
  }
}

/// 获取收藏的卖家列表参数
class GetFavoriteSellersParams extends Equatable {
  /// 页码，默认为1
  final int? pageNum;
  
  /// 每页数量，默认为10
  final int? pageSize;

  /// 构造函数
  const GetFavoriteSellersParams({
    this.pageNum,
    this.pageSize,
  });

  /// 创建默认参数
  factory GetFavoriteSellersParams.defaultParams() {
    return const GetFavoriteSellersParams(
      pageNum: 1,
      pageSize: 10,
    );
  }

  @override
  List<Object?> get props => [pageNum, pageSize];
}