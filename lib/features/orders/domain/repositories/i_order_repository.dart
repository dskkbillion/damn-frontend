import 'package:dartz/dartz.dart' hide Order; // 隐藏 dartz 中的 Order

import '../../../../core/error/failures.dart'; // 现在这个路径应该有效了
import '../entities/order.dart';
import '../entities/order_status.dart';

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

  /// Submits the final order requirements/materials.
  Future<Either<Failure, void>> submitRequirements({
    required String orderId,
    required int productId,
    required List<Map<String, String>> feature, // Use structured feature data
    required List<String> attachmentPaths, // Expecting URLs
  });

  // 可选：根据需要添加其他接口方法，例如：
  // Future<Either<Failure, void>> submitMaterials(int orderId, ...);
  // Future<Either<Failure, void>> evaluateOrder(int orderId, ...);
} 