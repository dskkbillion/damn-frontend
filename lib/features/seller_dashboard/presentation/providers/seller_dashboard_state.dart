import 'package:equatable/equatable.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart'; // Corrected import
import 'package:dskk_flutter_refactor/features/seller_dashboard/domain/entities/seller_dashboard_data.dart'; // Corrected import

enum SellerDashboardStatus { initial, loading, success, failure }

class SellerDashboardState extends Equatable {
  final SellerDashboardStatus status;
  final SellerDashboardData? data;
  final Failure? failure;

  const SellerDashboardState({
    this.status = SellerDashboardStatus.initial,
    this.data,
    this.failure,
  });

  // Optional:copyWith method for easier state updates
  SellerDashboardState copyWith({
    SellerDashboardStatus? status,
    SellerDashboardData? data,
    Failure? failure,
    bool clearFailure = false, // Helper to clear failure on retry etc.
  }) {
    return SellerDashboardState(
      status: status ?? this.status,
      data: data ?? this.data,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, data, failure];
} 