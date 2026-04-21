
import 'enums/order_refund_state.dart';
import 'enums/refund_type.dart';

/// 售后退款实体类
class OrderRefund {
  /// 退款ID
  final int id;

  /// 订单ID
  final int orderId;

  /// 订单编号
  final String orderSn;

  /// 退款单号
  final String refundSn;

  /// 退款金额（单位：分）
  final int refundPrice;

  /// 申请理由
  final String reason;

  /// 申请凭证（图片URL列表）
  final List<String> credentials;

  /// 退款状态
  final OrderRefundState state;

  /// 退款类型
  final RefundType type;

  /// 申请时间
  final DateTime applyTime;

  /// 审核时间
  final DateTime? auditTime;

  /// 完成时间
  final DateTime? finishTime;

  /// 拒绝原因
  final String? refuseReason;

  /// 收货地址
  final String? receiveAddress;

  /// 收货联系人
  final String? receiveContact;

  /// 收货电话
  final String? receivePhone;

  /// 卖家退货物流公司
  final String? sellerLogistics;

  /// 卖家退货物流单号
  final String? sellerLogisticsNo;

  /// 退货物流公司
  final String? buyerLogistics;

  /// 退货物流单号
  final String? buyerLogisticsNo;

  OrderRefund({
    required this.id,
    required this.orderId,
    required this.orderSn,
    required this.refundSn,
    required this.refundPrice,
    required this.reason,
    required this.credentials,
    required this.state,
    required this.type,
    required this.applyTime,
    this.auditTime,
    this.finishTime,
    this.refuseReason,
    this.receiveAddress,
    this.receiveContact,
    this.receivePhone,
    this.sellerLogistics,
    this.sellerLogisticsNo,
    this.buyerLogistics,
    this.buyerLogisticsNo,
  });

  /// 判断是否可以取消退款申请
  bool get canCancel => state == OrderRefundState.waitAudit;

  /// 判断是否可以填写物流信息（买家发货）
  bool get canAddLogistics => 
    type == RefundType.moneyAndProduct && 
    state == OrderRefundState.auditPass;

  /// 判断是否可以确认收货（卖家收货）
  bool get canConfirmReceipt => 
    type == RefundType.moneyAndProduct && 
    state == OrderRefundState.buyerShip &&
    buyerLogistics != null &&
    buyerLogisticsNo != null;

  /// 获取格式化的退款金额（元）
  double get formattedRefundPrice => refundPrice / 100;
} 