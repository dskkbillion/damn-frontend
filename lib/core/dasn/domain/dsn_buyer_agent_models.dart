import 'dsn_order_models.dart';

/// The six facts accepted by the canonical Buyer Agent commitment endpoint.
///
/// This is deliberately a wire contract, not a credential container.  A
/// Trusted App may prepare these facts after it has issued a confirmation
/// reference, but it must never attach an Agent access token, Grant, session,
/// or principal credential to them.
class DsnBuyerAgentCommitmentInput {
  DsnBuyerAgentCommitmentInput({
    required this.previewId,
    required this.providerAcceptanceId,
    required this.offerVersion,
    required String specHash,
    required String quoteHash,
    required this.confirmationRef,
  })  : specHash = _normalizeHash('specHash', specHash),
        quoteHash = _normalizeHash('quoteHash', quoteHash) {
    _requireNonEmpty('previewId', previewId);
    _requireNonEmpty('providerAcceptanceId', providerAcceptanceId);
    _requireNonEmpty('confirmationRef', confirmationRef);
    if (offerVersion <= 0) {
      throw ArgumentError.value(
          offerVersion, 'offerVersion', 'must be positive');
    }
  }

  final String previewId;
  final String providerAcceptanceId;
  final int offerVersion;
  final String specHash;
  final String quoteHash;
  final String confirmationRef;

  /// The exact six-key body accepted by `/agent/v1/requests/{id}/commitment`.
  ///
  /// Do not add actor, amount, provider, scope, token, Grant, or principal
  /// fields here.  Those facts are authenticated and checked by the Agent
  /// adapter/server, not supplied by the App handoff.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'previewId': previewId,
        'providerAcceptanceId': providerAcceptanceId,
        'offerVersion': offerVersion,
        'expectedSpecHash': specHash,
        'expectedQuoteHash': quoteHash,
        'confirmationRef': confirmationRef,
      };

  static void _requireNonEmpty(String field, String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, field, 'must not be empty');
    }
  }

  static String _normalizeHash(String field, String value) {
    final wire = value.startsWith('sha256:') ? value : 'sha256:$value';
    if (!RegExp(r'^sha256:[a-f0-9]{64}$').hasMatch(wire)) {
      throw ArgumentError.value(value, field, 'must be a sha256 hash');
    }
    return wire;
  }
}

/// App-visible status for the buyer-agent handoff.
enum DsnBuyerAgentHandoffStatus {
  readyForBuyerAgent,
  commitmentCreated,
  awaitingAppPayment,
}

extension DsnBuyerAgentHandoffStatusWire on DsnBuyerAgentHandoffStatus {
  String get wireName => switch (this) {
        DsnBuyerAgentHandoffStatus.readyForBuyerAgent =>
          'READY_FOR_BUYER_AGENT',
        DsnBuyerAgentHandoffStatus.commitmentCreated => 'COMMITMENT_CREATED',
        DsnBuyerAgentHandoffStatus.awaitingAppPayment => 'AWAITING_APP_PAYMENT',
      };

  /// Stable App-facing status labels for the 2x2 interaction surface.
  ///
  /// Keep [wireName] compatible with the handoff payload consumed by an
  /// external Agent.  The App copy is intentionally explicit about the
  /// boundary: it is waiting on an external Agent, or it has resumed at the
  /// App-owned payment gate.
  String get appName => switch (this) {
        DsnBuyerAgentHandoffStatus.readyForBuyerAgent =>
          'HANDOFF_PENDING_EXTERNAL_AGENT',
        DsnBuyerAgentHandoffStatus.commitmentCreated => 'COMMITMENT_CREATED',
        DsnBuyerAgentHandoffStatus.awaitingAppPayment => 'AWAITING_APP_PAYMENT',
      };
}

/// Facts that the Trusted App can display or hand off without carrying Agent
/// credentials.
///
/// `principalRef` is a required, stable, non-secret identity binding for an
/// Agent-origin request.  It must never be an access token or Grant.
class DsnBuyerAgentHandoff {
  DsnBuyerAgentHandoff({
    required this.requestId,
    required this.taskTraceId,
    required this.commitment,
    required this.status,
    required String principalRef,
  }) : principalRef = _requirePrincipalRef(principalRef);

  final int requestId;
  final String taskTraceId;
  final DsnBuyerAgentCommitmentInput commitment;
  final DsnBuyerAgentHandoffStatus status;
  final String principalRef;

  DsnBuyerAgentHandoff copyWith({
    DsnBuyerAgentHandoffStatus? status,
    String? principalRef,
  }) {
    return DsnBuyerAgentHandoff(
      requestId: requestId,
      taskTraceId: taskTraceId,
      commitment: commitment,
      status: status ?? this.status,
      principalRef: principalRef ?? this.principalRef,
    );
  }

  /// Safe handoff facts only.  This map is intentionally not an HTTP request
  /// body for the Agent route and contains no access token, session, or Grant.
  Map<String, dynamic> toSafeJson() => <String, dynamic>{
        'requestId': requestId,
        'taskTraceId': taskTraceId,
        'status': status.wireName,
        'principalRef': principalRef,
        ...commitment.toJson(),
      };

  static String _requirePrincipalRef(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(value, 'principalRef', 'must not be empty');
    }
    return normalized;
  }
}

/// Safe upper-layer injection point for the App handoff.
///
/// Implementations receive only non-secret handoff facts. They must not add
/// or derive an Agent token, session, or Grant, and the Flutter route never
/// calls the Agent commitment endpoint itself.
abstract interface class DsnBuyerAgentHandoffSink {
  void onReady(DsnBuyerAgentHandoff handoff);
}

/// Builds the handoff from the two server-owned facts already read by App.
/// It refuses to combine a confirmation reference with a different preview.
DsnBuyerAgentCommitmentInput buyerAgentCommitmentInputFromFacts({
  required DsnOrderPreview preview,
  required DsnConfirmationRef confirmation,
}) {
  if (preview.requestId != confirmation.requestId ||
      preview.taskTraceId != confirmation.taskTraceId ||
      preview.previewId != confirmation.previewId ||
      preview.specHash != confirmation.specHash ||
      preview.quoteHash != confirmation.quoteHash ||
      preview.amountMinor != confirmation.amountMinor ||
      preview.currency != confirmation.currency ||
      confirmation.paymentMethodType != 'CREDITS' ||
      !confirmation.allowedActions.contains('CREATE_ORDER') ||
      !confirmation.allowedActions.contains('CREATE_PAYMENT_ATTEMPT')) {
    throw ArgumentError('confirmation reference does not match preview facts');
  }
  return DsnBuyerAgentCommitmentInput(
    previewId: preview.previewId,
    providerAcceptanceId: preview.providerAcceptanceId,
    offerVersion: preview.offerVersion,
    specHash: preview.specHash,
    quoteHash: preview.quoteHash,
    confirmationRef: confirmation.confirmationRef,
  );
}
