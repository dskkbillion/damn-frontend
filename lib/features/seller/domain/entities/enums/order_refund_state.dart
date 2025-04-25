import 'package:flutter/foundation.dart';

/// 售后退款状态枚举
///
/// 基于后端API返回的状态值进行映射。
enum OrderRefundState {
  /// 待审核
  waitAudit('WAIT_AUDIT', '待审核'),
  
  /// 已拒绝
  refused('REFUSED', '已拒绝'),
  
  /// 审核通过
  auditPass('AUDIT_PASS', '审核通过'),
  
  /// 买家已发货
  buyerShip('BUYER_SHIP', '买家已发货'),
  
  /// 卖家已收货
  sellerReceived('SELLER_RECEIVED', '卖家已收货'),
  
  /// 已完成
  finished('FINISHED', '已完成'),
  
  /// 已取消
  canceled('CANCELED', '已取消'),
  
  /// 未知状态
  unknown('UNKNOWN', '未知状态');
  
  /// 状态的API值
  final String value;
  
  /// 用于显示的状态名称
  final String displayName;
  
  const OrderRefundState(this.value, this.displayName);
  
  /// 根据API返回的值获取对应的枚举值
  static OrderRefundState fromValue(String? value) {
    return OrderRefundState.values.firstWhere(
      (state) => state.value == value,
      orElse: () => OrderRefundState.unknown,
    );
  }
  
  /// 判断是否为终态
  bool get isTerminalState => this == OrderRefundState.finished || 
                             this == OrderRefundState.canceled || 
                             this == OrderRefundState.refused;
  
  /// 判断是否为进行中状态
  bool get isInProgress => !isTerminalState;
} 