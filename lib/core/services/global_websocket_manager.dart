import 'dart:async';
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
      print('[GlobalWebSocketManager] Already initialized, skipping');
      return;
    }

    print('[GlobalWebSocketManager] Initializing...');

    // 监听认证状态变化
    _authStatusSubscription = _authRepository.authStatus.listen((authStatus) {
      _handleAuthStatusChange(authStatus);
    });

    // 检查当前认证状态，如果已登录则立即连接
    _checkCurrentAuthStatus();

    _isInitialized = true;
    print('[GlobalWebSocketManager] Initialization complete');
  }

  /// 检查当前认证状态
  Future<void> _checkCurrentAuthStatus() async {
    try {
      final result = _authRepository.getLoggedInUserSync();
      result.fold(
        (failure) {
          print('[GlobalWebSocketManager] Not authenticated: $failure');
        },
        (user) {
          if (user != null) {
            print('[GlobalWebSocketManager] User already logged in, connecting WebSocket');
            _connectWebSocket();
          } else {
            print('[GlobalWebSocketManager] No user logged in');
          }
        },
      );
    } catch (e) {
      print('[GlobalWebSocketManager] Error checking auth status: $e');
    }
  }

  /// 处理认证状态变化
  void _handleAuthStatusChange(AuthStatus authStatus) {
    print('[GlobalWebSocketManager] Auth status changed: $authStatus');

    if (authStatus is Authenticated) {
      print('[GlobalWebSocketManager] User authenticated, connecting WebSocket');
      _connectWebSocket();
    } else if (authStatus is Unauthenticated) {
      print('[GlobalWebSocketManager] User logged out, disconnecting WebSocket');
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
        print('[GlobalWebSocketManager] Missing credentials, cannot connect');
        return;
      }

      print('[GlobalWebSocketManager] Connecting with userId: $commonUserId');

      // 连接 WebSocket
      await _webSocketCubit.connect(
        commonUserId: commonUserId.toString(),
        token: token,
      );

      print('[GlobalWebSocketManager] ✅ WebSocket connected successfully');
    } catch (e) {
      print('[GlobalWebSocketManager] ❌ Failed to connect WebSocket: $e');
    }
  }

  /// 断开 WebSocket
  void _disconnectWebSocket() {
    try {
      print('[GlobalWebSocketManager] Disconnecting WebSocket...');
      _webSocketCubit.disconnect();
      print('[GlobalWebSocketManager] ✅ WebSocket disconnected');
    } catch (e) {
      print('[GlobalWebSocketManager] ❌ Failed to disconnect WebSocket: $e');
    }
  }

  /// 释放资源
  void dispose() {
    print('[GlobalWebSocketManager] Disposing...');
    _authStatusSubscription?.cancel();
    _authStatusSubscription = null;
    _isInitialized = false;
    print('[GlobalWebSocketManager] Disposed');
  }
}
