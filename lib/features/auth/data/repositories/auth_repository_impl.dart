import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'dart:async';
import 'package:injectable/injectable.dart'; // Import injectable

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/platform/token_validator.dart';
import '../../../../core/storage/secure_storage_repository.dart';
import 'package:dskk_flutter_refactor/core/usecases/validate_token_usecase.dart';

import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_credentials.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_status.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/authenticated_user.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/user_info.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_user_info_repository.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

// Placeholder definitions removed as they should be imported
// class UserInfo { ... }
// abstract class IUserInfoRepository { ... }

@LazySingleton(as: IAuthRepository) // Register as LazySingleton for the interface
@injectable // Mark class for injectable generator
class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final ISecureStorageRepository secureStorage; // 注入安全存储
  final NetworkInfo networkInfo; // 注入网络状态检查
  final IUserInfoRepository userInfoRepository; // 注入 UserInfo Repository
  final TokenValidator tokenValidator;

  final StreamController<AuthStatus> _statusController = StreamController<AuthStatus>.broadcast();
  AuthenticatedUser? _currentUser;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
    required this.networkInfo,
    required this.userInfoRepository, // 添加依赖
    required this.tokenValidator, // 添加依赖
  }) {
    // 初始化时检查本地存储的认证状态
    _initializeAuthStatus();
  }

  // 初始化认证状态
  Future<void> _initializeAuthStatus() async {
    _statusController.add(const AuthUnknown()); // 初始为未知
    try {
      // 同时获取 id (int) 和 token (String)
      final id = await secureStorage.getInt('user_id'); // 使用约定的 key
      final token = await secureStorage.getString('auth_token'); // 使用约定的 key

      if (id != null && token != null) {
        // 验证Token有效性
        AppLogger.d('Found existing token and id in secure storage. Validating token...');
        final validationResult = await tokenValidator.validateToken(token);

        switch (validationResult) {
          case TokenValidationResult.valid:
            AppLogger.d('Token is valid. User is authenticated.');
            _currentUser = AuthenticatedUser(id: id, token: token);
            _statusController.add(Authenticated(_currentUser!));
            break;

          case TokenValidationResult.expired:
            AppLogger.d('Token has expired. Clearing local auth data.');
            await _clearLocalAuthData();
            _statusController.add(const Unauthenticated());
            break;

          case TokenValidationResult.invalid:
            AppLogger.d('Token is invalid. Clearing local auth data.');
            await _clearLocalAuthData();
            _statusController.add(const Unauthenticated());
            break;

          case TokenValidationResult.error:
            // 出错时暂时假定Token可能有效
            AppLogger.d('Error validating token. Assuming token is valid for now.');
            _currentUser = AuthenticatedUser(id: id, token: token);
            _statusController.add(Authenticated(_currentUser!));
            break;
        }
      } else {
        AppLogger.d('No existing token/id found, or only partial data found.');
        await _clearLocalAuthData(); // 清理本地数据
        _statusController.add(const Unauthenticated());
      }
    } catch (e) {
      AppLogger.d('Error initializing auth status: $e. Clearing storage.');
      await _clearLocalAuthData();
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
        AppLogger.d('ServerException in repository: ${e.message}');
        // Check for unauthenticated errors specifically if needed
        if (e is UnauthenticatedException) {
            await _handleLogoutLocally(); // Ensure local state is cleared on auth errors
            return Left(AuthenticationFailure(message: e.message ?? 'Session expired or invalid'));
        }
        return Left(ServerFailure(message: e.message ?? 'Unknown server error'));
      } on CacheException catch (e) { // 假设 SecureStorage 可能抛出
        AppLogger.d('CacheException in repository: ${e.message}');
        return Left(CacheFailure(message: e.message ?? 'Storage error'));
      } catch (e) {
        AppLogger.d('Unknown exception in repository: ${e.toString()}');
        return Left(UnknownFailure(message: 'An unknown error occurred'));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, AuthenticatedUser>> loginWithVerificationCode(
      VerificationCodeCredentials credentials) async {
    // Step 1: Call login API to get the token model
    final loginResult = await _networkedOperation(() =>
        remoteDataSource.loginWithVerificationCode(credentials));

    return loginResult.fold(
      (failure) => Left(failure),
      (authenticatedUserModel) async {
        // Step 2: Use the token to fetch UserInfo (contains id)
        final userFetchResult =
            await userInfoRepository.fetchUserInfo(authenticatedUserModel.token);

        return userFetchResult.fold(
          (failure) {
             AppLogger.d('Failed to fetch user info after successful token acquisition: $failure');
             // 不清除 token，让 core 的 token 校验逻辑来处理
             return Left(failure);
          },
          (userInfo) async {
            // Step 3: Combine id and token, save, and update status
            final authenticatedUser = AuthenticatedUser(id: userInfo.id, token: authenticatedUserModel.token);
            try {
              // 假设 secureStorage 有 saveInt 和 saveString
              await secureStorage.saveInt('user_id', userInfo.id); // 使用约定 key
              await secureStorage.saveString('auth_token', authenticatedUserModel.token); // 使用约定 key

              // 同时保存commonUserId
              if (userInfo.commonUserId != null) {
                await secureStorage.saveCommonUserId(userInfo.commonUserId!);
                // 同时保存为 refer_id，供聊天模块使用
                await secureStorage.saveString('refer_id', userInfo.commonUserId.toString());
                AppLogger.d('Saved commonUserId: ${userInfo.commonUserId}');
                AppLogger.d('Saved refer_id: ${userInfo.commonUserId} for chat module');
              } else {
                AppLogger.d('commonUserId from UserInfo is null. Key will not be saved/updated in secure storage.');
              }

              _currentUser = authenticatedUser;
              _statusController.add(Authenticated(authenticatedUser));
              AppLogger.d('Login successful. UserID: ${userInfo.id}, Token: ${authenticatedUserModel.token}');
              return Right(authenticatedUser);
            } on CacheException catch (e) {
              AppLogger.d('Failed to save credentials after login: ${e.message}');
              // 即使存储失败，也更新内存状态，但返回错误
              _currentUser = authenticatedUser;
              _statusController.add(Authenticated(authenticatedUser));
              return Left(CacheFailure(message: 'Login succeeded but failed to save credentials.'));
            }
          },
        );
      },
    );
  }

  // 清理本地认证数据
  Future<void> _clearLocalAuthData() async {
    try {
       // 假设 secureStorage 有 delete 方法
       await secureStorage.delete('user_id');
       await secureStorage.delete('auth_token');
       await secureStorage.delete('common_user_id'); // 同时清理commonUserId
       await secureStorage.delete('refer_id'); // 清理refer_id（用于聊天模块）
       AppLogger.d('Cleared local auth data (id, token, commonUserId, refer_id).');
    } catch (e) {
        AppLogger.d('Error clearing local auth data: $e');
    }
  }

  // 处理本地登出状态变更
  Future<void> _handleLogoutLocally() async {
     _currentUser = null;
     _statusController.add(const Unauthenticated());
     await _clearLocalAuthData();
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
      AppLogger.d('Error getting logged in user sync: $e');
      return Left(UnknownFailure(message: 'Failed to get current user status'));
    }
  }
}
