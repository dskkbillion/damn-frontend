import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/dasn/data/dsn_mandate_repository.dart';
import 'package:dskk_flutter_refactor/core/dasn/domain/dsn_mandate_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('previews a fixed App Mandate with the required write header', () async {
    final dio = Dio();
    String? path;
    Map<String, dynamic>? body;
    String? key;
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      path = options.path;
      body = Map<String, dynamic>.from(options.data as Map);
      key = options.headers['Idempotency-Key']?.toString();
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 201,
        data: _machine(
          'MANDATE_PREVIEW_CREATED',
          _previewData(),
        ),
      ));
    }));

    final preview = await DioDsnMandateRepository(dio).createPreview(
      _input(),
      idempotencyKey: 'app-mandate-preview-123456',
    );

    expect(path, '/app/v1/mandates/previews');
    expect(key, 'app-mandate-preview-123456');
    expect(body, _input().toJson());
    expect(body, isNot(contains('scope')));
    expect(body, isNot(contains('grant')));
    expect(body, isNot(contains('sessionToken')));
    expect(body, isNot(contains('agentClientId')));
    expect(body, isNot(contains('subjectRole')));
    expect(preview.approvalRef, 'apr_1');
    expect(preview.previewHash, _hash('a'));
    expect(preview.reviewHash, _hash('b'));
    expect(preview.allowedActionClasses, ['BUYER_CONFIRM_COMMITMENT']);
  });

  test('confirms with exactly the one-time preview facts', () async {
    final dio = Dio();
    Map<String, dynamic>? body;
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      body = Map<String, dynamic>.from(options.data as Map);
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 201,
        data: _machine('MANDATE_CREATED', _mandateData()),
      ));
    }));
    final mandate = await DioDsnMandateRepository(dio).confirmPreview(
      'preview-1',
      approvalRef: 'apr_1',
      expectedPreviewHash: _hash('a'),
      expectedReviewHash: _hash('b'),
      idempotencyKey: 'app-mandate-confirm-123456',
    );

    expect(body, <String, dynamic>{
      'approvalRef': 'apr_1',
      'expectedPreviewHash': _hash('a'),
      'expectedReviewHash': _hash('b'),
      'decision': 'CONFIRM',
    });
    expect(mandate.mandateId, 'mandate-1');
  });

  test('accepts the one unified Provider task template and server action set',
      () async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 201,
        data: _machine('MANDATE_PREVIEW_CREATED', _providerPreviewData()),
      ));
    }));

    final preview = await DioDsnMandateRepository(dio).createPreview(
      _providerInput(),
      idempotencyKey: 'app-mandate-provider-preview-123456',
    );

    expect(preview.templateCode, DsnMandateTemplateCode.providerFixedTaskV1);
    expect(preview.subjectRole, DsnMandateSubjectRole.provider);
    expect(preview.allowedActionClasses, <String>[
      'PROVIDER_SUBMIT_FIXED_OFFER',
      'PROVIDER_ACCEPT_FIXED_REQUEST',
      'PROVIDER_SUBMIT_DELIVERY',
    ]);
  });

  test('binds a buyer request with only its selected session ID', () async {
    final dio = Dio();
    String? path;
    Map<String, dynamic>? body;
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      path = options.path;
      body = Map<String, dynamic>.from(options.data as Map);
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 201,
        data: _machine('MANDATE_RESOURCE_BOUND', _buyerBindingData()),
      ));
    }));

    final binding = await DioDsnMandateRepository(dio).bindBuyerRequest(
      42,
      agentSessionId: '17',
      idempotencyKey: 'app-mandate-buyer-binding-123456',
    );

    expect(path, '/app/v1/requests/42/buyer-mandate-resource-bindings');
    expect(body, <String, dynamic>{'agentSessionId': '17'});
    expect(binding.resourceRef, 'opaque-buyer-binding');
    expect(binding.allowedTemplateCodes,
        [DsnMandateTemplateCode.buyerFixedCommitmentV1]);
  });

  test('binds a provider task with only its selected session ID', () async {
    final dio = Dio();
    String? path;
    Map<String, dynamic>? body;
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      path = options.path;
      body = Map<String, dynamic>.from(options.data as Map);
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 201,
        data: _machine('MANDATE_RESOURCE_BOUND', _providerBindingData()),
      ));
    }));

    final binding = await DioDsnMandateRepository(dio).bindProviderTask(
      'ttr_1234567890abcdef',
      agentSessionId: '18',
      idempotencyKey: 'app-mandate-provider-binding-123456',
    );

    expect(path,
        '/app/v1/provider-tasks/ttr_1234567890abcdef/mandate-resource-bindings');
    expect(body, <String, dynamic>{'agentSessionId': '18'});
    expect(binding.allowedTemplateCodes,
        [DsnMandateTemplateCode.providerFixedTaskV1]);
  });

  test('rejects a binding whose strict template scope is not canonical',
      () async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      final data = _buyerBindingData()
        ..['allowedTemplateCodes'] = <String>[
          'BUYER_FIXED_COMMITMENT_V1',
          'PROVIDER_FIXED_TASK_V1',
        ];
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 201,
        data: _machine('MANDATE_RESOURCE_BOUND', data),
      ));
    }));

    await expectLater(
      DioDsnMandateRepository(dio).bindBuyerRequest(
        42,
        agentSessionId: '17',
        idempotencyKey: 'app-mandate-buyer-binding-123456',
      ),
      throwsA(isA<DsnMandateApiException>().having(
        (error) => error.code,
        'code',
        'MANDATE_RESOURCE_BINDING_TEMPLATE_INVALID',
      )),
    );
  });

  test('revoke sends its optimistic version in body and If-Match', () async {
    final dio = Dio();
    Map<String, dynamic>? body;
    String? ifMatch;
    String? key;
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      body = Map<String, dynamic>.from(options.data as Map);
      ifMatch = options.headers['If-Match']?.toString();
      key = options.headers['Idempotency-Key']?.toString();
      handler.resolve(Response(
        requestOptions: options,
        data: _machine(
          'MANDATE_REVOKED',
          _mandateData(state: 'REVOKED', revokedAt: '2026-08-06T00:00:00Z'),
        ),
      ));
    }));
    final revoked = await DioDsnMandateRepository(dio).revoke(
      _mandate(),
      idempotencyKey: 'app-mandate-revoke-123456',
    );

    expect(ifMatch, '"3"');
    expect(key, 'app-mandate-revoke-123456');
    expect(body, <String, dynamic>{
      'expectedMandateVersion': 3,
      'reason': 'USER_REQUESTED',
    });
    expect(revoked.state, DsnMandateState.revoked);
  });

  test('rejects approvalRef leakage from a Mandate read', () async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      final data = _mandateData();
      data['approvalRef'] = 'must-not-be-readable';
      handler.resolve(Response(
        requestOptions: options,
        data: _machine('MANDATE_READ', data),
      ));
    }));

    await expectLater(
      DioDsnMandateRepository(dio).get('mandate-1'),
      throwsA(isA<DsnMandateApiException>().having(
        (error) => error.code,
        'code',
        'MANDATE_APPROVAL_REF_EXPOSED',
      )),
    );
  });

  test('rejects incomplete machine envelopes before accepting a Mandate',
      () async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      final response = _machine('MANDATE_CREATED', _mandateData())
        ..remove('operationTraceId');
      handler.resolve(Response(requestOptions: options, data: response));
    }));

    await expectLater(
      DioDsnMandateRepository(dio).confirmPreview(
        'preview-1',
        approvalRef: 'apr_1',
        expectedPreviewHash: _hash('a'),
        expectedReviewHash: _hash('b'),
        idempotencyKey: 'app-mandate-confirm-123456',
      ),
      throwsA(isA<DsnMandateApiException>()),
    );
  });
}

