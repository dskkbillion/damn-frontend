import 'package:dartz/dartz.dart';
// 假设 Failure 定义在 core/error/failures.dart
import 'package:dskk_flutter_refactor/core/error/failures.dart';

/// 定义认证相关功能的仓库接口契约。
/// 其他模块（如 Orders）通过此接口与认证状态交互，
/// 而具体的实现则由 Auth 模块在其 Data 层提供。
abstract class IAuthRepository {
  /// 获取当前登录用户的唯一标识符。
  ///
  /// 如果用户已登录，返回包含用户 ID 的 [Right]。
  /// 如果用户未登录或无法获取，返回包含 [AuthFailure] (或其他合适的 Failure 类型) 的 [Left]。
  Future<Either<Failure, String>> getCurrentUserId();

  // 未来可以根据需要添加其他方法，例如:
  // Future<bool> isLoggedIn();
  // Stream<String?> get authStateChanges;
  // Future<Either<Failure, User>> getCurrentUser(); // 如果定义了 User 实体
} 