import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/rating/repositories/i_rating_repository.dart';

/// IRatingRepository 的手动 Mock 实现。
class MockRatingRepository implements IRatingRepository {
  // --- 控制 canEvaluateOrder 的行为 ---
  bool _shouldFail = false;
  final Map<String, bool> _canEvaluateFlags = {}; // 存储特定订单是否可评价
  bool _defaultCanEvaluate = false; // 默认是否可评价
  // Removed const because ServerFailure constructor is not const
  Failure _failureToReturn = const ServerFailure(message: 'Mock Rating Error: Failed to check evaluation status'); // 默认错误

  void setShouldFail(bool fail) {
    _shouldFail = fail;
  }

  void setFailureToReturn(Failure failure) {
    _failureToReturn = failure;
  }

  /// 配置特定订单 ID 是否可评价。
  void setCanEvaluateForOrder(String orderId, bool canEvaluate) {
    _canEvaluateFlags[orderId] = canEvaluate;
  }

  /// 配置默认的可评价状态。
  void setDefaultCanEvaluate(bool canEvaluate) {
    _defaultCanEvaluate = canEvaluate;
  }

  void clearEvaluateFlags() {
    _canEvaluateFlags.clear();
  }

  @override
  Future<Either<Failure, bool>> canEvaluateOrder(String orderId) async {
    AppLogger.d('[MockRatingRepository] Checking if order $orderId can be evaluated.');
    await Future.delayed(const Duration(milliseconds: 50)); // 模拟延迟

    if (_shouldFail) {
      AppLogger.d('[MockRatingRepository] Returning Failure: $_failureToReturn');
      return Left(_failureToReturn);
    } else {
      final canEvaluate = _canEvaluateFlags[orderId] ?? _defaultCanEvaluate;
      AppLogger.d('[MockRatingRepository] Returning canEvaluate: $canEvaluate');
      return Right(canEvaluate);
    }
  }

  // --- 其他方法的 Mock 实现待添加 ---
} 