/// DS 0.2 Trusted App Mandate projections.
///
/// These are deliberately *not* Grant models. A Mandate is the small,
/// Principal-visible approval surface; its server-side BoundedGrant derivation
/// and any Agent session credentials never enter the Flutter process.
enum DsnMandateTemplateCode {
  buyerFixedCommitmentV1('BUYER_FIXED_COMMITMENT_V1'),
  providerFixedTaskV1('PROVIDER_FIXED_TASK_V1');

  const DsnMandateTemplateCode(this.wireValue);

  final String wireValue;

  static DsnMandateTemplateCode parse(String value) => values.firstWhere(
        (template) => template.wireValue == value,
        orElse: () => throw DsnMandateApiException(
          'Unsupported Mandate template: $value',
          code: 'MANDATE_TEMPLATE_UNSUPPORTED',
        ),
      );
}

enum DsnMandateSubjectRole {
  buyer('BUYER'),
  provider('PROVIDER');

  const DsnMandateSubjectRole(this.wireValue);

  final String wireValue;

  static DsnMandateSubjectRole parse(String value) => values.firstWhere(
        (role) => role.wireValue == value,
        orElse: () => throw DsnMandateApiException(
          'Unsupported Mandate subject role: $value',
          code: 'MANDATE_SCOPE_INVALID',
        ),
      );
}

enum DsnMandateState {
  active('ACTIVE'),
  revoked('REVOKED'),
  expired('EXPIRED'),
  exhausted('EXHAUSTED');

  const DsnMandateState(this.wireValue);

  final String wireValue;

  static DsnMandateState parse(String value) => values.firstWhere(
        (state) => state.wireValue == value,
        orElse: () => throw DsnMandateApiException(
          'Unsupported Mandate state: $value',
          code: 'MANDATE_STATE_INVALID',
        ),
      );
}

class DsnMandateApiException implements Exception {
  const DsnMandateApiException(this.message, {this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() => message;
}

/// The complete, closed preview payload. No arbitrary scope JSON is accepted.
class DsnMandatePreviewInput {
  const DsnMandatePreviewInput({
    required this.templateCode,
    required this.resourceRef,
  });

  final DsnMandateTemplateCode templateCode;
  final String resourceRef;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'templateCode': templateCode.wireValue,
        'resourceRef': resourceRef.trim(),
      };
}

/// One short-lived, Member-issued context binding used to create a preview.
///
/// It intentionally contains neither the subject role nor a Client/session
/// tuple. Those facts remain on the server and are re-derived from the bound
/// request or task before a preview is created.
class DsnMandateResourceBinding {
  const DsnMandateResourceBinding({
    required this.resourceRef,
    required this.expiresAt,
    required this.resourceHash,
    required this.allowedTemplateCodes,
  });

  final String resourceRef;
  final DateTime expiresAt;
  final String resourceHash;
  final List<DsnMandateTemplateCode> allowedTemplateCodes;
}

/// Server-derived facts that must be reviewed before confirming a Mandate.
class DsnMandateReviewCard {
  const DsnMandateReviewCard({
    required this.capability,
    required this.provider,
    required this.buyer,
    required this.variant,
    required this.quantity,
    required this.capacity,
    required this.sla,
    required this.currency,
    required this.amountMinor,
    required this.quoteHash,
    required this.maxDeliverySeconds,
  });

  final String capability;
  final String provider;
  final String buyer;
  final String variant;
  final int quantity;
  final int capacity;
  final Map<String, dynamic> sla;
  final String currency;
  final int amountMinor;
  final String quoteHash;
  final int maxDeliverySeconds;
}

class DsnMandatePreview {
  const DsnMandatePreview({
    required this.previewId,
    required this.templateCode,
    required this.templateVersion,
    required this.subjectRole,
    required this.agentClientId,
    required this.resourceRef,
    required this.previewHash,
    required this.allowedActionClasses,
    required this.review,
    required this.approvalRef,
    required this.reviewHash,
    required this.expiresAt,
    required this.state,
  });

  final String previewId;
  final DsnMandateTemplateCode templateCode;
  final int templateVersion;
  final DsnMandateSubjectRole subjectRole;
  final String? agentClientId;
  final String? resourceRef;
  final String previewHash;

  /// Server-derived action classes. The App displays these but never creates
  /// an action/scope list of its own.
  final List<String> allowedActionClasses;
  final DsnMandateReviewCard review;

  /// One-time, Principal-bound confirmation reference. This lives only in the
  /// in-memory review object and is never copied into [DsnMandate].
  final String approvalRef;
  final String reviewHash;
  final DateTime expiresAt;
  final String state;
}

/// Principal-safe Mandate projection. No `approvalRef` is ever part of this
/// created/list/detail/revoke projection.
class DsnMandate {
  const DsnMandate({
    required this.mandateId,
    required this.templateCode,
    required this.templateVersion,
    required this.subjectRole,
    required this.agentClientId,
    required this.mandateVersion,
    required this.mandateHash,
    required this.state,
    this.revokedAt,
  });

  final String mandateId;
  final DsnMandateTemplateCode templateCode;
  final int templateVersion;
  final DsnMandateSubjectRole subjectRole;
  final String? agentClientId;
  final int mandateVersion;
  final String mandateHash;
  final DsnMandateState state;
  final DateTime? revokedAt;
}
