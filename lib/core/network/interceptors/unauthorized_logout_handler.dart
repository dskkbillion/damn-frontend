import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';

/// Centralized 401 handling so every network entrypoint drives the same logout flow.
class UnauthorizedLogoutHandler {
  static bool _isHandlingUnauthorized = false;
  /// 主动登出时设为 true，抑制后续 401 触发的错误提示
  static bool isVoluntaryLogout = false;

  static Future<void> handle(DioException err) async {
    if (!shouldHandleError(err)) {
      return;
    }

    await _logout(err.requestOptions.path);
  }

  static Future<void> handleResponse(Response response) async {
    if (!shouldHandleResponse(response)) {
      return;
    }

    await _logout(response.requestOptions.path);
  }

  static bool shouldHandleError(DioException err) {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;

    return statusCode == 401 && !_shouldIgnore(path);
  }

  static bool shouldHandleResponse(Response response) {
    final path = response.requestOptions.path;
    if (_shouldIgnore(path)) {
      return false;
    }

    return _containsUnauthorizedPayload(response.data);
  }

  static bool _containsUnauthorizedPayload(dynamic data) {
    if (data is! Map) {
      return false;
    }

    final code = data['code'];
    if (code is num) {
      return code == 401;
    }

    if (code is String) {
      return code == '401';
    }

    return false;
  }

  static Future<void> _logout(String path) async {
    if (_isHandlingUnauthorized || isVoluntaryLogout) {
      AppLogger.d(
          '[UnauthorizedLogoutHandler] 401 suppressed (handling=$_isHandlingUnauthorized, voluntary=$isVoluntaryLogout).');
      return;
    }

    final getIt = GetIt.instance;
    if (!getIt.isRegistered<IAuthRepository>()) {
      AppLogger.d(
          '[UnauthorizedLogoutHandler] IAuthRepository not registered, cannot logout on 401.');
      return;
    }

    _isHandlingUnauthorized = true;
    AppLogger.d(
        '[UnauthorizedLogoutHandler] Received 401 for $path, logging out locally.');

    try {
      final result = await getIt<IAuthRepository>().logout();
      result.fold(
        (failure) => AppLogger.d(
            '[UnauthorizedLogoutHandler] Logout after 401 failed: $failure'),
        (_) => AppLogger.d(
            '[UnauthorizedLogoutHandler] Logout after 401 completed.'),
      );
    } catch (e) {
      AppLogger.d(
          '[UnauthorizedLogoutHandler] Unexpected error while handling 401 logout: $e');
    } finally {
      _isHandlingUnauthorized = false;
    }
  }

  static bool _shouldIgnore(String path) {
    return path.contains('/api/auth/login') ||
        path.contains('/api/auth/register') ||
        path.contains('/api/auth/sms') ||
        path.contains('/api/common/send-code/login');
  }
}
