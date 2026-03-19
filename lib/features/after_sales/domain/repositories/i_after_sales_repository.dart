import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/after_sales_application.dart';

// TODO: Consider defining specific Filter/Pagination Params later
class GetAfterSalesListParams extends Equatable {
  final int page;
  final int pageSize;
  final String? stateFilter; // e.g., "WAIT_AUDIT", "AUDIT_PASS" etc.

  const GetAfterSalesListParams({
    required this.page,
    required this.pageSize,
    this.stateFilter,
  });

  @override
  List<Object?> get props => [page, pageSize, stateFilter];
}

class ApplyAfterSalesParams extends Equatable {
  final int orderItemId;
  final String refundType; // "ONLY_MONEY" or "MONEY_AND_PRODUCT"
  final String refundReason;
  final String refundExplain;
  final List<String>? refundImage; // List of uploaded image URLs

  const ApplyAfterSalesParams({
    required this.orderItemId,
    required this.refundType,
    required this.refundReason,
    required this.refundExplain,
    this.refundImage,
  });

  @override
  List<Object?> get props => [
        orderItemId,
        refundType,
        refundReason,
        refundExplain,
        refundImage,
      ];
}


abstract class IAfterSalesRepository {
  /// Applies for after-sales (refund).
  /// Corresponds to POST /api/shop/order-refund/apply
  /// Returns the ID of the newly created application upon success.
  Future<Either<Failure, int>> applyForAfterSales(ApplyAfterSalesParams params);

  /// Fetches a list of after-sales applications for the current buyer.
  /// Corresponds to POST /api/shop/order-refund/list
  Future<Either<Failure, List<AfterSalesApplication>>> getAfterSalesList(
      GetAfterSalesListParams params);

  /// Fetches the details of a specific after-sales application.
  /// Corresponds to GET /api/shop/order-refund/detail?id={refundId}
  Future<Either<Failure, AfterSalesApplication>> getAfterSalesDetail(int refundId);

  /// Cancels an ongoing after-sales application.
  /// Corresponds to POST /api/shop/order-refund/cancel (assuming POST based on RN)
  Future<Either<Failure, void>> cancelAfterSales(int refundId);

  /// Applies for platform mediation on an existing after-sales application.
  /// Corresponds to POST /api/shop/order-refund/apply-mediation
  Future<Either<Failure, void>> applyMediation(int refundId);

  /// Deletes an after-sales application record (buyer side).
  /// Corresponds to POST /api/shop/order-refund/delete
  Future<Either<Failure, void>> deleteAfterSales(List<int> refundIds);

  /// Gets the refund ID for a given order ID.
  /// Returns null if no after-sales record exists for the order.
  Future<Either<Failure, int?>> getRefundIdByOrderId(int orderId);
} 
