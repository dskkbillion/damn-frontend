import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../domain/dsn_provider_models.dart';

/// Errors returned by the canonical human Provider DS 0.1 adapter.
class DsnProviderApiException implements Exception {
  const DsnProviderApiException(this.message, {this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Canonical human Provider boundary for ProviderOffer, ProviderAcceptance
/// and append-only Delivery writes.
///
/// The authenticated member session is added by the app's normal Dio
/// interceptor. No identity, role, grant or task selector is accepted in a
/// write body; those facts are server-derived from the assigned task.
abstract class DsnProviderRepository {
  Future<DsnProviderOfferResult> submitOffer(
    int requestId, {
    required DsnProviderOfferInput offer,
    required int ifMatchVersion,
    required String idempotencyKey,
  });

  Future<DsnProviderAcceptanceResult> submitAcceptance(
    int requestId, {
    required DsnProviderAcceptanceInput acceptance,
    required int ifMatchVersion,
    required String idempotencyKey,
  });

  Future<DsnDeliveryResult> submitDelivery(
    String orderId, {
    required DsnDeliveryInput delivery,
    required int ifMatchVersion,
    required String idempotencyKey,
  });
}

class DioDsnProviderRepository implements DsnProviderRepository {
  DioDsnProviderRepository(this.dio, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final Dio dio;
  final Uuid _uuid;

  @override
  Future<DsnProviderOfferResult> submitOffer(
    int requestId, {
    required DsnProviderOfferInput offer,
    required int ifMatchVersion,
    required String idempotencyKey,
  }) async {
    _validateRequestId(requestId);
    _validatePreconditions(ifMatchVersion, idempotencyKey);
    final body = await _machine(
      () => dio.post(
        '/provider/v1/requests/$requestId/offers',
        options: _options(ifMatchVersion, idempotencyKey, 'offer'),
        data: offer.toJson(),
      ),
      expectedStates: const {'PROVIDER_OFFERED'},
    );
    return _parseOffer(body);
  }

  @override
  Future<DsnProviderAcceptanceResult> submitAcceptance(
    int requestId, {
    required DsnProviderAcceptanceInput acceptance,
    required int ifMatchVersion,
    required String idempotencyKey,
  }) async {
    _validateRequestId(requestId);
    _validatePreconditions(ifMatchVersion, idempotencyKey);
    final body = await _machine(
      () => dio.post(
        '/provider/v1/requests/$requestId/acceptances',
        options: _options(ifMatchVersion, idempotencyKey, 'acceptance'),
        data: acceptance.toJson(),
      ),
      expectedStates: const {'PROVIDER_ACCEPTED', 'PROVIDER_REJECTED'},
    );
    return _parseAcceptance(body);
  }

  @override
  Future<DsnDeliveryResult> submitDelivery(
    String orderId, {
    required DsnDeliveryInput delivery,
    required int ifMatchVersion,
    required String idempotencyKey,
  }) async {
    if (orderId.trim().isEmpty) {
      throw const DsnProviderApiException('Order ID is required');
    }
    _validatePreconditions(ifMatchVersion, idempotencyKey);
    final body = await _machine(
      () => dio.post(
        '/provider/v1/orders/${Uri.encodeComponent(orderId)}/deliveries',
        options: _options(ifMatchVersion, idempotencyKey, 'delivery'),
        data: delivery.toJson(),
      ),
      expectedStates: const {'DELIVERY_SUBMITTED'},
    );
    return _parseDelivery(body);
  }

  Options _options(int ifMatchVersion, String idempotencyKey, String action) {
    return Options(headers: <String, dynamic>{
      'Idempotency-Key': idempotencyKey,
      'If-Match': '"$ifMatchVersion"',
      // A trace is per HTTP operation; the idempotency key remains the stable
      // logical-operation key used when the same call is retried.
      'X-Operation-Trace-Id': 'trace-provider-$action-${_uuid.v4()}',
    });
  }

  Future<Map<String, dynamic>> _machine(
    Future<Response<dynamic>> Function() operation, {
    required Set<String> expectedStates,
  }) async {
    try {
      final response = await operation();
      final raw = response.data;
      if (raw is! Map) {
        throw const DsnProviderApiException('Invalid DS 0.1 response');
      }
      final body = Map<String, dynamic>.from(raw);
      final metadata = _parseMetadata(body);
      if (!expectedStates.contains(metadata.state)) {
        throw DsnProviderApiException(
          'Unexpected DS 0.1 state: ${metadata.state}',
          code: 'UNEXPECTED_STATE',
        );
      }
      return body;
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  DsnProviderOfferResult _parseOffer(Map<String, dynamic> body) {
    final metadata = _parseMetadata(body);
    final data = _map(body['data'], 'ProviderOffer data');
    final offerVersion = _requiredPositiveInt(data, 'offerVersion');
    _requireResourceVersionMatches(
      metadata,
      offerVersion,
      factName: 'offerVersion',
    );
    return DsnProviderOfferResult(
      metadata: metadata,
      offerId: _requiredString(data, 'offerId'),
      providerId: _requiredString(data, 'providerId'),
      offerVersion: offerVersion,
      specHash: _requiredHash(data, 'specHash'),
      quoteHash: _requiredHash(data, 'quoteHash'),
      expiresAt: _optionalDate(data['expiresAt']),
      status: _requiredString(data, 'status'),
      actorType: _optionalString(data['actorType']),
      operationId: _optionalString(data['operationId']),
      operationStatus: _optionalString(data['operationStatus']),
    );
  }

  DsnProviderAcceptanceResult _parseAcceptance(Map<String, dynamic> body) {
    final metadata = _parseMetadata(body);
    final data = _map(body['data'], 'ProviderAcceptance data');
    final offerVersion = _requiredPositiveInt(data, 'offerVersion');
    _requireResourceVersionMatches(
      metadata,
      offerVersion,
      factName: 'offerVersion',
    );
    final wireAcceptance = _requiredString(data, 'acceptance');
    final acceptance = DsnProviderAcceptance.values.firstWhere(
      (value) => value.wireValue == wireAcceptance,
      orElse: () => throw const DsnProviderApiException(
        'Invalid ProviderAcceptance value',
      ),
    );
    return DsnProviderAcceptanceResult(
      metadata: metadata,
      acceptanceId: _requiredString(data, 'acceptanceId'),
      offerId: _requiredString(data, 'offerId'),
      offerVersion: offerVersion,
      specHash: _requiredHash(data, 'specHash'),
      quoteHash: _requiredHash(data, 'quoteHash'),
      acceptance: acceptance,
      actorType: _requiredString(data, 'actorType'),
      operationId: _optionalString(data['operationId']),
      operationStatus: _optionalString(data['operationStatus']),
    );
  }

  DsnDeliveryResult _parseDelivery(Map<String, dynamic> body) {
    final metadata = _parseMetadata(body);
    final data = _map(body['data'], 'Delivery data');
    final commitmentVersion = _requiredPositiveInt(data, 'commitmentVersion');
    _requireResourceVersionMatches(
      metadata,
      commitmentVersion,
      factName: 'commitmentVersion',
    );
    return DsnDeliveryResult(
      metadata: metadata,
      deliveryId: _requiredString(data, 'deliveryId'),
      orderId: _requiredString(data, 'orderId'),
      commitmentId: _requiredString(data, 'commitmentId'),
      commitmentVersion: commitmentVersion,
      submissionNo: _requiredPositiveInt(data, 'submissionNo'),
      supersedesDeliveryId: _optionalString(data['supersedesDeliveryId']),
      evidenceHash: _requiredHash(data, 'evidenceHash'),
      actorType: _requiredString(data, 'actorType'),
      createdAt: _optionalDate(data['createdAt']),
    );
  }

  DsnProviderMachineMetadata _parseMetadata(Map<String, dynamic> body) {
    for (final field in <String>[
      'schemaVersion',
      'state',
      'taskTraceId',
      'operationTraceId',
      'resource',
      'nextActions',
      'data',
    ]) {
      if (!body.containsKey(field) || body[field] == null) {
        throw DsnProviderApiException('DS 0.1 response is missing $field');
      }
    }
    final schemaVersion = _requiredString(body, 'schemaVersion');
    final state = _requiredString(body, 'state');
    final taskTraceId = _requiredString(body, 'taskTraceId');
    final operationTraceId = _requiredString(body, 'operationTraceId');
    final resource = _map(body['resource'], 'resource');
    final nextActions = body['nextActions'];
    if (nextActions is! List) {
      throw const DsnProviderApiException('Invalid DS 0.1 nextActions');
    }
    final resourceId = _requiredString(resource, 'id');
    final resourceVersion = _optionalInt(resource['version']);
    final resourceHash = _optionalHash(resource['hash']);
    return DsnProviderMachineMetadata(
      schemaVersion: schemaVersion,
      state: state,
      taskTraceId: taskTraceId,
      operationTraceId: operationTraceId,
      resourceId: resourceId,
      resourceVersion: resourceVersion,
      resourceHash: resourceHash,
      nextActions: List<dynamic>.unmodifiable(nextActions),
    );
  }

  void _validatePreconditions(int version, String key) {
    // A newly submitted DS request starts at resource version 0.  The
    // provider's first offer therefore legitimately uses If-Match: "0";
    // later facts advance the same server-owned version monotonically.
    if (version < 0) {
      throw const DsnProviderApiException(
        'If-Match version must be non-negative',
      );
    }
    if (key.trim().length < 16 || key.trim().length > 128) {
      throw const DsnProviderApiException(
        'Idempotency-Key must contain 16-128 characters',
      );
    }
  }

  static void _validateRequestId(int requestId) {
    if (requestId < 1) {
      throw const DsnProviderApiException('Request ID must be positive');
    }
  }

  void _requireResourceVersionMatches(
    DsnProviderMachineMetadata metadata,
    int factVersion, {
    required String factName,
  }) {
    final resourceVersion = metadata.resourceVersion;
    if (resourceVersion == null || resourceVersion < 1) {
      throw const DsnProviderApiException(
        'DS 0.1 resource.version is required for Provider write responses',
        code: 'RESOURCE_VERSION_MISSING',
      );
    }
    if (resourceVersion != factVersion) {
      throw DsnProviderApiException(
        'DS 0.1 resource.version does not match $factName',
        code: 'COMMITMENT_VERSION_MISMATCH',
      );
    }
  }
}

/// Explicit Provider Agent identity adapter over the same Provider Core.
///
/// The supplied [agentDio] must be a separately configured client carrying a
/// live Agent session token.  This type is intentionally distinct from
/// [DioDsnProviderRepository], which is used by the Trusted App/member route;
/// callers must never silently pass the App's global Member Dio here.  The
/// request bodies and canonical paths remain identical because actor, Grant,
/// assignment and session provenance are authenticated server facts.
class DioDsnProviderAgentRepository implements DsnProviderRepository {
  DioDsnProviderAgentRepository(Dio agentDio, {Uuid? uuid})
      : _delegate = DioDsnProviderRepository(agentDio, uuid: uuid);

  final DioDsnProviderRepository _delegate;

  @override
  Future<DsnProviderOfferResult> submitOffer(
    int requestId, {
    required DsnProviderOfferInput offer,
    required int ifMatchVersion,
    required String idempotencyKey,
  }) async {
    final result = await _delegate.submitOffer(
      requestId,
      offer: offer,
      ifMatchVersion: ifMatchVersion,
      idempotencyKey: idempotencyKey,
    );
    _requireAgentActor(result.actorType);
    return result;
  }

  @override
  Future<DsnProviderAcceptanceResult> submitAcceptance(
    int requestId, {
    required DsnProviderAcceptanceInput acceptance,
    required int ifMatchVersion,
    required String idempotencyKey,
  }) async {
    final result = await _delegate.submitAcceptance(
      requestId,
      acceptance: acceptance,
      ifMatchVersion: ifMatchVersion,
      idempotencyKey: idempotencyKey,
    );
    _requireAgentActor(result.actorType);
    return result;
  }

  @override
  Future<DsnDeliveryResult> submitDelivery(
    String orderId, {
    required DsnDeliveryInput delivery,
    required int ifMatchVersion,
    required String idempotencyKey,
  }) async {
    final result = await _delegate.submitDelivery(
      orderId,
      delivery: delivery,
      ifMatchVersion: ifMatchVersion,
      idempotencyKey: idempotencyKey,
    );
    _requireAgentActor(result.actorType);
    return result;
  }

  void _requireAgentActor(String? actorType) {
    if (actorType != 'AGENT') {
      throw const DsnProviderApiException(
        'Provider Agent response is missing actorType=AGENT',
        code: 'PROVIDER_AGENT_ACTOR_MISMATCH',
      );
    }
  }
}

Map<String, dynamic> _map(dynamic value, String label) {
  if (value is! Map) throw DsnProviderApiException('Invalid $label');
  return Map<String, dynamic>.from(value);
}

String _requiredString(Map<String, dynamic> map, String field) {
  final value = map[field];
  if (value is! String || value.trim().isEmpty) {
    throw DsnProviderApiException('Missing DS 0.1 field: $field');
  }
  return value.trim();
}

String? _optionalString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

int _requiredPositiveInt(Map<String, dynamic> map, String field) {
  final value = _optionalInt(map[field]);
  if (value == null || value < 1) {
    throw DsnProviderApiException('Invalid DS 0.1 field: $field');
  }
  return value;
}

int? _optionalInt(dynamic value) {
  if (value is num && value == value.truncateToDouble()) return value.toInt();
  if (value is String && RegExp(r'^(0|[1-9][0-9]*)$').hasMatch(value.trim())) {
    return int.tryParse(value.trim());
  }
  return null;
}

String _requiredHash(Map<String, dynamic> map, String field) {
  final value = _requiredString(map, field);
  if (!RegExp(r'^sha256:[a-f0-9]{64}$').hasMatch(value)) {
    throw DsnProviderApiException('Invalid DS 0.1 hash: $field');
  }
  return value;
}

String? _optionalHash(dynamic value) {
  if (value == null) return null;
  if (value is! String || !RegExp(r'^sha256:[a-f0-9]{64}$').hasMatch(value)) {
    throw const DsnProviderApiException('Invalid DS 0.1 resource hash');
  }
  return value;
}

DateTime? _optionalDate(dynamic value) {
  if (value == null) return null;
  if (value is! String) {
    throw const DsnProviderApiException('Invalid DS 0.1 date');
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    throw const DsnProviderApiException('Invalid DS 0.1 date');
  }
  return parsed;
}

DsnProviderApiException _mapError(DioException error) {
  final body = error.response?.data;
  if (body is Map) {
    final machineError = body['error'];
    if (machineError is Map) {
      return DsnProviderApiException(
        machineError['message']?.toString() ?? 'DS 0.1 request failed',
        code: machineError['code']?.toString(),
        statusCode: error.response?.statusCode,
      );
    }
    return DsnProviderApiException(
      body['msg']?.toString() ?? 'DS 0.1 request failed',
      code: body['errorCode']?.toString(),
      statusCode: error.response?.statusCode,
    );
  }
  return DsnProviderApiException(
    error.message ?? 'Network request failed',
    statusCode: error.response?.statusCode,
  );
}
