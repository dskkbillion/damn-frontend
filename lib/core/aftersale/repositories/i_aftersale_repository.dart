import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';

/// Represents the simplified, high-level status of an after-sale process for an order.
/// Used primarily by other modules (like Orders) to display basic status indicators.
enum SimpleAfterSaleStatus {
  /// No after-sale process initiated or applicable.
  none,
  /// An after-sale process (refund/return) is currently in progress.
  processing,
  /// An after-sale process has been completed (e.g., refunded, return finished).
  completed,
  /// An after-sale application was rejected or closed without completion.
  closed,
}

/// Defines the essential after-sale service interactions needed by other modules (initially Orders).
/// More specific methods (applyRefund, getRefundDetail etc.) will be added as the
/// AfterSale feature module and its Domain layer are fully defined.
abstract class IAfterSaleRepository {

  /// Gets a simplified after-sale status for a given order ID.
  ///
  /// This allows modules like Orders to display a basic status indicator without
  /// needing the full details of the after-sale process.
  /// Returns [SimpleAfterSaleStatus.none] if no relevant after-sale record exists for the order.
  ///
  /// [orderId] The ID of the order to check.
  Future<Either<Failure, SimpleAfterSaleStatus>> getSimpleOrderAfterSaleStatus(String orderId);

  // --- Methods to be defined later when AfterSale Domain is detailed ---
  // Future<Either<Failure, void>> applyRefund(RefundApplyData applyData);
  // Future<Either<Failure, RefundInfo>> getRefundDetail({String? refundId, String? orderId});
  // Future<Either<Failure, void>> cancelRefund(String refundId);
  // Future<Either<Failure, List</*RefundListItem*/>>> getAfterSaleList({...});
  // Future<Either<Failure, bool>> canApplyAfterSale(String orderId); // Eligibility check might live here too
} 