// Server-bound facts for the DS 0.1 human Provider adapter.
//
// These models intentionally keep Provider identity out of every write body.
// The backend derives the Provider principal from the authenticated member
// session and the server-side task assignment.

class DsnProviderOfferInput {
  const DsnProviderOfferInput({
    required this.offerVersion,
    required this.specHash,
    required this.quoteHash,
    required this.capabilityId,
    required this.variantId,
    required this.quantity,
    required this.amountMinor,
    required this.currency,
    required this.expiresAt,
    this.capacity,
    this.deliveryDeadline,
    this.maxRevisions,
    this.sla,
    this.deliverables,
    this.acceptanceCriteria,
  });

  final int offerVersion;
  final String specHash;
  final String quoteHash;
  final String capabilityId;
  final String variantId;
  final int quantity;
  final int? capacity;
  final int amountMinor;
  final String currency;
  final DateTime expiresAt;
  final DateTime? deliveryDeadline;
  final int? maxRevisions;
  final Map<String, dynamic>? sla;
  final List<String>? deliverables;
  final List<String>? acceptanceCriteria;

  /// Serializes only the fields allowed by provider-offer-input.schema.json.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'offerVersion': offerVersion,
        'specHash': specHash,
        'quoteHash': quoteHash,
        'capabilityId': capabilityId,
        'variantId': variantId,
        'quantity': quantity,
        if (capacity != null) 'capacity': capacity,
        'amountMinor': amountMinor,
        'currency': currency,
        'expiresAt': expiresAt.toUtc().toIso8601String(),
        if (deliveryDeadline != null)
          'deliveryDeadline': deliveryDeadline!.toUtc().toIso8601String(),
        if (maxRevisions != null) 'maxRevisions': maxRevisions,
        if (sla != null) 'sla': Map<String, dynamic>.from(sla!),
        if (deliverables != null)
          'deliverables': List<String>.from(deliverables!),
        if (acceptanceCriteria != null)
          'acceptanceCriteria': List<String>.from(acceptanceCriteria!),
      };
}

enum DsnProviderAcceptance {
  accept('ACCEPT'),
  reject('REJECT');

  const DsnProviderAcceptance(this.wireValue);

  final String wireValue;
}

class DsnProviderAcceptanceInput {
  const DsnProviderAcceptanceInput({
    required this.offerVersion,
    required this.specHash,
    required this.quoteHash,
    required this.acceptance,
    this.reason,
  });

  final int offerVersion;
  final String specHash;
  final String quoteHash;
  final DsnProviderAcceptance acceptance;
  final String? reason;

  /// Serializes only the fields allowed by provider-acceptance-input.schema.json.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'offerVersion': offerVersion,
        'specHash': specHash,
        'quoteHash': quoteHash,
        'acceptance': acceptance.wireValue,
        if (reason != null) 'reason': reason,
      };
}

class DsnDeliveryArtifactInput {
  const DsnDeliveryArtifactInput({
    required this.objectRef,
    required this.size,
    required this.mimeType,
    this.sha256,
  });

  final String objectRef;
  final String? sha256;
  final int size;
  final String mimeType;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'objectRef': objectRef,
        if (sha256 != null) 'sha256': sha256,
        'size': size,
        'mimeType': mimeType,
      };
}

class DsnDeliveryInput {
  const DsnDeliveryInput({
    required this.expectedCommitmentHash,
    required this.submissionNo,
    required this.artifacts,
    this.supersedesDeliveryId,
  });

  final String expectedCommitmentHash;
  final int submissionNo;
  final String? supersedesDeliveryId;
  final List<DsnDeliveryArtifactInput> artifacts;

  /// Serializes only the fields allowed by delivery-input.schema.json.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'expectedCommitmentHash': expectedCommitmentHash,
        'submissionNo': submissionNo,
        if (supersedesDeliveryId != null)
          'supersedesDeliveryId': supersedesDeliveryId,
        'artifacts': artifacts.map((artifact) => artifact.toJson()).toList(),
      };
}

/// Common machine-envelope facts returned by the canonical Provider routes.
class DsnProviderMachineMetadata {
  const DsnProviderMachineMetadata({
    required this.schemaVersion,
    required this.state,
    required this.taskTraceId,
    required this.operationTraceId,
    required this.resourceId,
    required this.resourceVersion,
    required this.resourceHash,
    required this.nextActions,
  });

  final String schemaVersion;
  final String state;
  final String taskTraceId;
  final String operationTraceId;
  final String resourceId;
  final int? resourceVersion;
  final String? resourceHash;
  final List<dynamic> nextActions;
}

class DsnProviderOfferResult {
  const DsnProviderOfferResult({
    required this.metadata,
    required this.offerId,
    required this.providerId,
    required this.offerVersion,
    required this.specHash,
    required this.quoteHash,
    required this.expiresAt,
    required this.status,
    this.operationId,
    this.operationStatus,
  });

  final DsnProviderMachineMetadata metadata;
  final String offerId;
  final String providerId;
  final int offerVersion;
  final String specHash;
  final String quoteHash;
  final DateTime? expiresAt;
  final String status;
  final String? operationId;
  final String? operationStatus;

  String get taskTraceId => metadata.taskTraceId;
}

class DsnProviderAcceptanceResult {
  const DsnProviderAcceptanceResult({
    required this.metadata,
    required this.acceptanceId,
    required this.offerId,
    required this.offerVersion,
    required this.specHash,
    required this.quoteHash,
    required this.acceptance,
    required this.actorType,
    this.operationId,
    this.operationStatus,
  });

  final DsnProviderMachineMetadata metadata;
  final String acceptanceId;
  final String offerId;
  final int offerVersion;
  final String specHash;
  final String quoteHash;
  final DsnProviderAcceptance acceptance;
  final String actorType;
  final String? operationId;
  final String? operationStatus;

  String get taskTraceId => metadata.taskTraceId;
}

class DsnDeliveryResult {
  const DsnDeliveryResult({
    required this.metadata,
    required this.deliveryId,
    required this.orderId,
    required this.commitmentId,
    required this.commitmentVersion,
    required this.submissionNo,
    required this.evidenceHash,
    required this.actorType,
    this.supersedesDeliveryId,
    this.createdAt,
  });

  final DsnProviderMachineMetadata metadata;
  final String deliveryId;
  final String orderId;
  final String commitmentId;
  final int commitmentVersion;
  final int submissionNo;
  final String? supersedesDeliveryId;
  final String evidenceHash;
  final String actorType;
  final DateTime? createdAt;

  String get taskTraceId => metadata.taskTraceId;
}
