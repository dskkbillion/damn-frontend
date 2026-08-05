import 'package:dskk_flutter_refactor/core/dasn/data/dsn_buyer_agent_commitment_repository.dart';
import 'package:dskk_flutter_refactor/core/dasn/domain/dsn_buyer_agent_models.dart';
import 'package:dskk_flutter_refactor/core/dasn/domain/dsn_order_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializes exactly the six Buyer Agent commitment facts', () {
    final input = DsnBuyerAgentCommitmentInput(
      previewId: 'preview-1',
      providerAcceptanceId: 'acceptance-1',
      offerVersion: 7,
      specHash: _hash('a'),
      quoteHash: _hash('b'),
      confirmationRef: 'cr_test-1',
    );

    expect(input.toJson(), <String, dynamic>{
      'previewId': 'preview-1',
      'providerAcceptanceId': 'acceptance-1',
      'offerVersion': 7,
      'expectedSpecHash': _hash('a'),
      'expectedQuoteHash': _hash('b'),
      'confirmationRef': 'cr_test-1',
    });
    expect(input.toJson().keys, hasLength(6));
    expect(input.toJson(), isNot(contains('orderId')));
    expect(input.toJson(), isNot(contains('amountMinor')));
    expect(input.toJson(), isNot(contains('accessToken')));
    expect(input.toJson(), isNot(contains('grant')));
  });

  test('normalizes legacy bare hashes to the canonical sha256 wire form', () {
    final input = DsnBuyerAgentCommitmentInput(
      previewId: 'preview-1',
      providerAcceptanceId: 'acceptance-1',
      offerVersion: 7,
      specHash: 'a' * 64,
      quoteHash: 'b' * 64,
      confirmationRef: 'cr_test-1',
    );

    expect(input.specHash, _hash('a'));
    expect(input.quoteHash, _hash('b'));
    expect(input.toJson()['expectedSpecHash'], _hash('a'));
    expect(input.toJson()['expectedQuoteHash'], _hash('b'));
  });

  test('rejects invalid commitment facts before an adapter can send them', () {
    expect(
      () => DsnBuyerAgentCommitmentInput(
        previewId: '',
        providerAcceptanceId: 'acceptance-1',
        offerVersion: 1,
        specHash: _hash('a'),
        quoteHash: _hash('b'),
        confirmationRef: 'cr_test-1',
      ),
      throwsArgumentError,
    );
    expect(
      () => DsnBuyerAgentCommitmentInput(
        previewId: 'preview-1',
        providerAcceptanceId: 'acceptance-1',
        offerVersion: 0,
        specHash: _hash('a'),
        quoteHash: _hash('b'),
        confirmationRef: 'cr_test-1',
      ),
      throwsArgumentError,
    );
    expect(
      () => DsnBuyerAgentCommitmentInput(
        previewId: 'preview-1',
        providerAcceptanceId: 'acceptance-1',
        offerVersion: 1,
        specHash: 'not-a-hash',
        quoteHash: _hash('b'),
        confirmationRef: 'cr_test-1',
      ),
      throwsArgumentError,
    );
  });

  test(
      'external repository contract carries If-Match and idempotency separately',
      () async {
    final adapter = _FakeBuyerAgentCommitmentRepository();
    final input = DsnBuyerAgentCommitmentInput(
      previewId: 'preview-1',
      providerAcceptanceId: 'acceptance-1',
      offerVersion: 7,
      specHash: _hash('a'),
      quoteHash: _hash('b'),
      confirmationRef: 'cr_test-1',
    );

    await adapter.createCommitment(
      42,
      input: input,
      ifMatchVersion: 3,
      idempotencyKey: 'agent-commit:42:preview-1',
    );

    expect(adapter.requestId, 42);
    expect(adapter.input?.toJson(), input.toJson());
    expect(adapter.ifMatchVersion, 3);
    expect(adapter.idempotencyKey, 'agent-commit:42:preview-1');
  });

  test('handoff refuses a confirmation ref from another preview', () {
    final preview = _preview();
    final confirmation = DsnConfirmationRef(
      confirmationRef: 'cr_test-1',
      requestId: preview.requestId,
      taskTraceId: preview.taskTraceId,
      previewId: 'different-preview',
      specHash: preview.specHash,
      quoteHash: preview.quoteHash,
      amountMinor: preview.amountMinor,
      currency: preview.currency,
      paymentMethodType: 'CREDITS',
      allowedActions: const ['CREATE_ORDER'],
    );

    expect(
      () => buyerAgentCommitmentInputFromFacts(
        preview: preview,
        confirmation: confirmation,
      ),
      throwsArgumentError,
    );
  });
}

class _FakeBuyerAgentCommitmentRepository
    implements DsnBuyerAgentCommitmentRepository {
  int? requestId;
  DsnBuyerAgentCommitmentInput? input;
  int? ifMatchVersion;
  String? idempotencyKey;

  @override
  Future<DsnOrder> createCommitment(
    int requestId, {
    required DsnBuyerAgentCommitmentInput input,
    required int ifMatchVersion,
    required String idempotencyKey,
  }) async {
    this.requestId = requestId;
    this.input = input;
    this.ifMatchVersion = ifMatchVersion;
    this.idempotencyKey = idempotencyKey;
    return const DsnOrder(
      orderId: 'order-1',
      taskTraceId: 'task-1',
      commitmentId: 'commit-1',
      confirmationRef: 'cr_test-1',
      amountMinor: 120,
      currency: 'CREDITS',
      orderState: 'awaitingPayment',
    );
  }
}

DsnOrderPreview _preview() => DsnOrderPreview(
      requestId: 42,
      taskTraceId: 'task-1',
      previewId: 'preview-1',
      providerId: 'provider-1',
      providerOfferId: 'offer-1',
      providerAcceptanceId: 'acceptance-1',
      offerVersion: 7,
      specHash: _hash('a'),
      quoteHash: _hash('b'),
      amountMinor: 120,
      currency: 'CREDITS',
      quantity: 1,
      expiresAt: DateTime(2026, 8, 6, 23),
    );

String _hash(String letter) => 'sha256:${letter * 64}';