DsnMandatePreviewInput _input() => const DsnMandatePreviewInput(
      templateCode: DsnMandateTemplateCode.buyerFixedCommitmentV1,
      resourceRef: 'opaque-buyer-binding',
    );

DsnMandatePreviewInput _providerInput() => const DsnMandatePreviewInput(
      templateCode: DsnMandateTemplateCode.providerFixedTaskV1,
      resourceRef: 'opaque-provider-binding',
    );

DsnMandate _mandate() => DsnMandate(
      mandateId: 'mandate-1',
      templateCode: DsnMandateTemplateCode.buyerFixedCommitmentV1,
      templateVersion: 1,
      subjectRole: DsnMandateSubjectRole.buyer,
      agentClientId: '7',
      mandateVersion: 3,
      mandateHash: _hash('c'),
      state: DsnMandateState.active,
    );

Map<String, dynamic> _previewData() => <String, dynamic>{
      'previewId': 'preview-1',
      'templateCode': 'BUYER_FIXED_COMMITMENT_V1',
      'templateVersion': 1,
      'subjectRole': 'BUYER',
      'agentClientId': '7',
      'resourceRef': 'opaque-buyer-binding',
      'previewHash': _hash('a'),
      'reviewHash': _hash('b'),
      'approvalRef': 'apr_1',
      'allowedActionClasses': <String>['BUYER_CONFIRM_COMMITMENT'],
      'review': _reviewData(),
      'expiresAt': '2026-08-07T00:00:00Z',
      'state': 'PREVIEWED',
    };

