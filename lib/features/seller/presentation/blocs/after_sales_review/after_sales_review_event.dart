part of 'after_sales_review_bloc.dart';

/// 售后审核事件基类
abstract class AfterSalesReviewEvent extends Equatable {
  /// 构造函数
  const AfterSalesReviewEvent();

  @override
  List<Object?> get props => [];
}

/// 加载售后列表事件
class LoadAfterSalesList extends AfterSalesReviewEvent {}

/// 加载更多售后列表事件
class LoadMoreAfterSalesList extends AfterSalesReviewEvent {}

/// 重新加载售后列表事件
class ReloadAfterSalesList extends AfterSalesReviewEvent {}

/// 审核售后申请事件
class AuditAfterSalesRequest extends AfterSalesReviewEvent {
  /// 售后ID
  final int refundId;
  
  /// 是否通过
  final bool approved;
  
  /// 拒绝原因（当approved为false时有效）
  final String? refusalReason;
  
  /// 构造函数
  const AuditAfterSalesRequest({
    required this.refundId,
    required this.approved,
    this.refusalReason,
  });
  
  @override
  List<Object?> get props => [refundId, approved, refusalReason];
} 