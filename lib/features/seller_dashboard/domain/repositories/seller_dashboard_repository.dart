import 'package:dartz/dartz.dart';

import 'package:dskk_flutter_refactor/core/error/failures.dart'; // Corrected import
import '../entities/seller_dashboard_data.dart';

/// Abstract contract for fetching seller dashboard data.
/// The implementation resides in the Data layer.
abstract class ISellerDashboardRepository {
  /// Fetches the consolidated data for the seller dashboard.
  ///
  /// Returns [Either] a [Failure] if an error occurs,
  /// or the [SellerDashboardData].
  Future<Either<Failure, SellerDashboardData>> getDashboardData();
} 