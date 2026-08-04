import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/features/agent/data/agent_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('submits with a stable canonical idempotency key of valid length', () async {
    final dio = Dio();
    String? seenKey;
    String? seenIfMatch;
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        seenKey = options.headers['Idempotency-Key']?.toString();
        seenIfMatch = options.headers['If-Match']?.toString();
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: <String, dynamic>{},
        ));
      },
    ));

    await DioAgentRepository(dio).submitRequest(
      12,
      version: 0,
      specHash: 'sha256:${'a' * 64}',
    );

    expect(seenKey, 'app-submit:12:0:v1');
    expect(seenKey!.length, greaterThanOrEqualTo(16));
    expect(seenIfMatch, '"0"');
  });
}
