part of 'order_detail_bloc.dart';

/// Defines the various states for the [OrderDetailBloc].
/// These states represent the UI state of the Order Detail page,
/// including loading, loaded data, errors, and action processing.

/// Base class for Order Detail states.
abstract class OrderDetailState extends Equatable {
  const OrderDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class OrderDetailInitial extends OrderDetailState {}

/// State indicating that the order details are loading.
class OrderDetailLoading extends OrderDetailState {}

/// State representing successfully loaded order details.
class OrderDetailLoaded extends OrderDetailState {
  final Order order;
  // Add flags for specific ongoing actions
  final bool isSubmittingRequirements;
  final bool isSavingDraft;
  final bool isSubmittingEvaluation;
  // Add other relevant data if needed, e.g., canEvaluate, afterSaleStatus
  // final bool canEvaluate;
  // final SimpleAfterSaleStatus afterSaleStatus;

  const OrderDetailLoaded({
    required this.order,
    this.isSubmittingRequirements = false, // Default to false
    this.isSavingDraft = false, // Default to false
    this.isSubmittingEvaluation = false, // Add this field
    // this.canEvaluate = false,
    // this.afterSaleStatus = SimpleAfterSaleStatus.none,
  });

  @override
  List<Object?> get props => [order, isSubmittingRequirements, isSavingDraft, isSubmittingEvaluation /*, canEvaluate, afterSaleStatus*/];

  // Optional copyWith method
  OrderDetailLoaded copyWith({
    Order? order,
    bool? isSubmittingRequirements,
    bool? isSavingDraft,
    bool? isSubmittingEvaluation,
    // bool? canEvaluate,
    // SimpleAfterSaleStatus? afterSaleStatus,
  }) {
    return OrderDetailLoaded(
      order: order ?? this.order,
      isSubmittingRequirements: isSubmittingRequirements ?? this.isSubmittingRequirements,
      isSavingDraft: isSavingDraft ?? this.isSavingDraft,
      isSubmittingEvaluation: isSubmittingEvaluation ?? this.isSubmittingEvaluation,
      // canEvaluate: canEvaluate ?? this.canEvaluate,
      // afterSaleStatus: afterSaleStatus ?? this.afterSaleStatus,
    );
  }
}

/// State representing an error loading order details.
class OrderDetailError extends OrderDetailState {
  final String message;
  const OrderDetailError({required this.message});
   @override
  List<Object?> get props => [message];
}

/// State indicating an action (like cancel, confirm) is being processed.
class OrderDetailActionLoading extends OrderDetailState {
  // Optionally include the previous loaded state to keep showing data
  final OrderDetailLoaded? previousState;
  const OrderDetailActionLoading({this.previousState});
   @override
  List<Object?> get props => [previousState];
}

/// State indicating an action was successful.
class OrderDetailActionSuccess extends OrderDetailState {
   final String message;
   // Optionally include the updated loaded state
   final OrderDetailLoaded? updatedState;
   // Add the type of action that succeeded
   final OrderAction actionType;

   const OrderDetailActionSuccess({
     required this.message,
     required this.actionType, // Make it required
     this.updatedState
     });

    @override
  List<Object?> get props => [message, updatedState, actionType];
}

/// State indicating an action failed.
class OrderDetailActionFailure extends OrderDetailState {
  final String message;
  // Optionally include the state before the action failed
  final OrderDetailLoaded? previousState;
  const OrderDetailActionFailure({required this.message, this.previousState});
   @override
  List<Object?> get props => [message, previousState];
} 