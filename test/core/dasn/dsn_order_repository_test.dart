import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/dasn/data/dsn_order_repository.dart';
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
