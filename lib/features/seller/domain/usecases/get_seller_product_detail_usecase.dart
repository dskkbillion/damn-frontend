import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

/// 获取卖家商品详情参数
class GetSellerProductDetailParams extends Equatable {
  /// 商品ID
  final int productId;

  /// 构造函数
  const GetSellerProductDetailParams({
    required this.productId,
  });

  @override
  List<Object> get props => [productId];
}

/// 获取卖家商品详情UseCase
@injectable
class GetSellerProductDetailUseCase
    implements UseCase<SellerManagedProduct, GetSellerProductDetailParams> {
  final ISellerRepository _sellerRepository;

  /// 构造函数
  GetSellerProductDetailUseCase(this._sellerRepository);

  @override
  Future<Either<Failure, SellerManagedProduct>> call(
      GetSellerProductDetailParams params) {
    return _sellerRepository.getProductDetail(params.productId);
  }
} 