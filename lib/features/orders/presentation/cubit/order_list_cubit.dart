import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order_status.dart';
import '../../domain/usecases/get_order_list_use_case.dart';
import 'order_list_state.dart';

/// 管理订单列表页面状态的 Cubit
class OrderListCubit extends Cubit<OrderListState> {
  final GetOrderListUseCase getOrderListUseCase;
  static const int _pageSize = 10; // 每页加载的数量

  OrderListCubit({required this.getOrderListUseCase})
      : super(const OrderListState());

  /// 加载订单列表（首次加载或切换过滤器时调用）
  Future<void> loadOrders({OrderStatus? filter, bool refresh = false}) async {
    // 当前过滤器，如果传入了 filter 则使用，否则使用状态中的
    final effectiveFilter = filter ?? state.currentFilter;

    // 如果是刷新，或者切换了过滤器，则重置状态并从第一页加载
    if (refresh || (filter != null && filter != state.currentFilter)) {
      // 状态设置为 loading，并清空列表，重置页码和 hasMore
      emit(state.copyWith(
        status: OrderListStatus.loading,
        currentFilter: effectiveFilter,
        orders: [],
        currentPage: 1,
        hasMore: true,
        clearFailure: true, // 清除之前的错误
      ));
    } else if (state.status == OrderListStatus.loading ||
        state.status == OrderListStatus.loadingMore) {
      // 如果正在加载中，则不重复加载
      return;
    }

    // 如果不是刷新或切换过滤器，则也设置为 loading 状态准备加载第一页
    // （这种情况可能发生在初始加载或出错后重试）
    emit(state.copyWith(status: OrderListStatus.loading, clearFailure: true));

    final params = GetOrderListParams(
      status: state.currentFilter == OrderStatus.unknown ? null : state.currentFilter,
      page: 1, // 总是从第一页开始加载
      limit: _pageSize,
    );

    final failureOrOrders = await getOrderListUseCase(params);

    failureOrOrders.fold(
      (failure) => emit(state.copyWith(
        status: OrderListStatus.failure,
        failure: failure,
        hasMore: false, // 出错时认为没有更多
      )),
      (orders) => emit(state.copyWith(
        status: OrderListStatus.success,
        orders: orders,
        currentPage: 1,
        hasMore: orders.length >= _pageSize, // 判断是否可能还有更多
      )),
    );
  }

  /// 加载更多订单
  Future<void> loadMoreOrders() async {
    // 如果没有更多数据或正在加载中，则不执行
    if (!state.hasMore ||
        state.status == OrderListStatus.loadingMore ||
        state.status == OrderListStatus.loading) {
      return;
    }

    emit(state.copyWith(status: OrderListStatus.loadingMore));

    final nextPage = state.currentPage + 1;
    final params = GetOrderListParams(
      status: state.currentFilter == OrderStatus.unknown ? null : state.currentFilter,
      page: nextPage,
      limit: _pageSize,
    );

    final failureOrOrders = await getOrderListUseCase(params);

    failureOrOrders.fold(
      (failure) => emit(state.copyWith(
        // 注意：加载更多失败时，状态最好保持 success 或恢复 loadingMore 之前的状态，
        // 而不是直接设为 failure，以免 UI 显示全局错误信息。
        // 这里暂时保持 failure，但实际应用中可能需要调整。
        status: OrderListStatus.failure,
        failure: failure,
        hasMore: false, // 加载更多出错时认为没有更多
      )),
      (newOrders) => emit(state.copyWith(
        status: OrderListStatus.success,
        orders: List.of(state.orders)..addAll(newOrders), // 将新数据追加到旧列表
        currentPage: nextPage,
        hasMore: newOrders.length >= _pageSize,
      )),
    );
  }

  /// 切换订单状态过滤器
  void changeFilter(OrderStatus newFilter) {
    if (newFilter != state.currentFilter) {
      // 调用 loadOrders 并传入新的过滤器，它会处理状态重置和数据加载
      loadOrders(filter: newFilter);
    }
  }
} 