import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/network/header_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'app_language': 'zh'});
  });

  test('public auth endpoints bypass platform storage before dispatch',
      () async {
    var preferenceReads = 0;
    var secureStorageReads = 0;
    final adapter = _ResponseAdapter();
    final prefs = await SharedPreferences.getInstance();
    final dio = _dioWithInterceptor(
      adapter,
      HeaderInterceptor(
        preferencesLoader: () async {
          preferenceReads++;
          return prefs;
        },
        secureStorageReader: (_) async {
          secureStorageReads++;
          return 'stale-token';
        },
      ),
    );

    for (final path in [
      '/api/auth/login',
      '/api/auth/sms',
      '/api/common/send-code/login',
    ]) {
      final response = await dio.post<dynamic>(path);
      expect(response.statusCode, 200);
    }

    expect(adapter.calls, 3);
    expect(preferenceReads, 0);
    expect(secureStorageReads, 0);
    expect(adapter.lastRequest?.headers['Accept-Language'], isNotEmpty);
  });

  test('explicit authorization bypasses storage and is preserved', () async {
    var preferenceReads = 0;
    var secureStorageReads = 0;
    final adapter = _ResponseAdapter();
    final prefs = await SharedPreferences.getInstance();
    final dio = _dioWithInterceptor(
      adapter,
      HeaderInterceptor(
        preferencesLoader: () async {
          preferenceReads++;
          return prefs;
        },
        secureStorageReader: (_) async {
          secureStorageReads++;
          return 'different-token';
        },
      ),
    );

    await dio.get<dynamic>(
      '/api/member/info',
      options: Options(
        headers: {'Authorization': 'Bearer explicit-token'},
      ),
    );

    expect(
        adapter.lastRequest?.headers['Authorization'], 'Bearer explicit-token');
    expect(preferenceReads, 0);
    expect(secureStorageReads, 0);
  });
}

Dio _dioWithInterceptor(
  _ResponseAdapter adapter,
  HeaderInterceptor interceptor,
) {
  return Dio(BaseOptions(baseUrl: 'https://example.test'))
    ..httpClientAdapter = adapter
    ..interceptors.add(interceptor);
}

class _ResponseAdapter implements HttpClientAdapter {
  int calls = 0;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    lastRequest = options;
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
