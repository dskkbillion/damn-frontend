import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

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

    test('redacts auth schemes and credential fields before printing', () {
      final lines = <String>[];

      runZoned(
        () => AppLogger.d(
          'Authorization: Bearer header-secret '
          'Proxy-Authorization: Basic basic-secret '
          '{"access_token":"response-secret",'
          '"verification_code":"565656",'
          '"mobile":"18888888888","email":"qa@example.test"} '
          'Headers(Cookie: session-cookie) X-API-Key=api-secret',
        ),
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) => lines.add(line),
        ),
      );

      final output = lines.join('\n');
      expect(output, contains('[REDACTED]'));
      expect(output, isNot(contains('header-secret')));
      expect(output, isNot(contains('response-secret')));
      expect(output, isNot(contains('basic-secret')));
      expect(output, isNot(contains('565656')));
      expect(output, isNot(contains('18888888888')));
      expect(output, isNot(contains('qa@example.test')));
      expect(output, isNot(contains('session-cookie')));
      expect(output, isNot(contains('api-secret')));
    });

    test('preserves non-sensitive numeric business codes', () {
      expect(
        AppLogger.sanitizeForLogging('statusCode=200, code: 200'),
        'statusCode=200, code: 200',
      );
    });
  });
}
