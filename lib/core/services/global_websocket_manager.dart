import 'dart:async';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_status.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/cubit/websocket/websocket_cubit.dart';
import 'package:dskk_flutter_refactor/core/storage/secure_storage_repository.dart';

/// 全局 WebSocket 管理器
///
/// 功能：
/// - 监听用户认证状态
/// - 登录后自动连接 WebSocket
/// - 登出后自动断开 WebSocket
/// - 确保 WebSocket 在整个应用生命周期内保持连接
class GlobalWebSocketManager {
  final IAuthRepository _authRepository;
  final WebSocketCubit _webSocketCubit;
  final ISecureStorageRepository _storage;

  StreamSubscription<AuthStatus>? _authStatusSubscription;
  bool _isInitialized = false;

  GlobalWebSocketManager({
    required IAuthRepository authRepository,
    required WebSocketCubit webSocketCubit,
    required ISecureStorageRepository storage,
  })  : _authRepository = authRepository,
        _webSocketCubit = webSocketCubit,
        _storage = storage;

  /// 初始化管理器，开始监听认证状态
  void initialize() {
    if (_isInitialized) {
      AppLogger.d('[GlobalWebSocketManager] Already initialized, skipping');
      return;
    }

    AppLogger.d('[GlobalWebSocketManager] Initializing...');

    // 监听认证状态变化
    _authStatusSubscription = _authRepository.authStatus.listen((authStatus) {
      _handleAuthStatusChange(authStatus);
    });

    // 检查当前认证状态，如果已登录则立即连接
    _checkCurrentAuthStatus();

    _isInitialized = true;
    AppLogger.d('[GlobalWebSocketManager] Initialization complete');
  }

  /// 检查当前认证状态
  Future<void> _checkCurrentAuthStatus() async {
    try {
      final result = _authRepository.getLoggedInUserSync();
      result.fold(
        (failure) {
          AppLogger.d('[GlobalWebSocketManager] Not authenticated: $failure');
        },
        (user) {
          if (user != null) {
            AppLogger.d(
                '[GlobalWebSocketManager] User already logged in, connecting WebSocket');
            _connectWebSocket();
          } else {
            AppLogger.d('[GlobalWebSocketManager] No user logged in');
          }
        },
      );
    } catch (e) {
      AppLogger.d(
          '[GlobalWebSocketManager] Error checking auth status: ${e.runtimeType}');
    }
  }

  /// 处理认证状态变化
  void _handleAuthStatusChange(AuthStatus authStatus) {
    AppLogger.d('[GlobalWebSocketManager] Auth status changed: $authStatus');

    if (authStatus is Authenticated) {
      AppLogger.d(
          '[GlobalWebSocketManager] User authenticated, connecting WebSocket');
      _connectWebSocket();
    } else if (authStatus is Unauthenticated) {
      AppLogger.d(
          '[GlobalWebSocketManager] User logged out, disconnecting WebSocket');
      _disconnectWebSocket();
    }
  }

  /// 连接 WebSocket
  Future<void> _connectWebSocket() async {
    try {
      // 获取用户凭证
      final commonUserId = await _storage.getCommonUserId();
      final token = await _storage.getToken();

      if (commonUserId == null || token == null) {
        AppLogger.d(
            '[GlobalWebSocketManager] Missing credentials, cannot connect');
        return;
      }

      AppLogger.d(
          '[GlobalWebSocketManager] Connecting with userId: $commonUserId');

      // 连接 WebSocket
      await _webSocketCubit.connect(
        commonUserId: commonUserId.toString(),
        token: token,
      );

      AppLogger.d(
          '[GlobalWebSocketManager] ✅ WebSocket connected successfully');
    } catch (e) {
      AppLogger.d(
          '[GlobalWebSocketManager] ❌ Failed to connect WebSocket: ${e.runtimeType}');
    }
  }

  /// 断开 WebSocket
  void _disconnectWebSocket() {
    try {
      AppLogger.d('[GlobalWebSocketManager] Disconnecting WebSocket...');
      _webSocketCubit.disconnect();
      AppLogger.d('[GlobalWebSocketManager] ✅ WebSocket disconnected');
    } catch (e) {
      AppLogger.d(
          '[GlobalWebSocketManager] ❌ Failed to disconnect WebSocket: ${e.runtimeType}');
    }
  }

  /// 释放资源
  void dispose() {
    AppLogger.d('[GlobalWebSocketManager] Disposing...');
    _authStatusSubscription?.cancel();
    _authStatusSubscription = null;
    _isInitialized = false;
    AppLogger.d('[GlobalWebSocketManager] Disposed');
  }
}
