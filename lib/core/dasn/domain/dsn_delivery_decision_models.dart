import 'dasn_task_view.dart';

/// The only buyer decisions exposed by the DS 0.1 App boundary.
enum DsnDeliveryDecisionAction {
  accept('ACCEPT', 'DELIVERY_ACCEPTED'),
  requestRevision('REQUEST_REVISION', 'REVISION_REQUESTED'),
  openDispute('OPEN_DISPUTE', 'DISPUTE_OPENED');

  const DsnDeliveryDecisionAction(this.wireValue, this.responseState);

  final String wireValue;
  final String responseState;

  static DsnDeliveryDecisionAction? fromWire(String? value) {
    for (final action in values) {
      if (action.wireValue == value) return action;
    }
    return null;
  }
}

/// Server-derived delivery facts used to construct a buyer decision.
///
/// A missing or malformed append-only projection returns `null`, which means
/// the UI must not guess from legacy OrderDelivery rows or render a write
/// control. The server remains authoritative when the decision is submitted.
class DsnCurrentDeliveryFact {
  const DsnCurrentDeliveryFact({
    required this.orderId,
    required this.deliveryId,
    required this.commitmentVersion,
    required this.submissionNo,
    required this.evidenceHash,
    required this.paymentCaptured,
    required this.disputeOpen,
    required this.finalDecision,
  });

  final int orderId;
  final String deliveryId;
  final int commitmentVersion;
  final int submissionNo;
  final String? evidenceHash;
  final bool paymentCaptured;
  final bool disputeOpen;
  final DsnDeliveryDecisionAction? finalDecision;

  bool get alreadyAccepted => finalDecision == DsnDeliveryDecisionAction.accept;

  /// The server rejects acceptance during a dispute and after acceptance.
  /// Keep the controls hidden in those terminal/frozen states instead of
  /// showing buttons that are guaranteed to fail.
  bool get decisionAvailable =>
      paymentCaptured && !disputeOpen && !alreadyAccepted;

  static DsnCurrentDeliveryFact? fromTaskView(DasnTaskView view) {
    final receipt = view.receipt;
    if (receipt == null || receipt['source'] != 'DSN_APPEND_ONLY') return null;
    final orderId = _positiveInt(receipt['orderId']);
    final commitmentVersion = _positiveInt(receipt['commitmentVersion']);
    final rawEvidence = receipt['latestEvidence'];
    if (orderId == null || commitmentVersion == null || rawEvidence is! Map) {
      return null;
    }
    final evidence = Map<String, dynamic>.from(rawEvidence);
    final deliveryId = _nonEmptyString(evidence['deliveryId']);
    final evidenceVersion = _positiveInt(evidence['commitmentVersion']);
    final submissionNo = _positiveInt(evidence['submissionNo']);
    if (deliveryId == null ||
        evidenceVersion == null ||
        evidenceVersion != commitmentVersion ||
        submissionNo == null) {
      return null;
    }
    final evidenceHash = _optionalHash(evidence['evidenceHash']);
    if (evidence['evidenceHash'] != null && evidenceHash == null) return null;
    final rawDisputeOpen = receipt['disputeOpen'];
    if (rawDisputeOpen != null && rawDisputeOpen is! bool) return null;
    final rawFinalDecision = receipt['finalDecision'];
    DsnDeliveryDecisionAction? finalDecision;
    if (rawFinalDecision != null) {
      if (rawFinalDecision is! Map) return null;
      final decisionMap = Map<String, dynamic>.from(rawFinalDecision);
      final rawAction = _nonEmptyString(decisionMap['action']);
      // A malformed, future, or unknown terminal decision must not be
      // treated as an open control.
      if (rawAction == null) return null;
      finalDecision = DsnDeliveryDecisionAction.fromWire(rawAction);
      if (finalDecision == null) return null;
    }
    return DsnCurrentDeliveryFact(
      orderId: orderId,
      deliveryId: deliveryId,
      commitmentVersion: commitmentVersion,
      submissionNo: submissionNo,
      evidenceHash: evidenceHash,
      paymentCaptured: receipt['fundsDisposition']?.toString() == 'CAPTURED',
      disputeOpen: rawDisputeOpen == true,
      finalDecision: finalDecision,
    );
  }
}

/// Strict request body for POST /app/v1/orders/{id}/acceptance-decisions.
class DsnDeliveryDecisionInput {
  const DsnDeliveryDecisionInput({
    required this.orderId,
    required this.decision,
    required this.deliveryId,
    required this.submissionNo,
    required this.commitmentVersion,
    this.expectedSubmissionHash,
    this.reason,
  });

  /// Server-derived order ID used only in the URL, never in the JSON body.
  final int orderId;
  final DsnDeliveryDecisionAction decision;
  final String deliveryId;
  final int submissionNo;
  final int commitmentVersion;
  final String? expectedSubmissionHash;
  final String? reason;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'decision': decision.wireValue,
        'deliveryId': deliveryId,
        'submissionNo': submissionNo,
        'commitmentVersion': commitmentVersion,
        if (expectedSubmissionHash != null)
          'expectedSubmissionHash': expectedSubmissionHash,
        if (reason != null && reason!.trim().isNotEmpty)
          'reason': reason!.trim(),
      };
}

class DsnDeliveryDecisionResult {
  const DsnDeliveryDecisionResult({
    required this.state,
    required this.taskTraceId,
    required this.operationTraceId,
    required this.decisionId,
    required this.orderId,
    required this.commitmentId,
    required this.commitmentVersion,
    required this.deliveryId,
    required this.submissionNo,
    required this.action,
    required this.actorType,
    this.createdAt,
  });

  final String state;
  final String taskTraceId;
  final String operationTraceId;
  final String decisionId;
  final int orderId;
  final String commitmentId;
  final int commitmentVersion;
  final String deliveryId;
  final int submissionNo;
  final DsnDeliveryDecisionAction action;
  final String actorType;
  final DateTime? createdAt;
}

String? _nonEmptyString(dynamic value) {
  if (value is! String || value.trim().isEmpty) return null;
  return value.trim();
}

int? _positiveInt(dynamic value) {
  if (value is num && value == value.truncateToDouble() && value >= 1) {
    return value.toInt();
  }
  if (value is String && RegExp(r'^[1-9][0-9]*$').hasMatch(value.trim())) {
    return int.tryParse(value.trim());
  }
  return null;
}

String? _optionalHash(dynamic value) {
  if (value == null) return null;
  if (value is String && RegExp(r'^sha256:[a-f0-9]{64}$').hasMatch(value)) {
    return value;
  }
  return null;
}
