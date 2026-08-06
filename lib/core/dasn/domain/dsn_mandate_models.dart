/// DS 0.2 Trusted App Mandate projections.
///
/// These are deliberately *not* Grant models. A Mandate is the small,
/// Principal-visible approval surface; its server-side BoundedGrant derivation
/// and any Agent session credentials never enter the Flutter process.
enum DsnMandateTemplateCode {
  buyerFixedCommitmentV1('BUYER_FIXED_COMMITMENT_V1'),
  providerFixedResponseV1('PROVIDER_FIXED_RESPONSE_V1'),
  providerFixedDeliveryV1('PROVIDER_FIXED_DELIVERY_V1');

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
    required this.agentClientId,
    required this.subjectRole,
    required this.resourceRef,
    this.expectedResourceVersion,
    this.expectedSpecHash,
    this.expectedQuoteHash,
  });

  final DsnMandateTemplateCode templateCode;
  final String agentClientId;
  final DsnMandateSubjectRole subjectRole;
  final String resourceRef;
  final int? expectedResourceVersion;
  final String? expectedSpecHash;
  final String? expectedQuoteHash;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'templateCode': templateCode.wireValue,
        'agentClientId': agentClientId.trim(),
        'subjectRole': subjectRole.wireValue,
        'resourceRef': resourceRef.trim(),
        if (expectedResourceVersion != null)
          'expectedResourceVersion': expectedResourceVersion,
        if (expectedSpecHash != null) 'expectedSpecHash': expectedSpecHash,
        if (expectedQuoteHash != null) 'expectedQuoteHash': expectedQuoteHash,
      };
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
    required this.allowedActions,
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

  /// Server-derived, human-readable action names. The App displays these but
  /// never creates an action/scope list of its own.
  final List<String> allowedActions;

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
