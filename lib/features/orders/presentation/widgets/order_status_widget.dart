import 'package:flutter/material.dart';

import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/utils/order_status_mapper.dart';

/// 根据订单状态显示不同文本和样式的 Widget
class OrderStatusWidget extends StatelessWidget {
  final OrderStatus status;
  final bool isSellerView;
  final dynamic order; // 可选，用于判断是否为轻咨询订单

  const OrderStatusWidget({
    super.key,
    required this.status,
    this.isSellerView = false,
    this.order,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    // 判断是否为轻咨询订单
    final isLightConsultation = order != null 
        ? OrderStatusMapper.isLightConsultationOrder(order)
        : true; // 默认使用轻咨询模式

    // 使用映射器获取状态文本和颜色
    final statusText = OrderStatusMapper.getSimplifiedStatusText(
      status,
      isLightConsultation: isLightConsultation,
      isSellerView: isSellerView,
    );
    
    final statusColor = OrderStatusMapper.getSimplifiedStatusColor(
      status,
      context,
      isLightConsultation: isLightConsultation,
    );

    return Text(
      statusText,
      style: textTheme.bodySmall?.copyWith(
        color: statusColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }
} 