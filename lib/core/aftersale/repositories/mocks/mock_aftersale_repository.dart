import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/aftersale/repositories/i_aftersale_repository.dart';

/// IAfterSaleRepository 的手动 Mock 实现，用于测试和预览环境。
class MockAfterSaleRepository implements IAfterSaleRepository {
  // --- 控制 getSimpleOrderAfterSaleStatus 的行为 ---
  bool _shouldFail = false;
  // 默认返回 'none' 状态，可以根据订单 ID 模拟不同状态，或提供方法设置
  Map<String, SimpleAfterSaleStatus> _orderStatuses = {};
  SimpleAfterSaleStatus _defaultStatus = SimpleAfterSaleStatus.none;
  // Removed const because ServerFailure constructor is not const
  Failure _failureToReturn = ServerFailure(message: 'Mock AfterSale Error: Failed to get status'); // 默认模拟错误

  /// 配置 Mock 对象在调用 getSimpleOrderAfterSaleStatus 时是否强制失败。
  void setShouldFail(bool fail) {
    _shouldFail = fail;
  }

  /// 配置 Mock 对象在失败时返回的 Failure 类型。
  void setFailureToReturn(Failure failure) {
    _failureToReturn = failure;
  }

  /// 为特定订单 ID 配置返回的状态。
  void setStatusForOrder(String orderId, SimpleAfterSaleStatus status) {
      _orderStatuses[orderId] = status;
  }

  /// 配置默认返回的状态（如果特定订单 ID 没有配置）。
  void setDefaultStatus(SimpleAfterSaleStatus status) {
      _defaultStatus = status;
  }

  /// 清除所有特定订单的状态配置。
  void clearOrderStatuses() {
      _orderStatuses.clear();
  }


  @override
  Future<Either<Failure, SimpleAfterSaleStatus>> getSimpleOrderAfterSaleStatus(String orderId) async {
    AppLogger.d('[MockAfterSaleRepository] Getting status for order: $orderId');
    await Future.delayed(const Duration(milliseconds: 80)); // 模拟延迟

    if (_shouldFail) {
      AppLogger.d('[MockAfterSaleRepository] Returning Failure: $_failureToReturn');
      return Left(_failureToReturn);
    } else {
      // 检查是否有为这个 orderId 配置的特定状态，否则返回默认状态
      final statusToReturn = _orderStatuses[orderId] ?? _defaultStatus;
      AppLogger.d('[MockAfterSaleRepository] Returning Status: $statusToReturn');
      return Right(statusToReturn);
    }
  }

  // --- 其他方法的 Mock 实现待添加 ---
  // Implement mock methods for applyRefund, getRefundDetail, etc. later
} 