import 'package:flutter/foundation.dart';

/// 表示订单的不同状态
///
/// 基于后端 API 返回的字符串状态进行映射。
enum OrderStatus {
  /// 待付款
  awaitingPayment,

  /// 买家待提交材料
  awaitingSubmission,

  /// 卖家要求买家重传材料
  buyAwaitingSubmission,

  /// 卖家待开始/处理中
  awaitingStart,

  /// 卖家待交付/待发货
  awaitingDelivery,

  /// 买家待确认收货
  awaitingConfirmation,

  /// 卖家要求补充材料 (平台介入前?) - 含义需进一步确认
  sellerSupplementaryMaterials,

  /// 买家申请平台介入/拒绝? - 含义需进一步确认
  applyForRefuse,

  /// 待评价
  awaitingEvaluation,

  /// 已完成
  orderCompleted,

  /// 已取消
  canceled,

  /// 售后中
  afterSale,

  /// 售后拒绝 - 含义需进一步确认
  AfterSaleRejection, // TODO: Rename to afterSaleRejection if preferred style

  /// 申请平台介入中
  applyingForMediation,

  /// 未知或无法解析的状态
  unknown;

  /// 从后端返回的字符串状态安全地转换为 [OrderStatus] 枚举。
  ///
  /// 如果字符串无法识别，则返回 [OrderStatus.unknown]。
  static OrderStatus fromString(String? statusString) {
    if (statusString == null) {
      return OrderStatus.unknown;
    }
    switch (statusString) {
      case 'awaitingPayment':
        return OrderStatus.awaitingPayment;
      case 'awaitingSubmission':
        return OrderStatus.awaitingSubmission;
      case 'buyAwaitingSubmission':
        return OrderStatus.buyAwaitingSubmission;
      case 'awaitingStart':
        return OrderStatus.awaitingStart;
      case 'awaitingDelivery':
        return OrderStatus.awaitingDelivery;
      case 'awaitingConfirmation':
        return OrderStatus.awaitingConfirmation;
      case 'sellerSupplementaryMaterials':
        return OrderStatus.sellerSupplementaryMaterials;
      case 'applyForRefuse':
        return OrderStatus.applyForRefuse;
      case 'awaitingEvaluation':
        return OrderStatus.awaitingEvaluation;
      case 'orderCompleted':
        return OrderStatus.orderCompleted;
      case 'canceled':
        return OrderStatus.canceled;
      case 'afterSale':
        return OrderStatus.afterSale;
      case 'AfterSaleRejection':
        return OrderStatus.AfterSaleRejection;
      case 'applyingForMediation':
        return OrderStatus.applyingForMediation;
      default:
        // 在开发环境下打印警告，以便发现未处理的状态
        if (kDebugMode) {
          print('Warning: Unknown OrderStatus string received: \$statusString');
        }
        return OrderStatus.unknown;
    }
  }

  /// 将枚举值转换为后端需要的字符串表示形式。
  ///
  /// 对于 [OrderStatus.unknown]，返回 null 或空字符串可能更合适，取决于 API 要求。
  String? toJsonString() {
    switch (this) {
      case OrderStatus.awaitingPayment:
        return 'awaitingPayment';
      case OrderStatus.awaitingSubmission:
        return 'awaitingSubmission';
      case OrderStatus.buyAwaitingSubmission:
        return 'buyAwaitingSubmission';
      case OrderStatus.awaitingStart:
        return 'awaitingStart';
      case OrderStatus.awaitingDelivery:
        return 'awaitingDelivery';
      case OrderStatus.awaitingConfirmation:
        return 'awaitingConfirmation';
      case OrderStatus.sellerSupplementaryMaterials:
        return 'sellerSupplementaryMaterials';
      case OrderStatus.applyForRefuse:
        return 'applyForRefuse';
      case OrderStatus.awaitingEvaluation:
        return 'awaitingEvaluation';
      case OrderStatus.orderCompleted:
        return 'orderCompleted';
      case OrderStatus.canceled:
        return 'canceled';
      case OrderStatus.afterSale:
        return 'afterSale';
      case OrderStatus.AfterSaleRejection:
        return 'AfterSaleRejection';
      case OrderStatus.applyingForMediation:
        return 'applyingForMediation';
      case OrderStatus.unknown:
      default:
        // 对于未知状态，返回 null 可能比返回 "unknown" 字符串更安全
        return null;
    }
  }
} 