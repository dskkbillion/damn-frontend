import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';

/// 定义评价服务相关的仓库接口契约。
/// 主要供其他模块（如 Orders）判断评价资格或触发评价流程。
abstract class IRatingRepository {

  /// 检查指定的订单是否可以进行评价。
  ///
  /// 这通常基于订单状态（例如已完成）和是否已经评价过。
  ///
  /// [orderId] 要检查的订单 ID。
  /// 成功返回 Right(true) 如果可以评价，Right(false) 如果不能评价。
  /// 失败返回 Left(Failure)。
  Future<Either<Failure, bool>> canEvaluateOrder(String orderId);

  // --- Methods to be defined later when Rating Domain is detailed ---
  // Future<Either<Failure, void>> submitEvaluation(EvaluationData evaluationData);
  // Future<Either<Failure, Evaluation?>> getEvaluationForOrder(String orderId);
  // ... etc.
} 