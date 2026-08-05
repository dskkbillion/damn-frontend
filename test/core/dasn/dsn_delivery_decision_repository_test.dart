import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/dasn/data/dsn_delivery_decision_repository.dart';
import 'package:dskk_flutter_refactor/core/dasn/domain/dsn_delivery_decision_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('posts only canonical decision facts with If-Match and idempotency',
      () async {
    final dio = Dio();
    String? path;
    String? ifMatch;
    String? idempotencyKey;
    Map<String, dynamic>? requestBody;
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        path = options.path;
        ifMatch = options.headers['If-Match']?.toString();
        idempotencyKey = options.headers['Idempotency-Key']?.toString();
        requestBody = Map<String, dynamic>.from(options.data as Map);
        handler.resolve(Response(
          requestOptions: options,
          data: _machine(
            state: 'DELIVERY_ACCEPTED',
            data: <String, dynamic>{
              'decisionId': 'dec-1',
              'orderId': 88,
              'commitmentId': 'commit-1',
              'commitmentVersion': 4,
              'deliveryId': 'del-2',
              'submissionNo': 2,
              'action': 'ACCEPT',
              'actorType': 'PRINCIPAL',
              'createdAt': '2026-08-05T12:00:00Z',
            },
          ),
        ));
      },
    ));

    final result = await DioDsnDeliveryDecisionRepository(dio).submitDecision(
      DsnDeliveryDecisionInput(
        orderId: 88,
        decision: DsnDeliveryDecisionAction.accept,
        deliveryId: 'del-2',
        submissionNo: 2,
        commitmentVersion: 4,
        expectedSubmissionHash: _hash('a'),
      ),
      idempotencyKey: 'buyer-decision:88:del-2:accept:v1',
    );

    expect(path, '/app/v1/orders/88/acceptance-decisions');
    expect(ifMatch, '"4"');
    expect(idempotencyKey, 'buyer-decision:88:del-2:accept:v1');
    expect(requestBody, <String, dynamic>{
      'decision': 'ACCEPT',
      'deliveryId': 'del-2',
      'submissionNo': 2,
      'commitmentVersion': 4,
      'expectedSubmissionHash': _hash('a'),
    });
    expect(requestBody, isNot(contains('orderId')));
    expect(result.action, DsnDeliveryDecisionAction.accept);
    expect(result.state, 'DELIVERY_ACCEPTED');
    expect(result.actorType, 'PRINCIPAL');
  });

  test('rejects invalid machine response state', () async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.resolve(Response(
          requestOptions: options,
          data: _machine(
            state: 'REVISION_REQUESTED',
            data: <String, dynamic>{
              'decisionId': 'dec-1',
              'orderId': 88,
              'commitmentId': 'commit-1',
              'commitmentVersion': 4,
              'deliveryId': 'del-2',
              'submissionNo': 2,
              'action': 'REQUEST_REVISION',
              'actorType': 'PRINCIPAL',
            },
          ),
        ));
      },
    ));

    expect(
      () => DioDsnDeliveryDecisionRepository(dio).submitDecision(
        const DsnDeliveryDecisionInput(
          orderId: 88,
          decision: DsnDeliveryDecisionAction.accept,
          deliveryId: 'del-2',
          submissionNo: 2,
          commitmentVersion: 4,
        ),
        idempotencyKey: 'buyer-decision:88:del-2:accept:v1',
      ),
      throwsA(isA<DsnDeliveryDecisionApiException>()),
    );
  });

  test('rejects a final decision without resource.version', () async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final response = _machine(
          state: 'DELIVERY_ACCEPTED',
          data: <String, dynamic>{
            'decisionId': 'dec-missing-version',
            'orderId': 88,
            'commitmentId': 'commit-1',
            'commitmentVersion': 4,
            'deliveryId': 'del-2',
            'submissionNo': 2,
            'action': 'ACCEPT',
            'actorType': 'PRINCIPAL',
          },
        );
        (response['resource'] as Map<String, dynamic>).remove('version');
        handler.resolve(Response(requestOptions: options, data: response));
      },
    ));

    await expectLater(
      DioDsnDeliveryDecisionRepository(dio).submitDecision(
        const DsnDeliveryDecisionInput(
          orderId: 88,
          decision: DsnDeliveryDecisionAction.accept,
          deliveryId: 'del-2',
          submissionNo: 2,
          commitmentVersion: 4,
        ),
        idempotencyKey: 'buyer-decision:88:del-2:missing:v1',
      ),
      throwsA(
        isA<DsnDeliveryDecisionApiException>().having(
          (error) => error.code,
          'code',
          'RESOURCE_VERSION_MISSING',
        ),
      ),
    );
  });

  test('rejects a final decision whose resource version is stale', () async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.resolve(Response(
          requestOptions: options,
          data: _machine(
            state: 'DELIVERY_ACCEPTED',
            resourceVersion: 3,
            data: <String, dynamic>{
              'decisionId': 'dec-stale-version',
              'orderId': 88,
              'commitmentId': 'commit-1',
              'commitmentVersion': 4,
              'deliveryId': 'del-2',
              'submissionNo': 2,
              'action': 'ACCEPT',
              'actorType': 'PRINCIPAL',
            },
          ),
        ));
      },
    ));

    await expectLater(
      DioDsnDeliveryDecisionRepository(dio).submitDecision(
        const DsnDeliveryDecisionInput(
          orderId: 88,
          decision: DsnDeliveryDecisionAction.accept,
          deliveryId: 'del-2',
          submissionNo: 2,
          commitmentVersion: 4,
        ),
        idempotencyKey: 'buyer-decision:88:del-2:stale:v1',
      ),
      throwsA(
        isA<DsnDeliveryDecisionApiException>().having(
          (error) => error.code,
          'code',
          'COMMITMENT_VERSION_MISMATCH',
        ),
      ),
    );
  });
}

Map<String, dynamic> _machine({
  required String state,
  required Map<String, dynamic> data,
  int resourceVersion = 4,
}) {
  return <String, dynamic>{
    'protocolVersion': 'dasn/0.1',
    'dsVersion': 'DS 0.1',
    'schemaVersion': '0.1',
    'state': state,
    'taskTraceId': 'ttr_1234567890abcdef',
    'operationTraceId': 'trace_decision_test',
    'resource': <String, dynamic>{'id': 'dec-1', 'version': resourceVersion},
    'nextActions': <dynamic>[],
    'data': data,
  };
}

String _hash(String letter) => 'sha256:${letter * 64}';
