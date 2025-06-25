import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:flutter/material.dart';

/// Widget displaying the order status timeline and description card.
class OrderStatusTimelineHeader extends StatefulWidget {
  final Order order;

  const OrderStatusTimelineHeader({super.key, required this.order});

  @override
  State<OrderStatusTimelineHeader> createState() => _OrderStatusTimelineHeaderState();
}

class _OrderStatusTimelineHeaderState extends State<OrderStatusTimelineHeader> {

  double _getCurrentProgress() {
    final currentStep = _getCurrentStepIndex(widget.order.state);
    return currentStep / 5.0; // 总共6步，索引0-5
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final List<String> steps = [
      '已拍下', '已提交', '已接单', '已交付', '已收货', '待评价'
    ];
    int currentStepIndex = _getCurrentStepIndex(widget.order.state);
    bool showTimeline = widget.order.state != OrderStatus.canceled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 优化后的时间线视觉效果 ---
        if (showTimeline)
          _buildOptimizedTimeline(context, steps, currentStepIndex),
        // 状态说明卡片
        if (showTimeline)
          const SizedBox(height: 16),
        _buildStatusInfoCard(context, widget.order.state),
      ],
    );
  }

  /// 构建优化后的时间线
  Widget _buildOptimizedTimeline(BuildContext context, List<String> steps, int currentStepIndex) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: colorScheme.surface, // 移除透明度
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部进度条 - 左对齐
          Align(
            alignment: Alignment.centerLeft,
            child: _buildProgressBar(context, _getCurrentProgress()), // 直接使用值，避免动画
          ),
          const SizedBox(height: 20),
          // 步骤指示器
          Row(
            children: _buildTimelineSteps(context, steps, currentStepIndex),
          ),
        ],
      ),
    );
  }

  /// 构建进度条
  Widget _buildProgressBar(BuildContext context, double progress) {
    final colorScheme = Theme.of(context).colorScheme;
    const double progressBarWidth = 280.0; // 固定宽度，避免MediaQuery调用
    
    return SizedBox(
      width: progressBarWidth,
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: progressBarWidth * progress.clamp(0.0, 1.0),
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.primary, // 简化为单色，移除渐变
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建时间线步骤
  List<Widget> _buildTimelineSteps(BuildContext context, List<String> steps, int currentStepIndex) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    List<Widget> stepWidgets = [];

    for (int i = 0; i < steps.length; i++) {
      bool isCompleted = i < currentStepIndex;
      bool isActive = i == currentStepIndex;
      bool isInactive = i > currentStepIndex;

      Color currentStepColor = isInactive ? Colors.grey.shade400 : colorScheme.primary;

      // 添加连接线（除了第一个步骤）
      if (i > 0) {
        stepWidgets.add(_buildConnectingLine(isCompleted || (i - 1) == currentStepIndex, context));
      }

      // 添加步骤组件
      stepWidgets.add(_buildStepWidget(
        context,
        steps[i],
        isCompleted,
        isActive,
        currentStepColor,
      ));
    }

    return stepWidgets;
  }

  /// 构建优化的连接线
  Widget _buildConnectingLine(bool isActive, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Expanded(
      child: Container(
        height: 2.0,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.primary : Colors.grey.shade300, // 简化为单色
          borderRadius: BorderRadius.circular(1.0),
        ),
      ),
    );
  }

  /// 构建步骤组件
  Widget _buildStepWidget(
    BuildContext context,
    String stepText,
    bool isCompleted,
    bool isActive,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStepCircle(isCompleted, isActive, color), // 直接使用，移除动画
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxWidth: 50),
          child: Text(
            stepText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// 构建步骤圆点
  Widget _buildStepCircle(bool isCompleted, bool isActive, Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted || isActive ? color : Colors.transparent,
        border: Border.all(
          color: color,
          width: isActive ? 2.5 : 2.0,
        ),
      ),
      child: isCompleted 
          ? const Icon(
              Icons.check,
              size: 14,
              color: Colors.white,
            )
          : isActive 
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                )
              : null,
    );
  }

  /// 构建简洁的状态信息卡片
  Widget _buildStatusInfoCard(BuildContext context, OrderStatus status) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    String statusTitle = _getStatusTitle(status);
    String? statusSubtitle = _getStatusSubtitle(status);
    IconData statusIcon = _getStatusIcon(status);
    Color statusColor = _getStatusColor(status, colorScheme);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              size: 24,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusTitle,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
                if (statusSubtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    statusSubtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 获取状态对应的图标
  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.awaitingPayment:
        return Icons.payment_outlined;
      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
        return Icons.upload_file_outlined;
      case OrderStatus.awaitingStart:
        return Icons.hourglass_empty_outlined;
      case OrderStatus.awaitingDelivery:
        return Icons.local_shipping_outlined;
      case OrderStatus.awaitingConfirmation:
        return Icons.inventory_2_outlined;
      case OrderStatus.awaitingEvaluation:
        return Icons.rate_review_outlined;
      case OrderStatus.orderCompleted:
        return Icons.check_circle_outline;
      case OrderStatus.canceled:
        return Icons.cancel_outlined;
      case OrderStatus.afterSale:
      case OrderStatus.AfterSaleRejection:
        return Icons.support_agent_outlined;
      case OrderStatus.applyingForMediation:
      case OrderStatus.applyForRefuse:
        return Icons.gavel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  /// 获取状态对应的颜色
  Color _getStatusColor(OrderStatus status, ColorScheme colorScheme) {
    switch (status) {
      case OrderStatus.awaitingPayment:
        return Colors.orange;
      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
        return Colors.blue;
      case OrderStatus.awaitingStart:
      case OrderStatus.awaitingDelivery:
        return colorScheme.primary;
      case OrderStatus.awaitingConfirmation:
        return Colors.teal;
      case OrderStatus.awaitingEvaluation:
        return Colors.amber;
      case OrderStatus.orderCompleted:
        return Colors.green;
      case OrderStatus.canceled:
        return colorScheme.error;
      case OrderStatus.afterSale:
      case OrderStatus.AfterSaleRejection:
      case OrderStatus.applyingForMediation:
      case OrderStatus.applyForRefuse:
        return Colors.deepOrange;
      default:
        return colorScheme.secondary;
    }
  }

  // Determine the index of the current step based on OrderStatus
  int _getCurrentStepIndex(OrderStatus status) {
    const int totalSteps = 6; // Define total steps here
    switch (status) {
      case OrderStatus.awaitingPayment:
        return 0; // Stuck at '已拍下' (or step 0)
      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
        return 1; // Active step: '已提交'
      case OrderStatus.awaitingStart:
        return 2; // Active step: '已接单'
      case OrderStatus.awaitingDelivery:
        return 3; // Active step: '已交付' (Seller needs to deliver)
      case OrderStatus.awaitingConfirmation:
        return 4; // Active step: '已收货' (Buyer needs to confirm)
      case OrderStatus.awaitingEvaluation:
        return 5; // Active step: '待评价'
      case OrderStatus.orderCompleted:
        return totalSteps; // Completed all steps
      case OrderStatus.canceled:
      case OrderStatus.afterSale:
      case OrderStatus.AfterSaleRejection:
      case OrderStatus.applyingForMediation:
      case OrderStatus.sellerSupplementaryMaterials:
      case OrderStatus.applyForRefuse:
      case OrderStatus.unknown:
      default:
        return totalSteps; // Treat as completed for visual purpose if shown
    }
  }

  // Get status title text based on prototype screenshots
  String _getStatusTitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.awaitingPayment: return '等待买家付款';
      case OrderStatus.awaitingSubmission: return '等待提交需求';
      case OrderStatus.buyAwaitingSubmission: return '卖家要求补充材料';
      case OrderStatus.awaitingStart: return '等待卖家接单';
      case OrderStatus.awaitingDelivery: return '等待卖家交付';
      case OrderStatus.awaitingConfirmation: return '等待确认收货';
      case OrderStatus.awaitingEvaluation: return '等待您的评价';
      case OrderStatus.orderCompleted: return '订单已完成';
      case OrderStatus.canceled: return '订单已取消';
      case OrderStatus.afterSale: return '售后处理中';
      case OrderStatus.AfterSaleRejection: return '售后申请已拒绝';
      case OrderStatus.applyingForMediation: return '平台介入处理中';
      case OrderStatus.sellerSupplementaryMaterials: return '卖家要求补充材料';
      case OrderStatus.applyForRefuse: return '申请平台介入';
      default: return '订单状态未知';
    }
  }

   // Get status subtitle text based on prototype screenshots
  String? _getStatusSubtitle(OrderStatus status) {
     switch (status) {
      case OrderStatus.awaitingPayment: 
        return '请尽快完成支付，超时订单将自动取消';
      case OrderStatus.awaitingSubmission: 
        return '请按照服务要求提交所需材料';
      case OrderStatus.buyAwaitingSubmission: 
        return '请及时对材料进行修改或补充';
      case OrderStatus.awaitingStart: 
        return '卖家会尽快处理您的订单';
      case OrderStatus.awaitingDelivery: 
        return '卖家正在为您准备服务内容';
      case OrderStatus.awaitingConfirmation: 
        return '请确认是否已收到满意的服务';
      case OrderStatus.awaitingEvaluation: 
        return '您的评价对卖家很重要';
      case OrderStatus.orderCompleted: 
        return '感谢您的信任与支持';
      case OrderStatus.canceled:
        return '订单已关闭，如有问题请联系客服';
      case OrderStatus.afterSale:
        return '售后申请正在处理中';
      case OrderStatus.AfterSaleRejection:
        return '您的售后申请未通过审核';
      case OrderStatus.applyingForMediation:
        return '平台正在协调处理您的问题';
      case OrderStatus.sellerSupplementaryMaterials:
        return '卖家需要您提供更多信息';
      case OrderStatus.applyForRefuse:
        return '您的申请正在等待平台处理';
      default: 
        return null;
    }
  }
} 