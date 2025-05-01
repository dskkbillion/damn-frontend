import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

/// 获取卖家草稿箱商品列表参数
class GetSellerDraftListParams extends Equatable {
  /// 页码
  final int pageNum;
  
  /// 每页记录数
  final int pageSize;

  /// 构造函数
  const GetSellerDraftListParams({
    required this.pageNum,
    required this.pageSize,
  });

  @override
  List<Object> get props => [pageNum, pageSize];
}

/// 获取卖家草稿箱商品列表UseCase
@injectable
class GetSellerDraftListUseCase implements UseCase<PaginatedList<SellerManagedProduct>, GetSellerDraftListParams> {
  final ISellerRepository _sellerRepository;

  /// 构造函数
  GetSellerDraftListUseCase(this._sellerRepository);

  @override
  Future<Either<Failure, PaginatedList<SellerManagedProduct>>> call(GetSellerDraftListParams params) {
    return _sellerRepository.getSellerDraftList(
      pageNum: params.pageNum,
      pageSize: params.pageSize,
    );
  }
} 