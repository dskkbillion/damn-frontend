import 'dart:math';

import 'package:dartz/dartz.dart' hide Order;
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_item.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/address.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_price_summary.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_payment_info.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_shipping_info.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/repositories/i_order_repository.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/submit_requirements_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/submit_evaluation_use_case.dart';

/// IOrderRepository 的手动 Mock/Dummy 实现，用于预览环境。
class MockOrderRepository implements IOrderRepository {
  // 存储一些硬编码的订单数据 (使用 Domain Entities)
  // Note: Mocks should ideally return Domain entities directly, conversion happens in RepositoryImpl
  // However, for simplicity in the preview, we might keep mocks returning entities
  // Let's update the structure to reflect potential underlying data changes
  final List<Order> _mockOrders = [
    Order(
      id: 1,
      orderSn: 'MOCK001', // Keep entity as orderSn, mapping happens in model
      state: OrderStatus.awaitingPayment,
      orderType: '0',
      items: [
        OrderItem(id: 101, orderId: 1, productId: 1001, productName: '测试商品 A (待付款)', skuId: 2001, skuName: '规格 1', imageUrl: 'https://picsum.photos/seed/MOCK001/150/150', quantity: 1, price: 50.0, totalPrice: 50.0),
      ],
      // Use the Address entity directly in the mock
      shippingAddress: const Address(recipientName: '测试收件人', phone: '13800138000', areaId: '110101', detailAddress: '北京市某某区某某街道1号'),
      priceSummary: const OrderPriceSummary(totalPrice: 50.0, discountPrice: 0.0, deliveryPrice: 5.0, payPrice: 55.0),
      // payStatus derived from payTime
      paymentInfo: const OrderPaymentInfo(payStatus: false, payTime: null),
      shippingInfo: const OrderShippingInfo(),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      buyerRemark: '这是待付款订单的备注',
    ),
     Order(
      id: 2,
      orderSn: 'MOCK002',
      state: OrderStatus.awaitingDelivery,
      orderType: '0',
      items: [
        OrderItem(id: 102, orderId: 2, productId: 1002, productName: '测试商品 B (待发货)', skuId: 2002, skuName: '规格 X', imageUrl: 'https://picsum.photos/seed/MOCK002/150/150', quantity: 2, price: 30.0, totalPrice: 60.0),
      ],
      shippingAddress: const Address(recipientName: '张三', phone: '13900139000', areaId: '310101', detailAddress: '上海市某某区某某路2号'),
      priceSummary: const OrderPriceSummary(totalPrice: 60.0, discountPrice: 5.0, deliveryPrice: 0.0, payPrice: 55.0),
      paymentInfo: OrderPaymentInfo(payStatus: true, payTime: DateTime.now().subtract(const Duration(hours: 12))),
      shippingInfo: const OrderShippingInfo(),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
     Order(
      id: 3,
      orderSn: 'MOCK003',
      state: OrderStatus.awaitingEvaluation,
      orderType: '1',
      items: [
        OrderItem(id: 103, orderId: 3, productId: 1003, productName: '测试商品 C (待评价)', skuId: 2003, skuName: '豪华版', imageUrl: 'https://picsum.photos/seed/MOCK003/150/150', quantity: 1, price: 199.0, totalPrice: 199.0),
      ],
      shippingAddress: const Address(recipientName: '李四', phone: '13700137000', areaId: '440101', detailAddress: '广州市某某区某某大道3号'),
      priceSummary: const OrderPriceSummary(totalPrice: 199.0, discountPrice: 10.0, deliveryPrice: 10.0, payPrice: 199.0),
      paymentInfo: OrderPaymentInfo(payStatus: true, payTime: DateTime.now().subtract(const Duration(days: 3))),
      shippingInfo: OrderShippingInfo(logisticsId: 123, logisticsNo: 'SF123456789', deliveryTime: DateTime.now().subtract(const Duration(days: 1))),
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      completeTime: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Order(
      id: 4,
      orderSn: 'MOCK004',
      state: OrderStatus.awaitingConfirmation,
      orderType: '0',
      items: [
        OrderItem(id: 104, orderId: 4, productId: 1004, productName: '测试商品 D (待收货)', skuId: 2004, skuName: '基础版', imageUrl: 'https://picsum.photos/seed/MOCK004/150/150', quantity: 2, price: 30.00, totalPrice: 60.00),
      ],
      shippingAddress: const Address(recipientName: '王五', phone: '13600136000', areaId: '510101', detailAddress: '成都市某某区某某街4号'),
      priceSummary: const OrderPriceSummary(totalPrice: 60.0, discountPrice: 0.0, deliveryPrice: 8.0, payPrice: 68.0),
      paymentInfo: OrderPaymentInfo(payStatus: true, payTime: DateTime.now().subtract(const Duration(days: 2, hours: 10))),
      shippingInfo: OrderShippingInfo(logisticsId: 456, logisticsNo: 'YD123456780', deliveryTime: DateTime.now().subtract(const Duration(hours: 1))),
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 12)),
    ),
    Order(
      id: 5,
      orderSn: 'MOCK005',
      state: OrderStatus.awaitingSubmission,
      orderType: '0',
      items: [
        OrderItem(id: 105, orderId: 5, productId: 1005, productName: '测试服务 E (待提交要求)', skuId: 2005, skuName: '加急处理', imageUrl: 'https://picsum.photos/seed/MOCK005/150/150', quantity: 1, price: 100.00, totalPrice: 100.00),
      ],
      shippingAddress: const Address(recipientName: '赵六', phone: '13500135000', areaId: '330101', detailAddress: '杭州市某某区某某路5号'),
      priceSummary: const OrderPriceSummary(totalPrice: 100.0, discountPrice: 10.0, deliveryPrice: 0.0, payPrice: 90.0),
      paymentInfo: OrderPaymentInfo(payStatus: true, payTime: DateTime.now().subtract(const Duration(hours: 2))),
      shippingInfo: const OrderShippingInfo(),
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      buyerRemark: '需要尽快完成，请告知具体要求！',
    ),
    Order(
      id: 6,
      orderSn: 'MOCK006',
      state: OrderStatus.canceled,
      items: [
        OrderItem(id: 106, orderId: 6, productId: 1006, productName: '测试商品 F (已取消)', skuId: 2006, skuName: '特殊规格', imageUrl: 'https://picsum.photos/seed/MOCK006/150/150', quantity: 1, price: 60.0, totalPrice: 60.0),
      ],
      shippingAddress: const Address(recipientName: '钱七', phone: '13400134000', areaId: '420101', detailAddress: '武汉市某某区某某路6号'),
      priceSummary: const OrderPriceSummary(totalPrice: 60.0, discountPrice: 0.0, deliveryPrice: 0.0, payPrice: 60.0),
      paymentInfo: OrderPaymentInfo(payStatus: true, payTime: DateTime.now().subtract(const Duration(days: 15, hours: -1))),
      shippingInfo: const OrderShippingInfo(),
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      cancelTime: DateTime.now().subtract(const Duration(days: 14)),
      buyerRemark: '突然不想要了，取消。',
    ),
    Order(
      id: 1,
      orderSn: 'MOCK007',
      state: OrderStatus.afterSale,
       items: [
        OrderItem(id: 107, orderId: 1, productId: 1007, productName: '测试商品 G (售后中)', skuId: 2007, skuName: '定制版', imageUrl: 'https://picsum.photos/seed/MOCK007/150/150', quantity: 1, price: 120.0, totalPrice: 120.0),
      ],
      shippingAddress: const Address(recipientName: '孙八', phone: '13300133000', areaId: '320101', detailAddress: '南京市某某区某某街7号'),
      priceSummary: const OrderPriceSummary(totalPrice: 120.0, discountPrice: 0.0, deliveryPrice: 0.0, payPrice: 120.0),
      paymentInfo: OrderPaymentInfo(payStatus: true, payTime: DateTime.now().subtract(const Duration(days: 20, hours: -1))),
      shippingInfo: const OrderShippingInfo(),
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      completeTime: DateTime.now().subtract(const Duration(days: 10)),
      buyerRemark: '这个商品申请售后了',
    ),
    // --- Add Mock Orders for Seller View ---
    Order(
      id: 8,
      orderSn: 'MOCK008_SELLER', 
      state: OrderStatus.awaitingStart, // **Seller: Waiting for seller to confirm acceptance**
      orderType: '0',
      items: [
        OrderItem(id: 108, orderId: 8, productId: 1008, productName: '服务 H (待接单)', skuId: 2008, skuName: '标准服务', imageUrl: 'https://picsum.photos/seed/MOCK008/150/150', quantity: 1, price: 80.0, totalPrice: 80.0),
      ],
      shippingAddress: const Address(recipientName: '买家小明', phone: '13100131000', areaId: '110105', detailAddress: '朝阳区 XX 路 8 号'),
      priceSummary: const OrderPriceSummary(totalPrice: 80.0, discountPrice: 0.0, deliveryPrice: 0.0, payPrice: 80.0),
      paymentInfo: OrderPaymentInfo(payStatus: true, payTime: DateTime.now().subtract(const Duration(minutes: 30))),
      shippingInfo: const OrderShippingInfo(),
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      buyerRemark: '买家希望快速开始',
    ),
    Order(
      id: 9,
      orderSn: 'MOCK009_SELLER', 
      state: OrderStatus.awaitingDelivery, // **Seller: Order accepted, waiting for delivery**
      orderType: '0',
      items: [
        OrderItem(id: 109, orderId: 9, productId: 1009, productName: '设计服务 I (进行中)', skuId: 2009, skuName: 'Logo 设计', imageUrl: 'https://picsum.photos/seed/MOCK009/150/150', quantity: 1, price: 500.0, totalPrice: 500.0),
      ],
      shippingAddress: const Address(recipientName: '买家小红', phone: '13200132000', areaId: '440305', detailAddress: '南山区 YY 路 9 号'),
      priceSummary: const OrderPriceSummary(totalPrice: 500.0, discountPrice: 20.0, deliveryPrice: 0.0, payPrice: 480.0),
      paymentInfo: OrderPaymentInfo(payStatus: true, payTime: DateTime.now().subtract(const Duration(days: 1, hours: 2))),
      shippingInfo: const OrderShippingInfo(),
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      buyerRemark: '需要包含源文件',
    ),
     Order(
      id: 10,
      orderSn: 'MOCK010_SELLER',
      state: OrderStatus.applyForRefuse, // **Seller: Buyer requested redo/refund (showing refuse for example)**
      orderType: '1',
      items: [
        OrderItem(id: 110, orderId: 10, productId: 1010, productName: '翻译服务 J (买家申请重做)', skuId: 2010, skuName: '英译中 1000 字', imageUrl: 'https://picsum.photos/seed/MOCK010/150/150', quantity: 1, price: 150.0, totalPrice: 150.0),
      ],
      shippingAddress: const Address(recipientName: '买家小刚', phone: '13300133000', areaId: '330106', detailAddress: '西湖区 ZZ 路 10 号'),
      priceSummary: const OrderPriceSummary(totalPrice: 150.0, discountPrice: 0.0, deliveryPrice: 0.0, payPrice: 150.0),
      paymentInfo: OrderPaymentInfo(payStatus: true, payTime: DateTime.now().subtract(const Duration(days: 5))),
      shippingInfo: OrderShippingInfo(logisticsId: null, logisticsNo: null, deliveryTime: DateTime.now().subtract(const Duration(days: 2))), // Simulating delivery happened
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      completeTime: null, // Not completed as redo requested
      buyerRemark: '翻译质量不满意，要求重新翻译指定段落。',
    ),
  ];

