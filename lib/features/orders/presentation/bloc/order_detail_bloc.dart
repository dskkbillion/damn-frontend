import 'package:bloc/bloc.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
// Removed INavigationService import as it might not be needed for direct navigation
// import 'package:dskk_flutter_refactor/core/navigation/services/i_navigation_service.dart';
import 'package:dskk_flutter_refactor/core/payment/services/i_payment_service.dart';
import 'package:dskk_flutter_refactor/core/payment/models/payment_models.dart';
// Import other core interfaces if needed
// import 'package:dskk_flutter_refactor/core/aftersale/repositories/i_aftersale_repository.dart';
// import 'package:dskk_flutter_refactor/core/rating/repositories/i_rating_repository.dart';
// import 'package:dskk_flutter_refactor/core/logistics/repositories/i_logistics_repository.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
// Import SimpleAfterSaleStatus if used in state
// import 'package:dskk_flutter_refactor/core/aftersale/repositories/i_aftersale_repository.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/cancel_order_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/confirm_order_receipt_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/delete_order_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/get_order_detail_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/submit_evaluation_use_case.dart';
// import 'package:dskk_flutter_refactor/features/orders/domain/usecases/save_requirement_draft_use_case.dart'; // REMOVED
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/submit_requirements_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/get_order_materials_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_materials.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_delivery.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/repositories/i_order_repository.dart'; // For AddOrderDemandParams
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:injectable/injectable.dart' hide Order;

part 'order_detail_state.dart';

