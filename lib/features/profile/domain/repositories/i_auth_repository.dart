import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

/// 定义身份验证相关的接口（由 Auth 模块提供实现）
abstract class IAuthRepository {
  /// 获取当前登录用户 ID
  ///
  /// 返回当前登录的用户 ID，如果未登录则返回 null
  Future<String?> getCurrentUserId();

  /// 退出登录
  ///
  /// 返回操作结果，成功或 [Failure]
  Future<Either<Failure, void>> logout();

  /// 检查用户是否已登录
  ///
  /// 返回用户登录状态
  Future<bool> isLoggedIn();
}
