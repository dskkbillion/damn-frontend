import 'package:equatable/equatable.dart';

import 'address.dart';
import 'member.dart';
import 'order_item.dart';
import 'order_evaluation_detail.dart';
import 'order_payment_info.dart';
import 'order_price_summary.dart';
import 'order_shipping_info.dart';
import 'order_status.dart';

/// 表示一个完整的订单核心业务实体。
class Order extends Equatable {
  /// 订单唯一标识符。
  final int id;

  /// 订单号。
  final String orderSn;

  /// 订单当前状态。
  final OrderStatus state;

  /// 订单类型 (例如 "NORMAL", "SECKILL")。
  final String? orderType;

  /// 订单包含的商品项列表。
  final List<OrderItem> items;

  /// 收货地址信息。
  final Address shippingAddress;

  /// 价格明细。
  final OrderPriceSummary priceSummary;

  /// 支付相关信息。
  final OrderPaymentInfo paymentInfo;

  /// 物流配送信息 (基础信息)。
  final OrderShippingInfo shippingInfo;

  /// 订单创建时间。
  final DateTime createdAt;

  /// 订单完成时间 (可选)。
  final DateTime? completeTime;

  /// 订单取消时间 (可选)。
  final DateTime? cancelTime;

  /// 买家备注 (可选)。
  final String? buyerRemark;

  /// 后端附加业务字段，用于承载聊天室关联等扩展信息。
  final dynamic feature;
  
  /// 买家信息
  final Member? buyer;
  
  /// 卖家信息
  final Member? tenant;
  
  /// 自动取消时间（待付款状态）
  final DateTime? autoCancelTime;
  
  /// 自动提交材料截止时间（待提交状态）
  final DateTime? autoMaterialTime;
  
  /// 自动接单时间（待接单状态）
  final DateTime? autoOrderReceivinTime;
  
  /// 发货时间戳（用于计算自动确认收货）
  final DateTime? deliveryTimestamp;
  
  /// 是否已评价
  final bool? evaluate;
  
  /// 评价详情
  final OrderEvaluationDetail? evaluateDetail;

  /// 关联的售后单 ID（如果存在）
  final int? refundId;

  // 注意：不包含 actions 字段，因为允许的操作应由 Presentation 层
  // 根据当前 state 和业务规则动态推断。

  /// 创建一个 [Order] 实例。
  const Order({
    required this.id,
    required this.orderSn,
    required this.state,
    this.orderType,
    required this.items,
    required this.shippingAddress,
    required this.priceSummary,
    required this.paymentInfo,
    required this.shippingInfo,
    required this.createdAt,
    this.completeTime,
    this.cancelTime,
    this.buyerRemark,
    this.feature,
    this.buyer,
    this.tenant,
    this.autoCancelTime,
    this.autoMaterialTime,
    this.autoOrderReceivinTime,
    this.deliveryTimestamp,
    this.evaluate,
    this.evaluateDetail,
    this.refundId,
  });

  Order copyWith({
    int? id,
    String? orderSn,
    OrderStatus? state,
    String? orderType,
    List<OrderItem>? items,
    Address? shippingAddress,
    OrderPriceSummary? priceSummary,
    OrderPaymentInfo? paymentInfo,
    OrderShippingInfo? shippingInfo,
    DateTime? createdAt,
    DateTime? completeTime,
    DateTime? cancelTime,
    String? buyerRemark,
    dynamic feature,
    Member? buyer,
    Member? tenant,
    DateTime? autoCancelTime,
    DateTime? autoMaterialTime,
    DateTime? autoOrderReceivinTime,
    DateTime? deliveryTimestamp,
    bool? evaluate,
    OrderEvaluationDetail? evaluateDetail,
    int? refundId,
  }) {
    return Order(
      id: id ?? this.id,
      orderSn: orderSn ?? this.orderSn,
      state: state ?? this.state,
      orderType: orderType ?? this.orderType,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      priceSummary: priceSummary ?? this.priceSummary,
      paymentInfo: paymentInfo ?? this.paymentInfo,
      shippingInfo: shippingInfo ?? this.shippingInfo,
      createdAt: createdAt ?? this.createdAt,
      completeTime: completeTime ?? this.completeTime,
      cancelTime: cancelTime ?? this.cancelTime,
      buyerRemark: buyerRemark ?? this.buyerRemark,
      feature: feature ?? this.feature,
      buyer: buyer ?? this.buyer,
      tenant: tenant ?? this.tenant,
      autoCancelTime: autoCancelTime ?? this.autoCancelTime,
      autoMaterialTime: autoMaterialTime ?? this.autoMaterialTime,
      autoOrderReceivinTime: autoOrderReceivinTime ?? this.autoOrderReceivinTime,
      deliveryTimestamp: deliveryTimestamp ?? this.deliveryTimestamp,
      evaluate: evaluate ?? this.evaluate,
      evaluateDetail: evaluateDetail ?? this.evaluateDetail,
      refundId: refundId ?? this.refundId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderSn,
        state,
        orderType,
        items,
        shippingAddress,
        priceSummary,
        paymentInfo,
        shippingInfo,
        createdAt,
        completeTime,
        cancelTime,
        buyerRemark,
        feature,
        buyer,
        tenant,
        autoCancelTime,
        autoMaterialTime,
        autoOrderReceivinTime,
        deliveryTimestamp,
        evaluate,
        evaluateDetail,
        refundId,
      ];
}
