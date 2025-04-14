import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart'; // Or your core Failure/Entity base imports

import 'package:dskk_flutter_refactor/core/error/failures.dart'; // Corrected import
import '../entities/seller_dashboard_data.dart';
import '../repositories/seller_dashboard_repository.dart'; // Import the repository interface

// Use cases should usually have a call method to make them callable like a function.
abstract class GetSellerDashboardData {
   /// Fetches and consolidates the data for the seller dashboard.
  Future<Either<Failure, SellerDashboardData>> call();
  // If the use case required parameters, they would go into the call method, e.g., call(Params params)
  // For this dashboard, it seems no parameters are needed for the initial load.
}

// Example of Params class if needed in the future (not needed now):
// class Params extends Equatable {
//   final String userId; // Example parameter
//
//   const Params({required this.userId});
//
//   @override
//   List<Object?> get props => [userId];
// }


// --- Implementation will go in the application layer or domain layer if simple ---
// This is just the interface definition for the Domain layer.
// A concrete class implementing this interface will be created later.
// e.g., in lib/features/seller_dashboard/domain/usecases/get_seller_dashboard_data_impl.dart
// or directly in the application layer if using a simpler structure.

/// Concrete implementation of the [GetSellerDashboardData] use case.
class GetSellerDashboardDataImpl implements GetSellerDashboardData {
  final ISellerDashboardRepository repository;

  /// Creates an instance of [GetSellerDashboardDataImpl].
  ///
  /// Requires an instance of [ISellerDashboardRepository] to fetch data.
  GetSellerDashboardDataImpl(this.repository);

  @override
  Future<Either<Failure, SellerDashboardData>> call() async {
    // The core logic resides in the repository.
    // This use case simply orchestrates the call.
    return await repository.getDashboardData();
  }
}

/*
Example Implementation (to be created later in Step 6):

class GetSellerDashboardDataImpl implements GetSellerDashboardData {
  final ISellerDashboardRepository repository;

  GetSellerDashboardDataImpl(this.repository);

  @override
  Future<Either<Failure, SellerDashboardData>> call() async {
    return await repository.getDashboardData();
  }
}
*/ 