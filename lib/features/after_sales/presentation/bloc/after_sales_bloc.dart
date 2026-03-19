import 'package:bloc/bloc.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart'; // For throttle/debounce if needed
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart'; // For throttle/debounce

import '../../../../core/error/failures.dart';
import '../../domain/entities/after_sales_application.dart';
import '../../domain/repositories/i_after_sales_repository.dart'; // For Params classes
import '../../domain/usecases/apply_for_after_sales_use_case.dart';
import '../../domain/usecases/apply_mediation_use_case.dart';
import '../../domain/usecases/cancel_after_sales_use_case.dart';
import '../../domain/usecases/delete_after_sales_use_case.dart';
import '../../domain/usecases/get_after_sales_detail_use_case.dart';
import '../../domain/usecases/get_after_sales_list_use_case.dart';
import '../../domain/usecases/get_refund_id_by_order_id_use_case.dart';

// Define these if Event/State are in separate files without 'part of'
part 'after_sales_event.dart';
part 'after_sales_state.dart';

// Define a throttle duration for list fetching to prevent spamming
const _throttleDuration = Duration(milliseconds: 300);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}


@injectable
class AfterSalesBloc extends Bloc<AfterSalesEvent, AfterSalesState> {
  final GetAfterSalesListUseCase _getAfterSalesListUseCase;
  final GetAfterSalesDetailUseCase _getAfterSalesDetailUseCase;
  final ApplyForAfterSalesUseCase _applyForAfterSalesUseCase;
  final ApplyMediationUseCase _applyMediationUseCase;
  final CancelAfterSalesUseCase _cancelAfterSalesUseCase;
  final DeleteAfterSalesUseCase _deleteAfterSalesUseCase;
  final GetRefundIdByOrderIdUseCase _getRefundIdByOrderIdUseCase;
  // TODO: Inject image upload use case when available

  // Constants for pagination
  static const int _defaultPageSize = 10;


  AfterSalesBloc(
    this._getAfterSalesListUseCase,
    this._getAfterSalesDetailUseCase,
    this._applyForAfterSalesUseCase,
    this._applyMediationUseCase,
    this._cancelAfterSalesUseCase,
    this._deleteAfterSalesUseCase,
    this._getRefundIdByOrderIdUseCase,
  ) : super(AfterSalesInitial()) {
    // Register event handlers
    on<LoadAfterSalesListRequested>(
      _onLoadAfterSalesListRequested,
      transformer: throttleDroppable(_throttleDuration), // Apply throttle
    );
    on<LoadAfterSalesDetail>(_onLoadAfterSalesDetail);
    on<LoadAfterSalesDetailByOrderId>(_onLoadAfterSalesDetailByOrderId);
    on<ApplyForAfterSalesSubmitted>(_onApplyForAfterSalesSubmitted);
    on<ApplyMediationRequested>(_onApplyMediationRequested);
    on<CancelAfterSalesRequested>(_onCancelAfterSalesRequested);
    on<DeleteAfterSalesRequested>(_onDeleteAfterSalesRequested);
    // TODO: Add handler for image upload event
  }

  // --- Event Handlers ---

  Future<void> _onLoadAfterSalesListRequested(
    LoadAfterSalesListRequested event,
    Emitter<AfterSalesState> emit,
  ) async {
    // Get the current state for pagination logic
    final currentState = state;
    bool isInitialLoad = event.page == 1;
    List<AfterSalesApplication> currentApps = [];

    if (!isInitialLoad && currentState is AfterSalesListLoaded) {
        // Check if already reached max in the previous loaded state
        // We need to store hasReachedMax within AfterSalesListLoaded state
        // TODO: Add hasReachedMax to AfterSalesListLoaded state
        // For now, we proceed optimistically
        currentApps = currentState.applications;
    } else if (!isInitialLoad) {
       // If loading page > 1 but current state isn't Loaded (e.g., Error), treat as initial load?
       // Or return early? Let's treat as initial load for simplicity.
       isInitialLoad = true;
    }

    // Emit Loading state
    if (isInitialLoad) {
      emit(AfterSalesListLoading());
    }
    // For subsequent pages, we might show a bottom indicator, but don't change the main state to Loading
    // The UI layer can handle showing a loading indicator at the end of the list

    final params = GetAfterSalesListParams(
      page: event.page,
      pageSize: event.pageSize,
      stateFilter: event.statusFilter,
    );

    final result = await _getAfterSalesListUseCase(params);

    result.fold(
      (failure) => emit(AfterSalesListError(_mapFailureToMessage(failure))),
      (newApplications) {
        // TODO: Add hasReachedMax logic based on newApplications.length < pageSize
        final combinedApps = isInitialLoad ? newApplications : (List.of(currentApps)..addAll(newApplications));
        emit(AfterSalesListLoaded(combinedApps));
      },
    );
  }

