import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart' hide Order;

import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/get_order_detail_use_case.dart';
// Import Seller Action UseCases
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/confirm_order_acceptance_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/reject_order_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/deliver_order_use_case.dart';
// 移除邀请评价功能
// import 'package:dskk_flutter_refactor/features/orders/domain/usecases/invite_evaluation_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/delete_seller_record_use_case.dart';
// Import Params classes needed
import 'package:dskk_flutter_refactor/features/orders/domain/repositories/i_order_repository.dart';

part 'seller_order_detail_event.dart';
part 'seller_order_detail_state.dart';

@injectable
class SellerOrderDetailBloc extends Bloc<SellerOrderDetailEvent, SellerOrderDetailState> {
  final GetOrderDetailUseCase _getOrderDetailUseCase;
  // Inject Seller Action UseCases
  final ConfirmOrderAcceptanceUseCase _confirmOrderAcceptanceUseCase;
  final RejectOrderUseCase _rejectOrderUseCase;
  final DeliverOrderUseCase _deliverOrderUseCase;
  // 移除邀请评价UseCase
  // final InviteEvaluationUseCase _inviteEvaluationUseCase;
  final DeleteSellerRecordUseCase _deleteSellerRecordUseCase;

  SellerOrderDetailBloc(
    this._getOrderDetailUseCase,
    // Add other use cases to constructor
    this._confirmOrderAcceptanceUseCase,
    this._rejectOrderUseCase,
    this._deliverOrderUseCase,
    // this._inviteEvaluationUseCase,
    this._deleteSellerRecordUseCase,
  ) : super(SellerOrderDetailInitial()) {
    on<LoadSellerOrderDetail>(_onLoadSellerOrderDetail);
    // Register handlers for seller actions
    on<SellerConfirmAcceptanceRequested>(_onSellerConfirmAcceptanceRequested);
    on<SellerRejectRequested>(_onSellerRejectRequested);
    on<SellerDeliverRequested>(_onSellerDeliverRequested);
    // 移除邀请评价事件处理
    // on<SellerInviteEvaluationRequested>(_onSellerInviteEvaluationRequested);
    on<SellerDeleteRecordRequested>(_onSellerDeleteRecordRequested);
  }

  // --- Event Handlers ---

  Future<void> _onLoadSellerOrderDetail(
    LoadSellerOrderDetail event,
    Emitter<SellerOrderDetailState> emit,
  ) async {
    emit(SellerOrderDetailLoading(loadingOrderId: event.orderId));
    final result = await _getOrderDetailUseCase(event.orderId);
    result.fold(
      (failure) => emit(SellerOrderDetailLoadFailure(
        failedOrderId: event.orderId,
        message: _mapFailureToMessage(failure),
      )),
      (order) => emit(SellerOrderDetailLoadSuccess(order: order)),
    );
  }

  Future<void> _onSellerConfirmAcceptanceRequested(
    SellerConfirmAcceptanceRequested event,
    Emitter<SellerOrderDetailState> emit,
  ) async {
    await _handleAction(
      event.orderId,
      emit,
      () => _confirmOrderAcceptanceUseCase(event.orderId),
      successMessage: '已成功接单',
    );
  }

  Future<void> _onSellerRejectRequested(
    SellerRejectRequested event,
    Emitter<SellerOrderDetailState> emit,
  ) async {
    // Use the params directly from the event
    await _handleAction(
      event.params.orderId, // Get orderId from params for logging/state
      emit,
      () => _rejectOrderUseCase(event.params), // Pass the full params object
      successMessage: '已成功拒绝订单',
    );
  }

   Future<void> _onSellerDeliverRequested(
    SellerDeliverRequested event,
    Emitter<SellerOrderDetailState> emit,
  ) async {
     // TODO: Use real delivery params from event/UI later
     final params = DeliverOrderParams(orderId: event.orderId, content: 'Mock delivery', files: []);
     await _handleAction(
       event.orderId,
       emit,
       () => _deliverOrderUseCase(params),
       successMessage: '已标记为发货',
     );
   }

