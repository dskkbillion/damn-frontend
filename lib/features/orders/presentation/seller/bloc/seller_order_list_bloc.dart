import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart' hide Order; // Hide Order from injectable
import 'package:stream_transform/stream_transform.dart';

import '../../../../../core/error/failures.dart'; // Import Failure types
import '../../../../../core/usecases/usecase.dart'; // Assuming NoParams is here or adjust path
import '../../../domain/entities/order.dart';
import '../../../domain/entities/order_status.dart';
import '../../../domain/usecases/get_order_list_use_case.dart'; // Use existing UseCase
import '../../../domain/usecases/confirm_order_acceptance_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/reject_order_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/deliver_order_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/invite_evaluation_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/delete_seller_record_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/repositories/i_order_repository.dart'; // Contains DeliverOrderParams

part 'seller_order_list_event.dart';
part 'seller_order_list_state.dart';

// Duration for throttle
const _throttleDuration = Duration(milliseconds: 500);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return events.throttle(duration).switchMap(mapper);
  };
}

@injectable
class SellerOrderListBloc extends Bloc<SellerOrderListEvent, SellerOrderListState> {
  final GetOrderListUseCase _getOrderListUseCase;
  final ConfirmOrderAcceptanceUseCase _confirmOrderAcceptanceUseCase;
  final RejectOrderUseCase _rejectOrderUseCase;
  final DeliverOrderUseCase _deliverOrderUseCase;
  final InviteEvaluationUseCase _inviteEvaluationUseCase;
  final DeleteSellerRecordUseCase _deleteSellerRecordUseCase;

  int _currentPage = 1;
  bool _hasReachedMax = false;
  // Track the current status filter
  OrderStatus? _currentStatusFilter;
  // Store the current keyword for loading more
  String? _currentKeyword;

  SellerOrderListBloc(
    this._getOrderListUseCase,
    this._confirmOrderAcceptanceUseCase,
    this._rejectOrderUseCase,
    this._deliverOrderUseCase,
    this._inviteEvaluationUseCase,
    this._deleteSellerRecordUseCase,
  ) : super(SellerOrderListInitial()) {
    on<LoadSellerOrdersRequested>(_onLoadSellerOrdersRequested);
    on<LoadMoreSellerOrders>(
      _onLoadMoreSellerOrders,
      transformer: throttleDroppable(_throttleDuration), // Throttle load more events
    );
    on<SellerOrderStatusFilterChanged>(_onSellerOrderStatusFilterChanged);
    on<ConfirmAcceptanceRequested>(_onConfirmAcceptanceRequested);
    on<RejectOrderRequested>(_onRejectOrderRequested);
    on<DeliverOrderRequested>(_onDeliverOrderRequested);
    on<InviteEvaluationRequested>(_onInviteEvaluationRequested);
    on<DeleteSellerRecordRequested>(_onDeleteSellerRecordRequested);
  }

  Future<void> _onLoadSellerOrdersRequested(
    LoadSellerOrdersRequested event,
    Emitter<SellerOrderListState> emit,
  ) async {
    _currentPage = 1; // Reset page number
    _currentStatusFilter = event.statusFilter;
    _currentKeyword = event.keyword;
    _hasReachedMax = false;
    emit(SellerOrderListLoading());

    final result = await _getOrderListUseCase(GetOrderListParams(
      page: _currentPage,
      limit: 10, // Or get from config
      status: _currentStatusFilter == OrderStatus.unknown ? null : _currentStatusFilter,
      keyword: _currentKeyword,
      // TODO: IMPORTANT - How to specify role? Add 'role' to GetOrderListParams?
      // role: 'seller',
    ));

    result.fold(
      (failure) {
         // Assume failure is ServerFailure or similar with a message
         final errorMessage = (failure is ServerFailure) 
           ? (failure.message ?? 'Unknown server error') // Handle null message in ServerFailure
           : 'An unknown error occurred';
         emit(SellerOrderListFailure(message: errorMessage));
      },
      (orders) {
        final hasReachedMax = orders.length < 10; // Assuming limit is 10
        emit(SellerOrderListSuccess(
          orders: orders,
          currentStatusFilter: _currentStatusFilter,
          hasReachedMax: hasReachedMax,
        ));
      },
    );
  }

