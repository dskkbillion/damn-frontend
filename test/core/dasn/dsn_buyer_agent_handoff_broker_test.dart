import 'package:get_it/get_it.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dskk_flutter_refactor/core/dasn/data/dsn_buyer_agent_handoff_broker.dart';
import 'package:dskk_flutter_refactor/core/dasn/domain/dsn_buyer_agent_models.dart';

void main() {
  test('registers one broker instance as the safe handoff sink', () async {
    final locator = GetIt.asNewInstance();
    addTearDown(locator.reset);

    registerDsnBuyerAgentHandoffBroker(locator);

    final broker = locator<DsnBuyerAgentHandoffBroker>();
    expect(locator<DsnBuyerAgentHandoffSink>(), same(broker));
    expect(
        locator<DsnBuyerAgentHandoffSink>(), isA<DsnBuyerAgentHandoffBroker>());
  });

  test('publishes credential-free facts and consumes them exactly once', () {
    final broker = DsnBuyerAgentHandoffBroker();
    final handoff = _handoff();

    broker.onReady(handoff);
    expect(broker.hasPending, isTrue);
    expect(broker.pending, same(handoff));

    final safe = broker.consumeSafeJson();
    expect(safe, isNotNull);
    expect(safe, containsPair('requestId', 42));
    expect(safe, containsPair('confirmationRef', 'cr_test-1'));
    expect(
        safe!.keys,
        containsAll(<String>[
          'requestId',
          'taskTraceId',
          'status',
          'principalRef',
          'previewId',
          'providerAcceptanceId',
          'offerVersion',
          'expectedSpecHash',
          'expectedQuoteHash',
          'confirmationRef',
        ]));
    expect(safe, isNot(contains('accessToken')));
    expect(safe, isNot(contains('session')));
    expect(safe, isNot(contains('sessionToken')));
    expect(safe, isNot(contains('grant')));
    expect(safe, isNot(contains('token')));

    expect(broker.hasPending, isFalse);
    expect(broker.consume(), isNull);
  });

  test(
      'same handoff is idempotent, but a different pending handoff cannot overwrite it',
      () {
    final broker = DsnBuyerAgentHandoffBroker();
    final first = _handoff();
    final second = _handoff(confirmationRef: 'cr_test-2');

    broker.onReady(first);
    broker.onReady(first);
    expect(broker.pending, same(first));
    expect(() => broker.onReady(second), throwsStateError);
    expect(broker.consume(), same(first));

    // A consumed one-time reference cannot be re-published.
    broker.onReady(first);
    expect(broker.consume(), isNull);

    // A new server-issued confirmation reference is a new logical handoff.
    broker.onReady(second);
    expect(broker.consume(), same(second));
  });
}

DsnBuyerAgentHandoff _handoff({String confirmationRef = 'cr_test-1'}) =>
    DsnBuyerAgentHandoff(
      requestId: 42,
      taskTraceId: 'ttr_1234567890abcdef',
      status: DsnBuyerAgentHandoffStatus.readyForBuyerAgent,
      principalRef: 'member:42',
      commitment: DsnBuyerAgentCommitmentInput(
        previewId: 'preview-1',
        providerAcceptanceId: 'acceptance-1',
        offerVersion: 7,
        specHash: _hash('a'),
        quoteHash: _hash('b'),
        confirmationRef: confirmationRef,
      ),
    );

String _hash(String letter) => 'sha256:${letter * 64}';
