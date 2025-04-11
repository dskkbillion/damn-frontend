import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/cancel_order_use_case.dart';
import '../../domain/usecases/confirm_order_receipt_use_case.dart';
import '../../domain/usecases/delete_order_use_case.dart';
import '../../domain/usecases/get_order_detail_use_case.dart';
import 'order_detail_state.dart';

/// 管理订单详情页面状态的 Cubit
class OrderDetailCubit extends Cubit<OrderDetailState> {
  final GetOrderDetailUseCase getOrderDetailUseCase;
  final CancelOrderUseCase cancelOrderUseCase;
  final ConfirmOrderReceiptUseCase confirmOrderReceiptUseCase;
  final DeleteOrderUseCase deleteOrderUseCase;
  // 可以根据需要注入其他操作的 UseCase

  OrderDetailCubit({
    required this.getOrderDetailUseCase,
    required this.cancelOrderUseCase,
    required this.confirmOrderReceiptUseCase,
    required this.deleteOrderUseCase,
  }) : super(const OrderDetailState());

  /// 加载指定 ID 的订单详情
  Future<void> loadOrderDetail(int orderId) async {
    if (state.status == OrderDetailStatus.loading) return;
    // 重置操作状态为空闲
    emit(state.copyWith(status: OrderDetailStatus.loading, clearFailure: true, actionStatus: OrderActionStatus.idle));

    final failureOrOrder = await getOrderDetailUseCase(orderId);

    failureOrOrder.fold(
      (failure) => emit(state.copyWith(
        status: OrderDetailStatus.failure,
        failure: failure,
      )),
      (order) => emit(state.copyWith(
        status: OrderDetailStatus.success,
        order: order,
      )),
    );
  }

  /// 取消当前订单
  Future<void> cancelOrder() async {
    if (state.order == null || state.actionStatus == OrderActionStatus.loading) {
      return;
    }

    emit(state.copyWith(actionStatus: OrderActionStatus.loading, clearActionFailure: true));

    final failureOrSuccess = await cancelOrderUseCase(state.order!.id);

    failureOrSuccess.fold(
      (failure) => emit(state.copyWith(
        actionStatus: OrderActionStatus.failure,
        actionFailure: failure,
      )),
      (_) {
        // 操作成功后，重新加载订单详情会重置 actionStatus 为 idle
        emit(state.copyWith(actionStatus: OrderActionStatus.success));
        loadOrderDetail(state.order!.id);
      },
    );
  }

  /// 确认收到当前订单
  Future<void> confirmOrderReceipt() async {
    if (state.order == null || state.actionStatus == OrderActionStatus.loading) {
      return;
    }

    emit(state.copyWith(actionStatus: OrderActionStatus.loading, clearActionFailure: true));

    final failureOrSuccess = await confirmOrderReceiptUseCase(state.order!.id);

    failureOrSuccess.fold(
      (failure) => emit(state.copyWith(
        actionStatus: OrderActionStatus.failure,
        actionFailure: failure,
      )),
      (_) {
        emit(state.copyWith(actionStatus: OrderActionStatus.success));
        loadOrderDetail(state.order!.id);
      },
    );
  }

  /// 删除当前订单
  Future<void> deleteOrder() async {
     if (state.order == null || state.actionStatus == OrderActionStatus.loading) {
      return;
    }

    emit(state.copyWith(actionStatus: OrderActionStatus.loading, clearActionFailure: true));

    final failureOrSuccess = await deleteOrderUseCase(state.order!.id);

     failureOrSuccess.fold(
      (failure) => emit(state.copyWith(
        actionStatus: OrderActionStatus.failure,
        actionFailure: failure,
      )),
      (_) {
        // 删除成功后，将主状态设为成功（表示操作成功），并清除订单
        emit(state.copyWith(
          status: OrderDetailStatus.success, // Or maybe a custom 'deleted' status?
          order: null, // Clear the order
          actionStatus: OrderActionStatus.success, // Mark action as success
          clearActionFailure: true,
        ));
      },
    );
  }
} 