import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/dasn/data/dsn_buyer_agent_commitment_repository.dart';
import 'package:dskk_flutter_refactor/core/dasn/data/dsn_order_repository.dart';
import 'package:dskk_flutter_refactor/core/dasn/domain/dsn_buyer_agent_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('posts the six-fact Buyer Agent commitment with strict headers',
      () async {
    final dio = Dio();
    String? path;
    Map<String, dynamic>? body;
    String? idempotencyKey;
    String? ifMatch;
    String? operationTrace;
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        path = options.path;
        body = Map<String, dynamic>.from(options.data as Map);
        idempotencyKey = options.headers['Idempotency-Key']?.toString();
        ifMatch = options.headers['If-Match']?.toString();
        operationTrace = options.headers['X-Operation-Trace-Id']?.toString();
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 201,
          data: _commitmentEnvelope(),
        ));
      },
    ));

    final input = _input();
    final result =
        await DioDsnBuyerAgentCommitmentRepository(dio).createCommitment(
      42,
      input: input,
      ifMatchVersion: 3,
      idempotencyKey: 'agent-commit:42:preview-1:v1',
    );

    expect(path, '/agent/v1/requests/42/commitment');
    expect(idempotencyKey, 'agent-commit:42:preview-1:v1');
    expect(ifMatch, '"3"');
    expect(operationTrace, startsWith('trace-agent-commitment-'));
    expect(body, input.toJson());
    expect(body, isNot(contains('accessToken')));
    expect(body, isNot(contains('grant')));
    expect(body, isNot(contains('sessionToken')));
    expect(body, isNot(contains('principalRef')));
    expect(result.orderId, 'order-1');
    expect(result.commitmentId, 'commit-1');
    expect(result.confirmationRef, input.confirmationRef);
    expect(result.commitmentVersion, 4);
    expect(result.orderState, 'awaitingPayment');
  });

  test('rejects a resource/data commitment version mismatch', () async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final response = _commitmentEnvelope();
        (response['resource'] as Map<String, dynamic>)['version'] = 4;
        (response['data'] as Map<String, dynamic>)['commitmentVersion'] = 5;
        handler.resolve(Response(requestOptions: options, data: response));
      },
    ));

    await expectLater(
      DioDsnBuyerAgentCommitmentRepository(dio).createCommitment(
        42,
        input: _input(),
        ifMatchVersion: 3,
        idempotencyKey: 'agent-commit:42:preview-1:v1',
      ),
      throwsA(
        isA<DsnOrderApiException>().having(
          (error) => error.code,
          'code',
          'COMMITMENT_VERSION_MISMATCH',
        ),
      ),
    );
  });

  test('rejects a response missing the canonical resource version', () async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final response = _commitmentEnvelope();
        (response['resource'] as Map<String, dynamic>).remove('version');
        handler.resolve(Response(requestOptions: options, data: response));
      },
    ));

    await expectLater(
      DioDsnBuyerAgentCommitmentRepository(dio).createCommitment(
        42,
        input: _input(),
        ifMatchVersion: 3,
        idempotencyKey: 'agent-commit:42:preview-1:v1',
      ),
      throwsA(isA<DsnOrderApiException>()),
    );
  });

  test('maps canonical Agent authorization errors without retrying', () async {
    final dio = Dio();
    var calls = 0;
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        calls += 1;
        handler.reject(DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: options,
            statusCode: 403,
            data: <String, dynamic>{
              'error': <String, dynamic>{
                'code': 'GRANT_SCOPE_INVALID',
                'message': 'Buyer Grant does not cover this request',
              },
            },
          ),
        ));
      },
    ));

    await expectLater(
      DioDsnBuyerAgentCommitmentRepository(dio).createCommitment(
        42,
        input: _input(),
        ifMatchVersion: 3,
        idempotencyKey: 'agent-commit:42:preview-1:v1',
      ),
      throwsA(
        isA<DsnOrderApiException>()
            .having((error) => error.code, 'code', 'GRANT_SCOPE_INVALID')
            .having((error) => error.statusCode, 'status', 403),
      ),
    );
    expect(calls, 1);
  });

  test('rejects invalid If-Match and idempotency headers before network',
      () async {
    final dio = Dio();
    var calls = 0;
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        calls += 1;
        handler.next(options);
      },
    ));
    final repository = DioDsnBuyerAgentCommitmentRepository(dio);

    await expectLater(
      repository.createCommitment(
        42,
        input: _input(),
        ifMatchVersion: -1,
        idempotencyKey: 'agent-commit:42:preview-1:v1',
      ),
      throwsA(isA<DsnOrderApiException>()),
    );
    await expectLater(
      repository.createCommitment(
        42,
        input: _input(),
        ifMatchVersion: 3,
        idempotencyKey: 'short',
      ),
      throwsA(isA<DsnOrderApiException>()),
    );
    expect(calls, 0);
  });
}

DsnBuyerAgentCommitmentInput _input() => DsnBuyerAgentCommitmentInput(
      previewId: 'preview-1',
      providerAcceptanceId: 'acceptance-1',
      offerVersion: 7,
      specHash: _hash('a'),
      quoteHash: _hash('b'),
      confirmationRef: 'cr_test-1',
    );

Map<String, dynamic> _commitmentEnvelope() => <String, dynamic>{
      'protocolVersion': 'dasn/0.1',
      'dsVersion': 'DS 0.1',
      'schemaVersion': '0.1',
      'state': 'ORDER_COMMITMENT_CREATED',
      'taskTraceId': 'ttr_1234567890abcdef',
      'operationTraceId': 'trace-agent-test',
      'resource': <String, dynamic>{
        'id': 'order-1',
        'version': 4,
        'hash': _hash('c'),
      },
      'nextActions': <dynamic>[
        <String, dynamic>{'action': 'CREATE_PAYMENT_ATTEMPT'},
      ],
      'data': <String, dynamic>{
        'requestId': '42',
        'orderId': 'order-1',
        'orderState': 'awaitingPayment',
        'commitmentId': 'commit-1',
        'commitmentHash': _hash('c'),
        'previewId': 'preview-1',
        'offerId': 'offer-1',
        'confirmationRef': 'cr_test-1',
        'amountMinor': 120,
        'currency': 'CREDITS',
        'commitmentVersion': 4,
        'replayed': false,
      },
    };

String _hash(String letter) => 'sha256:${letter * 64}';
