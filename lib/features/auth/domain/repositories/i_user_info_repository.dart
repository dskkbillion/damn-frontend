import 'package:dartz/dartz.dart';

import 'package:dskk_flutter_refactor/core/error/failures.dart'; // 使用包路径
import 'package:dskk_flutter_refactor/features/auth/domain/entities/user_info.dart';

abstract class IUserInfoRepository {
  /// Fetches user information using the provided token.
  ///
  /// Returns [Right] with [UserInfo] on success.
  /// Returns [Left] with [Failure] on error.
  Future<Either<Failure, UserInfo>> fetchUserInfo(String token);
}
