import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('staging backend traffic uses the official gateway', () {
    final values = <String, String>{};

    for (final line in File('.env.staging').readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) {
        continue;
      }

      final separator = trimmed.indexOf('=');
      if (separator <= 0) {
        continue;
      }

      values[trimmed.substring(0, separator)] =
          trimmed.substring(separator + 1);
    }

    const officialGateway = 'https://deep-stream.ai/prod-api';
    expect(values['BACKEND_BASE_URL'], officialGateway);
    expect(values['INTERNATIONAL_API_URL'], officialGateway);
    expect(
      values.values,
      isNot(contains('https://dskk-api-staging.zeabur.app')),
    );
  });
}
