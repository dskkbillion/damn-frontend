import 'dart:math';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';

import 'package:dartz/dartz.dart' hide Order;
import 'package:dskk_flutter_refactor/core/config/app_config.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_item.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_shipping_info.dart'; // Import if needed
import 'package:dskk_flutter_refactor/features/orders/domain/entities/address.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_payment_info.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_price_summary.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_creation_result.dart'; // 导入OrderCreationResult
import 'package:dskk_flutter_refactor/features/orders/domain/repositories/i_order_repository.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/submit_evaluation_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/submit_requirements_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_materials.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_delivery.dart';
import 'package:injectable/injectable.dart' hide Order;

// TODO: Consider if @LazySingleton or @Injectable is needed for this mock in preview
// @LazySingleton(as: IOrderRepository, env: [Environment.dev]) // Example if using env
class MockSellerOrderRepository implements IOrderRepository {
  final List<Order> _mockSellerOrders = [];
  final Random _random = Random();

  MockSellerOrderRepository() {
    _generateMockSellerOrders();
  }

  // Helper to create mock Address
  Address _createMockAddress(int id) => Address(
        recipientName: '模拟收件人$id',
        phone: '13800000${id.toString().padLeft(3, '0')}',
        areaId: '${610000 + id}', // Simulate some area ID
        detailAddress: '模拟详细地址 $id 号',
      );

  // Helper to create mock PriceSummary
  OrderPriceSummary _createMockPriceSummary(double itemTotalPrice) => OrderPriceSummary(
        totalPrice: itemTotalPrice, 
        discountPrice: itemTotalPrice > 100 ? 10.0 : 0.0, // 模拟折扣
        deliveryPrice: 5.0, // 模拟运费
        payPrice: (itemTotalPrice - (itemTotalPrice > 100 ? 10.0 : 0.0)) + 5.0, // 应付金额
      );

  // Helper to create mock PaymentInfo
  OrderPaymentInfo _createMockPaymentInfo(String orderSn, bool isPaid) => OrderPaymentInfo(
        payStatus: isPaid, 
        payTime: isPaid ? DateTime.now().subtract(const Duration(minutes: 30)) : null, // Simulate payment time
        payChannelCode: isPaid ? 'mock_channel' : null,
      );

  // Helper to create mock ShippingInfo
  OrderShippingInfo _createMockShippingInfo(int orderId, bool delivered) => OrderShippingInfo(
        logisticsId: delivered ? 9000 + orderId : null,
        logisticsNo: delivered ? 'SELLER_TRACK_$orderId' : null,
        deliveryTime: delivered ? DateTime.now().subtract(const Duration(days: 1)) : null,
      );

