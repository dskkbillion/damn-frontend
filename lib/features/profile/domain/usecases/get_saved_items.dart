import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/saved_item.dart';
import '../repositories/i_saved_item_repository.dart';

/// 获取用户收藏的服务或商品列表
class GetSavedItemsUseCase implements UseCase<List<SavedItem>, GetSavedItemsParams> {
  final ISavedItemRepository repository;

  GetSavedItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<SavedItem>>> call(GetSavedItemsParams params) {
    return repository.getSavedItems(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

/// 获取收藏列表的参数
class GetSavedItemsParams extends Equatable {
  final int page;
  final int pageSize;

  const GetSavedItemsParams({
    this.page = 1,
    this.pageSize = 10,
  });

  @override
  List<Object> get props => [page, pageSize];
}
