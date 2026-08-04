import 'dsn_provider_models.dart';

/// Server-owned Provider Task Center read facts.
///
/// The Provider Task Center deliberately consumes a separate read projection;
/// it must not reinterpret the buyer's `/api/agent-requests` list as provider
/// work.  The canonical read endpoint returns this server-owned shape.
class DsnProviderTask {
  const DsnProviderTask({
    required this.requestId,
    required this.version,
    required this.taskTraceId,
    required this.specHash,
    required this.title,
    required this.brief,
    required this.status,
    this.offer,
    this.commitment,
    this.taskLifecycle,
    this.responsibilityAction,
    this.waitingOn,
    this.nextActions = const <dynamic>[],
  });

  final int requestId;
  final int version;
  final String taskTraceId;
  final String specHash;
  final String title;
  final String brief;
  final String status;
  final DsnProviderOfferSnapshot? offer;
  final DsnProviderCommitmentSnapshot? commitment;
  final String? taskLifecycle;
  final String? responsibilityAction;
  final String? waitingOn;
  final List<dynamic> nextActions;

  DsnProviderTask copyWith({
    int? version,
    String? status,
    DsnProviderOfferSnapshot? offer,
    DsnProviderCommitmentSnapshot? commitment,
  }) {
    return DsnProviderTask(
      requestId: requestId,
      version: version ?? this.version,
      taskTraceId: taskTraceId,
      specHash: specHash,
      title: title,
      brief: brief,
      status: status ?? this.status,
      offer: offer ?? this.offer,
      commitment: commitment ?? this.commitment,
      taskLifecycle: taskLifecycle,
      responsibilityAction: responsibilityAction,
      waitingOn: waitingOn,
      nextActions: nextActions,
    );
  }

  factory DsnProviderTask.fromJson(Map<String, dynamic> json) {
    final offerValue = json['offer'];
    final acceptanceValue = json['acceptance'];
    final normalizedOffer = offerValue is Map
        ? <String, dynamic>{
            ...Map<String, dynamic>.from(offerValue),
            if (acceptanceValue != null) 'acceptance': acceptanceValue,
          }
        : offerValue;
    return DsnProviderTask(
      requestId: _positiveInt(json, 'requestId'),
      version: _nonNegativeInt(json, 'version'),
      taskTraceId: _requiredString(json, 'taskTraceId'),
      specHash: _requiredHash(json, 'specHash'),
      title: _requiredString(json, 'title'),
      brief: _requiredString(json, 'brief'),
      status: _requiredString(json, 'status'),
      offer: _optionalMap(normalizedOffer, 'offer', DsnProviderOfferSnapshot.fromJson),
      commitment: _optionalMap(
        json['commitment'],
        'commitment',
        DsnProviderCommitmentSnapshot.fromJson,
      ),
      taskLifecycle: _optionalString(json['state']),
      responsibilityAction: _optionalString(json['responsibilityAction']),
      waitingOn: _optionalString(json['waitingOn']),
      nextActions: json['nextActions'] is List
          ? List<dynamic>.unmodifiable(json['nextActions'] as List)
          : const <dynamic>[],
    );
  }

  /// Parses the canonical detail envelope.  The request, offer and
  /// acceptance are deliberately kept under `data`; no client identity is
  /// inferred from a route or copied into the model.
  factory DsnProviderTask.fromDetailEnvelope(Map<String, dynamic> json) {
    _expectProtocol(json);
    final data = _map(json['data'], 'data');
    final request = _map(data['request'], 'request');
    final offerValue = data['offer'];
    final acceptanceValue = data['acceptance'];
    final offer = offerValue == null
        ? null
        : DsnProviderOfferSnapshot.fromJson(<String, dynamic>{
            ...Map<String, dynamic>.from(offerValue as Map),
            if (acceptanceValue != null)
              'acceptance': acceptanceValue,
          });
    final commitmentValue = data['commitment'];
    final task = _map(json['task'], 'task');
    final taskTraceId = _requiredString(json, 'taskTraceId');
    return DsnProviderTask(
      requestId: _positiveInt(<String, dynamic>{'requestId': request['id']}, 'requestId'),
      version: _nonNegativeInt(<String, dynamic>{'version': request['version']}, 'version'),
      taskTraceId: taskTraceId,
      specHash: _requiredHash(<String, dynamic>{
        'specHash': request['specHash'] ?? offer?.specHash,
      }, 'specHash'),
      title: _requiredString(request, 'title'),
      brief: _requiredString(request, 'brief'),
      status: _requiredString(request, 'status'),
      offer: offer,
      commitment: commitmentValue == null
          ? null
          : DsnProviderCommitmentSnapshot.fromJson(
              Map<String, dynamic>.from(commitmentValue as Map)),
      taskLifecycle: _optionalString(task['taskLifecycle']),
      responsibilityAction: _optionalString(task['responsibilityAction']),
      waitingOn: _optionalString(task['waitingOn']),
      nextActions: task['nextActions'] is List
          ? List<dynamic>.unmodifiable(task['nextActions'] as List)
          : const <dynamic>[],
    );
  }
}

