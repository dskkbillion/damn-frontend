import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/dasn/data/dsn_provider_task_repository.dart';
import 'package:dskk_flutter_refactor/core/dasn/domain/dsn_provider_task_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lists only the canonical Provider task collection', () async {
    final dio = Dio();
    String? path;
    String? trace;
    Map<String, dynamic>? query;
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      path = options.path;
      trace = options.headers['X-Operation-Trace-Id']?.toString();
      query = options.queryParameters;
      handler.resolve(Response(
        requestOptions: options,
        data: _listEnvelope(),
      ));
    }));

    final page = await DioDsnProviderTaskRepository(dio).listAssignedTasks(
      cursor: '2',
      limit: 10,
    );

    expect(path, '/provider/v1/tasks');
    expect(trace, startsWith('trace-provider-task-list-'));
    expect(query, <String, dynamic>{'cursor': '2', 'limit': 10});
    expect(page.tasks.single.taskTraceId, 'ttr_1234567890abcdef');
    expect(page.tasks.single.specHash, _hash('a'));
    expect(page.hasMore, false);
  });

  test('reads a task by server-issued taskTraceId and maps provider facts',
      () async {
    final dio = Dio();
    String? path;
    String? trace;
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      path = options.path;
      trace = options.headers['X-Operation-Trace-Id']?.toString();
      handler.resolve(Response(
        requestOptions: options,
        data: _detailEnvelope(),
      ));
    }));

    final task = await DioDsnProviderTaskRepository(dio)
        .getAssignedTask('ttr_1234567890abcdef');

    expect(path, '/provider/v1/tasks/ttr_1234567890abcdef');
    expect(trace, startsWith('trace-provider-task-read-'));
    expect(task.requestId, 33);
    expect(task.offer?.offerVersion, 1);
    expect(task.offer?.acceptance?.wireValue, 'ACCEPT');
    expect(task.fixedLine?.capabilityId, 'translation');
    expect(task.fixedLine?.amountMinor, 100);
    expect(task.fixedLine?.quoteHash, _hash('b'));
    expect(task.fixedLine?.maxRevisions, 2);
    expect(task.commitment, isNull);
  });

  test('rejects a client-selected non-task trace before network access', () {
    final dio = Dio();
    var called = false;
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      called = true;
      handler.next(options);
    }));

    expect(
      () => DioDsnProviderTaskRepository(dio).getAssignedTask('request-33'),
      throwsA(isA<DsnProviderTaskApiException>()),
    );
    expect(called, false);
  });

  test('fails closed when the detail envelope has a non-object provider fact',
      () async {
    final dio = Dio();
    final envelope = _detailEnvelope();
    (envelope['data'] as Map<String, dynamic>)['offer'] = 'not-an-object';
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      handler.resolve(Response(requestOptions: options, data: envelope));
    }));

    expect(
      () => DioDsnProviderTaskRepository(dio)
          .getAssignedTask('ttr_1234567890abcdef'),
      throwsA(isA<DsnProviderTaskFormatException>()),
    );
  });
}

Map<String, dynamic> _listEnvelope() => <String, dynamic>{
      'protocolVersion': 'dasn/0.1',
      'dsVersion': 'DS 0.1',
      'schemaVersion': '0.1',
      'state': 'PROVIDER_TASKS_LISTED',
      'taskTraceId': 'provider-task-list:1',
      'operationTraceId': 'trace-provider-list',
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
      'operationTraceId': 'trace-provider-detail',
      'resource': <String, dynamic>{
        'id': 'ttr_1234567890abcdef',
        'version': 1,
        'hash': _hash('z'),
      },
      'nextActions': <dynamic>[],
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
          'offerId': 'offer-1',
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
        'fixedLine': <String, dynamic>{
          'capability': 'translation',
          'provider': 'provider-1',
          'buyer': 'buyer-1',
          'variantId': 'standard',
          'quantity': 1,
          'capacity': null,
          'currency': 'CREDITS',
          'amountMinor': 100,
          'quoteHash': _hash('b'),
          'deliverySeconds': 3600,
          'maxRevisions': 2,
          'outputTypes': <String>['FILE'],
          'slaHash': _hash('c'),
          'catalogRevision': _hash('d'),
          'fixedLineHash': _hash('e'),
        },
        'acceptance': <String, dynamic>{
          'acceptanceId': 'accept-1',
          'offerId': 'offer-1',
          'taskTraceId': 'ttr_1234567890abcdef',
          'offerVersion': 1,
          'specHash': _hash('a'),
          'quoteHash': _hash('b'),
          'acceptance': 'ACCEPT',
          'actorType': 'HUMAN',
        },
        'commitment': null,
      },
    };

String _hash(String letter) => 'sha256:${letter * 64}';
