import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';

/// 订单状态映射器 - 用于轻咨询模式的状态简化
/// 
/// 将详细状态映射到当前轻咨询展示状态：
/// - 待付款 (awaitingPayment)
/// - 待交付 (awaitingDelivery) 
/// - 评价 (awaitingEvaluation)
/// - 完成 (orderCompleted)
/// - 售后中 (afterSale)
/// - 平台介入中 (applyingForMediation)
/// - 已取消 (canceled)
class OrderStatusMapper {
  /// 获取简化后的状态文本
  static String getSimplifiedStatusText(
    OrderStatus status, {
    bool isLightConsultation = true,
    bool isSellerView = false,
  }) {
    // 如果不是轻咨询模式，返回原始状态文本
    if (!isLightConsultation) {
      return _getOriginalStatusText(status, isSellerView);
    }

    // 轻咨询模式：核心交易状态 + 售后状态铺开显示
    switch (status) {
      case OrderStatus.awaitingPayment:
        return '待付款';

      // 轻咨询：咨询中（买家视角） / 待交付（卖家视角保持不变）
      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
      case OrderStatus.awaitingStart:
      case OrderStatus.awaitingDelivery:
        return isSellerView ? '待交付' : '咨询中';

      case OrderStatus.awaitingConfirmation:
        return isSellerView ? '待交付' : '待确认';

      case OrderStatus.awaitingEvaluation:
        return '评价';

      case OrderStatus.orderCompleted:
        return '完成';

      // 售后相关状态显示为"售后中"
      case OrderStatus.afterSale:
      case OrderStatus.AfterSaleRejection:
      case OrderStatus.sellerSupplementaryMaterials:
      case OrderStatus.applyForRefuse:
        return '售后中';

      case OrderStatus.applyingForMediation:
        return '平台介入中';

      case OrderStatus.canceled:
        return '已取消';

      case OrderStatus.unknown:
      default:
        return '未知状态';
    }
  }

  /// 获取简化后的状态颜色
  static Color getSimplifiedStatusColor(
    OrderStatus status,
    BuildContext context, {
    bool isLightConsultation = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!isLightConsultation) {
      return _getOriginalStatusColor(status, context);
    }

    // 轻咨询模式的简化颜色方案
    switch (status) {
      case OrderStatus.awaitingPayment:
        return colorScheme.error; // 红色 - 待付款

      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
      case OrderStatus.awaitingStart:
      case OrderStatus.awaitingDelivery:
      case OrderStatus.awaitingConfirmation:
        return AppColors.warning; // 橙色 - 进行中

      case OrderStatus.awaitingEvaluation:
        return Colors.green; // 绿色 - 待评价

      case OrderStatus.orderCompleted:
        return colorScheme.secondary; // 次要色 - 已完成

      case OrderStatus.afterSale:
      case OrderStatus.AfterSaleRejection:
      case OrderStatus.sellerSupplementaryMaterials:
      case OrderStatus.applyForRefuse:
        return Colors.deepOrange; // 橙红色 - 售后处理中

      case OrderStatus.applyingForMediation:
        return Colors.blueGrey; // 蓝灰色 - 平台介入

      case OrderStatus.canceled:
        return AppColors.textSecondary; // 灰色 - 已取消

      case OrderStatus.unknown:
      default:
        return AppColors.textSecondary;
    }
  }

  /// 判断订单是否为轻咨询类型
  static bool isLightConsultationOrder(dynamic order) {
    // 根据订单的产品类型或服务等级判断
    // 可以根据实际的订单数据结构调整判断逻辑
    if (order == null) return true; // 默认为轻咨询模式
    
    // 检查订单的feature字段（后端可能在这里标记）
    try {
      if (order.feature != null) {
        // 如果feature中包含轻咨询标记
        if (order.feature is Map) {
          return order.feature['consultationType'] == 'light' ||
                 order.feature['orderType'] == 'LIGHT_CONSULTATION';
        }
        if (order.feature is String && order.feature.contains('light')) {
          return true;
        }
      }
    } catch (e) {
      // 忽略访问错误
    }
    
    // 检查订单备注中是否包含轻咨询关键词
    try {
      if (order.remark != null && order.remark is String) {
        final remarkLower = order.remark.toLowerCase();
        if (remarkLower.contains('轻咨询') || 
            remarkLower.contains('light consultation') ||
            remarkLower.contains('咨询')) {
          return true;
        }
      }
    } catch (e) {
      // 忽略访问错误
    }
    
    // 默认为轻咨询模式（当前阶段全部使用轻咨询模式）
    return true;
  }