/// A read-only view of the current ProviderOffer and its acceptance facts.
class DsnProviderOfferSnapshot {
  const DsnProviderOfferSnapshot({
    required this.offerId,
    required this.offerVersion,
    required this.specHash,
    required this.quoteHash,
    required this.capabilityId,
    required this.variantId,
    required this.quantity,
    required this.amountMinor,
    required this.currency,
    required this.status,
    this.expiresAt,
    this.acceptance,
  });

  final String offerId;
  final int offerVersion;
  final String specHash;
  final String quoteHash;
  final String capabilityId;
  final String variantId;
  final int quantity;
  final int amountMinor;
  final String currency;
  final String status;
  final DateTime? expiresAt;
  final DsnProviderAcceptance? acceptance;

  factory DsnProviderOfferSnapshot.fromJson(Map<String, dynamic> json) {
    final acceptanceValue = json['acceptance'];
    return DsnProviderOfferSnapshot(
      offerId: _requiredString(json, 'offerId'),
      offerVersion: _positiveInt(json, 'offerVersion'),
      specHash: _requiredHash(json, 'specHash'),
      quoteHash: _requiredHash(json, 'quoteHash'),
      capabilityId: _requiredString(json, 'capabilityId'),
      variantId: _requiredString(json, 'variantId'),
      quantity: _positiveInt(json, 'quantity'),
      amountMinor: _nonNegativeInt(json, 'amountMinor'),
      currency: _requiredString(json, 'currency'),
      status: _requiredString(json, 'status'),
      expiresAt: _optionalDate(json['expiresAt']),
      acceptance: acceptanceValue == null
          ? null
          : _parseAcceptance(acceptanceValue),
    );
  }
}

/// The delivery context is exposed only after the server has a Commitment.
/// It is intentionally opaque beyond the facts needed to append evidence.
class DsnProviderCommitmentSnapshot {
  const DsnProviderCommitmentSnapshot({
    required this.orderId,
    required this.commitmentId,
    required this.commitmentVersion,
    required this.commitmentHash,
    required this.nextSubmissionNo,
  });

  final String orderId;
  final String commitmentId;
  final int commitmentVersion;
  final String commitmentHash;
  final int nextSubmissionNo;

  factory DsnProviderCommitmentSnapshot.fromJson(Map<String, dynamic> json) {
    return DsnProviderCommitmentSnapshot(
      orderId: _requiredString(json, 'orderId'),
      commitmentId: _requiredString(json, 'commitmentId'),
      commitmentVersion: _positiveInt(json, 'commitmentVersion'),
      commitmentHash: _requiredHash(json, 'commitmentHash'),
      nextSubmissionNo: _positiveInt(json, 'nextSubmissionNo'),
    );
  }
}

