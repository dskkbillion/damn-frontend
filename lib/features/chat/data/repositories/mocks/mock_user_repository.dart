import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/user.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_user_repository.dart';

/// Chat模块专用的MockUserRepository实现
class MockUserRepository implements IUserRepository {
  final User _mockUser = const User(
    id: 1, // 修改为匹配main_dev_preview.dart中testCommonUserId的值
    commonUserId: '1', // 与main_dev_preview.dart中的testCommonUserId一致
    nickName: '瑞',
    avatar: 'https://duoshaokankan.oss-cn-beijing.aliyuncs.com/20250309/9c09ca8f-59df-4cbf-8d45-c8edb66f8ba9.jpg',
    type: 'MEMBER',
  );

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 100));
    return Right(_mockUser);
  }
} 