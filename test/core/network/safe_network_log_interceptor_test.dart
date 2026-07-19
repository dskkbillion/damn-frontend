import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/network/interceptors/safe_network_log_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('logs lifecycle metadata without request or response secrets', () async {
    final logs = <String>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = _ResponseAdapter(statusCode: 200)
      ..interceptors.add(SafeNetworkLogInterceptor(log: logs.add));

    await dio.post<dynamic>(
      '/api/auth/login',
      queryParameters: {'access_token': 'query-secret'},
      data: {'password': 'body-secret', 'code': '565656'},
      options: Options(
        headers: {
          'Authorization': 'Bearer header-secret',
          'Cookie': 'session=cookie-secret',
        },
      ),
    );

    final output = logs.join('\n');
    expect(output, contains('--> POST /api/auth/login'));
    expect(output, contains('<-- 200 POST /api/auth/login'));
    for (final secret in [
      'query-secret',
      'body-secret',
      '565656',
      'header-secret',
      'cookie-secret',
      'response-secret',
      'response-cookie-secret',
    ]) {
      expect(output, isNot(contains(secret)));
    }
  });

  test('does not include an error response body or query string', () async {
    final logs = <String>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = _ResponseAdapter(statusCode: 401)
      ..interceptors.add(SafeNetworkLogInterceptor(log: logs.add));

    await expectLater(
      dio.get<dynamic>(
        '/api/private',
        queryParameters: {'token': 'query-secret'},
      ),
      throwsA(isA<DioException>()),
    );

    final output = logs.join('\n');
    expect(output, contains('<-- ERROR 401 GET /api/private'));
    expect(output, isNot(contains('query-secret')));
    expect(output, isNot(contains('response-secret')));
  });
}

class _ResponseAdapter implements HttpClientAdapter {
  _ResponseAdapter({required this.statusCode});

  final int statusCode;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{"access_token":"response-secret"}',
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
        'set-cookie': ['session=response-cookie-secret'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