Map<String, dynamic> _providerPreviewData() => <String, dynamic>{
      'previewId': 'preview-provider-1',
      'templateCode': 'PROVIDER_FIXED_TASK_V1',
      'templateVersion': 1,
      'subjectRole': 'PROVIDER',
      'agentClientId': '8',
      'resourceRef': 'opaque-provider-binding',
      'previewHash': _hash('d'),
      'reviewHash': _hash('e'),
      'approvalRef': 'apr_provider_1',
      'allowedActionClasses': <String>[
        'PROVIDER_SUBMIT_FIXED_OFFER',
        'PROVIDER_ACCEPT_FIXED_REQUEST',
        'PROVIDER_SUBMIT_DELIVERY',
      ],
      'review': _reviewData(),
      'expiresAt': '2026-08-07T00:00:00Z',
      'state': 'PREVIEWED',
    };

Map<String, dynamic> _buyerBindingData() => <String, dynamic>{
      'resourceRef': 'opaque-buyer-binding',
      'expiresAt': '2026-08-07T00:00:00Z',
      'resourceHash': _hash('f'),
      'allowedTemplateCodes': <String>['BUYER_FIXED_COMMITMENT_V1'],
    };

Map<String, dynamic> _providerBindingData() => <String, dynamic>{
      'resourceRef': 'opaque-provider-binding',
      'expiresAt': '2026-08-07T00:00:00Z',
      'resourceHash': _hash('e'),
      'allowedTemplateCodes': <String>['PROVIDER_FIXED_TASK_V1'],
    };

Map<String, dynamic> _reviewData() => <String, dynamic>{
      'capability': 'captioning',
      'provider': 'provider-1',
      'buyer': 'buyer-1',
      'variant': 'standard',
      'quantity': 1,
      'capacity': 1,
      'sla': <String, dynamic>{'delivery': '24h'},
      'currency': 'CREDITS',
      'amountMinor': 100,
      'quoteHash': _hash('e'),
      'maxDeliverySeconds': 86400,
    };

Map<String, dynamic> _mandateData({
  String state = 'ACTIVE',
  String? revokedAt,
}) =>
    <String, dynamic>{
      'mandateId': 'mandate-1',
      'templateCode': 'BUYER_FIXED_COMMITMENT_V1',
      'templateVersion': 1,
      'subjectRole': 'BUYER',
      'agentClientId': '7',
      'mandateVersion': 3,
      'mandateHash': _hash('c'),
      'state': state,
      if (revokedAt != null) 'revokedAt': revokedAt,
    };

Map<String, dynamic> _machine(String state, Map<String, dynamic> data) =>
    <String, dynamic>{
      'schemaVersion': '0.1',
      'state': state,
      'taskTraceId': 'ttr_1234567890abcdef',
      'operationTraceId': 'trace-mandate-1',
      'resource': <String, dynamic>{'id': 'resource-1', 'version': 1},
      'nextActions': const <dynamic>[],
      'data': data,
    };

String _hash(String char) => 'sha256:${char * 64}';
