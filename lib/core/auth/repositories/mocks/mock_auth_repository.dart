import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_credentials.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_status.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/authenticated_user.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// IAuthRepository 的手动 Mock 实现，用于测试和预览环境。
/// 从SecureStorage读取用户ID以匹配其他模块
class MockAuthRepository implements IAuthRepository {
  final FlutterSecureStorage _secureStorage; // 添加SecureStorage
  
  // 使用依赖注入获取SecureStorage
  MockAuthRepository({FlutterSecureStorage? secureStorage}) 
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();
      
  // 缓存用户ID，避免重复读取
  int? _cachedUserId;
  String? _cachedToken;
  
  // 获取真实用户ID的方法
  Future<int> _getUserId() async {
    if (_cachedUserId != null) return _cachedUserId!;
    
    // 优先使用common_user_id
    final commonUserIdStr = await _secureStorage.read(key: 'common_user_id');
    if (commonUserIdStr != null && commonUserIdStr.isNotEmpty) {
      final userId = int.tryParse(commonUserIdStr);
      if (userId != null) {
        _cachedUserId = userId;
        AppLogger.d('[MockAuthRepository] 使用common_user_id: $_cachedUserId');
        return userId;
      }
    }
    
    // 其次使用user_id
    final userIdStr = await _secureStorage.read(key: 'user_id');
    if (userIdStr != null && userIdStr.isNotEmpty) {
      final userId = int.tryParse(userIdStr);
      if (userId != null) {
        _cachedUserId = userId;
        AppLogger.d('[MockAuthRepository] 使用user_id: $_cachedUserId');
        return userId;
      }
    }
    
    // 如果无法获取有效用户ID，直接抛出异常
    AppLogger.d('[MockAuthRepository] 无法获取有效的用户ID');
    throw Exception('无法获取有效的用户ID。请确保已登录并设置了common_user_id或user_id');
  }
  
  // 获取真实token的方法
  Future<String> _getToken() async {
    if (_cachedToken != null) return _cachedToken!;
    
    // 首先尝试auth_token
    final token = await _secureStorage.read(key: 'auth_token');
    if (token != null && token.isNotEmpty) {
      _cachedToken = token;
      AppLogger.d('[MockAuthRepository] 使用auth_token');
      return token;
    }
    
    // 其次尝试user_token
    final userToken = await _secureStorage.read(key: 'user_token');
    if (userToken != null && userToken.isNotEmpty) {
      _cachedToken = userToken;
      AppLogger.d('[MockAuthRepository] 使用user_token');
      return userToken;
    }
    
    // 如果无法获取有效token，直接抛出异常
    AppLogger.d('[MockAuthRepository] 无法获取有效的token');
    throw Exception('无法获取有效的token。请确保已登录并设置了auth_token或user_token');
  }

  // Return a stream that immediately emits the fake authenticated status
  @override
  Stream<AuthStatus> get authStatus async* {
    try {
      final userId = await _getUserId();
      final token = await _getToken();
      yield Authenticated(AuthenticatedUser(id: userId, token: token));
    } catch (e) {
      yield const Unauthenticated();
      AppLogger.d('[MockAuthRepository] authStatus生成Unauthenticated: $e');
    }
  }

  // Return the user from SecureStorage synchronously (as sync as possible)
  @override
  Either<Failure, AuthenticatedUser?> getLoggedInUserSync() {
    AppLogger.d('[MockAuthRepository] getLoggedInUserSync called');
    
    // 如果有缓存，直接使用
    if (_cachedUserId != null && _cachedToken != null) {
      return Right(AuthenticatedUser(id: _cachedUserId!, token: _cachedToken!));
    }
    
    // 没有缓存时，启动异步更新
    _updateCachedValuesOrEmitError();
    
    // 返回失败，因为我们需要异步加载数据
    return const Left(AuthFailure(message: '用户数据尚未加载完成，请稍后再试'));
  }
  
  // 异步更新缓存的值，出错时不使用默认值
  Future<void> _updateCachedValuesOrEmitError() async {
    try {
      _cachedUserId = await _getUserId();
      _cachedToken = await _getToken();
      AppLogger.d('[MockAuthRepository] 缓存更新成功: userId=$_cachedUserId');
    } catch (e) {
      // 清除可能的部分缓存
      _cachedUserId = null;
      _cachedToken = null;
      AppLogger.d('[MockAuthRepository] 缓存更新失败: $e');
    }
  }

  // Simulate login but with real user data
  @override
  Future<Either<Failure, AuthenticatedUser>> loginWithVerificationCode(
      VerificationCodeCredentials credentials) async {
    AppLogger.d('[MockAuthRepository] loginWithVerificationCode called');
    try {
      // 获取真实用户ID和token
      final userId = await _getUserId();
      final token = await _getToken();
      return Right(AuthenticatedUser(id: userId, token: token));
    } catch (e) {
      return Left(AuthFailure(message: '登录失败: ${e.toString()}'));
    }
  }

  // Simulate logout, clearing cached values
  @override
  Future<Either<Failure, void>> logout() async {
    AppLogger.d('[MockAuthRepository] logout called - 正在清除用户认证信息');
    
    // 清除缓存
    _cachedUserId = null;
    _cachedToken = null;
    
    // 清除secure storage中的认证信息
    try {
      await _secureStorage.delete(key: 'user_id');
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'common_user_id');
      await _secureStorage.delete(key: 'user_token');
      AppLogger.d('[MockAuthRepository] 成功清除secure storage中的认证信息');
    } catch (e) {
      AppLogger.d('[MockAuthRepository] 清除secure storage数据失败: $e');
      return Left(CacheFailure(message: '清除认证信息失败: $e'));
    }
    
    return const Right(null);
  }

  // Simulate successful code sending
  @override
  Future<Either<Failure, void>> sendVerificationCode({required String phone}) async {
    AppLogger.d('[MockAuthRepository] sendVerificationCode called for $phone (simulated success).');
    return const Right(null);
  }

  // Return user ID from storage with proper error handling
  @override
  Future<Either<Failure, String>> getCurrentUserId() async {
    try {
      final userId = await _getUserId();
      AppLogger.d('[MockAuthRepository] getCurrentUserId: 返回用户ID $userId');
      return Right(userId.toString());
    } catch (e) {
      AppLogger.d('[MockAuthRepository] getCurrentUserId 失败: $e');
      return Left(AuthFailure(message: '获取用户ID失败: ${e.toString()}'));
    }
  }

  // --- 未来可以为其他接口方法添加类似的控制逻辑 ---
} 