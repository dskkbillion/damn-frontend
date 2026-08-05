import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/dasn/data/dsn_order_repository.dart';
import 'package:dskk_flutter_refactor/core/dasn/domain/dsn_order_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses canonical App offer IDs encoded as JSON strings', () async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.resolve(Response(
          requestOptions: options,
          data: _machine(
            state: 'PROVIDER_OFFER_ACCEPTED',
            data: <String, dynamic>{
              // Java's current App adapter emits these business IDs as
              // String values while the machine contract keeps them numeric
              // in the client domain model.
              'requestId': '33',
              'offerId': 'offer-1',
              'acceptanceId': 'accept-1',
              'providerId': '77',
              'capabilityId': 'service:42',
              'variantId': 'standard',
              'offerVersion': '2',
              'specHash': _hash('a'),
              'quoteHash': _hash('b'),
              'quantity': '1',
              'amountMinor': '120',
              'currency': 'CREDITS',
            },
          ),
        ));
      },
    ));

    final offer = await DioDsnOrderRepository(dio).getProviderOffer(33);

    expect(offer.requestId, 33);
    expect(offer.offerVersion, 2);
    expect(offer.quantity, 1);
    expect(offer.amountMinor, 120);
  });

  test('rejects decimal string facts instead of truncating them', () async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.resolve(Response(
          requestOptions: options,
          data: _machine(
            state: 'PROVIDER_OFFER_ACCEPTED',
            data: <String, dynamic>{
              'requestId': '33.5',
              'offerId': 'offer-1',
              'acceptanceId': 'accept-1',
              'providerId': '77',
              'capabilityId': 'service:42',
              'variantId': 'standard',
              'offerVersion': '2',
              'specHash': _hash('a'),
              'quoteHash': _hash('b'),
              'quantity': '1',
              'amountMinor': '120',
              'currency': 'CREDITS',
            },
          ),
        ));
      },
    ));

    expect(
      () => DioDsnOrderRepository(dio).getProviderOffer(33),
      throwsA(isA<DsnOrderApiException>()),
    );
  });

  test('sends confirmation idempotency key on the canonical App route',
      () async {
    final dio = Dio();
    String? seenKey;
    String? seenTrace;
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        seenKey = options.headers['Idempotency-Key']?.toString();
        seenTrace = options.headers['X-Operation-Trace-Id']?.toString();
        handler.resolve(Response(
          requestOptions: options,
          data: _machine(
            state: 'CONFIRMATION_REF_ISSUED',
            data: <String, dynamic>{
              'confirmationRef': 'cr_test-1',
              'requestId': '33',
              'previewId': 'preview-1',
              'specHash': _hash('a'),
              'quoteHash': _hash('b'),
              'amountMinor': '120',
              'currency': 'CREDITS',
              'paymentMethodType': 'CREDITS',
              'allowedActions': <String>[
                'CREATE_ORDER',
                'CREATE_PAYMENT_ATTEMPT',
              ],
            },
          ),
        ));
      },
    ));

    final ref = await DioDsnOrderRepository(dio).issueConfirmationRef(
      33,
      previewId: 'preview-1',
      allowedActions: const ['CREATE_ORDER', 'CREATE_PAYMENT_ATTEMPT'],
      idempotencyKey: 'app-confirmation:33:preview-1',
    );

    expect(seenKey, 'app-confirmation:33:preview-1');
    expect(seenTrace, matches(RegExp(r'^trace-app-confirmation-[0-9a-f-]{36}$')));
    expect(ref.confirmationRef, 'cr_test-1');
  });

  test('reconciles uncertain payment only through the explicit POST route',
      () async {
    final dio = Dio();
    String? seenMethod;
    String? seenPath;
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        seenMethod = options.method;
        seenPath = options.path;
        final body = _machine(
          state: 'PAYMENT_CAPTURED',
          data: <String, dynamic>{
            'orderId': '41',
            'confirmationRef': 'cr_test-1',
            'amountMinor': '120',
            'currency': 'CREDITS',
            'commitmentVersion': '2',
          },
        );
        body['paymentAttempt'] = <String, dynamic>{
          'paymentAttemptId': '51',
          'fundsDisposition': 'CAPTURED',
          'effectiveCommitment': true,
        };
        handler.resolve(Response(requestOptions: options, data: body));
      },
    ));

    final payment =
        await DioDsnOrderRepository(dio).reconcilePaymentAttempt('51');

    expect(seenMethod, 'POST');
    expect(seenPath, '/app/v1/payment-attempts/51/reconcile');
    expect(payment.captured, isTrue);
    expect(payment.commitmentVersion, 2);
  });

  test('uses the frozen Commitment resource version for payment precondition',
      () async {
    final dio = Dio();
    String? seenIfMatch;
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        seenIfMatch = options.headers['If-Match']?.toString();
        final body = _machine(
          state: 'PAYMENT_CAPTURED',
          data: <String, dynamic>{
            'orderId': '41',
            'confirmationRef': 'cr_test-1',
            'amountMinor': '120',
            'currency': 'CREDITS',
            'commitmentVersion': '7',
          },
        );
        body['paymentAttempt'] = <String, dynamic>{
          'paymentAttemptId': '51',
          'fundsDisposition': 'CAPTURED',
          'effectiveCommitment': true,
        };
        (body['resource'] as Map<String, dynamic>)['version'] = '7';
        handler.resolve(Response(requestOptions: options, data: body));
      },
    ));
    const order = DsnOrder(
      orderId: '41',
      taskTraceId: 'ttr_1234567890abcdef',
      commitmentId: 'commit-1',
      confirmationRef: 'cr_test-1',
      amountMinor: 120,
      currency: 'CREDITS',
      orderState: 'awaitingPayment',
      commitmentVersion: 7,
    );
    final preview = DsnOrderPreview(
      requestId: 33,
      taskTraceId: 'ttr_1234567890abcdef',
      previewId: 'preview-1',
      providerId: 'provider-1',
      providerOfferId: 'offer-1',
      providerAcceptanceId: 'accept-1',
      offerVersion: 2,
      specHash: _hash('a'),
      quoteHash: _hash('b'),
      amountMinor: 120,
      currency: 'CREDITS',
      quantity: 1,
      expiresAt: DateTime(2026, 8, 6),
    );
    final confirmation = DsnConfirmationRef(
      confirmationRef: 'cr_test-1',
      requestId: 33,
      taskTraceId: 'ttr_1234567890abcdef',
      previewId: 'preview-1',
      specHash: _hash('a'),
      quoteHash: _hash('b'),
      amountMinor: 120,
      currency: 'CREDITS',
      paymentMethodType: 'CREDITS',
      allowedActions: const ['CREATE_ORDER', 'CREATE_PAYMENT_ATTEMPT'],
    );

    await DioDsnOrderRepository(dio).createPaymentAttempt(
      order,
      preview: preview,
      confirmation: confirmation,
      ifMatchVersion: 7,
      idempotencyKey: 'app-payment:41:cr_test-1',
    );

    expect(seenIfMatch, '"7"');
  });

  test('rejects a payment response whose server versions disagree', () async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final body = _machine(
          state: 'PAYMENT_CAPTURED',
          data: <String, dynamic>{
            'orderId': '41',
            'confirmationRef': 'cr_test-1',
            'amountMinor': '120',
            'currency': 'CREDITS',
            'commitmentVersion': '7',
          },
        );
        body['paymentAttempt'] = <String, dynamic>{
          'paymentAttemptId': '51',
          'fundsDisposition': 'CAPTURED',
          'effectiveCommitment': true,
        };
        handler.resolve(Response(requestOptions: options, data: body));
      },
    ));

    expect(
      () => DioDsnOrderRepository(dio).reconcilePaymentAttempt('51'),
      throwsA(
        isA<DsnOrderApiException>().having(
          (error) => error.code,
          'code',
          'COMMITMENT_VERSION_MISMATCH',
        ),
      ),
    );
  });

  test('rejects a payment precondition that differs from the frozen order',
      () async {
    final dio = Dio();
    var called = false;
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      called = true;
      handler.next(options);
    }));
    const order = DsnOrder(
      orderId: '41',
      taskTraceId: 'ttr_1234567890abcdef',
      commitmentId: 'commit-1',
      confirmationRef: 'cr_test-1',
      amountMinor: 120,
      currency: 'CREDITS',
      orderState: 'awaitingPayment',
      commitmentVersion: 7,
    );

    expect(
      () => DioDsnOrderRepository(dio).createPaymentAttempt(
        order,
        preview: DsnOrderPreview(
          requestId: 33,
          taskTraceId: 'ttr_1234567890abcdef',
          previewId: 'preview-1',
          providerId: 'provider-1',
          providerOfferId: 'offer-1',
          providerAcceptanceId: 'accept-1',
          offerVersion: 2,
          specHash: 'sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
          quoteHash: 'sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
          amountMinor: 120,
          currency: 'CREDITS',
          quantity: 1,
          expiresAt: DateTime(2026, 8, 6),
        ),
        confirmation: const DsnConfirmationRef(
          confirmationRef: 'cr_test-1',
          requestId: 33,
          taskTraceId: 'ttr_1234567890abcdef',
          previewId: 'preview-1',
          specHash: 'sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
          quoteHash: 'sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
          amountMinor: 120,
          currency: 'CREDITS',
          paymentMethodType: 'CREDITS',
          allowedActions: ['CREATE_ORDER', 'CREATE_PAYMENT_ATTEMPT'],
        ),
        ifMatchVersion: 2,
        idempotencyKey: 'app-payment:41:cr_test-1',
      ),
      throwsA(isA<DsnOrderApiException>()),
    );
    expect(called, isFalse);
  });
}

Map<String, dynamic> _machine({
  required String state,
  required Map<String, dynamic> data,
}) {
  return <String, dynamic>{
    'schemaVersion': '0.1',
    'state': state,
    'taskTraceId': 'ttr_1234567890abcdef',
    'operationTraceId': 'trace_test',
    'resource': <String, dynamic>{
      'id': 'offer-1',
      'version': '2',
      'hash': _hash('b'),
    },
    'nextActions': <dynamic>[],
    'data': data,
  };
}

String _hash(String letter) => 'sha256:${letter * 64}';