  // 移除邀请评价处理方法
  /*
  Future<void> _onSellerInviteEvaluationRequested(
    SellerInviteEvaluationRequested event,
    Emitter<SellerOrderDetailState> emit,
  ) async {
     await _handleAction(
       event.orderId,
       emit,
       () => _inviteEvaluationUseCase(event.orderId),
       successMessage: '已成功邀请评价',
       reloadOnSuccess: false, 
     );
   }
  */

   Future<void> _onSellerDeleteRecordRequested(
    SellerDeleteRecordRequested event,
    Emitter<SellerOrderDetailState> emit,
  ) async {
      await _handleAction(
       event.orderId,
       emit,
       () => _deleteSellerRecordUseCase(event.orderId),
       successMessage: '已成功删除记录',
       // For delete, maybe navigate back or show a specific deleted state?
       // For now, reload might show an error or empty state if detail fetch fails after delete
       // Let's reload for now to see the effect.
     );
   }

  // --- Helper Methods ---

  /// Generic helper to handle actions: emits progress, calls use case, handles result.
  Future<void> _handleAction(
    int orderId,
    Emitter<SellerOrderDetailState> emit,
    Future<Either<Failure, void>> Function() useCaseCall,
    { required String successMessage, bool reloadOnSuccess = true } // Add reloadOnSuccess flag
  ) async {
    Order? currentOrder = _getCurrentOrderFromState();
    if (currentOrder == null) {
      print('[SellerOrderDetailBloc] Cannot perform action: No order data available in state.');
      // Optionally emit a specific error state if needed
      return;
    }

    emit(SellerOrderDetailActionInProgress(order: currentOrder));

    final result = await useCaseCall();

    result.fold(
      (failure) {
         print('[SellerOrderDetailBloc] Action failed for order $orderId: $failure');
         emit(SellerOrderDetailActionFailure(
            order: currentOrder, // Show original order on failure
            message: '操作失败: ${_mapFailureToMessage(failure)}'
          ));
      },
      (_) {
         print('[SellerOrderDetailBloc] Action succeeded for order $orderId.');
         if (reloadOnSuccess) {
            // Reload the order detail to reflect changes
            add(LoadSellerOrderDetail(orderId: orderId));
         } else {
            // Emit success state directly without reloading (e.g., for invite evaluation)
             // We need the potentially updated order here if not reloading.
             // Since use cases return void, we reuse currentOrder. If use cases returned Order, use that.
            emit(SellerOrderDetailActionSuccess(order: currentOrder, message: successMessage));
         }
      },
    );
  }

  /// Helper to safely extract the current order from various states.
  Order? _getCurrentOrderFromState() {
     if (state is SellerOrderDetailLoadSuccess) {
       return (state as SellerOrderDetailLoadSuccess).order;
     } else if (state is SellerOrderDetailActionInProgress) {
       return (state as SellerOrderDetailActionInProgress).order;
     } else if (state is SellerOrderDetailActionFailure) {
       return (state as SellerOrderDetailActionFailure).order;
     } else if (state is SellerOrderDetailActionSuccess) {
        return (state as SellerOrderDetailActionSuccess).order;
     }
     return null;
  }

  /// Maps Failure objects to user-friendly error messages.
  String _mapFailureToMessage(Failure failure) {
    // TODO: Implement more specific error mapping based on Failure types
    print('[Bloc Error Mapping] Encountered failure: ${failure.runtimeType}');
    if (failure is ServerFailure) {
      return failure.message ?? '服务器通信错误，请稍后重试';
    } else if (failure is CacheFailure) {
      return '读取本地数据失败';
    } else if (failure is NetworkFailure) { // NetworkFailure is defined
      return '网络连接失败，请检查网络设置';
    } else if (failure is AuthFailure) { // Use defined AuthFailure
      return failure.message ?? '认证失败，请重新登录'; // Use message from AuthFailure
    } 
    // else if (failure is InvalidInputFailure) { // Assuming InputFailure - Commented out for now
    //    return failure.message ?? '输入无效'; // Use message from failure if provided
    // } 
    else {
      // Generic fallback for unexpected failure types
      return '发生未知错误 (${failure.runtimeType})';
    }
  }

}
