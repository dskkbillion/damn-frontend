import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/dasn/data/dsn_provider_repository.dart';
import 'package:dskk_flutter_refactor/core/dasn/domain/dsn_provider_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DioDsnProviderAgentRepository', () {
    test('submits an Agent ProviderOffer on the canonical route', () async {
      final dio = _agentDio();
      String? path;
      String? authorization;
      Map<String, dynamic>? body;
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          path = options.path;
          authorization = options.headers['Authorization']?.toString();
          body = Map<String, dynamic>.from(options.data as Map);
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 201,
            data: _machine(
              state: 'PROVIDER_OFFERED',
              data: <String, dynamic>{
                'offerId': 'offer-agent-1',
                'providerId': '77',
                'offerVersion': 2,
                'specHash': _hash('a'),
                'quoteHash': _hash('b'),
                'expiresAt': '2026-08-05T12:00:00Z',
                'status': 'OFFERED',
                'actorType': 'AGENT',
              },
            ),
          ));
        },
      ));

      final result = await DioDsnProviderAgentRepository(dio).submitOffer(
        33,
        offer: _offerInput(),
        ifMatchVersion: 0,
        idempotencyKey: 'agent-provider-offer:33:v1',
      );

      expect(path, '/provider/v1/requests/33/offers');
      expect(authorization, 'Bearer agent-session-test');
      expect(body, _offerInput().toJson());
      expect(body, isNot(contains('providerId')));
      expect(body, isNot(contains('subjectRole')));
      expect(body, isNot(contains('agentSession')));
      expect(result.actorType, 'AGENT');
      expect(result.offerId, 'offer-agent-1');
      expect(result.metadata.state, 'PROVIDER_OFFERED');
    });

    test('submits Agent ProviderAcceptance and preserves actor provenance',
        () async {
      final dio = _agentDio();
      String? path;
      Map<String, dynamic>? body;
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          path = options.path;
          body = Map<String, dynamic>.from(options.data as Map);
          handler.resolve(Response(
            requestOptions: options,
            data: _machine(
              state: 'PROVIDER_ACCEPTED',
              data: <String, dynamic>{
                'acceptanceId': 'accept-agent-1',
                'offerId': 'offer-agent-1',
                'offerVersion': '2',
                'specHash': _hash('a'),
                'quoteHash': _hash('b'),
                'acceptance': 'ACCEPT',
                'actorType': 'AGENT',
              },
            ),
          ));
        },
      ));

      final input = DsnProviderAcceptanceInput(
        offerVersion: 2,
        specHash: _hash('a'),
        quoteHash: _hash('b'),
        acceptance: DsnProviderAcceptance.accept,
      );
      final result = await DioDsnProviderAgentRepository(dio).submitAcceptance(
        33,
        acceptance: input,
        ifMatchVersion: 2,
        idempotencyKey: 'agent-provider-accept:33:v1',
      );

      expect(path, '/provider/v1/requests/33/acceptances');
      expect(body, input.toJson());
      expect(result.actorType, 'AGENT');
      expect(result.acceptance, DsnProviderAcceptance.accept);
    });

    test('submits Agent delivery evidence on the canonical order route',
        () async {
      final dio = _agentDio();
      String? path;
      Map<String, dynamic>? body;
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          path = options.path;
          body = Map<String, dynamic>.from(options.data as Map);
          handler.resolve(Response(
            requestOptions: options,
            data: _machine(
              state: 'DELIVERY_SUBMITTED',
              resourceVersion: 1,
              data: <String, dynamic>{
                'deliveryId': 'delivery-agent-1',
                'orderId': '1001',
                'commitmentId': 'commit-1',
                'commitmentVersion': 1,
                'submissionNo': 1,
                'evidenceHash': _hash('c'),
                'actorType': 'AGENT',
              },
            ),
          ));
        },
      ));

      final input = DsnDeliveryInput(
        expectedCommitmentHash: _hash('d'),
        submissionNo: 1,
        artifacts: <DsnDeliveryArtifactInput>[
          DsnDeliveryArtifactInput(
            objectRef: 'staging://artifact/agent-1',
            size: 12,
            mimeType: 'text/plain',
            sha256: _hash('e'),
          ),
        ],
      );
      final result = await DioDsnProviderAgentRepository(dio).submitDelivery(
        '1001',
        delivery: input,
        ifMatchVersion: 1,
        idempotencyKey: 'agent-provider-delivery:1001:v1',
      );

      expect(path, '/provider/v1/orders/1001/deliveries');
      expect(body, input.toJson());
      expect(result.actorType, 'AGENT');
      expect(result.deliveryId, 'delivery-agent-1');
    });

    test('rejects a ProviderOffer response with HUMAN actor provenance',
        () async {
      final dio = _agentDio();
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(Response(
            requestOptions: options,
            data: _machine(
              state: 'PROVIDER_OFFERED',
              resourceVersion: 1,
              data: <String, dynamic>{
                'offerId': 'offer-human',
                'providerId': '77',
                'offerVersion': 1,
                'specHash': _hash('a'),
                'quoteHash': _hash('b'),
                'status': 'OFFERED',
                'actorType': 'HUMAN',
              },
            ),
          ));
        },
      ));

      await expectLater(
        DioDsnProviderAgentRepository(dio).submitOffer(
          33,
          offer: _offerInput(),
          ifMatchVersion: 0,
          idempotencyKey: 'agent-provider-offer:33:v1',
        ),
        throwsA(
          isA<DsnProviderApiException>().having(
            (error) => error.code,
            'code',
            'PROVIDER_AGENT_ACTOR_MISMATCH',
          ),
        ),
      );
    });

    test('rejects a ProviderOffer response missing actor provenance', () async {
      final dio = _agentDio();
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(Response(
            requestOptions: options,
            data: _machine(
              state: 'PROVIDER_OFFERED',
              resourceVersion: 1,
              data: <String, dynamic>{
                'offerId': 'offer-legacy',
                'providerId': '77',
                'offerVersion': 1,
                'specHash': _hash('a'),
                'quoteHash': _hash('b'),
                'status': 'OFFERED',
              },
            ),
          ));
        },
      ));

      await expectLater(
        DioDsnProviderAgentRepository(dio).submitOffer(
          33,
          offer: _offerInput(),
          ifMatchVersion: 0,
          idempotencyKey: 'agent-provider-offer:33:v1',
        ),
        throwsA(
          isA<DsnProviderApiException>().having(
            (error) => error.code,
            'code',
            'PROVIDER_AGENT_ACTOR_MISMATCH',
          ),
        ),
      );
    });
  });
}

Dio _agentDio() =>
    Dio()..options.headers['Authorization'] = 'Bearer agent-session-test';

DsnProviderOfferInput _offerInput() => DsnProviderOfferInput(
      offerVersion: 2,
      specHash: _hash('a'),
      quoteHash: _hash('b'),
      capabilityId: 'translation',
      variantId: 'standard',
      quantity: 1,
      amountMinor: 120,
      currency: 'CREDITS',
      expiresAt: DateTime.utc(2026, 8, 5, 12),
    );

Map<String, dynamic> _machine({
  required String state,
  required Map<String, dynamic> data,
  int resourceVersion = 2,
}) {
  return <String, dynamic>{
    'protocolVersion': 'dasn/0.1',
    'dsVersion': 'DS 0.1',
    'schemaVersion': '0.1',
    'state': state,
    'taskTraceId': 'ttr_1234567890abcdef',
    'operationTraceId': 'trace-provider-agent-test',
    'resource': <String, dynamic>{
      'id': 'resource-agent-1',
      'version': resourceVersion,
      'hash': _hash('f'),
    },
    'nextActions': <dynamic>[],
    'data': data,
  };
}

String _hash(String letter) => 'sha256:${letter * 64}';
