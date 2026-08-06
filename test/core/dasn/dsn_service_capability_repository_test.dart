import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/dasn/data/dsn_service_capability_repository.dart';
import 'package:dskk_flutter_refactor/core/dasn/domain/dsn_service_capability_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads the canonical App capability and keeps the server revision',
      () async {
    final dio = Dio();
    String? path;
    String? trace;
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        path = options.path;
        trace = options.headers['X-Operation-Trace-Id']?.toString();
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: _envelope(),
        ));
      },
    ));

    final capability =
        await DioDsnServiceCapabilityRepository(dio).getServiceCapability(582);

    expect(path, '/app/v1/capabilities/service/582');
    expect(trace, startsWith('trace-app-capability-read-'));
    expect(capability.serviceId, 582);
    expect(capability.capabilityId, 'service:582');
    expect(capability.revision, _hash('a'));
    expect(capability.amountMinor, 100);
    expect(capability.currency, 'CREDITS');
    expect(capability.outputTypes, ['TEXT']);
  });

  test('rejects a capability revision that is not server-owned', () async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final body = _envelope();
        final capability = (body['data'] as Map<String, dynamic>)['capability']
            as Map<String, dynamic>;
        capability['revision'] = 'sha256:${'0' * 63}';
        handler.resolve(Response(requestOptions: options, data: body));
      },
    ));

    await expectLater(
      DioDsnServiceCapabilityRepository(dio).getServiceCapability(582),
      throwsA(isA<DsnServiceCapabilityFormatException>()),
    );
  });

  test('rejects a capability response for another service', () async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final body = _envelope();
        final capability = (body['data'] as Map<String, dynamic>)['capability']
            as Map<String, dynamic>;
        capability['capabilityId'] = 'service:581';
        handler.resolve(Response(requestOptions: options, data: body));
      },
    ));

    await expectLater(
      DioDsnServiceCapabilityRepository(dio).getServiceCapability(582),
      throwsA(isA<DsnServiceCapabilityFormatException>()),
    );
  });

  test('rejects malformed machine envelopes before using capability facts',
      () async {
    for (final mutation in <void Function(Map<String, dynamic>)>[
      (body) => body.remove('protocolVersion'),
      (body) => body['dsVersion'] = 'DS 0.2',
      (body) => body['state'] = 'CAPABILITY_STALE',
      (body) => (body['resource'] as Map<String, dynamic>)['hash'] = _hash('b'),
    ]) {
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          final body = _envelope();
          mutation(body);
          handler.resolve(Response(requestOptions: options, data: body));
        },
      ));

      await expectLater(
        DioDsnServiceCapabilityRepository(dio).getServiceCapability(582),
        throwsA(isA<DsnServiceCapabilityFormatException>()),
      );
    }
  });

  test('does not call the network for an invalid service id', () async {
    final dio = Dio();
    var calls = 0;
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        calls += 1;
        handler.next(options);
      },
    ));

    await expectLater(
      DioDsnServiceCapabilityRepository(dio).getServiceCapability(0),
      throwsA(isA<DsnServiceCapabilityFormatException>()),
    );
    expect(calls, 0);
  });
}

Map<String, dynamic> _envelope() => <String, dynamic>{
      'protocolVersion': 'dasn/0.1',
      'dsVersion': 'DS 0.1',
      'schemaVersion': '0.1',
      'state': 'CAPABILITY_AVAILABLE',
      'taskTraceId': 'capability-discovery-test',
      'operationTraceId': 'trace-test',
      'resource': <String, dynamic>{
        'id': 'service:582',
        'version': 1,
        'hash': _hash('a'),
      },
      'nextActions': <dynamic>[],
      'data': <String, dynamic>{
        'capability': <String, dynamic>{
          'schemaVersion': '0.1',
          'capabilityId': 'service:582',
          'title': 'DS 0.2 Staging Capability',
          'description': 'staging',
          'outputTypes': <String>['TEXT'],
          'pricing': <String, dynamic>{
            'mode': 'FIXED',
            'amountMinor': 100,
            'currency': 'CREDITS',
          },
          'sla': <String, dynamic>{
            'deliveryHours': 24,
            'maxRevisions': 1,
          },
          'revision': _hash('a'),
        },
      },
    };

String _hash(String letter) => 'sha256:${letter * 64}';
