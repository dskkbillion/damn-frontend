import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/dasn/data/dsn_provider_repository.dart';
import 'package:dskk_flutter_refactor/core/dasn/domain/dsn_provider_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DioDsnProviderRepository', () {
    test('should submit a human ProviderOffer without identity fields',
        () async {
      final dio = Dio();
      String? seenPath;
      Map<String, dynamic>? seenBody;
      String? seenIfMatch;
      String? seenKey;
      String? seenTrace;
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          seenPath = options.path;
          seenBody = Map<String, dynamic>.from(options.data as Map);
          seenIfMatch = options.headers['If-Match']?.toString();
          seenKey = options.headers['Idempotency-Key']?.toString();
          seenTrace = options.headers['X-Operation-Trace-Id']?.toString();
          handler.resolve(Response(
            requestOptions: options,
            data: _machine(
              state: 'PROVIDER_OFFERED',
              data: <String, dynamic>{
                'offerId': 'offer-1',
                'taskTraceId': 'ttr_1234567890abcdef',
                'providerId': '77',
                'offerVersion': 2,
                'specHash': _hash('a'),
                'quoteHash': _hash('b'),
                'expiresAt': '2026-08-05T12:00:00Z',
                'status': 'OFFERED',
              },
            ),
          ));
        },
      ));

      final result = await DioDsnProviderRepository(dio).submitOffer(
        33,
        offer: DsnProviderOfferInput(
          offerVersion: 2,
          specHash: _hash('a'),
          quoteHash: _hash('b'),
          capabilityId: 'translation',
          variantId: 'standard',
          quantity: 1,
          amountMinor: 120,
          currency: 'CREDITS',
          expiresAt: DateTime.utc(2026, 8, 5, 12),
        ),
        ifMatchVersion: 3,
        idempotencyKey: 'provider-offer:33:2:v1',
      );

      expect(seenPath, '/provider/v1/requests/33/offers');
      expect(seenIfMatch, '"3"');
      expect(seenKey, 'provider-offer:33:2:v1');
      expect(seenTrace, startsWith('trace-provider-offer-'));
      expect(seenBody, isNot(contains('providerId')));
      expect(seenBody, isNot(contains('subjectRole')));
      expect(result.offerId, 'offer-1');
      expect(result.providerId, '77');
      expect(result.metadata.state, 'PROVIDER_OFFERED');
    });

    test('should submit same-version human ProviderAcceptance', () async {
      final dio = Dio();
      String? seenPath;
      Map<String, dynamic>? seenBody;
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          seenPath = options.path;
          seenBody = Map<String, dynamic>.from(options.data as Map);
          handler.resolve(Response(
            requestOptions: options,
            data: _machine(
              state: 'PROVIDER_ACCEPTED',
              data: <String, dynamic>{
                'acceptanceId': 'accept-1',
                'offerId': 'offer-1',
                'taskTraceId': 'ttr_1234567890abcdef',
                'offerVersion': '2',
                'specHash': _hash('a'),
                'quoteHash': _hash('b'),
                'acceptance': 'ACCEPT',
                'actorType': 'HUMAN',
              },
            ),
          ));
        },
      ));

      final result = await DioDsnProviderRepository(dio).submitAcceptance(
        33,
        acceptance: DsnProviderAcceptanceInput(
          offerVersion: 2,
          specHash: _hash('a'),
          quoteHash: _hash('b'),
          acceptance: DsnProviderAcceptance.accept,
        ),
        ifMatchVersion: 3,
        idempotencyKey: 'provider-acceptance:33:2:v1',
      );

      expect(seenPath, '/provider/v1/requests/33/acceptances');
      expect(seenBody, <String, dynamic>{
        'offerVersion': 2,
        'specHash': _hash('a'),
        'quoteHash': _hash('b'),
        'acceptance': 'ACCEPT',
      });
      expect(result.acceptance, DsnProviderAcceptance.accept);
      expect(result.actorType, 'HUMAN');
    });

    test('should submit append-only delivery artifacts on the Provider route',
        () async {
      final dio = Dio();
      String? seenPath;
      String? seenIfMatch;
      Map<String, dynamic>? seenBody;
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          seenPath = options.path;
          seenIfMatch = options.headers['If-Match']?.toString();
          seenBody = Map<String, dynamic>.from(options.data as Map);
          handler.resolve(Response(
            requestOptions: options,
            data: _machine(
              state: 'DELIVERY_SUBMITTED',
              resourceVersion: 1,
              data: <String, dynamic>{
                'deliveryId': 'delivery-1',
                'orderId': '1001',
                'commitmentId': 'commit-1',
                'commitmentVersion': 1,
                'submissionNo': 1,
                'evidenceHash': _hash('c'),
                'actorType': 'HUMAN',
              },
            ),
          ));
        },
      ));

      final result = await DioDsnProviderRepository(dio).submitDelivery(
        '1001',
        delivery: DsnDeliveryInput(
          expectedCommitmentHash: _hash('d'),
          submissionNo: 1,
          artifacts: [
            DsnDeliveryArtifactInput(
              uploadRef: 'upl_artifact1',
              size: 12,
              mimeType: 'text/plain',
              sha256: _hash('e'),
            ),
          ],
        ),
        ifMatchVersion: 1,
        idempotencyKey: 'provider-delivery:1001:1:v1',
      );

      expect(seenPath, '/provider/v1/orders/1001/deliveries');
      expect(seenIfMatch, '"1"');
      expect(seenBody?['expectedCommitmentHash'], _hash('d'));
      expect(seenBody?['artifacts'], isA<List>());
      expect(result.deliveryId, 'delivery-1');
      expect(result.evidenceHash, _hash('c'));
      expect(result.actorType, 'HUMAN');
    });

    test('should reject a non-canonical response state or hash', () async {
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(Response(
            requestOptions: options,
            data: _machine(
              state: 'PROVIDER_OFFERED',
              data: <String, dynamic>{
                'offerId': 'offer-1',
                'providerId': '77',
                'offerVersion': 2,
                'specHash': 'not-a-hash',
                'quoteHash': _hash('b'),
                'status': 'OFFERED',
              },
            ),
          ));
        },
      ));

      expect(
        () => DioDsnProviderRepository(dio).submitOffer(
          33,
          offer: DsnProviderOfferInput(
            offerVersion: 2,
            specHash: _hash('a'),
            quoteHash: _hash('b'),
            capabilityId: 'translation',
            variantId: 'standard',
            quantity: 1,
            amountMinor: 120,
            currency: 'CREDITS',
            expiresAt: DateTime.utc(2026, 8, 5, 12),
          ),
          ifMatchVersion: 3,
          idempotencyKey: 'provider-offer:33:2:v1',
        ),
        throwsA(isA<DsnProviderApiException>()),
      );
    });

    test('should allow the initial request resource version zero', () async {
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(Response(
            requestOptions: options,
            data: _machine(
              state: 'PROVIDER_OFFERED',
              resourceVersion: 1,
              data: <String, dynamic>{
                'offerId': 'offer-0',
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

      final result = await DioDsnProviderRepository(dio).submitOffer(
        33,
        offer: DsnProviderOfferInput(
          offerVersion: 1,
          specHash: _hash('a'),
          quoteHash: _hash('b'),
          capabilityId: 'translation',
          variantId: 'standard',
          quantity: 1,
          amountMinor: 120,
          currency: 'CREDITS',
          expiresAt: DateTime.utc(2026, 8, 5, 12),
        ),
        ifMatchVersion: 0,
        idempotencyKey: 'provider-offer:33:1:v0',
      );

      expect(result.offerId, 'offer-0');
    });

    test('should reject an offer response without resource.version', () async {
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          final response = _machine(
            state: 'PROVIDER_OFFERED',
            data: <String, dynamic>{
              'offerId': 'offer-missing-version',
              'providerId': '77',
              'offerVersion': 2,
              'specHash': _hash('a'),
              'quoteHash': _hash('b'),
              'status': 'OFFERED',
            },
          );
          (response['resource'] as Map<String, dynamic>).remove('version');
          handler.resolve(Response(requestOptions: options, data: response));
        },
      ));

      await expectLater(
        DioDsnProviderRepository(dio).submitOffer(
          33,
          offer: _offerInput(),
          ifMatchVersion: 0,
          idempotencyKey: 'provider-offer:33:missing:v1',
        ),
        throwsA(
          isA<DsnProviderApiException>().having(
            (error) => error.code,
            'code',
            'RESOURCE_VERSION_MISSING',
          ),
        ),
      );
    });

    test('should reject an acceptance response with a stale resource version',
        () async {
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(Response(
            requestOptions: options,
            data: _machine(
              state: 'PROVIDER_ACCEPTED',
              data: <String, dynamic>{
                'acceptanceId': 'accept-stale-version',
                'offerId': 'offer-1',
                'offerVersion': 2,
                'specHash': _hash('a'),
                'quoteHash': _hash('b'),
                'acceptance': 'ACCEPT',
                'actorType': 'HUMAN',
              },
              resourceVersion: 1,
            ),
          ));
        },
      ));

      await expectLater(
        DioDsnProviderRepository(dio).submitAcceptance(
          33,
          acceptance: DsnProviderAcceptanceInput(
            offerVersion: 2,
            specHash: _hash('a'),
            quoteHash: _hash('b'),
            acceptance: DsnProviderAcceptance.accept,
          ),
          ifMatchVersion: 2,
          idempotencyKey: 'provider-acceptance:33:stale:v1',
        ),
        throwsA(
          isA<DsnProviderApiException>().having(
            (error) => error.code,
            'code',
            'COMMITMENT_VERSION_MISMATCH',
          ),
        ),
      );
    });

    test('should reject delivery when resource version differs from commitment',
        () async {
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(Response(
            requestOptions: options,
            data: _machine(
              state: 'DELIVERY_SUBMITTED',
              data: <String, dynamic>{
                'deliveryId': 'delivery-stale-version',
                'orderId': '1001',
                'commitmentId': 'commit-1',
                'commitmentVersion': 1,
                'submissionNo': 1,
                'evidenceHash': _hash('c'),
                'actorType': 'HUMAN',
              },
              resourceVersion: 2,
            ),
          ));
        },
      ));

      await expectLater(
        DioDsnProviderRepository(dio).submitDelivery(
          '1001',
          delivery: DsnDeliveryInput(
            expectedCommitmentHash: _hash('d'),
            submissionNo: 1,
            artifacts: <DsnDeliveryArtifactInput>[
              DsnDeliveryArtifactInput(
                uploadRef: 'upl_artifact1',
                size: 12,
                mimeType: 'text/plain',
              ),
            ],
          ),
          ifMatchVersion: 1,
          idempotencyKey: 'provider-delivery:1001:stale:v1',
        ),
        throwsA(
          isA<DsnProviderApiException>().having(
            (error) => error.code,
            'code',
            'COMMITMENT_VERSION_MISMATCH',
          ),
        ),
      );
    });

    test('issues canonical uploadRef slots before delivery', () async {
      final dio = Dio();
      String? seenPath;
      Map<String, dynamic>? seenBody;
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          seenPath = options.path;
          seenBody = Map<String, dynamic>.from(options.data as Map);
          handler.resolve(Response(
            requestOptions: options,
            data: _machine(
              state: 'ARTIFACT_UPLOAD_SLOTS_ISSUED',
              resourceVersion: 1,
              data: <String, dynamic>{
                'submissionNo': 1,
                'items': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'uploadRef': 'upl_fixture1',
                    'expiresAt': '2026-08-06T12:00:00Z',
                    'maxBytes': 1024,
                  },
                ],
              },
            ),
          ));
        },
      ));

      final result =
          await DioDsnProviderRepository(dio).issueArtifactUploadSlots(
        '1001',
        input: DsnArtifactUploadSlotInput(
          expectedCommitmentHash: _hash('d'),
          submissionNo: 1,
          artifacts: const <DsnArtifactUploadMetadata>[
            DsnArtifactUploadMetadata(size: 3, mimeType: 'text/plain'),
          ],
        ),
        ifMatchVersion: 1,
        idempotencyKey: 'provider-upload-slots:1001:1:v1',
      );

      expect(seenPath, '/provider/v1/orders/1001/artifact-upload-slots');
      expect(seenBody?['expectedCommitmentHash'], _hash('d'));
      expect(seenBody?['artifacts'], isA<List>());
      expect(seenBody?['artifacts'], isNot(contains('objectRef')));
      expect(result.items.single.uploadRef, 'upl_fixture1');
      expect(result.items.single.maxBytes, 1024);
    });

    test(
        'uploads multipart bytes to opaque uploadRef and parses verified facts',
        () async {
      final dio = Dio();
      String? seenPath;
      String? seenIfMatch;
      String? seenCommitmentHash;
      String? seenSubmissionNo;
      FormData? seenForm;
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          seenPath = options.path;
          seenIfMatch = options.headers['If-Match']?.toString();
          seenCommitmentHash = options.headers['X-Commitment-Hash']?.toString();
          seenSubmissionNo = options.headers['X-Submission-No']?.toString();
          seenForm = options.data as FormData;
          handler.resolve(Response(
            requestOptions: options,
            data: _machine(
              state: 'ARTIFACT_UPLOADED',
              resourceVersion: 1,
              data: <String, dynamic>{
                'uploadRef': 'upl_fixture1',
                'status': 'UPLOADED',
                'sha256':
                    'sha256:ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
                'size': 3,
                'mimeType': 'text/plain',
              },
            ),
          ));
        },
      ));

      final result = await DioDsnProviderRepository(dio).uploadArtifact(
        '1001',
        uploadRef: 'upl_fixture1',
        source: const DsnArtifactUploadSource(
          fileName: 'fixture.txt',
          bytes: <int>[97, 98, 99],
          size: 3,
          mimeType: 'text/plain',
        ),
        commitmentHash: _hash('d'),
        submissionNo: 1,
        ifMatchVersion: 1,
      );

      expect(seenPath,
          '/provider/v1/orders/1001/artifact-upload-slots/upl_fixture1');
      expect(seenIfMatch, '"1"');
      expect(seenCommitmentHash, _hash('d'));
      expect(seenSubmissionNo, '1');
      expect(seenForm?.files.single.key, 'file');
      expect(seenForm?.files.single.value.filename, 'fixture.txt');
      expect(result.uploadRef, 'upl_fixture1');
      expect(result.sha256,
          'sha256:ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad');
      expect(result.status, 'UPLOADED');
      expect(result.toString(), isNot(contains('objectRef')));
    });

    test('fails closed when upload response metadata disagrees with source',
        () async {
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(Response(
            requestOptions: options,
            data: _machine(
              state: 'ARTIFACT_UPLOADED',
              resourceVersion: 1,
              data: <String, dynamic>{
                'uploadRef': 'upl_fixture1',
                'status': 'UPLOADED',
                'sha256':
                    'sha256:ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
                'size': 3,
                'mimeType': 'application/octet-stream',
              },
            ),
          ));
        },
      ));

      await expectLater(
        DioDsnProviderRepository(dio).uploadArtifact(
          '1001',
          uploadRef: 'upl_fixture1',
          source: const DsnArtifactUploadSource(
            fileName: 'fixture.csv',
            bytes: <int>[97, 98, 99],
            size: 3,
            mimeType: 'text/csv',
          ),
          commitmentHash: _hash('d'),
          submissionNo: 1,
          ifMatchVersion: 1,
        ),
        throwsA(
          isA<DsnProviderApiException>().having(
            (error) => error.code,
            'code',
            'ARTIFACT_RESPONSE_METADATA_MISMATCH',
          ),
        ),
      );
    });
  });
}

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
    'schemaVersion': '0.1',
    'state': state,
    'taskTraceId': 'ttr_1234567890abcdef',
    'operationTraceId': 'trace_test_1234',
    'resource': <String, dynamic>{
      'id': 'resource-1',
      'version': resourceVersion,
      'hash': _hash('b'),
    },
    'nextActions': <dynamic>[],
    'data': data,
  };
}

String _hash(String letter) => 'sha256:${letter * 64}';
