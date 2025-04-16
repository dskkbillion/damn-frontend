import '../../domain/entities/order_status.dart';
import '../models/order_model.dart';
import '../../domain/repositories/i_order_repository.dart';

/// 定义订单远程数据源的契约。
///
/// 此接口定义了与后端订单相关 API 直接交互的方法。
/// 实现类将负责发起 HTTP 请求并处理原始响应。
abstract class IOrderRemoteDataSource {
  /// 调用后端 API 获取订单列表。
  ///
  /// - [status]: 要筛选的订单状态 (枚举值，实现时需要转换为字符串)。
  /// - [keyword]: 搜索关键词。
  /// - [page]: 页码。
  /// - [limit]: 每页数量。
  /// - [userRole]: The role of the user making the request.
  ///
  /// 成功时返回 [List<OrderModel>]。
  /// 失败时应抛出特定异常 (如 ServerException)。
  Future<List<OrderModel>> getOrderList({
    OrderStatus? status,
    String? keyword,
    required int page,
    required int limit,
    required String userRole,
  });

  /// 调用后端 API 获取指定 ID 的订单详情。
  ///
  /// - [orderId]: 要获取的订单 ID。
  ///
  /// 成功时返回 [OrderModel]。
  /// 失败时应抛出特定异常。
  Future<OrderModel> getOrderDetail(int orderId);

  /// 调用后端 API 取消指定 ID 的订单。
  ///
  /// - [orderId]: 要取消的订单 ID。
  ///
  /// 成功时不返回特定数据。
  /// 失败时应抛出特定异常。
  Future<void> cancelOrder(int orderId);

  /// 调用后端 API 确认收到指定 ID 的订单货品。
  ///
  /// - [orderId]: 要确认收货的订单 ID。
  ///
  /// 成功时不返回特定数据。
  /// 失败时应抛出特定异常。
  Future<void> confirmOrderReceipt(int orderId);

  /// 调用后端 API 删除指定 ID 的订单。
  ///
  /// - [orderId]: 要删除的订单 ID。
  ///
  /// 成功时不返回特定数据。
  /// 失败时应抛出特定异常。
  Future<void> deleteOrder(int orderId);

  /// Adds an evaluation for a specific order item.
  Future<void> addEvaluation({
    required int orderItemId,
    required double score,
    required String content,
    required bool isAnonymous,
    required List<String> pictures,
  });

  /// Submits the final order requirements/materials.
  Future<void> submitRequirements({
    required String orderId,
    required int productId,
    required List<Map<String, String>> feature,
    required List<String> attachmentPaths,
  });

  // --- Seller specific actions ---

  /// Seller confirms acceptance of the order.
  /// API endpoint is currently unclear (might be a general status update).
  Future<void> confirmOrderAcceptance(int orderId);

  /// Seller submits a demand/application (e.g., reject order, request supplement).
  /// Calls `POST /api/project/orderDemand/add`.
  Future<void> addOrderDemand(AddOrderDemandParams params);

  /// Seller delivers the order (submits deliverables).
  /// Calls `POST /api/project/orderDelivery/add`.
  Future<void> deliverOrder(DeliverOrderParams params);

  /// Seller deletes their view of an order record.
  /// Calls `POST /api/shop/order/sellerDelete`.
  Future<void> deleteSellerOrderRecord(int orderId);

  /// Seller invites the buyer to evaluate the order.
  /// API endpoint needs confirmation.
  Future<void> inviteEvaluation(int orderId);

  // TODO: Add other seller API call signatures as needed
} 