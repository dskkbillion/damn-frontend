import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

/// 售后退款状态枚举
///
/// 基于后端API返回的状态值进行映射。
enum OrderRefundState {
  /// 待审核
  waitAudit('WAIT_AUDIT'),

  /// 已拒绝
  refused('AUDIT_REFUSED'),

  /// 审核通过
  auditPass('AUDIT_PASS'),

  /// 买家已发货
  buyerShip('BUYER_SHIP'),

  /// 卖家已收货
  sellerReceived('SELLER_RECEIVED'),

  /// 已完成
  finished('FINISHED'),

  /// 已取消
  canceled('CANCELED'),

  /// 未知状态
  unknown('UNKNOWN');

  /// 状态的API值
  final String value;

  const OrderRefundState(this.value);

  /// 根据API返回的值获取对应的枚举值
  static OrderRefundState fromValue(String? value) {
    final normalized = value?.trim().toUpperCase();
    return OrderRefundState.values.firstWhere(
      (state) => state.value == normalized,
      orElse: () => OrderRefundState.unknown,
    );
  }

  /// 判断是否为终态
  bool get isTerminalState =>
      this == OrderRefundState.finished ||
      this == OrderRefundState.canceled ||
      this == OrderRefundState.refused;

  /// 判断是否为进行中状态
  bool get isInProgress => !isTerminalState;

  /// 获取用于显示的状态名称
  String displayName(BuildContext? context) {
    final l10n = context != null ? AppLocalizations.of(context) : null;
    switch (this) {
      case OrderRefundState.waitAudit:
        return l10n?.after_sales_status_wait_audit ?? '待审核';
      case OrderRefundState.refused:
        return l10n?.after_sales_status_refused ?? '已拒绝';
      case OrderRefundState.auditPass:
        return l10n?.after_sales_status_audit_pass ?? '审核通过';
      case OrderRefundState.buyerShip:
        return l10n?.after_sales_status_buyer_shipped ?? '买家已发货';
      case OrderRefundState.sellerReceived:
        return l10n?.after_sales_status_seller_received ?? '卖家已收货';
      case OrderRefundState.finished:
        return l10n?.after_sales_status_finished ?? '已完成';
      case OrderRefundState.canceled:
        return l10n?.after_sales_status_canceled ?? '已取消';
      case OrderRefundState.unknown:
      default:
        return l10n?.after_sales_status_unknown ?? '未知状态';
    }
  }
}
