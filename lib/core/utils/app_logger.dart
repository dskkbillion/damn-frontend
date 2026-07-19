import 'package:flutter/foundation.dart';

/// 应用日志工具类
///
/// 仅在 debug 模式下输出日志，profile/release 模式静默。
/// 用法与 print() 相同，直接替换即可：
///   AppLogger.d('message')       → 普通调试日志
///   AppLogger.w('message')       → 警告
///   AppLogger.e('message', err)  → 错误（可附带异常）
class AppLogger {
  AppLogger._();

  static final RegExp _authSchemePattern = RegExp(
    r'\b(Bearer|Basic)\s+[^\s,\]\}]+',
    caseSensitive: false,
  );
  static final RegExp _digestPattern = RegExp(
    r'\bDigest\s+[^\r\n\}\]]+',
    caseSensitive: false,
  );
  static final RegExp _sensitiveFieldPattern = RegExp(
    r'''((?:^|[\(\[,{&?\s])["']?(?:authorization|proxy-authorization|x-auth-token|x-api-key|api-key|access[_-]?token|refresh[_-]?token|auth[_-]?token|id[_-]?token|verify[_-]?token|token|password|passcode|secret|client[_-]?secret|verification[_-]?code|sms[_-]?code|user[_-]?code|device[_-]?code|otp|phone|mobile|email|contact|cookie|set-cookie|csrf|xsrf|session)["']?\s*[:=]\s*)(?:"[^"]*"|'[^']*'|(?:Bearer|Basic)\s+[^\s,\]\}]+|Digest\s+[^\r\n\}\]]+|[^,\s\}\]&]+)''',
    caseSensitive: false,
    multiLine: true,
  );

  /// Redacts common credentials before any value reaches the console.
  static String sanitizeForLogging(Object? value) {
    var sanitized = value?.toString() ?? 'null';
    sanitized = sanitized.replaceAllMapped(
      _authSchemePattern,
      (match) => '${match.group(1)} [REDACTED]',
    );
    sanitized = sanitized.replaceAll(_digestPattern, 'Digest [REDACTED]');
    return sanitized.replaceAllMapped(
      _sensitiveFieldPattern,
      (match) => '${match.group(1)}[REDACTED]',
    );
  }

  /// Debug 日志 — 仅在非 release 模式下输出
  static void d(Object? message, [String? tag]) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[${tag ?? 'DEBUG'}] ${sanitizeForLogging(message)}');
    }
  }

  /// Warning 日志
  static void w(Object? message, [String? tag]) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[${tag ?? 'WARN'}] ${sanitizeForLogging(message)}');
    }
  }

  /// Error 日志 — 附带可选异常和堆栈
  static void e(
    Object? message, [
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  ]) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[${tag ?? 'ERROR'}] ${sanitizeForLogging(message)}');
      if (error != null) {
        // ignore: avoid_print
        print('[${tag ?? 'ERROR'}] Exception: ${sanitizeForLogging(error)}');
      }
      if (stackTrace != null) {
        // ignore: avoid_print
        print('[${tag ?? 'ERROR'}] StackTrace: $stackTrace');
      }
    }
  }
}
