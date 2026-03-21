import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';

/// Centralized 401 handling so every network entrypoint drives the same logout flow.
class UnauthorizedLogoutHandler {
  static bool _isHandlingUnauthorized = false;

  static Future<void> handle(DioException err) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;

    if (statusCode != 401 || _shouldIgnore(path)) {
      return;
    }

    if (_isHandlingUnauthorized) {
      AppLogger.d('[UnauthorizedLogoutHandler] 401 handling already in progress, skip duplicate logout.');
      return;
    }

    final getIt = GetIt.instance;
    if (!getIt.isRegistered<IAuthRepository>()) {
      AppLogger.d('[UnauthorizedLogoutHandler] IAuthRepository not registered, cannot logout on 401.');
      return;
    }

    _isHandlingUnauthorized = true;
    AppLogger.d('[UnauthorizedLogoutHandler] Received 401 for $path, logging out locally.');

    try {
      final result = await getIt<IAuthRepository>().logout();
      result.fold(
        (failure) => AppLogger.d('[UnauthorizedLogoutHandler] Logout after 401 failed: $failure'),
        (_) => AppLogger.d('[UnauthorizedLogoutHandler] Logout after 401 completed.'),
      );
    } catch (e) {
      AppLogger.d('[UnauthorizedLogoutHandler] Unexpected error while handling 401 logout: $e');
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
