import 'package:equatable/equatable.dart';

/// 表示订单的基础物流配送信息。
///
/// 注意：根据代码分析，此信息通常直接包含在订单详情中，
/// 且不包含实时物流轨迹 (trackingUpdates)。
class OrderShippingInfo extends Equatable {
  /// 物流 ID (可选)。
  final int? logisticsId;

  /// 物流单号 (可选)。
  final String? logisticsNo;

  /// 发货时间 (可选)。
  final DateTime? deliveryTime;

  // 注意：没有包含 trackingUpdates 字段

  /// 创建一个 [OrderShippingInfo] 实例。
  const OrderShippingInfo({
    this.logisticsId,
    this.logisticsNo,
    this.deliveryTime,
  });

  // Add an empty factory constructor or static constant
  static const OrderShippingInfo empty = OrderShippingInfo(
    logisticsId: null,
    logisticsNo: null,
    deliveryTime: null,
  );

  @override
  List<Object?> get props => [logisticsId, logisticsNo, deliveryTime];
} 