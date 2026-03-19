import '../models/after_sales_application_model.dart';
import '../../domain/repositories/i_after_sales_repository.dart'; // For Params

/// Abstract interface for fetching after-sales data from the remote API.
///
/// Throws a [ServerException] for all error codes.
abstract class IAfterSalesRemoteDataSource {
  /// Calls the POST /api/shop/order-refund/apply endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  /// Returns the ID of the created application from the API response.
  Future<int> applyForAfterSales(ApplyAfterSalesParams params);

  /// Calls the POST /api/shop/order-refund/list endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<List<AfterSalesApplicationModel>> getAfterSalesList(
      GetAfterSalesListParams params);

  /// Calls the GET /api/shop/order-refund/detail?id={refundId} endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<AfterSalesApplicationModel> getAfterSalesDetail(int refundId);

  /// Calls the POST /api/shop/order-refund/cancel endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<void> cancelAfterSales(int refundId);

  /// Calls the POST /api/shop/order-refund/apply-mediation endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<void> applyMediation(int refundId);

   /// Calls the POST /api/shop/order-refund/delete endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<void> deleteAfterSales(List<int> refundIds);

  /// Gets the refund ID for a given order ID by querying the list API.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<int?> getRefundIdByOrderId(int orderId);
} 
