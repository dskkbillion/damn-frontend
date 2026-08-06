import 'dart:convert';

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

/// Canonical DS 0.2 delivery artifact input.
///
/// The client submits only a server-issued opaque upload handle.  A client
/// chosen object key, URL or path is deliberately not representable here;
/// legacy `objectRef` routes live behind a separate compatibility boundary and
/// are not Provider conformance evidence.
class DsnDeliveryArtifactInput {
  const DsnDeliveryArtifactInput({
    required this.uploadRef,
    required this.size,
    required this.mimeType,
    this.sha256,
  });

  final String uploadRef;
  final String? sha256;
  final int size;
  final String mimeType;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'uploadRef': uploadRef,
        if (sha256 != null) 'sha256': sha256,
        'size': size,
        'mimeType': mimeType,
      };
}

/// Metadata sent when requesting a server-owned upload slot.
class DsnArtifactUploadMetadata {
  const DsnArtifactUploadMetadata({
    required this.size,
    required this.mimeType,
    this.sha256,
  });

  final String? sha256;
  final int size;
  final String mimeType;

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (sha256 != null) 'sha256': sha256,
        'size': size,
        'mimeType': mimeType,
      };
}

class DsnArtifactUploadSlotInput {
  const DsnArtifactUploadSlotInput({
    required this.expectedCommitmentHash,
    required this.submissionNo,
    required this.artifacts,
  });

  final String expectedCommitmentHash;
  final int submissionNo;
  final List<DsnArtifactUploadMetadata> artifacts;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'expectedCommitmentHash': expectedCommitmentHash,
        'submissionNo': submissionNo,
        'artifacts': artifacts.map((artifact) => artifact.toJson()).toList(),
      };
}

class DsnArtifactUploadSlot {
  const DsnArtifactUploadSlot({
    required this.uploadRef,
    required this.expiresAt,
    required this.maxBytes,
  });

  final String uploadRef;
  final DateTime expiresAt;
  final int maxBytes;
}

class DsnArtifactUploadSlotResult {
  const DsnArtifactUploadSlotResult({
    required this.metadata,
    required this.submissionNo,
    required this.items,
  });

  final DsnProviderMachineMetadata metadata;
  final int submissionNo;
  final List<DsnArtifactUploadSlot> items;
}

class DsnArtifactUploadResult {
  const DsnArtifactUploadResult({
    required this.metadata,
    required this.uploadRef,
    required this.status,
    required this.sha256,
    required this.size,
    required this.mimeType,
  });

  final DsnProviderMachineMetadata metadata;
  final String uploadRef;
  final String status;
  final String sha256;
  final int size;
  final String mimeType;
}

/// Source bytes selected by the Provider UI or supplied by a staging fixture.
///
/// `bytes` keeps widget tests and mobile file pickers deterministic.  A
/// `path` is supported for platforms where FilePicker cannot return bytes in
/// memory.  Neither field crosses the HTTP boundary; the repository sends a
/// multipart `file` part only.
class DsnArtifactUploadSource {
  const DsnArtifactUploadSource({
    required this.fileName,
    required this.size,
    required this.mimeType,
    this.bytes,
    this.path,
  }) : assert(bytes != null || path != null);

  final String fileName;
  final int size;
  final String mimeType;
  final List<int>? bytes;
  final String? path;

  String get canonicalMimeType =>
      canonicalDsnArtifactMimeType(bytes: bytes, declaredMimeType: mimeType);
}

/// The server derives artifact MIME from bytes.  Keep the client request in
/// the same small canonical vocabulary so a CSV/text upload does not fail the
/// slot binding merely because the picker reported `text/csv`.
String canonicalDsnArtifactMimeType({
  required List<int>? bytes,
  required String declaredMimeType,
}) {
  if (bytes != null && bytes.isNotEmpty) {
    if (_startsWith(bytes, const <int>[
      0x89,
      0x50,
      0x4e,
      0x47,
      0x0d,
      0x0a,
      0x1a,
      0x0a,
    ])) {
      return 'image/png';
    }
    if (_startsWith(bytes, const <int>[0xff, 0xd8, 0xff])) {
      return 'image/jpeg';
    }
    if (_startsWithAscii(bytes, 'GIF87a') ||
        _startsWithAscii(bytes, 'GIF89a')) {
      return 'image/gif';
    }
    if (_startsWithAscii(bytes, '%PDF-')) return 'application/pdf';
    if (_startsWithAscii(bytes, 'RIFF') &&
        _startsWithAsciiAt(bytes, 'WEBP', 8)) {
      return 'image/webp';
    }
    final text = _utf8Text(bytes);
    if (text != null) {
      final trimmed = text.trimLeft();
      if ((trimmed.startsWith('{') && trimmed.trimRight().endsWith('}')) ||
          (trimmed.startsWith('[') && trimmed.trimRight().endsWith(']'))) {
        return 'application/json';
      }
      return 'text/plain';
    }
    // The server only accepts the generic binary label when its byte sniff
    // cannot identify a more specific type; do not trust a picker label here.
    return 'application/octet-stream';
  }
  final declared = declaredMimeType.trim().toLowerCase();
  if (declared == 'text/csv' || declared.startsWith('text/')) {
    return 'text/plain';
  }
  if (declared.isEmpty) return 'application/octet-stream';
  return declared;
}

bool _startsWith(List<int> actual, List<int> prefix) {
  if (actual.length < prefix.length) return false;
  for (var index = 0; index < prefix.length; index++) {
    if (actual[index] != prefix[index]) return false;
  }
  return true;
}

bool _startsWithAscii(List<int> actual, String prefix) =>
    _startsWith(actual, prefix.codeUnits);

bool _startsWithAsciiAt(List<int> actual, String prefix, int offset) {
  if (offset < 0 || actual.length < offset + prefix.length) return false;
  for (var index = 0; index < prefix.length; index++) {
    if (actual[offset + index] != prefix.codeUnits[index]) return false;
  }
  return true;
}

String? _utf8Text(List<int> bytes) {
  try {
    final value = utf8.decode(bytes, allowMalformed: false);
    for (final codeUnit in value.codeUnits) {
      if (codeUnit == 0 ||
          (codeUnit < 32 &&
              codeUnit != 9 &&
              codeUnit != 10 &&
              codeUnit != 13)) {
        return null;
      }
    }
    return value;
  } catch (_) {
    return null;
  }
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
    this.actorType,
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

  /// Present on Agent responses when the server exposes actor provenance.
  /// Human Provider responses from older deployments may omit it; the
  /// explicit Provider Agent adapter rejects that omission rather than
  /// treating a Member response as an Agent write.
  final String? actorType;
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