  Future<void> _onLoadMoreSellerOrders(
    LoadMoreSellerOrders event,
    Emitter<SellerOrderListState> emit,
  ) async {
    if (state is SellerOrderListSuccess && !(state as SellerOrderListSuccess).hasReachedMax) {
      final currentState = state as SellerOrderListSuccess;
      _currentPage++;

      final result = await _getOrderListUseCase(GetOrderListParams(
        page: _currentPage,
        limit: 10,
        status: _currentStatusFilter == OrderStatus.unknown ? null : _currentStatusFilter,
        keyword: _currentKeyword,
        // role: 'seller', // Add role here too
      ));

      result.fold(
        (failure) {
          // Optionally emit a failure state or keep the current list
          // For simplicity, we keep the current list but maybe show an error toast later
          // Ensure errorMessage is always non-null
          final errorMessage = (failure is ServerFailure) 
            ? (failure.message ?? 'Unknown server error loading more') // Handle null message
            : 'An unknown error occurred loading more';
          print('Error loading more seller orders: $errorMessage');
           // Restore page number on failure?
           _currentPage--;
        },
        (newOrders) {
          final hasReachedMax = newOrders.length < 10;
          emit(currentState.copyWith(
            orders: List.of(currentState.orders)..addAll(newOrders),
            hasReachedMax: hasReachedMax,
          ));
        },
      );
    }
  }

  Future<void> _onSellerOrderStatusFilterChanged(
    SellerOrderStatusFilterChanged event,
    Emitter<SellerOrderListState> emit,
  ) async {
    // Update the tracked filter and reset pagination
    _currentStatusFilter = event.newStatusFilter;
    _currentPage = 1;
    _hasReachedMax = false;
    // Keep the current keyword if any
    add(LoadSellerOrdersRequested(statusFilter: event.newStatusFilter, keyword: _currentKeyword));
  }

  Future<void> _onConfirmAcceptanceRequested(
    ConfirmAcceptanceRequested event,
    Emitter<SellerOrderListState> emit,
  ) async {
    print('[SellerOrderListBloc] Received ConfirmAcceptanceRequested for order ${event.orderId}');
    // Ensure we have a previous success state to pass
    final currentState = state;
    if (currentState is SellerOrderListSuccess) {
       // Emit InProgress state before calling UseCase
      emit(SellerOrderListActionInProgress(previousState: currentState)); 
    } else {
      // Handle cases where action is triggered from a non-success state (e.g., initial, error)
      // Maybe just log or prevent action? For now, let it proceed but log.
      print('[SellerOrderListBloc] Warning: ConfirmAcceptance requested from non-success state: ${currentState.runtimeType}');
    }

    final result = await _confirmOrderAcceptanceUseCase(event.orderId);

    result.fold(
      (failure) {
        print('[SellerOrderListBloc] Failed to confirm acceptance for order ${event.orderId}: $failure');
        // Emit Failure state, passing the previous state if available
        if (currentState is SellerOrderListSuccess) {
           emit(SellerOrderListActionFailure(
            previousState: currentState,
             message: '确认接单失败: ${failure.toString()}' // Provide user-friendly message if possible
            ));
        } else {
          // If no previous success state, maybe revert to initial or a general error state?
          // For now, just log, as the list might not be visible anyway.
           print('[SellerOrderListBloc] Error occurred from non-success state, cannot show previous list.');
        }
      },
      (_) {
        print('[SellerOrderListBloc] Successfully confirmed acceptance for order ${event.orderId}.');
        // Refresh the list to show the updated order status
        add(LoadSellerOrdersRequested(
          statusFilter: _currentStatusFilter,
          refresh: true,
        ));
      },
    );
  }

  Future<void> _onRejectOrderRequested(
    RejectOrderRequested event,
    Emitter<SellerOrderListState> emit,
  ) async {
    print('[SellerOrderListBloc] Received RejectOrderRequested for order ${event.orderId}');
    final currentState = state;
    if (currentState is SellerOrderListSuccess) {
      emit(SellerOrderListActionInProgress(previousState: currentState));
    } else {
      print('[SellerOrderListBloc] Warning: RejectOrder requested from non-success state: ${currentState.runtimeType}');
    }

    // Construct AddOrderDemandParams for refusal here
    // TODO: Later, get reason/remarks from the event or UI interaction
    final params = AddOrderDemandParams(
      orderId: event.orderId, 
      type: 'refuse', // Default refusal type
      reasonValue: 'seller_reject', // Default reason code
      reasonLabel: '卖家拒绝接单', // Default reason text
      // remarks: null, // Optional remarks
      );

    final result = await _rejectOrderUseCase(params); // Pass the params object
    result.fold(
      (failure) {
        print('[SellerOrderListBloc] Failed to reject order ${event.orderId}: $failure');
        if (currentState is SellerOrderListSuccess) {
          emit(SellerOrderListActionFailure(
            previousState: currentState,
            message: '拒绝订单失败: ${failure.toString()}'
            ));
        } else {
           print('[SellerOrderListBloc] Error occurred from non-success state.');
        }
      },
      (_) {
        print('[SellerOrderListBloc] Successfully rejected order ${event.orderId}.');
        add(LoadSellerOrdersRequested(statusFilter: _currentStatusFilter, refresh: true));
      },
    );
  }