/// Manages the state and business logic for the Order Detail page.
/// Handles loading order details, processing user actions (cancel, confirm, etc.),
/// and coordinating with navigation and other services.
@injectable
class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  final GetOrderDetailUseCase _getOrderDetailUseCase;
  final CancelOrderUseCase _cancelOrderUseCase;
  final ConfirmOrderReceiptUseCase _confirmOrderReceiptUseCase;
  final DeleteOrderUseCase _deleteOrderUseCase;
  // Removed _navigationService dependency
  // final INavigationService _navigationService;
  final IPaymentService _paymentService;
  final SubmitEvaluationUseCase _submitEvaluationUseCase;
  // final SaveRequirementDraftUseCase _saveRequirementDraftUseCase; // REMOVED
  final SubmitRequirementsUseCase _submitRequirementsUseCase;
  final GetOrderMaterialsUseCase _getOrderMaterialsUseCase;
  final IOrderRepository _orderRepository; // Added for platform intervention
  // Add other dependencies as needed
  // final IAfterSaleRepository _afterSaleRepository;
  // final IRatingRepository _ratingRepository;
  // final ILogisticsRepository _logisticsRepository;


  OrderDetailBloc({
    required GetOrderDetailUseCase getOrderDetailUseCase,
    required CancelOrderUseCase cancelOrderUseCase,
    required ConfirmOrderReceiptUseCase confirmOrderReceiptUseCase,
    required DeleteOrderUseCase deleteOrderUseCase,
    // Removed navigationService from constructor
    // required INavigationService navigationService,
    required IPaymentService paymentService,
    required SubmitEvaluationUseCase submitEvaluationUseCase,
    // required SaveRequirementDraftUseCase saveRequirementDraftUseCase, // REMOVED
    required SubmitRequirementsUseCase submitRequirementsUseCase,
    required GetOrderMaterialsUseCase getOrderMaterialsUseCase,
    required IOrderRepository orderRepository, // Added
    // required IAfterSaleRepository afterSaleRepository,
    // required IRatingRepository ratingRepository,
    // required ILogisticsRepository logisticsRepository,

  })  : _getOrderDetailUseCase = getOrderDetailUseCase,
        _cancelOrderUseCase = cancelOrderUseCase,
        _confirmOrderReceiptUseCase = confirmOrderReceiptUseCase,
        _deleteOrderUseCase = deleteOrderUseCase,
        // Removed assignment
        // _navigationService = navigationService,
        _paymentService = paymentService,
        _submitEvaluationUseCase = submitEvaluationUseCase,
        // _saveRequirementDraftUseCase = saveRequirementDraftUseCase, // REMOVED
        _submitRequirementsUseCase = submitRequirementsUseCase,
        _getOrderMaterialsUseCase = getOrderMaterialsUseCase,
        _orderRepository = orderRepository, // Added
        // _afterSaleRepository = afterSaleRepository,
        // _ratingRepository = ratingRepository,
        // _logisticsRepository = logisticsRepository,
        super(OrderDetailInitial()) {

    on<LoadOrderDetail>(_onLoadOrderDetail);
    on<LoadOrderMaterials>(_onLoadOrderMaterials);
    on<OrderActionRequested>(_onOrderActionRequested);
    on<SubmitRequirementsSubmitted>(_onSubmitRequirementsSubmitted);
    // on<SaveRequirementDraftRequested>(_onSaveRequirementDraftRequested); // REMOVED Handler Registration
    on<SubmitEvaluationRequested>(_onSubmitEvaluationRequested);
    // Add more event handlers as needed
    // Register handlers for GoToPayment, GoToTracking, GoToEvaluation if they have specific logic
    on<GoToPayment>(_onGoToPayment);
    on<GoToTracking>(_onGoToTracking);
    on<GoToEvaluation>(_onGoToEvaluation);
    on<PlatformInterventionRequested>(_onPlatformInterventionRequested);
    on<OrderDemandRequested>(_onOrderDemandRequested);
  }

  Future<void> _onLoadOrderDetail(LoadOrderDetail event, Emitter<OrderDetailState> emit) async {
    emit(OrderDetailLoading());
    final result = await _getOrderDetailUseCase(event.orderId);
    result.fold(
      (failure) => emit(OrderDetailError(message: 'Failed to load order details: ${failure.toString()}')),
      (order) {
        emit(OrderDetailLoaded(order: order));
        // 自动加载材料和交付数据
        add(LoadOrderMaterials(orderId: event.orderId));
      },
      // TODO: Fetch additional states like canEvaluate, afterSaleStatus here if needed
      // and include them in OrderDetailLoaded state
    );
  }

  Future<void> _onLoadOrderMaterials(LoadOrderMaterials event, Emitter<OrderDetailState> emit) async {
    if (state is! OrderDetailLoaded) {
      print('[OrderDetailBloc] Cannot load materials: State is not OrderDetailLoaded.');
      return;
    }
    
    final currentState = state as OrderDetailLoaded;
    
    try {
      final result = await _getOrderMaterialsUseCase(
        GetOrderMaterialsParams(orderId: event.orderId)
      );
      
      result.fold(
        (failure) {
          print('[OrderDetailBloc] Failed to load materials and deliveries: ${failure.toString()}');
          // 不发出错误状态，保持当前状态，只是记录错误
        },
        (materialsAndDeliveries) {
          print('[OrderDetailBloc] Loaded ${materialsAndDeliveries.materials.length} materials and ${materialsAndDeliveries.deliveries.length} deliveries');
          emit(currentState.copyWith(
            materials: materialsAndDeliveries.materials,
            deliveries: materialsAndDeliveries.deliveries,
          ));
        },
      );
    } catch (e) {
      print('[OrderDetailBloc] Exception while loading materials: $e');
    }
  }

  Future<void> _onOrderActionRequested(OrderActionRequested event, Emitter<OrderDetailState> emit) async {
    // Ensure we are in a loaded state to get the orderId correctly (though event carries it as string)
    if (state is! OrderDetailLoaded) {
       emit(const OrderDetailActionFailure(message: '无法执行操作：订单数据未加载'));
       return;
    }
    final currentState = state as OrderDetailLoaded;
    final orderIdInt = int.tryParse(event.orderId); // Parse orderId string to int

    if (orderIdInt == null) {
       emit(OrderDetailActionFailure(
           message: '无法执行操作：无效的订单 ID ${event.orderId}',
           previousState: currentState
           ));
       return;
    }

    // Emit loading state, passing previous state to keep displaying data
    emit(OrderDetailActionLoading(previousState: currentState));
    print('[OrderDetailBloc] Received OrderActionRequested: ${event.action}');

    Either<Failure, void>? result;
    bool shouldReload = false;
    bool shouldGoBack = false;
    String successMessage = '操作成功!'; // Default success message

    try {
       switch (event.action) {
         case OrderAction.confirmReceipt:
           print('[OrderDetailBloc] Calling confirmOrderReceiptUseCase...');
           result = await _confirmOrderReceiptUseCase(orderIdInt);
           shouldReload = true;
           successMessage = '确认收货成功!';
           break;
         case OrderAction.cancel:
           print('[OrderDetailBloc] Calling cancelOrderUseCase...');
           result = await _cancelOrderUseCase(orderIdInt);
           shouldGoBack = true;
           successMessage = '订单已取消';
           break;
         case OrderAction.delete:
           print('[OrderDetailBloc] Calling deleteOrderUseCase...');
           result = await _deleteOrderUseCase(orderIdInt);
           shouldGoBack = true;
           successMessage = '订单已删除';
           break;

         // --- REMOVED Navigation/Other Actions from Bloc Handling ---
         case OrderAction.goToPayment: // Keep payment logic if it does more than nav
           await _paymentService.initiatePayment(event.orderId.toString()); // Assuming service needs string
           emit(currentState); // Revert UI immediately after initiating payment
           return;
         /* REMOVED
         case OrderAction.goToAfterSale:
           // Navigation is now handled directly in the UI button
           emit(currentState); // Remove this emit
           return;
         case OrderAction.goToEvaluation:
            // Navigation is now handled directly in the UI button (or potentially by this event if it does more)
            // Let's assume this event is still used to *show* the evaluation form within the page, not navigate away
            // If it was purely for navigation, remove the case.
            // For now, let's keep it but remove the navigation service call and emit.
            print('[OrderDetailBloc] GoToEvaluation action received - UI should handle showing form.');
            emit(currentState);
           return;
         case OrderAction.goToTracking:
           // Navigation is likely handled directly in UI
           emit(currentState); // Remove this emit
           return;
         */
          // Add default case or handle unknown actions
          default:
             print('[OrderDetailBloc] Unhandled OrderAction: ${event.action}');
             emit(OrderDetailActionFailure(
                message: '未知的操作: ${event.action}',
                previousState: currentState
             ));
             return;
       }
     } catch (e) {
       // Catch potential errors during UseCase call or parsing
       print('[OrderDetailBloc] Error during action execution: ${e.toString()}');
       // Ensure correct construction of OrderDetailActionFailure
       emit(OrderDetailActionFailure(
           message: '执行操作 [${event.action}] 时出错: ${e.toString()}',
           previousState: currentState,
       ));
       return; // Stop processing on error
     }

    // --- Handle UseCase Result (Confirm, Cancel, Delete) ---
    if (result != null) {
      result.fold(
        (failure) {
          print('[OrderDetailBloc] Action [${event.action}] failed: ${failure.toString()}');
          // Ensure correct construction of OrderDetailActionFailure
          emit(OrderDetailActionFailure(
            message: _mapFailureToMessage(failure), // Use helper function
            previousState: currentState, // Show previous state on failure
          ));
        },
        (_) {
          print('[OrderDetailBloc] Action [${event.action}] succeeded.');
          // Emit success state FIRST (for SnackBar/UI feedback)
          // We will add actionType to the State definition next.
          emit(OrderDetailActionSuccess(
              message: successMessage,
              updatedState: currentState, // Can keep showing old state until reload/nav
              actionType: event.action // Provide the action type
              ));

          // The UI layer (BlocListener) should handle the actual reload/navigation
          // based on the presence of OrderDetailActionSuccess and potentially the actionType.
        },
      );
    } else {
       // This case might happen if goToPayment was the action
       print('[OrderDetailBloc] Action [${event.action}] had null result or was handled directly.');
       // State was already reverted or handled
    }
  }

  Future<void> _onSubmitRequirementsSubmitted(
    SubmitRequirementsSubmitted event,
    Emitter<OrderDetailState> emit,
  ) async {
     if (state is! OrderDetailLoaded) {
        print('[OrderDetailBloc] Cannot submit requirements: State is not OrderDetailLoaded.');
        emit(const OrderDetailError(message: '无法提交要求：订单数据未加载'));
        return;
     }
     final currentState = state as OrderDetailLoaded;
     print('[OrderDetailBloc] Received SubmitRequirementsSubmitted event...');
     emit(currentState.copyWith(isSubmittingRequirements: true));

     // Call the SubmitRequirementsUseCase with correct event properties
      final result = await _submitRequirementsUseCase(
        SubmitRequirementsParams(
          orderId: event.orderId,
          // Use feature and attachmentPaths from the updated event
          productId: event.productId, // Use event.productId
          feature: event.feature, // Use event.feature
          attachmentPaths: event.attachmentPaths,
        ),
      );

      result.fold(
         (failure) {
           print('[OrderDetailBloc] SubmitRequirementsUseCase failed: ${failure.toString()}');
           emit(OrderDetailActionFailure(
             message: '提交要求失败: ${failure.toString()}',
             previousState: currentState.copyWith(isSubmittingRequirements: false),
           ));
         },
         (_) {
            print('[OrderDetailBloc] SubmitRequirementsUseCase succeeded.');
            // Emit success state with the correct action type
            emit(OrderDetailActionSuccess(
              message: '要求提交成功!',
              actionType: OrderAction.submitRequirements,
              updatedState: currentState.copyWith(isSubmittingRequirements: false)
            ));
            // Optionally trigger reload if needed
            // add(LoadOrderDetail(orderId: int.parse(event.orderId)));
         }
      );
  }

  Future<void> _onSubmitEvaluationRequested(SubmitEvaluationRequested event, Emitter<OrderDetailState> emit) async {
    if (state is! OrderDetailLoaded) {
      emit(const OrderDetailActionFailure(message: '无法提交评价：订单数据未加载'));
      return;
    }
    final currentState = state as OrderDetailLoaded;

    // Emit loading state by updating the flag in OrderDetailLoaded
    emit(currentState.copyWith(isSubmittingEvaluation: true));
    print('[OrderDetailBloc] Submitting evaluation...');

    try {
      final result = await _submitEvaluationUseCase(event.params);

      result.fold(
        (failure) {
          print('[OrderDetailBloc] Evaluation submission failed: ${failure.toString()}');
          // Emit failure state, resetting the loading flag
          emit(OrderDetailActionFailure(
            message: _mapFailureToMessage(failure, defaultMsg: '评价提交失败'),
            previousState: currentState.copyWith(isSubmittingEvaluation: false), // Reset flag
          ));
        },
        (_) {
          print('[OrderDetailBloc] Evaluation submitted successfully.');
          // Emit success state FIRST (for SnackBar)
          emit(OrderDetailActionSuccess(
            message: '评价提交成功!',
            actionType: OrderAction.submitEvaluation, // Assuming OrderAction has this value
            // No need to pass updatedState, BlocListener will trigger reload
          ));
          // Reloading is handled by BlocListener based on OrderDetailActionSuccess
        },
      );
    } catch (e) {
       print('[OrderDetailBloc] Exception during evaluation submission: ${e.toString()}');
        // Emit failure state in case of unexpected exceptions, resetting the loading flag
       emit(OrderDetailActionFailure(
          message: '评价提交时发生意外错误: ${e.toString()}', // Provide error message
          previousState: currentState.copyWith(isSubmittingEvaluation: false), // Reset flag
        ));
    }
  }

  // --- Other Handlers (GoToPayment, GoToTracking, GoToEvaluation) ---
  // Implement these if they need specific Bloc logic beyond just UI navigation handled by buttons

  Future<void> _onGoToPayment(GoToPayment event, Emitter<OrderDetailState> emit) async {
     // 如果当前状态不是已加载，无法进行支付
     if (state is! OrderDetailLoaded) {
        emit(const OrderDetailError(message: '无法进行支付：订单数据未加载'));
        return;
     }
     final currentState = state as OrderDetailLoaded;
     final order = currentState.order;
     
     // 检查订单状态是否允许支付
     if (order.state != OrderStatus.awaitingPayment) {
        print('[OrderDetailBloc] 订单状态不允许支付: ${order.state}');
        emit(OrderDetailActionFailure(
          message: '该订单状态不允许支付',
          previousState: currentState,
        ));
        return;
     }
     
     print('[OrderDetailBloc] Initiating payment for order ${event.orderId}');
     
     // 发出支付中状态
     emit(OrderDetailPaymentLoading(previousState: currentState));
     
     try {
        // 从订单中获取实际金额和商品信息
        final payAmount = order.priceSummary.payPrice;
        final productName = order.items.isNotEmpty ? order.items.first.productName : '商品订单';
        
        // 调用支付服务创建支付 - 使用区域配置的默认支付方式
        final supportedMethods = RegionConfig.supportedPaymentMethods;
        final defaultPaymentMethod = supportedMethods.isNotEmpty 
            ? supportedMethods.first 
            : PaymentMethod.alipay;
            
        final paymentRequest = PaymentRequest(
          orderId: event.orderId.toString(),
          amount: payAmount.toStringAsFixed(2), // 使用实际订单金额
          subject: productName,
          description: '订单号: ${order.orderSn}',
          method: defaultPaymentMethod,
          scene: PaymentScene.order,
        );
        
        final response = await _paymentService.createPayment(paymentRequest);
        
        // 发出支付结果状态，让UI层处理导航
        emit(OrderDetailPaymentResult(
          paymentResponse: response,
          previousState: currentState,
        ));
        
     } catch (e) {
        print('[OrderDetailBloc] Error initiating payment: $e');
        emit(OrderDetailActionFailure(
          message: '发起支付失败: $e',
          previousState: currentState,
        ));
     }
  }

  Future<void> _onGoToTracking(GoToTracking event, Emitter<OrderDetailState> emit) async {
     // Usually navigation is handled in UI. Add logic here if Bloc needs to do something.
     print('[OrderDetailBloc] GoToTracking requested for order ${event.orderId}. Navigation handled by UI.');
     // Perhaps emit a state to signal UI to navigate?
     // emit(NavigateToTrackingState(orderId: event.orderId));
  }

    Future<void> _onGoToEvaluation(GoToEvaluation event, Emitter<OrderDetailState> emit) async {
     // Similar to tracking, often UI handles showing the form.
     // Add logic if Bloc needs to prepare something before evaluation.
     print('[OrderDetailBloc] GoToEvaluation requested for order ${event.orderId}. UI should handle showing the form.');
     // emit(ShowEvaluationFormState(orderId: event.orderId));
  }

  Future<void> _onPlatformInterventionRequested(
    PlatformInterventionRequested event,
    Emitter<OrderDetailState> emit,
  ) async {
    if (state is! OrderDetailLoaded) {
      emit(const OrderDetailError(message: '无法提交平台介入：订单数据未加载'));
      return;
    }
    
    final currentState = state as OrderDetailLoaded;
    emit(OrderDetailActionLoading(previousState: currentState));
    
    try {
      // 调用repository的addOrderDemand方法，type为'platform'
      final params = AddOrderDemandParams(
        orderId: event.orderId,
        type: 'platform',
        reasonValue: event.reasonValue,
        reasonLabel: event.reasonLabel,
        remarks: event.description,
      );
      
      // 调用真实的repository方法
      final result = await _orderRepository.addOrderDemand(params);
      
      result.fold(
        (failure) {
          emit(OrderDetailActionFailure(
            message: '平台介入申请失败: ${_mapFailureToMessage(failure)}',
            previousState: currentState,
          ));
        },
        (_) {
          emit(OrderDetailActionSuccess(
            message: '平台介入申请已提交，客服会在24小时内联系您',
            actionType: OrderAction.platformIntervention,
            updatedState: currentState,
          ));
          
          // 触发重新加载
          add(LoadOrderDetail(orderId: event.orderId));
        },
      );
    } catch (e) {
      emit(OrderDetailActionFailure(
        message: '平台介入申请失败: $e',
        previousState: currentState,
      ));
    }
  }
  
  Future<void> _onOrderDemandRequested(
    OrderDemandRequested event,
    Emitter<OrderDetailState> emit,
  ) async {
    if (state is! OrderDetailLoaded) {
      emit(const OrderDetailError(message: '无法提交申请：订单数据未加载'));
      return;
    }
    
    final currentState = state as OrderDetailLoaded;
    emit(OrderDetailActionLoading(previousState: currentState));
    
    try {
      // 调用repository的addOrderDemand方法
      final params = AddOrderDemandParams(
        orderId: event.orderId,
        type: event.type,
        reasonValue: event.reasonValue,
        reasonLabel: event.reasonLabel,
        remarks: event.description,
      );
      
      // 调用真实的repository方法
      final result = await _orderRepository.addOrderDemand(params);
      
      result.fold(
        (failure) {
          emit(OrderDetailActionFailure(
            message: '申请提交失败: ${_mapFailureToMessage(failure)}',
            previousState: currentState,
          ));
        },
        (_) {
          final message = event.type == 'replenishment' 
            ? '补充材料申请已提交，卖家会在24小时内回复'
            : '重做申请已提交，卖家会重新处理您的订单';
          
          emit(OrderDetailActionSuccess(
            message: message,
            actionType: OrderAction.orderDemand,
            updatedState: currentState,
          ));
          
          // 触发重新加载
          add(LoadOrderDetail(orderId: event.orderId));
        },
      );
    } catch (e) {
      emit(OrderDetailActionFailure(
        message: '申请提交失败: $e',
        previousState: currentState,
      ));
    }
  }

  // --- Helper Function to map Failure to String ---
  // TODO: Move this to a shared utility or base bloc if common
  String _mapFailureToMessage(Failure failure, {String defaultMsg = '操作失败'}) {
    // Base Failure might not have a message, check specific types
    if (failure is ServerFailure) {
       // Assuming ServerFailure has a message property
       return failure.message ?? defaultMsg;
    } else if (failure is CacheFailure) {
       return '缓存错误，请清理缓存后重试'; // CacheFailure might not have a specific message
    } else if (failure is NetworkFailure) {
       return '网络连接错误，请检查您的网络连接'; // NetworkFailure implies connection issue
    } else {
       // Handle generic Failure or other specific types
       print('[OrderDetailBloc] Unmapped Failure type: ${failure.runtimeType}');
       return defaultMsg; // Generic fallback
    }
  }
}


