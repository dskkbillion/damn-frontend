import 'package:dartz/dartz.dart';
import 'dart:async';

import 'package:damn_frontend/core/error/exceptions.dart';
import 'package:damn_frontend/core/error/failures.dart';
import 'package:damn_frontend/core/network/network_info.dart'; // 假设有网络状态检查
import 'package:damn_frontend/core/storage/secure_storage_repository.dart'; // 引入安全存储接口

import 'package:damn_frontend/features/auth/domain/entities/auth_credentials.dart';
import 'package:damn_frontend/features/auth/domain/entities/auth_status.dart';
import 'package:damn_frontend/features/auth/domain/entities/authenticated_user.dart';
import 'package:damn_frontend/features/auth/domain/entities/registration_details.dart';
import 'package:damn_frontend/features/auth/domain/entities/verification_purpose.dart';
import 'package:damn_frontend/features/auth/domain/repositories/i_auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_info_model.dart'; // Import the new UserInfoModel

// TODO: Remove this placeholder if UserInfo is defined in Core/Profile
class UserInfo {
  final String userId;
  final String mobile;
  const UserInfo({required this.userId, required this.mobile});
}
abstract class IUserInfoRepository {
  Future<Either<Failure, UserInfo>> fetchUserInfo(String token);
}
// End placeholder

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final ISecureStorageRepository secureStorage; // 注入安全存储
  final NetworkInfo networkInfo; // 注入网络状态检查
  final IUserInfoRepository userInfoRepository; // 注入 UserInfo Repository

  final StreamController<AuthStatus> _statusController = StreamController<AuthStatus>.broadcast();
  AuthenticatedUser? _currentUser;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
    required this.networkInfo,
    required this.userInfoRepository, // 添加依赖
  }) {
    // 初始化时检查本地存储的认证状态
    _initializeAuthStatus();
  }

  // 初始化认证状态
  Future<void> _initializeAuthStatus() async {
    _statusController.add(const AuthUnknown()); // 初始为未知
    try {
      // 同时获取 userId 和 token
      final userId = await secureStorage.getUserId();
      final token = await secureStorage.getToken();

      if (userId != null && token != null) {
        // TODO: Token 有效性校验逻辑仍需考虑
        print('Found existing token and userId in secure storage.');
        _currentUser = AuthenticatedUser(userId: userId, token: token);
        _statusController.add(Authenticated(_currentUser!));
      } else {
        print('No existing token/userId found, or only partial data found.');
        // 只要有一个不存在，就清理掉另一个，确保状态一致性
        await secureStorage.clearAllAuthData();
        _statusController.add(const Unauthenticated());
      }
    } catch (e) {
      print('Error initializing auth status: $e. Clearing storage.');
      try {
        await secureStorage.clearAllAuthData();
      } catch (clearError) {
         print('Failed to clear storage during init error: $clearError');
      }
      _statusController.add(const Unauthenticated());
    }
  }

  @override
  Stream<AuthStatus> get authStatus => _statusController.stream;

  // 辅助函数，用于执行需要网络的操作
  Future<Either<Failure, T>> _networkedOperation<T>(
      Future<T> Function() operation) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await operation();
        return Right(result);
      } on ServerException catch (e) {
        // TODO: 可以根据 e 的具体错误信息返回更具体的 Failure
        print('ServerException in repository: ${e.message}');
        // Check for unauthenticated errors specifically if needed
        if (e is UnauthenticatedException) {
            await _handleLogoutLocally(); // Ensure local state is cleared on auth errors
            return Left(AuthenticationFailure(message: e.message ?? 'Session expired or invalid'));
        }
        return Left(ServerFailure(message: e.message ?? 'Unknown server error'));
      } on CacheException catch (e) { // 假设 SecureStorage 可能抛出
        print('CacheException in repository: ${e.message}');
        return Left(CacheFailure(message: e.message ?? 'Storage error'));
      } catch (e) {
        print('Unknown exception in repository: ${e.toString()}');
        return Left(UnknownFailure(message: 'An unknown error occurred'));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, AuthenticatedUser>> loginWithVerificationCode(
      VerificationCodeCredentials credentials) async {
    // Step 1: Call login API to get the token
    final loginResult = await _networkedOperation(() =>
        remoteDataSource.loginWithVerificationCode(credentials));

    return loginResult.fold(
      (failure) => Left(failure),
      (loginResponse) async {
        // Step 2: Use the token to fetch UserInfo (which contains userId)
        // Now uses the injected userInfoRepository
        final userFetchResult = await userInfoRepository.fetchUserInfo(loginResponse.token);

        return userFetchResult.fold(
          (failure) {
             // If fetching user info fails (e.g., token invalid immediately after login?)
             // Treat this as a login failure overall.
             print('Failed to fetch user info after successful token acquisition: $failure');
             // We might want to clear the potentially invalid token we just got?
             // await secureStorage.deleteToken();
             return Left(failure); // Forward the failure (could be ServerFailure, AuthFailure etc.)
          },
          (userInfo) async {
            // Step 3: Combine userId and token, save, and update status
            final authenticatedUser = AuthenticatedUser(userId: userInfo.userId, token: loginResponse.token);
            try {
              await secureStorage.saveUserId(userInfo.userId);
              await secureStorage.saveToken(loginResponse.token);
              _currentUser = authenticatedUser;
              _statusController.add(Authenticated(authenticatedUser));
              print('Login successful and user info fetched. UserID: ${userInfo.userId}');
              return Right(authenticatedUser);
            } on CacheException catch (e) {
              print('Failed to save credentials after login: ${e.message}');
              _currentUser = authenticatedUser;
              _statusController.add(Authenticated(authenticatedUser));
              return Left(CacheFailure(message: 'Login succeeded but failed to save credentials.'));
            }
          },
        );
      },
    );
  }

  @override
  Future<Either<Failure, void>> register(
      RegistrationDetails details) async {
    // Just call the remote data source method. Registration doesn't log in.
    return _networkedOperation<void>(() async {
      await remoteDataSource.register(details);
    });
  }

  // Helper to handle local logout state changes
  Future<void> _handleLogoutLocally() async {
     _currentUser = null;
     _statusController.add(const Unauthenticated());
     try {
       await secureStorage.clearAllAuthData();
       print('Cleared local secure storage during local logout handler.');
     } catch (e) {
        print('Error clearing secure storage during local logout handler: $e');
        // Log this, but don't block logout state change
     }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    // Logout is now primarily a local operation
    await _handleLogoutLocally();
    // Since there's no backend call confirmed, always return success locally
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> sendVerificationCode({
    required String phone,
  }) async {
    return _networkedOperation<void>(() async {
      await remoteDataSource.sendVerificationCode(phone: phone);
    });
  }

  @override
  Either<Failure, AuthenticatedUser?> getLoggedInUserSync() {
    // 直接返回当前内存中的用户状态
    // 注意：这不保证 Token 仍然有效，只是反映了上次成功登录或初始化的状态
    // TODO: 是否应该尝试从 secureStorage 再读一次以防内存丢失？
    // 或者增加一个后台校验 token 的逻辑?
    try {
      return Right(_currentUser);
    } catch (e) {
      // 理论上这里不应出错，除非 currentUser 状态管理有问题
      print('Error getting logged in user sync: $e');
      return Left(UnknownFailure(message: 'Failed to get current user status'));
    }
  }
}
