import 'package:flutter/foundation.dart';

/// 应用日志工具类
///
/// 在 debug/profile 模式下输出日志，release 模式下静默。
/// 用法与 print() 相同，直接替换即可：
///   AppLogger.d('message')       → 普通调试日志
///   AppLogger.w('message')       → 警告
///   AppLogger.e('message', err)  → 错误（可附带异常）
class AppLogger {
  AppLogger._();

  /// Debug 日志 — 仅在非 release 模式下输出
  static void d(Object? message, [String? tag]) {
    if (!kReleaseMode) {
      // ignore: avoid_print
      print('[${tag ?? 'DEBUG'}] $message');
    }
  }

  /// Warning 日志
  static void w(Object? message, [String? tag]) {
    if (!kReleaseMode) {
      // ignore: avoid_print
      print('[${tag ?? 'WARN'}] $message');
    }
  }

  /// Error 日志 — 附带可选异常和堆栈
  static void e(Object? message, [Object? error, StackTrace? stackTrace, String? tag]) {
    if (!kReleaseMode) {
      // ignore: avoid_print
      print('[${tag ?? 'ERROR'}] $message');
      if (error != null) {
        // ignore: avoid_print
        print('[${tag ?? 'ERROR'}] Exception: $error');
      }
      if (stackTrace != null) {
        // ignore: avoid_print
        print('[${tag ?? 'ERROR'}] StackTrace: $stackTrace');
      }
    }
  }
}