// --- Event Definitions (Top Level) ---

/// Base class for Order Detail events.
abstract class OrderDetailEvent extends Equatable {
  const OrderDetailEvent();
   @override
  List<Object?> get props => [];
}

/// Event to load the details for a specific order.
class LoadOrderDetail extends OrderDetailEvent {
  final int orderId; // Changed to int to match use case
  const LoadOrderDetail({required this.orderId});
   @override
  List<Object?> get props => [orderId];
}

/// Event to load materials and deliveries for a specific order.
class LoadOrderMaterials extends OrderDetailEvent {
  final int orderId;
  const LoadOrderMaterials({required this.orderId});
  @override
  List<Object?> get props => [orderId];
}

/// Event to trigger cancelling an order.
class CancelOrder extends OrderDetailEvent {
  final int orderId;
  const CancelOrder({required this.orderId});
   @override
  List<Object?> get props => [orderId];
}

/// Event to trigger confirming receipt of an order.
class ConfirmReceipt extends OrderDetailEvent {
   final int orderId;
  const ConfirmReceipt({required this.orderId});
   @override
  List<Object?> get props => [orderId];
}

/// Event to trigger deleting an order.
class DeleteOrder extends OrderDetailEvent {
   final int orderId;
  const DeleteOrder({required this.orderId});
   @override
  List<Object?> get props => [orderId];
}

