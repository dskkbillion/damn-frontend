import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/logistics/repositories/i_logistics_repository.dart';

/// ILogisticsRepository 的手动 Mock 实现。
class MockLogisticsRepository implements ILogisticsRepository {
  // --- 控制 getSimplifiedOrderTrackingInfo 的行为 ---
  bool _shouldFail = false;
  Map<String, SimplifiedTrackingInfo?> _trackingInfos = {}; // 存储特定订单的追踪信息
  SimplifiedTrackingInfo? _defaultTrackingInfo; // 默认追踪信息（可能为 null）
  // Removed const because ServerFailure constructor is not const
  Failure _failureToReturn = ServerFailure(message: 'Mock Logistics Error: Failed to get tracking info'); // 默认错误

  void setShouldFail(bool fail) {
    _shouldFail = fail;
  }

  void setFailureToReturn(Failure failure) {
    _failureToReturn = failure;
  }

  /// 配置特定订单 ID 返回的追踪信息。可以设置为 null 表示没有信息。
  void setTrackingInfoForOrder(String orderId, SimplifiedTrackingInfo? info) {
    _trackingInfos[orderId] = info;
  }

  /// 配置默认返回的追踪信息。
  void setDefaultTrackingInfo(SimplifiedTrackingInfo? info) {
    _defaultTrackingInfo = info;
  }

  void clearTrackingInfos() {
    _trackingInfos.clear();
  }

  @override
  Future<Either<Failure, SimplifiedTrackingInfo?>> getSimplifiedOrderTrackingInfo(String orderId) async {
    AppLogger.d('[MockLogisticsRepository] Getting tracking info for order: $orderId');
    await Future.delayed(const Duration(milliseconds: 120)); // 模拟延迟

    if (_shouldFail) {
      AppLogger.d('[MockLogisticsRepository] Returning Failure: $_failureToReturn');
      return Left(_failureToReturn);
    } else {
      final info = _trackingInfos.containsKey(orderId)
                   ? _trackingInfos[orderId] // 如果 map 中存在 key，即使 value 是 null 也要返回
                   : _defaultTrackingInfo;
      AppLogger.d('[MockLogisticsRepository] Returning Tracking Info: ${info?.trackingNumber ?? 'None'}');
      return Right(info);
    }
  }

  // --- 其他方法的 Mock 实现待添加 ---
} 