  // Helper to find and potentially update an order
  Order? _findOrderById(int orderId) {
    try {
      return _mockOrders.firstWhere((o) => o.id == orderId);
    } catch (e) {
      return null;
    }
  }

  void _updateOrder(Order updatedOrder) {
    final index = _mockOrders.indexWhere((o) => o.id == updatedOrder.id);
    if (index != -1) {
      _mockOrders[index] = updatedOrder;
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getOrderList({
    OrderStatus? status,
    String? keyword,
    required int page,
    required int limit,
    // Assuming this mock serves both buyer and seller views for simplicity
    // In a real scenario, might filter based on a role or have separate mocks
  }) async {
    print('[MockOrderRepository] Getting Order List - Page: $page, Limit: $limit, Status: $status, Keyword: $keyword');
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay

    // Simulate filtering by status
    List<Order> filteredOrders = _mockOrders;
    if (status != null && status != OrderStatus.unknown) { // Handle 'All' case
      filteredOrders = _mockOrders.where((order) => order.state == status).toList();
    }
    // Simulate keyword search (simple)
    if (keyword != null && keyword.isNotEmpty) {
      filteredOrders = filteredOrders.where((order) =>
        (order.orderSn?.contains(keyword) ?? false) || // Null check for safety
        order.items.any((item) => item.productName.contains(keyword)) ||
        (order.shippingAddress.recipientName.contains(keyword))
      ).toList();
    }

    // Simulate pagination
    int startIndex = (page - 1) * limit;
    int endIndex = startIndex + limit;
    if (startIndex >= filteredOrders.length) {
      return const Right([]); // No more data for this page
    }
    if (endIndex > filteredOrders.length) {
      endIndex = filteredOrders.length;
    }

    return Right(filteredOrders.sublist(startIndex, endIndex));
  }

  @override
  Future<Either<Failure, Order>> getOrderDetail(int orderId) async {
    print('[MockOrderRepository] Getting Order Detail for ID: $orderId');
    await Future.delayed(const Duration(milliseconds: 200));

    final order = _findOrderById(orderId);

    if (order != null) {
      return Right(order);
    } else {
      // Simulate not found
      return Left(ServerFailure(message: 'Mock: Order with ID $orderId not found'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelOrder(int orderId) async {
    print('[MockOrderRepository] Buyer Cancelling Order ID: $orderId');
    await Future.delayed(const Duration(milliseconds: 150));
    final order = _findOrderById(orderId);
    if (order != null && order.state == OrderStatus.awaitingPayment) { // Only allow cancel if awaiting payment
       _updateOrder(order.copyWith(state: OrderStatus.canceled, cancelTime: DateTime.now()));
       print('[MockOrderRepository] Order $orderId status changed to canceled.');
       return const Right(null);
    } else {
      print('[MockOrderRepository] Cannot cancel order $orderId (state: ${order?.state}).');
      return Left(ServerFailure(message: 'Mock: Cannot cancel order in its current state'));
    }
  }

  @override
  Future<Either<Failure, void>> confirmOrderReceipt(int orderId) async {
     print('[MockOrderRepository] Buyer Confirming Receipt for Order ID: $orderId');
     await Future.delayed(const Duration(milliseconds: 150));
     final order = _findOrderById(orderId);
     if (order != null && order.state == OrderStatus.awaitingConfirmation) {
        _updateOrder(order.copyWith(state: OrderStatus.awaitingEvaluation, completeTime: DateTime.now()));
        print('[MockOrderRepository] Order $orderId status changed to awaitingEvaluation.');
        return const Right(null);
     } else {
       print('[MockOrderRepository] Cannot confirm receipt for order $orderId (state: ${order?.state}).');
       return Left(ServerFailure(message: 'Mock: Cannot confirm receipt in its current state'));
     }
  }

  @override
  Future<Either<Failure, void>> deleteOrder(int orderId) async {
    print('[MockOrderRepository] Buyer Deleting Order ID: $orderId');
    await Future.delayed(const Duration(milliseconds: 150));
    final initialLength = _mockOrders.length; // 记录初始长度
    _mockOrders.removeWhere((o) => o.id == orderId); // 直接修改列表
    final removedCount = initialLength - _mockOrders.length; // 计算删除的数量

    if (removedCount > 0) { // 使用计算出的数量进行判断
       print('[MockOrderRepository] Order $orderId removed from mock list.');
       return const Right(null);
    } else {
       print('[MockOrderRepository] Order $orderId not found for deletion.');
       return Left(ServerFailure(message: 'Mock: Order not found for deletion'));
    }
  }

  @override
  Future<Either<Failure, void>> addEvaluation({
    required int orderItemId,
    required double score,
    required String content,
    required bool isAnonymous,
    required List<String> pictures,
  }) async {
     print('[MockOrderRepository] Adding Evaluation for OrderItem ID: $orderItemId, Score: $score');
     await Future.delayed(const Duration(milliseconds: 150));
    // Find the order containing the item and update its state if needed
    final orderIndex = _mockOrders.indexWhere((o) => o.items.any((item) => item.id == orderItemId));
    if (orderIndex != -1 && _mockOrders[orderIndex].state == OrderStatus.awaitingEvaluation) {
      _mockOrders[orderIndex] = _mockOrders[orderIndex].copyWith(state: OrderStatus.orderCompleted);
      print('[MockOrderRepository] Order ${_mockOrders[orderIndex].id} status changed to orderCompleted after evaluation.');
    } else {
       print('[MockOrderRepository] Could not find order in awaitingEvaluation state for item $orderItemId.');
       // Return success anyway for mock, or failure if strict check needed
       // return Left(ServerFailure(message: 'Mock: Cannot evaluate order in its current state'));
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> submitRequirements(SubmitRequirementsParams params) async {
    print('[MockOrderRepository] Submitting Requirements for Order ID: ${params.orderId}');
    await Future.delayed(const Duration(milliseconds: 150));
    final order = _findOrderById(int.tryParse(params.orderId) ?? -1);
     if (order != null && order.state == OrderStatus.awaitingSubmission) {
        // Simulate state change after submission
        _updateOrder(order.copyWith(state: OrderStatus.awaitingStart));
        print('[MockOrderRepository] Order ${params.orderId} status changed to awaitingStart.');
        return const Right(null);
     } else {
       print('[MockOrderRepository] Cannot submit requirements for order ${params.orderId} (state: ${order?.state}).');
       return Left(ServerFailure(message: 'Mock: Cannot submit requirements in its current state'));
     }
  }

  @override
  Future<Either<Failure, void>> saveRequirementDraft(/* DraftParams params */) async {
    print('[MockOrderRepository] saveRequirementDraft called (Mock does nothing).');
    return const Right(null);
  }

  // --- Seller action mock implementations ---

  @override
  Future<Either<Failure, void>> confirmOrderAcceptance(int orderId) async {
    print('[MockOrderRepository] Seller Confirming Acceptance for Order ID: $orderId');
    await Future.delayed(const Duration(milliseconds: 150));
    final order = _findOrderById(orderId);
    if (order != null && order.state == OrderStatus.awaitingStart) {
      _updateOrder(order.copyWith(state: OrderStatus.awaitingDelivery));
      print('[MockOrderRepository] Order $orderId status changed to awaitingDelivery.');
      return const Right(null);
    } else {
      print('[MockOrderRepository] Cannot confirm acceptance for order $orderId (state: ${order?.state}).');
      return Left(ServerFailure(message: 'Mock: Order not in awaitingStart state'));
    }
  }

  @override
  Future<Either<Failure, void>> addOrderDemand(AddOrderDemandParams params) async {
    print('[MockOrderRepository] Seller Adding Demand for Order ID: ${params.orderId}, Type: ${params.type}');
    await Future.delayed(const Duration(milliseconds: 150));
    final order = _findOrderById(params.orderId);
    if (order != null) {
      if (params.type == 'refuse') {
        _updateOrder(order.copyWith(state: OrderStatus.applyForRefuse)); // Simulate state change
        print('[MockOrderRepository] Order ${params.orderId} status changed to applyForRefuse.');
      } else if (params.type == 'material') {
        _updateOrder(order.copyWith(state: OrderStatus.sellerSupplementaryMaterials)); // Simulate state change
        print('[MockOrderRepository] Order ${params.orderId} status changed to sellerSupplementaryMaterials.');
      } else {
        print('[MockOrderRepository] Unknown demand type: ${params.type}');
        return Left(ServerFailure(message: 'Mock: Invalid demand type'));
      }
      return const Right(null);
    } else {
      print('[MockOrderRepository] Order ${params.orderId} not found for adding demand.');
      return Left(ServerFailure(message: 'Mock: Order not found'));
    }
  }

  @override
  Future<Either<Failure, void>> deliverOrder(DeliverOrderParams params) async {
    print('[MockOrderRepository] Seller Delivering Order ID: ${params.orderId}');
    await Future.delayed(const Duration(milliseconds: 150));
    final order = _findOrderById(params.orderId);
    if (order != null && (order.state == OrderStatus.awaitingDelivery || order.state == OrderStatus.sellerSupplementaryMaterials)) {
      _updateOrder(order.copyWith(state: OrderStatus.awaitingConfirmation, shippingInfo: OrderShippingInfo(deliveryTime: DateTime.now()))); // Simulate state change
      print('[MockOrderRepository] Order ${params.orderId} status changed to awaitingConfirmation.');
      return const Right(null);
    } else {
      print('[MockOrderRepository] Cannot deliver order ${params.orderId} (state: ${order?.state}).');
      return Left(ServerFailure(message: 'Mock: Order not in correct state for delivery'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSellerOrderRecord(int orderId) async {
     print('[MockOrderRepository] Seller Deleting Order Record ID: $orderId');
     await Future.delayed(const Duration(milliseconds: 150));
     // Simulate deletion by just returning success, or remove if needed for list testing
     // final removed = _mockOrders.removeWhere((o) => o.id == orderId);
     // if (removed > 0) { return const Right(null); } else { return Left(ServerFailure(message: 'Mock: Order not found'));}
     return const Right(null);
  }

  @override
  Future<Either<Failure, void>> inviteEvaluation(int orderId) async {
    print('[MockOrderRepository] Seller Inviting Evaluation for Order ID: $orderId');
    await Future.delayed(const Duration(milliseconds: 150));
    // Just simulate success
    return const Right(null);
  }
}