/// Event to trigger navigation to the payment flow.
class GoToPayment extends OrderDetailEvent {
  final int orderId; // Changed to int
  const GoToPayment({required this.orderId});
   @override
  List<Object?> get props => [orderId];
}

/// Event to trigger navigation to the after-sale application flow.
class GoToAfterSale extends OrderDetailEvent {
  final int orderId; // Changed to int
  const GoToAfterSale({required this.orderId});
   @override
  List<Object?> get props => [orderId];
}

/// Event to trigger navigation to the evaluation submission flow.
class GoToEvaluation extends OrderDetailEvent {
  final int orderId; // Changed to int
  const GoToEvaluation({required this.orderId});
   @override
  List<Object?> get props => [orderId];
}

/// Event to trigger navigation to the tracking details view.
class GoToTracking extends OrderDetailEvent {
  final int orderId; // Changed to int
  const GoToTracking({required this.orderId});
   @override
  List<Object?> get props => [orderId];
}

/// Event triggered when the user submits an evaluation for an order item.
class SubmitEvaluationRequested extends OrderDetailEvent {
  final SubmitEvaluationParams params;
  const SubmitEvaluationRequested({required this.params});

  @override
  List<Object?> get props => [params];
}

// Add other events 

// Event for platform intervention request
class PlatformInterventionRequested extends OrderDetailEvent {
  final int orderId;
  final String reasonValue;
  final String reasonLabel;
  final String description;
  
