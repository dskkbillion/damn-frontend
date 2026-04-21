import 'package:equatable/equatable.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart'; // Assuming Failure is needed
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart'; // Import the Order entity

// Define the possible statuses for loading the order detail
enum OrderDetailStatus { initial, loading, success, failure }

// Define the possible statuses for actions performed on the order (e.g., cancel, confirm)
enum OrderActionStatus { idle, loading, success, failure }

/// Represents the state for the Order Detail feature.
class OrderDetailState extends Equatable {
  final OrderDetailStatus status;
  final OrderActionStatus actionStatus;
  final Order? order; // The loaded order detail
  final Failure? failure; // Failure object if status is failure
  final Failure? actionFailure; // Failure object if actionStatus is failure

  const OrderDetailState({
    this.status = OrderDetailStatus.initial,
    this.actionStatus = OrderActionStatus.idle,
    this.order,
    this.failure,
    this.actionFailure,
  });

  // Helper method to create a copy of the state with updated values
  OrderDetailState copyWith({
    OrderDetailStatus? status,
    OrderActionStatus? actionStatus,
    Order? order,
    Failure? failure,
    Failure? actionFailure,
    bool clearFailure = false, // Flag to explicitly clear failure
    bool clearActionFailure = false, // Flag to explicitly clear actionFailure
    bool clearOrder = false, // Flag to explicitly clear order
  }) {
    return OrderDetailState(
      status: status ?? this.status,
      actionStatus: actionStatus ?? this.actionStatus,
      // Handle clearing the order explicitly
      order: clearOrder ? null : (order ?? this.order), 
      // Handle clearing failures explicitly
      failure: clearFailure ? null : (failure ?? this.failure),
      actionFailure: clearActionFailure ? null : (actionFailure ?? this.actionFailure),
    );
  }

  @override
  List<Object?> get props => [status, actionStatus, order, failure, actionFailure];
} 