  /// 获取原始状态文本（非轻咨询模式）
  static String _getOriginalStatusText(OrderStatus status, bool isSellerView) {
    switch (status) {
      case OrderStatus.awaitingPayment:
        return '待付款';
      case OrderStatus.awaitingSubmission:
        return '待提交';
      case OrderStatus.buyAwaitingSubmission:
        return '待重传';
      case OrderStatus.awaitingStart:
        return isSellerView ? '待接单' : '待接单';
      case OrderStatus.awaitingDelivery:
        return isSellerView ? '待交付' : '待发货';
      case OrderStatus.awaitingConfirmation:
        return isSellerView ? '待确认' : '待收货';
      case OrderStatus.sellerSupplementaryMaterials:
        return '补充材料';
      case OrderStatus.applyForRefuse:
        return '申请拒绝';
      case OrderStatus.awaitingEvaluation:
        return '待评价';
      case OrderStatus.orderCompleted:
        return '已完成';
      case OrderStatus.canceled:
        return '已取消';
      case OrderStatus.afterSale:
        return '售后中';
      case OrderStatus.AfterSaleRejection:
        return '售后拒绝';
      case OrderStatus.applyingForMediation:
        return '平台介入中';
      case OrderStatus.unknown:
      default:
        return '未知状态';
    }
  }

  /// 获取原始状态颜色（非轻咨询模式）
  static Color _getOriginalStatusColor(OrderStatus status, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (status) {
      case OrderStatus.awaitingPayment:
        return colorScheme.error;
      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
        return AppColors.warning;
      case OrderStatus.awaitingStart:
        return AppColors.info;
      case OrderStatus.awaitingDelivery:
        return AppColors.warning;
      case OrderStatus.awaitingConfirmation:
        return colorScheme.primary;
      case OrderStatus.awaitingEvaluation:
        return Colors.green;
      case OrderStatus.orderCompleted:
        return colorScheme.secondary;
      case OrderStatus.canceled:
        return AppColors.textSecondary;
      case OrderStatus.afterSale:
      case OrderStatus.AfterSaleRejection:
        return Colors.deepOrange;
      case OrderStatus.applyingForMediation:
        return Colors.blueGrey;
      case OrderStatus.sellerSupplementaryMaterials:
      case OrderStatus.applyForRefuse:
      case OrderStatus.unknown:
      default:
        return AppColors.textSecondary;
    }
  }

  /// 获取简化后的操作按钮
  static List<String> getSimplifiedActions(
    OrderStatus status, {
    bool isSellerView = false,
  }) {
    switch (status) {
      case OrderStatus.awaitingPayment:
        return isSellerView ? [] : ['支付', '取消'];

      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
      case OrderStatus.awaitingStart:
      case OrderStatus.awaitingDelivery:
      case OrderStatus.awaitingConfirmation:
        // 待交付状态
        if (isSellerView) {
          return ['交付', '联系买家'];
        } else {
          return ['查看', '联系卖家'];
        }

      case OrderStatus.awaitingEvaluation:
        return isSellerView ? [] : ['评价'];

      case OrderStatus.orderCompleted:
        return ['查看'];

      case OrderStatus.applyingForMediation:
      case OrderStatus.afterSale:
      case OrderStatus.AfterSaleRejection:
      case OrderStatus.sellerSupplementaryMaterials:
      case OrderStatus.applyForRefuse:
        return ['查看', '联系客服'];

      case OrderStatus.canceled:
        return ['删除'];

      case OrderStatus.unknown:
      default:
        return [];
    }
  }
}
