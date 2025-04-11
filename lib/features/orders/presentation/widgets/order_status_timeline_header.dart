import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:flutter/material.dart';

/// Widget displaying the order status timeline and description card.
class OrderStatusTimelineHeader extends StatelessWidget {
  final Order order;

  const OrderStatusTimelineHeader({super.key, required this.order});

  // TODO: Implement the actual timeline and description card UI based on prototypes
  // This is a basic placeholder structure
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final List<String> steps = [
      '已拍下', '已提交', '已接单', '已交付', '已收货', '待评价'
    ];
    int currentStepIndex = _getCurrentStepIndex(order.state);
    String statusTitle = _getStatusTitle(order.state);
    String? statusSubtitle = _getStatusSubtitle(order.state);
    bool showTimeline = order.state != OrderStatus.canceled; // Don't show timeline for canceled orders

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Timeline Visual (conditional) ---
        if (showTimeline)
          _buildTimelineVisual(context, steps, currentStepIndex),
        if (showTimeline) // Add spacing only if timeline is shown
          const SizedBox(height: 16),
        // --- Status Description Card ---
        Card(
          elevation: 1,
          margin: EdgeInsets.zero, // Reset margin if Card adds default
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusTitle,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (statusSubtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      statusSubtitle,
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.secondary),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Determine the index of the current step based on OrderStatus
  int _getCurrentStepIndex(OrderStatus status) {
    // Refined mapping based on typical flow and prototype screenshots
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

  // Builds the visual representation of the timeline steps and connectors.
  Widget _buildTimelineVisual(BuildContext context, List<String> steps, int currentStepIndex) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final double iconSize = 18.0; // Slightly smaller icons might look better
    final double lineThickness = 1.0;
    final Color activeColor = colorScheme.primary; // Use primary theme color
    final Color inactiveColor = Colors.grey.shade400;

    List<Widget> stepWidgets = [];

    for (int i = 0; i < steps.length; i++) {
      bool isCompleted = i < currentStepIndex;
      bool isActive = i == currentStepIndex;
      bool isInactive = i > currentStepIndex;

      Color currentStepColor = isInactive ? inactiveColor : activeColor;
      IconData currentIconData;
      if (isCompleted) {
        currentIconData = Icons.check_circle;
      } else if (isActive) {
        currentIconData = Icons.circle; // Active step as solid circle
      } else { // isInactive
        currentIconData = Icons.circle; // Inactive step also solid circle, but grey
      }

      // --- Add Connecting Line ---
      if (i > 0) {
        bool previousStepCompleted = (i - 1) < currentStepIndex;
        stepWidgets.add(
          Expanded(
            child: Container(
              height: lineThickness,
              color: previousStepCompleted ? activeColor : inactiveColor,
              margin: const EdgeInsets.symmetric(horizontal: 4.0), // Adjust line margin
            ),
          ),
        );
      }

      // --- Add Step Widget (Icon + Text) ---
      stepWidgets.add(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              currentIconData,
              color: currentStepColor,
              size: iconSize,
            ),
            const SizedBox(height: 6), // Adjust spacing
            Text(
              steps[i],
              style: theme.textTheme.bodySmall?.copyWith(
                color: currentStepColor,
                fontSize: 11, // Adjust font size
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      // Ensure the Row takes full available width
      child: SizedBox(
        width: double.infinity,
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween, // Keep or adjust as needed
          children: stepWidgets,
        ),
      ),
    );
  }
} 