  // REMOVED: _onLoadAfterSalesDetailRequested method

  // ADDED: Handler for LoadAfterSalesDetail
  Future<void> _onLoadAfterSalesDetail(
    LoadAfterSalesDetail event,
    Emitter<AfterSalesState> emit,
  ) async {
    emit(AfterSalesDetailLoading(event.id));
    final params = GetAfterSalesDetailParams(id: event.id);
    final failureOrApplication = await _getAfterSalesDetailUseCase(params);

    failureOrApplication.fold(
      (failure) => emit(AfterSalesDetailError(id: event.id, message: _mapFailureToMessage(failure))),
      (application) => emit(AfterSalesDetailLoaded(application)),
    );
  }

  // Handler for LoadAfterSalesDetailByOrderId
  Future<void> _onLoadAfterSalesDetailByOrderId(
    LoadAfterSalesDetailByOrderId event,
    Emitter<AfterSalesState> emit,
  ) async {
    AppLogger.d('[AfterSalesBloc] Loading after-sales detail by order ID: ${event.orderId}');
    emit(AfterSalesDetailLoading(event.orderId.toString()));
    
    try {
      // First, get the refund ID by order ID
      final refundIdParams = GetRefundIdByOrderIdParams(orderId: event.orderId);
      AppLogger.d('[AfterSalesBloc] Calling getRefundIdByOrderIdUseCase with orderId: ${event.orderId}');
      final refundIdResult = await _getRefundIdByOrderIdUseCase(refundIdParams);

      await refundIdResult.fold(
        (failure) async {
          AppLogger.d('[AfterSalesBloc] Failed to get refund ID: ${_mapFailureToMessage(failure)}');
          emit(AfterSalesDetailError(
            id: event.orderId.toString(), 
            message: _mapFailureToMessage(failure)
          ));
        },
        (refundId) async {
          AppLogger.d('[AfterSalesBloc] Got refund ID: $refundId for order ID: ${event.orderId}');
          if (refundId == null) {
            AppLogger.d('[AfterSalesBloc] No refund record found for order ID: ${event.orderId}');
            emit(AfterSalesDetailError(
              id: event.orderId.toString(), 
              message: '该订单没有对应的售后记录'
            ));
            return;
          }

          // Now load the after-sales detail using the refund ID
          AppLogger.d('[AfterSalesBloc] Loading after-sales detail with refund ID: $refundId');
          final detailParams = GetAfterSalesDetailParams(id: refundId.toString());
          final detailResult = await _getAfterSalesDetailUseCase(detailParams);

          detailResult.fold(
            (failure) {
              AppLogger.d('[AfterSalesBloc] Failed to load after-sales detail: ${_mapFailureToMessage(failure)}');
              emit(AfterSalesDetailError(
                id: event.orderId.toString(), 
                message: _mapFailureToMessage(failure)
              ));
            },
            (application) {
              AppLogger.d('[AfterSalesBloc] Successfully loaded after-sales detail: ${application.id}');
              emit(AfterSalesDetailLoaded(application));
            },
          );
        },
      );
    } catch (e) {
      AppLogger.d('[AfterSalesBloc] Unexpected error in _onLoadAfterSalesDetailByOrderId: $e');
      emit(AfterSalesDetailError(
        id: event.orderId.toString(), 
        message: '加载售后详情时发生未知错误: $e'
      ));
    }
  }


