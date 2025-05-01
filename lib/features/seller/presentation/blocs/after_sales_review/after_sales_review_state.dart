part of 'after_sales_review_bloc.dart';

/// 售后审核状态基类
abstract class AfterSalesReviewState extends Equatable {
  /// 构造函数
  const AfterSalesReviewState();
  
  @override
  List<Object?> get props => [];
}

/// 初始状态
class AfterSalesReviewInitial extends AfterSalesReviewState {}

/// 加载中状态
class AfterSalesReviewLoading extends AfterSalesReviewState {}

/// 加载更多状态
class AfterSalesReviewLoadingMore extends AfterSalesReviewState {
  /// 当前售后列表
  final List<OrderRefund> refunds;
  
  /// 是否有更多数据
  final bool hasMore;
  
  /// 当前页码
  final int currentPage;
  
  /// 构造函数
  const AfterSalesReviewLoadingMore({
    required this.refunds,
    required this.hasMore,
    required this.currentPage,
  });
  
  @override
  List<Object?> get props => [refunds, hasMore, currentPage];
}

/// 加载成功状态
class AfterSalesReviewLoaded extends AfterSalesReviewState {
  /// 售后列表
  final List<OrderRefund> refunds;
  
  /// 是否有更多数据
  final bool hasMore;
  
  /// 当前页码
  final int currentPage;
  
  /// 构造函数
  const AfterSalesReviewLoaded({
    required this.refunds,
    required this.hasMore,
    required this.currentPage,
  });
  
  @override
  List<Object?> get props => [refunds, hasMore, currentPage];
}

/// 审核中状态
class AfterSalesReviewAuditing extends AfterSalesReviewLoaded {
  /// 正在审核的售后ID
  final int auditingId;
  
  /// 构造函数
  const AfterSalesReviewAuditing({
    required super.refunds,
    required super.hasMore,
    required super.currentPage,
    required this.auditingId,
  });
  
  @override
  List<Object?> get props => [...super.props, auditingId];
}

/// 空数据状态
class AfterSalesReviewEmpty extends AfterSalesReviewState {}

/// 错误状态
class AfterSalesReviewError extends AfterSalesReviewState {
  /// 错误信息
  final String message;
  
  /// 当前售后列表（可能为空）
  final List<OrderRefund> refunds;
  
  /// 是否有更多数据
  final bool hasMore;
  
  /// 当前页码
  final int currentPage;
  
  /// 构造函数
  const AfterSalesReviewError({
    required this.message,
    required this.refunds,
    required this.hasMore,
    required this.currentPage,
  });
  
  @override
  List<Object?> get props => [message, refunds, hasMore, currentPage];
} 