  void _generateMockSellerOrders() {
    _mockSellerOrders.clear(); // Clear previous data if regenerating
    // Define some mock items first
    final item1 = OrderItem(
      id: 201,
      orderId: 101, // Will be set later if needed, keep track
      productId: 301,
      productName: '定制服务X (待卖家确认)',
      skuId: 401,
      skuName: '基础版, 红色', // Matches properties format
      imageUrl: 'https://placehold.co/80x80/E91E63/FFFFFF/png?text=Item1', // Correct field name
      quantity: 1, // Correct field name
      price: 150.00, // Correct field name
      totalPrice: 150.00, // Correct field name
    );
     final item2 = OrderItem(
      id: 202,
      orderId: 102,
      productId: 302,
      productName: '实体商品Y (卖家备货中)',
      skuId: 402,
      skuName: '标准装, V2',
      imageUrl: 'https://placehold.co/80x80/4CAF50/FFFFFF/png?text=Item2',
      quantity: 1,
      price: 88.00,
      totalPrice: 88.00,
    );
     final item3 = OrderItem(
      id: 203,
      orderId: 103,
      productId: 303,
      productName: '实体商品Z (待买家收货)',
      skuId: 403,
      skuName: '豪华版',
      imageUrl: 'https://placehold.co/80x80/2196F3/FFFFFF/png?text=Item3',
      quantity: 1,
      price: 250.00,
      totalPrice: 250.00,
    );
      final item4 = OrderItem(
      id: 204,
      orderId: 104,
      productId: 304,
      productName: '设计服务W (已完成)',
      skuId: 404,
      skuName: '高级套餐',
      imageUrl: 'https://placehold.co/80x80/FF9800/FFFFFF/png?text=Item4',
      quantity: 1,
      price: 500.00,
      totalPrice: 500.00,
      // evaluateState: 1, // This field is not in OrderItem definition
    );
     final item5 = OrderItem(
      id: 205,
      orderId: 105,
      productId: 305,
      productName: '商品V (已取消)',
      skuId: 405,
      skuName: '基础款',
      imageUrl: 'https://placehold.co/80x80/9E9E9E/FFFFFF/png?text=Item5',
      quantity: 1,
      price: 99.00,
      totalPrice: 99.00,
    );

    // Now create Orders using these items and helper methods
    _mockSellerOrders.addAll([
      // Example: Order waiting for Seller Confirmation (awaitingStart)
      Order(
        id: 101,
        orderSn: 'SELLER_SN_101',
        state: OrderStatus.awaitingStart,
        orderType: "NORMAL", // Use String?
        items: [item1],
        shippingAddress: _createMockAddress(101),
        priceSummary: _createMockPriceSummary(item1.totalPrice),
        paymentInfo: _createMockPaymentInfo('SELLER_SN_101', true),
        shippingInfo: _createMockShippingInfo(101, false), // Not shipped yet
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        buyerRemark: '买家备注示例1',
      ),
      // Example: Order being prepared/shipped (awaitingDelivery)
      Order(
        id: 102,
        orderSn: 'SELLER_SN_102',
        state: OrderStatus.awaitingDelivery,
        orderType: "NORMAL",
        items: [item2],
        shippingAddress: _createMockAddress(102),
        priceSummary: _createMockPriceSummary(item2.totalPrice),
        paymentInfo: _createMockPaymentInfo('SELLER_SN_102', true),
        shippingInfo: _createMockShippingInfo(102, false), // Not shipped yet
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      // Example: Order shipped, waiting for buyer confirmation (awaitingConfirmation)
       Order(
        id: 103,
        orderSn: 'SELLER_SN_103',
        state: OrderStatus.awaitingConfirmation,
        orderType: "NORMAL",
        items: [item3],
        shippingAddress: _createMockAddress(103),
        priceSummary: _createMockPriceSummary(item3.totalPrice),
        paymentInfo: _createMockPaymentInfo('SELLER_SN_103', true),
        shippingInfo: _createMockShippingInfo(103, true), // Shipped
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      // Example: Completed Order
       Order(
        id: 104,
        orderSn: 'SELLER_SN_104',
        state: OrderStatus.orderCompleted,
        orderType: "NORMAL",
        items: [item4],
        shippingAddress: _createMockAddress(104),
        priceSummary: _createMockPriceSummary(item4.totalPrice),
        paymentInfo: _createMockPaymentInfo('SELLER_SN_104', true),
        shippingInfo: _createMockShippingInfo(104, true), // Shipped
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        completeTime: DateTime.now().subtract(const Duration(days: 5)), // Add complete time
      ),
      // Example: Cancelled Order
       Order(
        id: 105,
        orderSn: 'SELLER_SN_105',
        state: OrderStatus.canceled,
        orderType: "NORMAL",
        items: [item5],
        shippingAddress: _createMockAddress(105),
        priceSummary: _createMockPriceSummary(item5.totalPrice),
        paymentInfo: _createMockPaymentInfo('SELLER_SN_105', false),
        shippingInfo: _createMockShippingInfo(105, false),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        cancelTime: DateTime.now().subtract(const Duration(days: 1)), // Add cancel time
      ),
    ]);
    AppLogger.d('[MockSellerOrderRepository] Generated ${_mockSellerOrders.length} mock seller orders.');
  }

  Order? _findOrderById(int id) {
    try {
      return _mockSellerOrders.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }

  void _updateOrder(Order updatedOrder) {
    final index = _mockSellerOrders.indexWhere((o) => o.id == updatedOrder.id);
    if (index != -1) {
      _mockSellerOrders[index] = updatedOrder;
      AppLogger.d('[MockSellerOrderRepository] Updated order ${updatedOrder.id} in mock list.');
    } else {
      AppLogger.d('[MockSellerOrderRepository] Failed to find order ${updatedOrder.id} for update.');
    }
  }


  // --- Interface Methods Implementation ---

  @override
  Future<Either<Failure, List<Order>>> getOrderList({
    OrderStatus? status,
    String? keyword,
    int? productId,
    required int page,
    required int limit,
    required String userRole,
    bool forceRefresh = false,
  }) async {
    AppLogger.d('[MockSellerOrderRepository] getOrderList called. Page: $page, Status: $status, Keyword: $keyword, Role: $userRole, forceRefresh: $forceRefresh');
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay

    List<Order> filteredOrders = _mockSellerOrders;

    // Filter by status
    if (status != null) {
      filteredOrders = filteredOrders.where((order) => order.state == status).toList();
    }

    // Filter by keyword (simple search in product name or SN)
    if (keyword != null && keyword.isNotEmpty) {
      filteredOrders = filteredOrders.where((order) {
        final orderSnMatch = order.orderSn?.toLowerCase().contains(keyword.toLowerCase()) ?? false;
        final itemNameMatch = order.items?.any((item) => item.productName.toLowerCase().contains(keyword.toLowerCase())) ?? false;
        return orderSnMatch || itemNameMatch;
      }).toList();
    }

    if (productId != null) {
      filteredOrders = filteredOrders.where((order) {
        return order.items.any((item) => item.productId == productId);
      }).toList();
    }

    // Apply pagination
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    List<Order> paginatedOrders = filteredOrders.sublist(
      startIndex < filteredOrders.length ? startIndex : filteredOrders.length,
      endIndex < filteredOrders.length ? endIndex : filteredOrders.length,
    );

    AppLogger.d('[MockSellerOrderRepository] Returning ${paginatedOrders.length} orders for page $page.');
    return Right(paginatedOrders);
  }

  @override
  Future<Either<Failure, Order>> getOrderDetail(int orderId) async {
    AppLogger.d('[MockSellerOrderRepository] getOrderDetail called for ID: $orderId');
    await Future.delayed(const Duration(milliseconds: 150));
    final order = _findOrderById(orderId);
    if (order != null) {
      return Right(order);
    } else {
      return Left(ServerFailure(message: 'Mock Seller: Order not found'));
    }
  }

  // --- Seller Specific Actions ---

  @override
  Future<Either<Failure, void>> confirmOrderAcceptance(int orderId) async {
    AppLogger.d('[MockSellerOrderRepository] Seller Confirming Acceptance for Order ID: $orderId');
    await Future.delayed(const Duration(milliseconds: 150));
    final order = _findOrderById(orderId);
    if (order != null && order.state == OrderStatus.awaitingStart) {
      _updateOrder(order.copyWith(state: OrderStatus.awaitingDelivery)); // Change state
      AppLogger.d('[MockSellerOrderRepository] Order $orderId status changed to awaitingDelivery.');
      return const Right(null);
    } else {
      AppLogger.d('[MockSellerOrderRepository] Cannot confirm acceptance for order $orderId (state: ${order?.state}).');
      return Left(ServerFailure(message: 'Mock Seller: Order not in awaitingStart state'));
    }
  }

  @override
  Future<Either<Failure, void>> addOrderDemand(AddOrderDemandParams params) async {
     AppLogger.d('[MockSellerOrderRepository] Seller Adding Demand for Order ID: ${params.orderId}, Type: ${params.type}');
     await Future.delayed(const Duration(milliseconds: 150));
     final order = _findOrderById(params.orderId);
     if (order != null) {
       // Simulate state change based on demand type (adjust if needed)
       if (params.type == 'refuse') {
         _updateOrder(order.copyWith(state: OrderStatus.applyForRefuse)); // Example state
         AppLogger.d('[MockSellerOrderRepository] Order ${params.orderId} status changed to applyForRefuse.');
       } else if (params.type == 'material') {
         _updateOrder(order.copyWith(state: OrderStatus.sellerSupplementaryMaterials)); // Example state
         AppLogger.d('[MockSellerOrderRepository] Order ${params.orderId} status changed to sellerSupplementaryMaterials.');
       } else {
         AppLogger.d('[MockSellerOrderRepository] Unknown demand type: ${params.type}');
         return Left(ServerFailure(message: 'Mock Seller: Invalid demand type'));
       }
       return const Right(null);
     } else {
       AppLogger.d('[MockSellerOrderRepository] Order ${params.orderId} not found for adding demand.');
       return Left(ServerFailure(message: 'Mock Seller: Order not found'));
     }
  }

  @override
  Future<Either<Failure, void>> deliverOrder(DeliverOrderParams params) async {
     AppLogger.d('[MockSellerOrderRepository] Seller Delivering Order ID: ${params.orderId}');
     await Future.delayed(const Duration(milliseconds: 150));
     final order = _findOrderById(params.orderId);
     // Seller can deliver if awaitingDelivery or potentially if buyer provided materials back
     if (order != null && (order.state == OrderStatus.awaitingDelivery /* Add other valid states if needed */)) {
       _updateOrder(order.copyWith(
         state: OrderStatus.awaitingConfirmation, // Move to buyer confirmation
         shippingInfo: OrderShippingInfo( // Add/Update shipping info
           deliveryTime: DateTime.now(),
           logisticsNo: 'SELLER_TRACK_${params.orderId}', 
           logisticsId: 9000 + params.orderId, // Add mock ID
         ),
       ));
       AppLogger.d('[MockSellerOrderRepository] Order ${params.orderId} status changed to awaitingConfirmation.');
       return const Right(null);
     } else {
       AppLogger.d('[MockSellerOrderRepository] Cannot deliver order ${params.orderId} (state: ${order?.state}).');
       return Left(ServerFailure(message: 'Mock Seller: Order not in correct state for delivery'));
     }
  }

  @override
  Future<Either<Failure, void>> deleteSellerOrderRecord(int orderId) async {
     AppLogger.d('[MockSellerOrderRepository] Seller Deleting Order Record ID: $orderId');
     await Future.delayed(const Duration(milliseconds: 150));
     final initialLength = _mockSellerOrders.length;
     _mockSellerOrders.removeWhere((o) => o.id == orderId);
     final removedCount = initialLength - _mockSellerOrders.length;
     if (removedCount > 0) {
       AppLogger.d('[MockSellerOrderRepository] Order $orderId removed from seller mock list.');
       return const Right(null);
     } else {
        AppLogger.d('[MockSellerOrderRepository] Order $orderId not found for seller deletion.');
       return Left(ServerFailure(message: 'Mock Seller: Order not found for deletion'));
     }
  }

  @override
  Future<Either<Failure, void>> inviteEvaluation(int orderId) async {
     AppLogger.d('[MockSellerOrderRepository] Seller Inviting Evaluation for Order ID: $orderId');
     await Future.delayed(const Duration(milliseconds: 150));
     final order = _findOrderById(orderId);
     if (order != null && order.state == OrderStatus.orderCompleted) {
       // Simulate some action, maybe update a flag on the order if needed
       AppLogger.d('[MockSellerOrderRepository] Mock invitation sent for order $orderId.');
       return const Right(null);
     } else {
       AppLogger.d('[MockSellerOrderRepository] Cannot invite evaluation for order $orderId (state: ${order?.state}).');
       return Left(ServerFailure(message: 'Mock Seller: Order not completed'));
     }
  }


  // --- Buyer Actions (Should ideally do nothing or return error in Seller Repo) ---

  @override
  Future<Either<Failure, void>> cancelOrder(int orderId) async {
    AppLogger.d('[MockSellerOrderRepository] cancelOrder called (Seller cannot initiate). Returning failure.');
    // Seller typically cannot cancel an order this way, buyer initiates cancellation or seller uses 'addOrderDemand' for refusal.
    return Left(ActionNotAllowedFailure(message: 'Mock Seller: Seller cannot directly cancel order. Use refusal demand.'));
  }

  @override
  Future<Either<Failure, void>> confirmOrderReceipt(int orderId) async {
    AppLogger.d('[MockSellerOrderRepository] confirmOrderReceipt called (Seller action not applicable). Returning failure.');
    return Left(ActionNotAllowedFailure(message: 'Mock Seller: This action is for buyers.'));
  }

  @override
  Future<Either<Failure, void>> deleteOrder(int orderId) async {
     AppLogger.d('[MockSellerOrderRepository] deleteOrder called (Seller uses deleteSellerOrderRecord). Returning failure.');
    return Left(ActionNotAllowedFailure(message: 'Mock Seller: Use deleteSellerOrderRecord for seller view deletion.'));
  }

  @override
  Future<Either<Failure, void>> addEvaluation(
      {required int orderId,
      required double score,
      required String content,
      required bool isAnonymous,
      required List<String> pictures}) async {
     AppLogger.d('[MockSellerOrderRepository] addEvaluation called (Seller action not applicable). Returning failure.');
     return Left(ActionNotAllowedFailure(message: 'Mock Seller: Evaluation is added by buyers.'));
  }

  @override
  Future<Either<Failure, void>> submitRequirements(SubmitRequirementsParams params) async {
     AppLogger.d('[MockSellerOrderRepository] submitRequirements called (Seller action not applicable). Returning failure.');
     return Left(ActionNotAllowedFailure(message: 'Mock Seller: Requirements are submitted by buyers.'));
  }

  @override
  Future<Either<Failure, void>> saveRequirementDraft(/* DraftParams params */) async {
     AppLogger.d('[MockSellerOrderRepository] saveRequirementDraft called (Seller action not applicable). Returning failure.');
    return Left(ActionNotAllowedFailure(message: 'Mock Seller: Drafts are saved by buyers.'));
  }

  @override
  Future<Either<Failure, OrderCreationResult>> createOrder({
    required int productId,
    required int variantId,
    required int quantity,
    required int sellerId,
    required double price,
    int? chatRoomId,
  }) async {
    AppLogger.d('[MockSellerOrderRepository] Creating order for product: $productId, variant: $variantId, quantity: $quantity');
    await Future.delayed(const Duration(milliseconds: 300)); // 模拟网络延迟
    
    // 生成模拟订单ID (使用随机数)
    final String mockOrderId = 'ORDER-SELLER-${DateTime.now().millisecondsSinceEpoch}-${_random.nextInt(10000)}';
    
    // 生成模拟支付信息 - 使用配置化的支付应用ID
    final String mockOrderInfo = 'app_id=${AppConfig.alipayAppId}&biz_content={"timeout_express":"30m","product_code":"QUICK_MSECURITY_PAY","total_amount":"${price * quantity}","subject":"商品付款","body":"商品ID: $productId, 规格ID: $variantId","out_trade_no":"$mockOrderId"}&charset=utf-8&format=JSON&method=alipay.trade.app.pay&sign=MOCK_SIGN&timestamp=${DateTime.now().toIso8601String()}&version=1.0';
    
    // 返回模拟创建结果
    return Right(OrderCreationResult(
      orderId: mockOrderId,
      orderInfo: mockOrderInfo,
      totalAmount: price * quantity,
    ));
  }
  
  @override
  Future<Either<Failure, List<OrderMaterials>>> getOrderMaterials(int orderId) async {
    // Mock repository不实现此功能，返回空列表
    return const Right([]);
  }
  
  @override
  Future<Either<Failure, List<OrderDelivery>>> getOrderDeliveries(int orderId) async {
    // Mock repository不实现此功能，返回空列表
    return const Right([]);
  }
  
  @override
  Future<Either<Failure, OrderMaterials>> getOrderMaterialById(int materialId) async {
    // Mock repository不实现此功能，返回错误
    return const Left(ServerFailure(message: 'Mock repository does not implement getOrderMaterialById'));
  }
  
  @override
  Future<Either<Failure, OrderDelivery>> getOrderDeliveryById(int deliveryId) async {
    // Mock repository不实现此功能，返回错误
    return const Left(ServerFailure(message: 'Mock repository does not implement getOrderDeliveryById'));
  }
}

// Optional: Define ActionNotAllowedFailure if not already present
class ActionNotAllowedFailure extends Failure {
  final String message;
  const ActionNotAllowedFailure({required this.message}) : super(message: message);
  @override
  List<Object?> get props => [message];
} 
