import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

/// 获取卖家售后审核列表参数
class GetTenantAuditListParams extends Equatable {
  /// 页码
  final int pageNum;
  
  /// 每页记录数
  final int pageSize;

  /// 构造函数
  const GetTenantAuditListParams({
    required this.pageNum,
    required this.pageSize,
  });

  @override
  List<Object> get props => [pageNum, pageSize];
}

/// 获取卖家售后审核列表UseCase
@injectable
class GetTenantAuditListUseCase
    implements UseCase<PaginatedList<OrderRefund>, GetTenantAuditListParams> {
  final ISellerRepository _sellerRepository;

  /// 构造函数
  GetTenantAuditListUseCase(this._sellerRepository);

  @override
  Future<Either<Failure, PaginatedList<OrderRefund>>> call(
      GetTenantAuditListParams params) {
    return _sellerRepository.getTenantAuditList(
      pageNum: params.pageNum,
      pageSize: params.pageSize,
    );
  }
} 