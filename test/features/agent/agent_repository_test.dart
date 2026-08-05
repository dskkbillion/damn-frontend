import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/features/agent/data/agent_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('submits with a stable canonical idempotency key of valid length',
      () async {
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

  test('creates a human request through the canonical App route', () async {
    final dio = Dio();
    final paths = <String>[];
    Map<String, dynamic>? body;
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        paths.add(options.path);
        if (options.path == '/app/v1/requests') {
          body = Map<String, dynamic>.from(options.data as Map);
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 201,
            data: <String, dynamic>{
              'data': <String, dynamic>{'requestId': '34'},
            },
          ));
          return;
        }
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: <String, dynamic>{
            'protocolVersion': 'dasn/0.1',
            'dsVersion': 'DS 0.2',
            'schemaVersion': '0.1',
            'state': 'AWAITING_APP_REVIEW',
            'taskTraceId': 'ttr_human_1234567890',
            'operationTraceId': 'trace-test',
            'resource': <String, dynamic>{
              'id': '34',
              'version': 0,
              'hash': 'sha256:${'a' * 64}',
            },
            'nextActions': <dynamic>[],
            'data': <String, dynamic>{
              'requestId': '34',
              'taskTraceId': 'ttr_human_1234567890',
              'version': 0,
              'specHash': 'sha256:${'a' * 64}',
              'serviceId': '581',
              'title': 'Human request',
              'brief': 'Human brief',
              'status': 'AWAITING_APP_REVIEW',
              'appReviewUrl': '/requests/34/review',
            },
          },
        ));
      },
    ));

    final result = await DioAgentRepository(dio).createHumanRequest(
      serviceId: 581,
      capabilityRevision: 'sha256:${'0' * 64}',
      title: 'Human request',
      brief: 'Human brief',
    );

    expect(paths, <String>['/app/v1/requests', '/app/v1/requests/34']);
    expect(body?['capabilityId'], 'service:581');
    expect(body?['currency'], 'CREDITS');
    expect(result.id, 34);
    expect(result.status, 'AWAITING_APP_REVIEW');
  });

  test('lists human requests from the canonical collection envelope', () async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        expect(options.path, '/app/v1/requests');
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: <String, dynamic>{
            'protocolVersion': 'dasn/0.1',
            'dsVersion': 'DS 0.2',
            'schemaVersion': '0.1',
            'state': 'REQUEST_COLLECTION',
            'taskTraceId': 'ttr_request_collection',
            'operationTraceId': 'trace-test',
            'resource': <String, dynamic>{'id': 'requests'},
            'nextActions': <dynamic>[],
            'data': <String, dynamic>{
              'requests': <dynamic>[
                <String, dynamic>{
                  'id': '34',
                  'version': 0,
                  'hash': 'sha256:${'a' * 64}',
                  'state': 'AWAITING_APP_REVIEW',
                  'taskTraceId': 'ttr_human_1234567890',
                  'requesterActorType': 'HUMAN',
                  'title': 'Human request',
                  'serviceId': '581',
                },
              ],
            },
          },
        ));
      },
    ));

    final result = await DioAgentRepository(dio).listRequests();

    expect(result, hasLength(1));
    expect(result.single.id, 34);
    expect(result.single.serviceId, 581);
    expect(result.single.status, 'AWAITING_APP_REVIEW');
    expect(result.single.taskTraceId, 'ttr_human_1234567890');
    expect(result.single.requesterActorType, 'HUMAN');
  });
}
