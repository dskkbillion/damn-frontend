import 'package:mockito/mockito.dart';
import 'package:dskk_flutter_refactor/core/auth/repositories/auth_repository.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dartz/dartz.dart';

class MockAuthRepository extends Mock implements IAuthRepository {
  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserProfile() async {
    // 模拟用户信息，包含卖家需要的字段
    return Right({
      'id': 12345,
      'nickName': '测试卖家',
      'avatar': 'https://example.com/avatar.jpg',
      'mobile': '13800138000',
      'onlineFlag': true,
      'recoverFlag': true,
      'recoverContent': '您好，我现在不在线，稍后回复您。',
      'status': 'ENABLE',
      'productNum': 10,
      'orderNum': 20,
      'buyOrderNum': 5
    });
  }
  
  @override
  Future<Either<Failure, bool>> updateOnlineStatus(bool isOnline) async {
    return Right(true); // 操作成功
  }
  
  @override
  Future<Either<Failure, bool>> updateAutoReplySettings({
    required bool isEnabled, 
    String? content
  }) async {
    return Right(true); // 操作成功
  }
} 