  Future<void> _onDeliverOrderRequested(
    DeliverOrderRequested event,
    Emitter<SellerOrderListState> emit,
  ) async {
    print('[SellerOrderListBloc] Received DeliverOrderRequested for order ${event.orderId}');
    final currentState = state;
    if (currentState is SellerOrderListSuccess) {
      emit(SellerOrderListActionInProgress(previousState: currentState));
    } else {
       print('[SellerOrderListBloc] Warning: DeliverOrder requested from non-success state: ${currentState.runtimeType}');
    }

    // TODO: Construct DeliverOrderParams properly. This needs UI interaction (files, content).
    // For now, use placeholder params for the skeleton call.
    final params = DeliverOrderParams(orderId: event.orderId, content: 'Mock delivery content', files: []);
    final result = await _deliverOrderUseCase(params);
    result.fold(
      (failure) {
        print('[SellerOrderListBloc] Failed to deliver order ${event.orderId}: $failure');
         if (currentState is SellerOrderListSuccess) {
          emit(SellerOrderListActionFailure(
            previousState: currentState,
            message: '确认发货失败: ${failure.toString()}'
            ));
        } else {
            print('[SellerOrderListBloc] Error occurred from non-success state.');
        }
      },
      (_) {
        print('[SellerOrderListBloc] Successfully delivered order ${event.orderId}.');
        add(LoadSellerOrdersRequested(statusFilter: _currentStatusFilter, refresh: true));
      },
    );
  }

  Future<void> _onInviteEvaluationRequested(
    InviteEvaluationRequested event,
    Emitter<SellerOrderListState> emit,
  ) async {
    print('[SellerOrderListBloc] Received InviteEvaluationRequested for order ${event.orderId}');
     final currentState = state;
    if (currentState is SellerOrderListSuccess) {
      emit(SellerOrderListActionInProgress(previousState: currentState));
    } else {
       print('[SellerOrderListBloc] Warning: InviteEvaluation requested from non-success state: ${currentState.runtimeType}');
    }

    final result = await _inviteEvaluationUseCase(event.orderId);
    result.fold(
      (failure) {
        print('[SellerOrderListBloc] Failed to invite evaluation for order ${event.orderId}: $failure');
        if (currentState is SellerOrderListSuccess) {
          emit(SellerOrderListActionFailure(
            previousState: currentState,
            message: '邀请评价失败: ${failure.toString()}'
            ));
        } else {
           print('[SellerOrderListBloc] Error occurred from non-success state.');
        }
      },
      (_) {
        print('[SellerOrderListBloc] Successfully invited evaluation for order ${event.orderId}.');
        // For non-list-modifying actions, revert to previous success state 
        // Or potentially emit a specific ActionSuccess state for SnackBar
        if (currentState is SellerOrderListSuccess) {
           // Option 1: Just revert state
           // emit(currentState); 
           // Option 2: Emit specific success state (if defined) for listener
           // emit(SellerOrderListActionSuccess(previousState: currentState, message: '已成功邀请评价'));
           // For now, let's just revert to previous state. Refresh is commented out.
           emit(currentState);
        } 
        // Optionally show a success message via state/listener, refreshing list might not be needed
        // add(LoadSellerOrdersRequested(statusFilter: _currentStatusFilter, refresh: true));
      },
    );
  }

  Future<void> _onDeleteSellerRecordRequested(
    DeleteSellerRecordRequested event,
    Emitter<SellerOrderListState> emit,
  ) async {
    print('[SellerOrderListBloc] Received DeleteSellerRecordRequested for order ${event.orderId}');
    final currentState = state;
     if (currentState is SellerOrderListSuccess) {
      emit(SellerOrderListActionInProgress(previousState: currentState));
    } else {
       print('[SellerOrderListBloc] Warning: DeleteRecord requested from non-success state: ${currentState.runtimeType}');
    }

    final result = await _deleteSellerRecordUseCase(event.orderId);
    result.fold(
      (failure) {
        print('[SellerOrderListBloc] Failed to delete seller record for order ${event.orderId}: $failure');
         if (currentState is SellerOrderListSuccess) {
          emit(SellerOrderListActionFailure(
            previousState: currentState,
            message: '删除记录失败: ${failure.toString()}'
            ));
        } else {
            print('[SellerOrderListBloc] Error occurred from non-success state.');
        }
      },
      (_) {
        print('[SellerOrderListBloc] Successfully deleted seller record for order ${event.orderId}.');
        // Refresh the list to remove the deleted order
        add(LoadSellerOrdersRequested(statusFilter: _currentStatusFilter, refresh: true));
      },
    );
  }
}


