import 'package:dartz/dartz.dart' hide Order; // 隐藏 dartz 中的 Order
import 'package:equatable/equatable.dart'; // Add Equatable import

import '../../../../core/error/failures.dart'; // 现在这个路径应该有效了
import '../entities/order.dart';
import '../entities/order_status.dart';
// 导入 UseCase 中的 Params 定义
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/submit_requirements_use_case.dart';
import '../entities/order_creation_result.dart';

// Define Params classes for complex operations

class AddOrderDemandParams extends Equatable { // Make Equatable
  final int orderId;
  final String type; // e.g., 'refuse', 'material'
  final String reasonValue;
  final String reasonLabel;
  final String? remarks;
  // Add other fields if needed based on API: files, etc.

  AddOrderDemandParams({
    required this.orderId,
    required this.type,
    required this.reasonValue,
    required this.reasonLabel,
    this.remarks,
  });

  @override
  List<Object?> get props => [orderId, type, reasonValue, reasonLabel, remarks]; // Add props
}

class DeliverOrderParams extends Equatable { // Make Equatable
  final int orderId;
  final String content;
  final List<String> files; // Assuming file paths or identifiers
  // Add fields for shipping info
  final String? deliverySn;
  final String? deliveryCompany;

  DeliverOrderParams({
    required this.orderId,
    required this.content,
    required this.files,
    this.deliverySn, // Add to constructor
    this.deliveryCompany, // Add to constructor
  });

  @override
  List<Object?> get props => [orderId, content, files, deliverySn, deliveryCompany]; // Add to props
}

/// 定义订单模块的数据访问契约。
///
/// 此接口定义了 Orders 模块需要对数据执行的操作，
/// 而不关心数据的来源 (远程 API、本地缓存等)。
abstract class IOrderRepository {
  /// 获取订单列表。
  ///
  /// 可以根据状态 [status]、关键词 [keyword] 进行筛选，
  /// 并支持分页 ([page] 和 [limit])。
  /// 返回一个包含订单列表的 [Either] 对象，或者一个 [Failure]。
  Future<Either<Failure, List<Order>>> getOrderList({
    OrderStatus? status,
    String? keyword,
    required int page,
    required int limit,
    required String userRole,
  });

  /// 获取指定 ID 的订单详情。
  ///
  /// 返回包含订单详情的 [Either] 对象，或者一个 [Failure]。
  Future<Either<Failure, Order>> getOrderDetail(int orderId);

  /// 取消指定 ID 的订单。
  ///
  /// 返回一个空的 [Either] 表示成功，或者一个 [Failure]。
  Future<Either<Failure, void>> cancelOrder(int orderId);

  /// 确认收到指定 ID 的订单货品。
  ///
  /// 返回一个空的 [Either] 表示成功，或者一个 [Failure]。
  Future<Either<Failure, void>> confirmOrderReceipt(int orderId);

  /// 删除指定 ID 的订单 (逻辑或物理删除)。
  ///
  /// 返回一个空的 [Either] 表示成功，或者一个 [Failure]。
  Future<Either<Failure, void>> deleteOrder(int orderId);

  /// Submits an evaluation for a specific order item.
  Future<Either<Failure, void>> addEvaluation({
    required int orderItemId,
    required double score,
    required String content,
    required bool isAnonymous,
    required List<String> pictures,
  });

  /// Buyer submits requirements (e.g., text, attachments) for a service order.
  /// Uses [SubmitRequirementsParams] which should be defined elsewhere or passed directly.
  Future<Either<Failure, void>> submitRequirements(SubmitRequirementsParams params);

  /// Buyer saves a draft of requirements locally (implementation specific).
  Future<Either<Failure, void>> saveRequirementDraft(/* DraftParams params */);

  /// Seller confirms acceptance of the order.
  /// Corresponds to RN `verifyOrder` action. API endpoint is currently unclear.
  Future<Either<Failure, void>> confirmOrderAcceptance(int orderId);

  /// Seller submits a demand/application (e.g., reject order, request supplement).
  /// Calls `POST /api/project/orderDemand/add`.
  Future<Either<Failure, void>> addOrderDemand(AddOrderDemandParams params);

  /// Seller delivers the order (submits deliverables).
  /// Calls `POST /api/project/orderDelivery/add`.
  Future<Either<Failure, void>> deliverOrder(DeliverOrderParams params);

  /// Seller deletes their view of an order record.
  /// Calls `POST /api/shop/order/sellerDelete`.
  Future<Either<Failure, void>> deleteSellerOrderRecord(int orderId);

  /// Seller invites the buyer to evaluate the order.
  /// API endpoint needs confirmation.
  Future<Either<Failure, void>> inviteEvaluation(int orderId);

  /// 创建订单
  /// 
  /// 参数：
  /// [productId] - 商品ID
  /// [variantId] - 商品变体ID
  /// [quantity] - 数量
  /// [sellerId] - 卖家ID
  /// [price] - 价格
  /// 
  /// 返回 [OrderCreationResult] 或 [Failure]
  Future<Either<Failure, OrderCreationResult>> createOrder({
    required int productId,
    required int variantId,
    required int quantity,
    required int sellerId,
    required double price,
  });

  // 可选：根据需要添加其他接口方法，例如：
  // Future<Either<Failure, void>> submitMaterials(int orderId, ...);
  // Future<Either<Failure, void>> evaluateOrder(int orderId, ...);
} 