import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

/// 获取卖家商品列表参数
class GetSellerProductListParams extends Equatable {
  /// 页码
  final int pageNum;
  
  /// 每页记录数
  final int pageSize;
  
  /// 状态筛选
  final String? state;

  /// 构造函数
  const GetSellerProductListParams({
    required this.pageNum,
    required this.pageSize,
    this.state,
  });

  @override
  List<Object?> get props => [pageNum, pageSize, state];
}

/// 获取卖家商品列表UseCase
@injectable
class GetSellerProductListUseCase
    implements UseCase<PaginatedList<SellerManagedProduct>, GetSellerProductListParams> {
  final ISellerRepository _sellerRepository;

  /// 构造函数
  GetSellerProductListUseCase(this._sellerRepository);

  @override
  Future<Either<Failure, PaginatedList<SellerManagedProduct>>> call(
      GetSellerProductListParams params) {
    return _sellerRepository.getSellerProductList(
      pageNum: params.pageNum,
      pageSize: params.pageSize,
      state: params.state,
    );
  }
} 