  const PlatformInterventionRequested({
    required this.orderId,
    required this.reasonValue,
    required this.reasonLabel,
    required this.description,
  });
  
  @override
  List<Object?> get props => [orderId, reasonValue, reasonLabel, description];
}

// Event for order demand (replenishment/reform) request
class OrderDemandRequested extends OrderDetailEvent {
  final int orderId;
  final String type; // 'replenishment' or 'reform'
  final String reasonValue;
  final String reasonLabel;
  final String description;
  
  const OrderDemandRequested({
    required this.orderId,
    required this.type,
    required this.reasonValue,
    required this.reasonLabel,
    required this.description,
  });
  
  @override
  List<Object?> get props => [orderId, type, reasonValue, reasonLabel, description];
}

// Define OrderAction enum if not already defined
enum OrderAction {
  cancel,
  confirmReceipt,
  delete,
  goToPayment,
  goToAfterSale,
  goToEvaluation,
  goToTracking,
  submitRequirements,
  submitEvaluation,
  platformIntervention,
  orderDemand,
  // Add other actions as needed ONLY ONCE
}

class OrderActionRequested extends OrderDetailEvent {
  final OrderAction action;
  final String orderId;
  const OrderActionRequested({required this.action, required this.orderId});
  @override
  List<Object> get props => [action, orderId];
}

class SubmitRequirementsSubmitted extends OrderDetailEvent {
   final String orderId;
   // Add new fields based on API
   final int productId;
   final List<Map<String, String>> feature;
   final List<String> attachmentPaths;

   const SubmitRequirementsSubmitted({
     required this.orderId,
     required this.productId,
     required this.feature,
     required this.attachmentPaths,
   });

  @override
  // Update props
  List<Object?> get props => [orderId, productId, feature, attachmentPaths];
}

// Remove other specific event classes like CancelOrder, ConfirmReceipt if they are handled by OrderActionRequested
