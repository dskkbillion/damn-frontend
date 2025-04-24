import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/favorite_service.dart';
import '../repositories/i_favorites_repository.dart';

/// 获取收藏的服务列表用例
class GetFavoriteServicesUseCase implements UseCase<List<FavoriteService>, GetFavoriteServicesParams> {
  final IFavoritesRepository repository;

  /// 构造函数
  const GetFavoriteServicesUseCase(this.repository);

  @override
  Future<Either<Failure, List<FavoriteService>>> call(GetFavoriteServicesParams params) async {
    return await repository.getFavoriteServices(
      pageNum: params.pageNum,
      pageSize: params.pageSize,
    );
  }
}

/// 获取收藏的服务列表参数
class GetFavoriteServicesParams extends Equatable {
  /// 页码，默认为1
  final int? pageNum;
  
  /// 每页数量，默认为10
  final int? pageSize;

  /// 构造函数
  const GetFavoriteServicesParams({
    this.pageNum,
    this.pageSize,
  });

  /// 创建默认参数
  factory GetFavoriteServicesParams.defaultParams() {
    return const GetFavoriteServicesParams(
      pageNum: 1,
      pageSize: 10,
    );
  }

  @override
  List<Object?> get props => [pageNum, pageSize];
}