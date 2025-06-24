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
    String statusTitle = _getStatusTitle(widget.order.state);
    String? statusSubtitle = _getStatusSubtitle(widget.order.state);
    bool showTimeline = widget.order.state != OrderStatus.canceled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 优化后的时间线视觉效果 ---
        if (showTimeline)
          _buildOptimizedTimeline(context, steps, currentStepIndex),
        if (showTimeline)
          const SizedBox(height: 16),
        // --- Status Description Card ---
        Card(
          elevation: 1,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusTitle,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (statusSubtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      statusSubtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
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
      case OrderStatus.awaitingSubmission: return '订单要求提交';
      case OrderStatus.buyAwaitingSubmission: return '卖家申请补充材料'; // From screenshot
      case OrderStatus.awaitingStart: return '等待卖家接单'; // From screenshot
      case OrderStatus.awaitingDelivery: return '等待卖家交付'; // From screenshot
      case OrderStatus.awaitingConfirmation: return '等待确认收货'; // From screenshot
      case OrderStatus.awaitingEvaluation: return '等待您的评价'; // From screenshot
      case OrderStatus.orderCompleted: return '订单已完成';
      case OrderStatus.canceled:
        // Check if specific cancellation reasons have different titles
        // Example: '卖家拒绝接单' was shown in one screenshot for a canceled state
        // This might need more context from the order object itself if available
        return '订单已取消'; // Generic title
      case OrderStatus.afterSale: return '售后处理中';
      case OrderStatus.AfterSaleRejection: return '售后申请已拒绝';
      case OrderStatus.applyingForMediation: return '平台介入处理中';
       case OrderStatus.sellerSupplementaryMaterials: return '卖家要求补充材料'; // Might be same as buyAwaitingSubmission title?
       case OrderStatus.applyForRefuse: return '买家申请平台介入'; // Guessing based on enum name
      default: return '订单状态未知';
    }
  }

   // Get status subtitle text based on prototype screenshots
  String? _getStatusSubtitle(OrderStatus status) {
     switch (status) {
      case OrderStatus.awaitingPayment: return '订单将在xx时间后关闭，请尽快付款'; // Add timer logic later
      case OrderStatus.awaitingSubmission: return 'xx天xx时xx分后，如您仍未上传订单要求，系统将自动取消该订单并将款项原路返回'; // Add timer logic later
      case OrderStatus.buyAwaitingSubmission: return '请及时对材料进行修改或补充'; // Example, adjust based on exact prototype text
      case OrderStatus.awaitingStart: return 'xx天xx时xx分后，如卖家未响应，系统将对卖家进行积分减扣，该订单将自动取消并将款项原路返回'; // Add timer later
      case OrderStatus.awaitingDelivery: return 'xx天xx时xx分前，您将收到交付。如卖家到期未交付，您可以联系客服寻求帮助'; // Add timer later
      case OrderStatus.awaitingConfirmation: return '买家已完成交付，请确认是否收货。xxx后将自动收货，订单有任何问题请联系卖家或申请平台介入'; // Add timer later
      case OrderStatus.awaitingEvaluation: return '请对本次服务做出评价';
      case OrderStatus.orderCompleted: return '订单已顺利完成'; // Example subtitle
      case OrderStatus.canceled:
        // Example: '该订单已自动取消，三天内款项将原路返回，如有问题请联系客服' (For seller rejection case)
        return '订单已关闭'; // Generic subtitle
       // Add subtitles for other states if needed
      default: return null;
    }
  }
} 