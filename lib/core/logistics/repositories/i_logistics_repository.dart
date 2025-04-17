import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';

/// 代表订单的简化物流追踪信息。
/// 用于在订单列表或详情中快速展示关键物流状态。
class SimplifiedTrackingInfo {
  final String? carrierName; // 物流公司名称
  final String? trackingNumber; // 运单号
  final String? latestEventDescription; // 最新的物流事件描述
  final DateTime? latestEventTimestamp; // 最新事件的时间戳

  SimplifiedTrackingInfo({
    this.carrierName,
    this.trackingNumber,
    this.latestEventDescription,
    this.latestEventTimestamp,
  });

  // 可以添加一个 factory 构造函数或者属性来判断是否有有效信息
  bool get hasTrackingInfo => trackingNumber != null && trackingNumber!.isNotEmpty;
}

/// 定义物流/追踪服务相关的仓库接口契约。
abstract class ILogisticsRepository {

  /// 获取指定订单的简化物流追踪信息。
  ///
  /// 如果订单有关联的物流信息，则返回包含 [SimplifiedTrackingInfo] 的 Right。
  /// 如果订单没有物流信息或查询失败，则根据情况返回 Right(null) 或 Left(Failure)。
  ///
  /// [orderId] 要查询的订单 ID。
  Future<Either<Failure, SimplifiedTrackingInfo?>> getSimplifiedOrderTrackingInfo(String orderId);

  // --- Methods to be defined later when Logistics Domain is detailed ---
  // Future<Either<Failure, FullTrackingInfo>> getFullTrackingDetails(String orderId, String? shipmentId);
  // ... etc.
} 