part of 'after_sales_bloc.dart';

/// Represents the overall status or specific focus of the AfterSalesBloc.
/// Used to determine which part of the UI state is currently relevant.
enum AfterSalesStatus {
  initial, // Initial state before any loading
  listLoading, // Loading the list of applications
  listLoaded, // List loaded successfully
  listError, // Error loading the list
  detailLoading, // Loading details of a specific application
  detailLoaded, // Detail loaded successfully
  detailError, // Error loading detail
  actionLoading, // Performing an action (apply, cancel, delete)
  actionSuccess, // Action completed successfully
  actionError // Error performing an action
}

// Base state
abstract class AfterSalesState extends Equatable {
  final AfterSalesStatus status;
  final String? errorMessage; // Generic error message for list/action failures
  final String? actionSuccessMessage; // Message for successful actions

  const AfterSalesState({
    required this.status,
    this.errorMessage,
    this.actionSuccessMessage,
  });

  @override
  List<Object?> get props => [status, errorMessage, actionSuccessMessage];
}

// Initial State
class AfterSalesInitial extends AfterSalesState {
  const AfterSalesInitial() : super(status: AfterSalesStatus.initial);
}

// --- List States ---

class AfterSalesListLoading extends AfterSalesState {
  const AfterSalesListLoading() : super(status: AfterSalesStatus.listLoading);
}

class AfterSalesListLoaded extends AfterSalesState {
  final List<AfterSalesApplication> applications;
  // TODO: Add bool hasReachedMax for pagination control
  final bool hasReachedMax;

  const AfterSalesListLoaded(this.applications, {this.hasReachedMax = false})
      : super(status: AfterSalesStatus.listLoaded);

  @override
  List<Object?> get props => [status, applications, hasReachedMax];
}

class AfterSalesListError extends AfterSalesState {
  const AfterSalesListError(String message)
      : super(status: AfterSalesStatus.listError, errorMessage: message);

   @override
  List<Object?> get props => [status, errorMessage];
}


// --- Detail States ---

class AfterSalesDetailLoading extends AfterSalesState {
   final String loadingId; // Keep track of which ID is loading
   const AfterSalesDetailLoading(this.loadingId) : super(status: AfterSalesStatus.detailLoading);

   @override
  List<Object?> get props => [status, loadingId];
}

class AfterSalesDetailLoaded extends AfterSalesState {
  final AfterSalesApplication application;
  const AfterSalesDetailLoaded(this.application) : super(status: AfterSalesStatus.detailLoaded);

  @override
  List<Object?> get props => [status, application];
}

class AfterSalesDetailError extends AfterSalesState {
  final String id; // ID of the application that failed to load
  const AfterSalesDetailError({required this.id, required String message})
      : super(status: AfterSalesStatus.detailError, errorMessage: message);

   @override
  List<Object?> get props => [status, id, errorMessage];
}


// --- Action States ---
// Used for Apply, Cancel, Delete operations

class AfterSalesActionLoading extends AfterSalesState {
  const AfterSalesActionLoading() : super(status: AfterSalesStatus.actionLoading);
}

class AfterSalesActionSuccess extends AfterSalesState {
  final String? newId; // Optional: ID of newly created application after Apply
  const AfterSalesActionSuccess({this.newId, String? message})
      : super(status: AfterSalesStatus.actionSuccess, actionSuccessMessage: message);

  @override
  List<Object?> get props => [status, newId, actionSuccessMessage];
}

class AfterSalesActionError extends AfterSalesState {
  const AfterSalesActionError(String message)
      : super(status: AfterSalesStatus.actionError, errorMessage: message);

  @override
  List<Object?> get props => [status, errorMessage];
} 