class DsnProviderTaskPage {
  const DsnProviderTaskPage({
    required this.tasks,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<DsnProviderTask> tasks;
  final String? nextCursor;
  final bool hasMore;

  factory DsnProviderTaskPage.fromJson(Map<String, dynamic> json) {
    _expectProtocol(json);
    if (json['state'] != 'PROVIDER_TASKS_LISTED') {
      throw const DsnProviderTaskFormatException('Provider task collection state is not canonical');
    }
    final data = _map(json['data'], 'data');
    final rawTasks = data['tasks'];
    if (rawTasks is! List) {
      throw const DsnProviderTaskFormatException(
        'Provider task collection must contain data.tasks',
      );
    }
    return DsnProviderTaskPage(
      tasks: List<DsnProviderTask>.unmodifiable(
        rawTasks.map((value) {
          if (value is! Map) {
            throw const DsnProviderTaskFormatException(
              'Provider task must be an object',
            );
          }
          return DsnProviderTask.fromJson(Map<String, dynamic>.from(value));
        }),
      ),
      nextCursor: _optionalString(data['nextCursor']),
      hasMore: data['hasMore'] == true,
    );
  }

  factory DsnProviderTaskPage.singleFromJson(Map<String, dynamic> json) {
    final task = DsnProviderTask.fromDetailEnvelope(json);
    return DsnProviderTaskPage(
      tasks: <DsnProviderTask>[task],
    );
  }
}

class DsnProviderTaskFormatException implements Exception {
  const DsnProviderTaskFormatException(this.message);
  final String message;

  @override
  String toString() => message;
}

void _expectProtocol(Map<String, dynamic> json) {
  if (json['protocolVersion'] != 'dasn/0.1' ||
      json['dsVersion'] != 'DS 0.1' ||
      json['schemaVersion'] != '0.1' ||
      _requiredString(json, 'taskTraceId').isEmpty ||
      _requiredString(json, 'operationTraceId').isEmpty) {
    throw const DsnProviderTaskFormatException(
      'Provider task response is not a DS 0.1 machine envelope',
    );
  }
}

T? _optionalMap<T>(
  dynamic value,
  String field,
  T Function(Map<String, dynamic>) parse,
) {
  if (value == null) return null;
  if (value is! Map) {
    throw DsnProviderTaskFormatException('Provider task $field is invalid');
  }
  return parse(Map<String, dynamic>.from(value));
}

Map<String, dynamic> _map(dynamic value, String field) {
  if (value is! Map) {
    throw DsnProviderTaskFormatException('Provider task $field is invalid');
  }
  return Map<String, dynamic>.from(value);
}

String _requiredString(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is! String || value.trim().isEmpty) {
    throw DsnProviderTaskFormatException('Provider task field $field is required');
  }
  return value.trim();
}

String? _optionalString(dynamic value) {
  if (value == null) return null;
  final result = value.toString().trim();
  return result.isEmpty ? null : result;
}

int _positiveInt(Map<String, dynamic> json, String field) {
  final value = _integer(json[field]);
  if (value == null || value < 1) {
    throw DsnProviderTaskFormatException('Provider task field $field is invalid');
  }
  return value;
}

int _nonNegativeInt(Map<String, dynamic> json, String field) {
  final value = _integer(json[field]);
  if (value == null || value < 0) {
    throw DsnProviderTaskFormatException('Provider task field $field is invalid');
  }
  return value;
}

int? _integer(dynamic value) {
  if (value is num && value == value.truncateToDouble()) return value.toInt();
  if (value is String && RegExp(r'^(0|[1-9][0-9]*)$').hasMatch(value.trim())) {
    return int.tryParse(value.trim());
  }
  return null;
}

String _requiredHash(Map<String, dynamic> json, String field) {
  final value = _requiredString(json, field);
  if (!RegExp(r'^sha256:[a-f0-9]{64}$').hasMatch(value)) {
    throw DsnProviderTaskFormatException('Provider task hash $field is invalid');
  }
  return value;
}

DateTime? _optionalDate(dynamic value) {
  if (value == null) return null;
  if (value is! String) {
    throw const DsnProviderTaskFormatException('Provider task date is invalid');
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    throw const DsnProviderTaskFormatException('Provider task date is invalid');
  }
  return parsed;
}

DsnProviderAcceptance _parseAcceptance(dynamic value) {
  final raw = value is Map ? value['acceptance'] : value;
  final normalized = raw.toString().trim().toUpperCase();
  for (final item in DsnProviderAcceptance.values) {
    if (item.wireValue == normalized) return item;
  }
  throw const DsnProviderTaskFormatException('Provider acceptance is invalid');
}
