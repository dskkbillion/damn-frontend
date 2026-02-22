import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';

import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';

void main() {
  group('AppLogger', () {
    test('AppLogger.d 在 debug 模式下不抛出异常', () {
      // 在测试环境中 kReleaseMode 为 false，验证不会抛出
      expect(() => AppLogger.d('test message'), returnsNormally);
    });

    test('AppLogger.d 接受 null 消息', () {
      expect(() => AppLogger.d(null), returnsNormally);
    });

    test('AppLogger.d 接受带 tag 的消息', () {
      expect(() => AppLogger.d('test message', 'MyTag'), returnsNormally);
    });

    test('AppLogger.w 不抛出异常', () {
      expect(() => AppLogger.w('warning message'), returnsNormally);
    });

    test('AppLogger.w 接受带 tag 的消息', () {
      expect(() => AppLogger.w('warning', 'WARN_TAG'), returnsNormally);
    });

    test('AppLogger.e 不抛出异常', () {
      expect(() => AppLogger.e('error message'), returnsNormally);
    });

    test('AppLogger.e 接受 error 和 stackTrace', () {
      final error = Exception('test error');
      final stackTrace = StackTrace.current;
      expect(
        () => AppLogger.e('error occurred', error, stackTrace, 'NET'),
        returnsNormally,
      );
    });

    test('在 release 模式下 AppLogger 静默（kReleaseMode = false 时验证接口存在）', () {
      // kReleaseMode 在测试中始终为 false
      // 这里验证 API 签名完整，不会在任何模式下崩溃
      expect(kReleaseMode, isFalse);
      expect(() {
        AppLogger.d('msg');
        AppLogger.w('msg');
        AppLogger.e('msg', Exception('e'), StackTrace.empty, 'TAG');
      }, returnsNormally);
    });
  });
}
