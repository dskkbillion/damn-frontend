import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

/// 删除商品参数
class DeleteProductParams extends Equatable {
  /// 商品ID列表
  final List<int> productIds;

  /// 构造函数
  const DeleteProductParams({
    required this.productIds,
  });

  @override
  List<Object> get props => [productIds];
}

/// 删除商品UseCase
@injectable
class DeleteProductUseCase implements UseCase<bool, DeleteProductParams> {
  final ISellerRepository _sellerRepository;

  /// 构造函数
  DeleteProductUseCase(this._sellerRepository);

  @override
  Future<Either<Failure, bool>> call(DeleteProductParams params) {
    return _sellerRepository.deleteProduct(params.productIds);
  }
} 