  Future<void> _onApplyForAfterSalesSubmitted(
    ApplyForAfterSalesSubmitted event,
    Emitter<AfterSalesState> emit,
  ) async {
    // Use the new Action States
    emit(AfterSalesActionLoading());

    // TODO: Implement actual image upload here if needed before submitting paths
    // For mock, we assume paths are sufficient or handled by UseCase/Repository
    final List<String> imagePathsToSubmit = event.imagePaths ?? [];

    final params = ApplyAfterSalesParams(
        orderItemId: event.orderItemId,
        refundType: event.refundType,
        refundReason: event.refundReason,
        refundExplain: event.refundExplain,
        refundImage: imagePathsToSubmit, // Pass the prepared image paths
        // Pass refundAmount to ApplyAfterSalesParams if the definition includes it
        // This depends on ApplyAfterSalesParams and the corresponding UseCase/Repo logic
        // Let's assume ApplyAfterSalesParams needs updating or amount is handled differently
        // For now, we won't pass amount directly to params unless defined.
        // Check ApplyAfterSalesParams definition.
    );

    // Assuming ApplyForAfterSalesUseCase takes ApplyAfterSalesParams
    final result = await _applyForAfterSalesUseCase(params);

    result.fold(
      (failure) => emit(AfterSalesActionError(_mapFailureToMessage(failure))),
      (refundId) {
         // Convert int refundId to String for the state
         emit(AfterSalesActionSuccess(newId: refundId.toString()));
         // Optionally, you might want to navigate back or show a success dialog.
         // This can be handled by listening to the state in the UI.
         // Maybe also reload the after-sales list or detail page?
         // For now, just emit success.
      }
    );
  }

  Future<void> _onApplyMediationRequested(
    ApplyMediationRequested event,
    Emitter<AfterSalesState> emit,
  ) async {
    emit(AfterSalesActionLoading());

    final result = await _applyMediationUseCase(event.refundId);

    result.fold(
      (failure) => emit(AfterSalesActionError(_mapFailureToMessage(failure))),
      (_) => emit(const AfterSalesActionSuccess(message: '平台介入申请已提交')),
    );
  }


  Future<void> _onCancelAfterSalesRequested(
    CancelAfterSalesRequested event,
    Emitter<AfterSalesState> emit,
  ) async {
     // TODO: Fix this handler's emit logic
     // emit(state.copyWith(actionStatus: AfterSalesActionStatus.loading, clearActionFailure: true));
     emit(AfterSalesActionLoading()); // Placeholder

     final result = await _cancelAfterSalesUseCase(event.refundId);

     result.fold(
      (failure) => emit(AfterSalesActionError(_mapFailureToMessage(failure))), // Placeholder
      (_) => emit(AfterSalesActionSuccess()), // Placeholder
    );
  }


  Future<void> _onDeleteAfterSalesRequested(
    DeleteAfterSalesRequested event,
    Emitter<AfterSalesState> emit,
  ) async {
     // TODO: Fix this handler's emit logic
     // emit(state.copyWith(actionStatus: AfterSalesActionStatus.loading, clearActionFailure: true));
     emit(AfterSalesActionLoading()); // Placeholder

     final result = await _deleteAfterSalesUseCase(event.refundIds);

      result.fold(
      (failure) => emit(AfterSalesActionError(_mapFailureToMessage(failure))), // Placeholder
      (_) => emit(AfterSalesActionSuccess()), // Placeholder
    );
  }

   // Helper to map Failure objects to user-friendly messages
   String _mapFailureToMessage(Failure failure) {
     switch (failure.runtimeType) {
       case ServerFailure:
         return (failure as ServerFailure).message ?? '服务器错误';
       case CacheFailure:
         return '缓存错误';
       case NetworkFailure:
         return '网络连接错误';
        case SimpleFailure:
          return (failure as SimpleFailure).message;
       default:
         return '发生未知错误';
     }
   }

} 
