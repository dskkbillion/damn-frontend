import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/utils/order_status_mapper.dart';
import 'package:flutter/material.dart';

/// Widget displaying the order status timeline and description card.
class OrderStatusTimelineHeader extends StatefulWidget {
  final Order order;

  const OrderStatusTimelineHeader({super.key, required this.order});

  @override
  State<OrderStatusTimelineHeader> createState() => _OrderStatusTimelineHeaderState();
}

class _OrderStatusTimelineHeaderState extends State<OrderStatusTimelineHeader> {


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    // 判断是否为轻咨询订单
    final isLightConsultation = OrderStatusMapper.isLightConsultationOrder(widget.order);

    // 轻咨询模式：简化的时间线步骤
    final List<String> steps = isLightConsultation 
        ? ['下单', '付款', '交付', '评价', '完成']  // 5个简化步骤
        : ['已拍下', '已提交', '已接单', '已交付', '已收货', '待评价'];  // 原有6个步骤
        
    int currentStepIndex = isLightConsultation 
        ? _getSimplifiedStepIndex(widget.order.state)
        : _getCurrentStepIndex(widget.order.state);
    bool showTimeline = widget.order.state != OrderStatus.canceled && 
                       widget.order.state != OrderStatus.applyingForMediation;

    return Container(
      width: double.infinity,
      child: Column(
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
      ),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _buildTimelineSteps(context, steps, currentStepIndex),
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

      // 添加步骤组件（不再添加连接线）
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
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
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
    
    // 判断是否为轻咨询订单
    final isLightConsultation = OrderStatusMapper.isLightConsultationOrder(widget.order);
    
    String statusTitle = isLightConsultation 
        ? _getSimplifiedStatusTitle(status)
        : _getStatusTitle(status);
    String? statusSubtitle = isLightConsultation
        ? _getSimplifiedStatusSubtitle(status)
        : _getStatusSubtitle(status);
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

  // 轻咨询模式：获取简化的步骤索引
  int _getSimplifiedStepIndex(OrderStatus status) {
    const int totalSteps = 5; // 简化为5个步骤
    switch (status) {
      case OrderStatus.awaitingPayment:
        return 0; // 下单
      
      // 这些状态都映射到"交付"步骤
      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
      case OrderStatus.awaitingStart:
      case OrderStatus.awaitingDelivery:
      case OrderStatus.awaitingConfirmation:
        return 2; // 交付中
        
      case OrderStatus.awaitingEvaluation:
        return 3; // 评价
        
      case OrderStatus.orderCompleted:
        return 4; // 完成
        
      // 平台介入、售后、取消等特殊状态
      case OrderStatus.applyingForMediation:
      case OrderStatus.afterSale:
      case OrderStatus.AfterSaleRejection:
      case OrderStatus.sellerSupplementaryMaterials:
      case OrderStatus.applyForRefuse:
      case OrderStatus.canceled:
      case OrderStatus.unknown:
      default:
        return totalSteps; // 视为结束状态
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

  // 轻咨询模式：获取简化的状态标题
  String _getSimplifiedStatusTitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.awaitingPayment: 
        return '等待付款';
      
      // 这些状态都映射到"待交付"
      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
      case OrderStatus.awaitingStart:
      case OrderStatus.awaitingDelivery:
      case OrderStatus.awaitingConfirmation:
        return '咨询进行中';
        
      case OrderStatus.awaitingEvaluation: 
        return '等待评价';
        
      case OrderStatus.orderCompleted: 
        return '咨询完成';
        
      case OrderStatus.canceled: 
        return '已取消';
        
      // 平台介入相关状态
      case OrderStatus.applyingForMediation:
      case OrderStatus.afterSale:
      case OrderStatus.AfterSaleRejection:
      case OrderStatus.sellerSupplementaryMaterials:
      case OrderStatus.applyForRefuse:
        return '平台处理中';
        
      default: 
        return '状态更新中';
    }
  }
  
  // 轻咨询模式：获取简化的状态副标题
  String? _getSimplifiedStatusSubtitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.awaitingPayment: 
        return '请尽快完成支付以开始咨询';
        
      // 这些状态都映射到"待交付"
      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
      case OrderStatus.awaitingStart:
      case OrderStatus.awaitingDelivery:
      case OrderStatus.awaitingConfirmation:
        return '顾问正在为您提供服务';
        
      case OrderStatus.awaitingEvaluation: 
        return '您的评价对顾问很重要';
        
      case OrderStatus.orderCompleted: 
        return '感谢您的信任与支持';
        
      case OrderStatus.canceled:
        return '订单已关闭';
        
      // 平台介入相关状态
      case OrderStatus.applyingForMediation:
      case OrderStatus.afterSale:
      case OrderStatus.AfterSaleRejection:
      case OrderStatus.sellerSupplementaryMaterials:
      case OrderStatus.applyForRefuse:
        return '平台正在协调处理';
        
      default: 
        return null;
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