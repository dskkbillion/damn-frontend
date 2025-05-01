import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/user.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_user_repository.dart';

/// Chat模块专用的MockUserRepository实现
class MockUserRepository implements IUserRepository {
  final User _mockUser = const User(
    id: 9999, // 示例开发用户ID
    commonUserId: 'user-9999', // 系统通用ID
    nickName: '测试用户',
    avatar: 'https://example.com/avatar.jpg',
    type: 'MEMBER',
  );

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 100));
    return Right(_mockUser);
  }
} 