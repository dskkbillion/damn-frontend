/// Frozen facts returned by the canonical Trusted App order boundary.
///
/// These models intentionally contain only server-owned facts.  The client
/// can select a preview or confirmation reference, but it cannot edit price,
/// provider, quantity, currency, or hashes.
class DsnProviderOffer {
  const DsnProviderOffer({
    required this.requestId,
    required this.taskTraceId,
    required this.offerId,
    required this.acceptanceId,
    required this.providerId,
    required this.capabilityId,
    required this.variantId,
    required this.offerVersion,
    required this.specHash,
    required this.quoteHash,
    required this.quantity,
    required this.amountMinor,
    required this.currency,
    this.capacity,
    this.expiresAt,
    this.deliveryDeadline,
    this.maxRevisions,
    this.sla,
    this.acceptance,
  });

  final int requestId;
  final String taskTraceId;
  final String offerId;
  final String acceptanceId;
  final String providerId;
  final String capabilityId;
  final String variantId;
  final int offerVersion;
  final String specHash;
  final String quoteHash;
  final int quantity;
  final int amountMinor;
  final String currency;
  final int? capacity;
  final DateTime? expiresAt;
  final DateTime? deliveryDeadline;
  final int? maxRevisions;
  final String? sla;
  final String? acceptance;
}

class DsnOrderPreview {
  const DsnOrderPreview({
    required this.requestId,
    required this.taskTraceId,
    required this.previewId,
    required this.providerId,
    required this.providerOfferId,
    required this.providerAcceptanceId,
    required this.offerVersion,
    required this.specHash,
    required this.quoteHash,
    required this.amountMinor,
    required this.currency,
    required this.quantity,
    required this.expiresAt,
    this.deliveryDeadline,
    this.maxRevisions,
    this.candidateHash,
  });

  final int requestId;
  final String taskTraceId;
  final String previewId;
  final String providerId;
  final String providerOfferId;
  final String providerAcceptanceId;
  final int offerVersion;
  final String specHash;
  final String quoteHash;
  final int amountMinor;
  final String currency;
  final int quantity;
  final DateTime expiresAt;
  final DateTime? deliveryDeadline;
  final int? maxRevisions;
  final String? candidateHash;
}

class DsnConfirmationRef {
  const DsnConfirmationRef({
    required this.confirmationRef,
    required this.requestId,
    required this.taskTraceId,
    required this.previewId,
    required this.specHash,
    required this.quoteHash,
    required this.amountMinor,
    required this.currency,
    required this.paymentMethodType,
    required this.allowedActions,
    this.expiresAt,
  });

  final String confirmationRef;
  final int requestId;
  final String taskTraceId;
  final String previewId;
  final String specHash;
  final String quoteHash;
  final int amountMinor;
  final String currency;
  final String paymentMethodType;
  final List<String> allowedActions;
  final DateTime? expiresAt;
}

class DsnOrder {
  const DsnOrder({
    required this.orderId,
    required this.taskTraceId,
    required this.commitmentId,
    required this.confirmationRef,
    required this.amountMinor,
    required this.currency,
    required this.orderState,
    this.offerId,
    this.replayed = false,
  });

  final String orderId;
  final String taskTraceId;
  final String commitmentId;
  final String confirmationRef;
  final int amountMinor;
  final String currency;
  final String orderState;
  final String? offerId;
  final bool replayed;
}

class DsnPaymentAttempt {
  const DsnPaymentAttempt({
    required this.paymentAttemptId,
    required this.orderId,
    required this.taskTraceId,
    required this.state,
    required this.fundsDisposition,
    required this.effectiveCommitment,
    required this.amountMinor,
    required this.currency,
    required this.confirmationRef,
    this.nextAction,
    this.replayed = false,
  });

  final String paymentAttemptId;
  final String orderId;
  final String taskTraceId;
  final String state;
  final String fundsDisposition;
  final bool effectiveCommitment;
  final int amountMinor;
  final String currency;
  final String confirmationRef;
  final String? nextAction;
  final bool replayed;

  bool get captured => fundsDisposition == 'CAPTURED';
  bool get pending =>
      fundsDisposition == 'PROCESSING' || fundsDisposition == 'RECONCILING';
}
