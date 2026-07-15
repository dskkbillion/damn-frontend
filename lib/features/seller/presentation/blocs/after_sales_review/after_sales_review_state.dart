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
class AfterSalesReviewLoadingMore extends AfterSalesReviewLoaded {
  /// 当前售后列表
  /// 构造函数
  const AfterSalesReviewLoadingMore({
    required super.refunds,
    required super.hasMore,
    required super.currentPage,
  });
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

/// 审核成功后短暂保留列表，用于向用户确认结果，再刷新远端数据。
class AfterSalesReviewAuditSuccess extends AfterSalesReviewLoaded {
  final String message;

  const AfterSalesReviewAuditSuccess({
    required super.refunds,
    required super.hasMore,
    required super.currentPage,
    required this.message,
  });

  @override
  List<Object?> get props => [...super.props, message];
}

/// 审核失败后保留原列表，避免用户需要重新进入页面才能重试。
class AfterSalesReviewAuditFailure extends AfterSalesReviewLoaded {
  final String message;

  const AfterSalesReviewAuditFailure({
    required super.refunds,
    required super.hasMore,
    required super.currentPage,
    required this.message,
  });

  @override
  List<Object?> get props => [...super.props, message];
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
