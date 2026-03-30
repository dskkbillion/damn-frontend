import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart'; // 引入 Failure
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';

/// 表示订单列表页面的不同状态
enum OrderListStatus {
  initial, // 初始状态
  loading, // 正在加载（首次加载或刷新）
  loadingMore, // 正在加载更多
  success, // 加载成功
  failure, // 加载失败
}

/// 订单列表页面的状态类
class OrderListState extends Equatable {
  /// 当前的加载状态
  final OrderListStatus status;

  /// 当前显示的订单列表
  final List<Order> orders;

  /// 当前激活的订单状态过滤器
  final OrderStatus currentFilter;

  /// 是否还有更多订单可以加载
  final bool hasMore;

  /// 当前加载到的页码
  final int currentPage;

  /// 加载失败时的错误信息
  final Failure? failure;

  /// True when cached data is shown while a background refresh is in progress.
  final bool isRefreshing;

  const OrderListState({
    this.status = OrderListStatus.initial,
    this.orders = const [],
    this.currentFilter = OrderStatus.unknown, // 默认查询全部
    this.hasMore = true,
    this.currentPage = 1,
    this.failure,
    this.isRefreshing = false,
  });

  /// 创建状态的副本，方便更新部分属性
  OrderListState copyWith({
    OrderListStatus? status,
    List<Order>? orders,
    OrderStatus? currentFilter,
    bool? hasMore,
    int? currentPage,
    Failure? failure,
    bool clearFailure = false, // 用于显式清除错误
    bool? isRefreshing,
  }) {
    return OrderListState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      currentFilter: currentFilter ?? this.currentFilter,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      // 如果 clearFailure 为 true，则强制 failure 为 null
      // 否则，如果传入了新的 failure，则使用新的，否则保持旧的
      failure: clearFailure ? null : (failure ?? this.failure),
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
        status,
        orders,
        currentFilter,
        hasMore,
        currentPage,
        failure,
        isRefreshing,
      ];
} 