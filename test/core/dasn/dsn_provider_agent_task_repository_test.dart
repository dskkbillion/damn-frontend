import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/dasn/data/dsn_provider_task_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses the Agent-authenticated Provider Task projection', () async {
    final dio = Dio()
      ..options.headers['Authorization'] = 'Bearer agent-session-test';
    String? path;
    String? authorization;
    Map<String, dynamic>? query;
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      path = options.path;
      authorization = options.headers['Authorization']?.toString();
      query = options.queryParameters;
      handler.resolve(Response(
        requestOptions: options,
        data: _listEnvelope(),
      ));
    }));

    final page = await DioDsnProviderAgentTaskRepository(dio)
        .listAssignedTasks(cursor: '2', limit: 10);

    expect(path, '/provider/v1/tasks');
    expect(authorization, 'Bearer agent-session-test');
    expect(query, <String, dynamic>{'cursor': '2', 'limit': 10});
    expect(page.tasks.single.taskTraceId, 'ttr_1234567890abcdef');
    expect(page.tasks.single.requestId, 33);
  });

  test('does not expose a buyer endpoint fallback for Agent detail reads',
      () async {
    final dio = Dio();
    String? path;
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      path = options.path;
      handler.resolve(Response(
        requestOptions: options,
        data: _detailEnvelope(),
      ));
    }));

    final task = await DioDsnProviderAgentTaskRepository(dio)
        .getAssignedTask('ttr_1234567890abcdef');

    expect(path, '/provider/v1/tasks/ttr_1234567890abcdef');
    expect(path, isNot(contains('/api/agent-requests')));
    expect(task.offer?.offerVersion, 1);
    expect(task.commitment, isNull);
  });
}

Map<String, dynamic> _listEnvelope() => <String, dynamic>{
      'protocolVersion': 'dasn/0.1',
      'dsVersion': 'DS 0.1',
      'schemaVersion': '0.1',
      'state': 'PROVIDER_TASKS_LISTED',
      'taskTraceId': 'provider-task-list:1',
      'operationTraceId': 'trace-provider-agent-list',
      'resource': <String, dynamic>{'id': 'provider-tasks', 'version': 1},
      'nextActions': <dynamic>[],
      'data': <String, dynamic>{
        'tasks': <dynamic>[
          <String, dynamic>{
            'taskTraceId': 'ttr_1234567890abcdef',
            'requestId': 33,
            'version': 0,
            'state': 'ALIGNING',
            'responsibilityAction': 'PENDING',
            'waitingOn': 'PRINCIPAL',
            'title': 'Translation',
            'brief': 'A fixed brief',
            'specHash': _hash('a'),
            'status': 'SUBMITTED',
            'nextActions': <dynamic>[],
          },
        ],
        'nextCursor': null,
        'hasMore': false,
      },
    };

Map<String, dynamic> _detailEnvelope() => <String, dynamic>{
      'protocolVersion': 'dasn/0.1',
      'dsVersion': 'DS 0.1',
      'schemaVersion': '0.1',
      'state': 'ALIGNING',
      'taskTraceId': 'ttr_1234567890abcdef',
      'operationTraceId': 'trace-provider-agent-detail',
      'resource': <String, dynamic>{
        'id': 'ttr_1234567890abcdef',
        'version': 1,
        'hash': _hash('z'),
      },
      'task': <String, dynamic>{
        'taskLifecycle': 'ALIGNING',
        'responsibilityAction': 'PENDING',
        'waitingOn': 'PRINCIPAL',
        'nextActions': <dynamic>[],
      },
      'data': <String, dynamic>{
        'request': <String, dynamic>{
          'id': 33,
          'taskTraceId': 'ttr_1234567890abcdef',
          'version': 1,
          'status': 'PROVIDER_RESPONDED',
          'title': 'Translation',
          'brief': 'A fixed brief',
          'specHash': _hash('a'),
        },
        'offer': <String, dynamic>{
          'offerId': 'offer-agent-1',
          'taskTraceId': 'ttr_1234567890abcdef',
          'requestId': 33,
          'offerVersion': 1,
          'specHash': _hash('a'),
          'quoteHash': _hash('b'),
          'capabilityId': 'translation',
          'variantId': 'standard',
          'quantity': 1,
          'amountMinor': 100,
          'currency': 'CREDITS',
          'status': 'ACTIVE',
        },
        'acceptance': <String, dynamic>{
          'acceptanceId': 'accept-agent-1',
          'offerId': 'offer-agent-1',
          'taskTraceId': 'ttr_1234567890abcdef',
          'offerVersion': 1,
          'specHash': _hash('a'),
          'quoteHash': _hash('b'),
          'acceptance': 'ACCEPT',
          'actorType': 'AGENT',
        },
        'commitment': null,
      },
    };

String _hash(String letter) => 'sha256:${letter * 64}';
