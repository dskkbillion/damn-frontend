import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

/// 售后审核状态
enum RefundAuditState {
  /// 审核通过
  pass('AUDIT_PASS', '通过'),
  
  /// 审核拒绝
  reject('AUDIT_REJECT', '拒绝');

  /// API值
  final String value;
  
  /// 显示名称
  final String displayName;

  const RefundAuditState(this.value, this.displayName);
}

/// 审核售后申请参数
class AuditRefundParams extends Equatable {
  /// 售后ID
  final int id;
  
  /// 审核状态
  final RefundAuditState state;
  
  /// 审核备注
  final String? auditRemark;

  /// 构造函数
  const AuditRefundParams({
    required this.id,
    required this.state,
    this.auditRemark,
  });

  @override
  List<Object?> get props => [id, state, auditRemark];
}

/// 审核售后申请UseCase
@injectable
class AuditRefundUseCase implements UseCase<bool, AuditRefundParams> {
  final ISellerRepository _sellerRepository;

  /// 构造函数
  AuditRefundUseCase(this._sellerRepository);

  @override
  Future<Either<Failure, bool>> call(AuditRefundParams params) {
    return _sellerRepository.auditRefund(
      id: params.id,
      refundState: params.state.value,
      auditRemark: params.auditRemark,
    );
  }
} 