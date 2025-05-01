import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/enums/product_status.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

/// 更新商品状态参数
class UpdateProductStatusParams extends Equatable {
  /// 商品ID
  final int productId;
  
  /// 商品状态
  final ProductStatus status;

  /// 构造函数
  const UpdateProductStatusParams({
    required this.productId,
    required this.status,
  });

  @override
  List<Object?> get props => [productId, status];
}

/// 更新商品状态UseCase
@injectable
class UpdateProductStatusUseCase implements UseCase<bool, UpdateProductStatusParams> {
  final ISellerRepository _sellerRepository;

  /// 构造函数
  UpdateProductStatusUseCase(this._sellerRepository);

  @override
  Future<Either<Failure, bool>> call(UpdateProductStatusParams params) {
    return _sellerRepository.updateProductStatus(
      params.productId,
      params.status.value,
    );
  }
} 