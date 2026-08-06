import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:uuid/uuid.dart';

import '../domain/dsn_provider_models.dart';

/// Errors returned by the canonical human Provider DS 0.2 adapter.
class DsnProviderApiException implements Exception {
  const DsnProviderApiException(this.message, {this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Canonical human Provider boundary for ProviderOffer, ProviderAcceptance,
/// server-owned artifact upload and append-only Delivery writes.
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

  Future<DsnArtifactUploadSlotResult> issueArtifactUploadSlots(
    String orderId, {
    required DsnArtifactUploadSlotInput input,
    required int ifMatchVersion,
    required String idempotencyKey,
  });

  Future<DsnArtifactUploadResult> uploadArtifact(
    String orderId, {
    required String uploadRef,
    required DsnArtifactUploadSource source,
    required String commitmentHash,
    required int submissionNo,
    required int ifMatchVersion,
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

  @override
  Future<DsnArtifactUploadSlotResult> issueArtifactUploadSlots(
    String orderId, {
    required DsnArtifactUploadSlotInput input,
    required int ifMatchVersion,
    required String idempotencyKey,
  }) async {
    _validateOrderId(orderId);
    _validatePreconditions(ifMatchVersion, idempotencyKey);
    final body = await _machine(
      () => dio.post(
        '/provider/v1/orders/${Uri.encodeComponent(orderId)}/artifact-upload-slots',
        options: _options(ifMatchVersion, idempotencyKey, 'upload-slots'),
        data: input.toJson(),
      ),
      expectedStates: const {'ARTIFACT_UPLOAD_SLOTS_ISSUED'},
    );
    return _parseUploadSlots(body, expectedVersion: ifMatchVersion);
  }

  @override
  Future<DsnArtifactUploadResult> uploadArtifact(
    String orderId, {
    required String uploadRef,
    required DsnArtifactUploadSource source,
    required String commitmentHash,
    required int submissionNo,
    required int ifMatchVersion,
  }) async {
    _validateOrderId(orderId);
    _validateIfMatchVersion(ifMatchVersion);
    _requireHash(commitmentHash, 'commitmentHash');
    final normalizedUploadRef = uploadRef.trim();
    if (!RegExp(r'^upl_[A-Za-z0-9]+$').hasMatch(normalizedUploadRef)) {
      throw const DsnProviderApiException(
        'uploadRef must be a server-issued opaque handle',
        code: 'INVALID_UPLOAD_REF',
      );
    }
    if (submissionNo < 1) {
      throw const DsnProviderApiException(
        'submissionNo must be positive',
        code: 'INVALID_SUBMISSION_NO',
      );
    }
    if (source.size < 1) {
      throw const DsnProviderApiException(
        'Artifact size must be positive',
        code: 'INVALID_ARTIFACT_SIZE',
      );
    }
    if (source.bytes != null && source.bytes!.length != source.size) {
      throw const DsnProviderApiException(
        'Artifact source size does not match its bytes',
        code: 'INVALID_ARTIFACT_SIZE',
      );
    }
    final multipart = await _multipart(source);
    final body = await _machine(
      () => dio.put(
        '/provider/v1/orders/${Uri.encodeComponent(orderId)}/artifact-upload-slots/${Uri.encodeComponent(normalizedUploadRef)}',
        options: Options(headers: <String, dynamic>{
          'If-Match': '"$ifMatchVersion"',
          'X-Commitment-Hash': commitmentHash,
          'X-Submission-No': '$submissionNo',
          'X-Operation-Trace-Id': 'trace-provider-upload-${_uuid.v4()}',
        }),
        data: FormData.fromMap(<String, dynamic>{'file': multipart}),
      ),
      expectedStates: const {'ARTIFACT_UPLOADED'},
    );
    return _parseUpload(body, expectedUploadRef: normalizedUploadRef);
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

  DsnArtifactUploadSlotResult _parseUploadSlots(
    Map<String, dynamic> body, {
    required int expectedVersion,
  }) {
    final metadata = _parseMetadata(body);
    if (metadata.resourceVersion != expectedVersion) {
      throw const DsnProviderApiException(
        'Artifact upload slot response version does not match If-Match',
        code: 'COMMITMENT_VERSION_MISMATCH',
      );
    }
    final data = _map(body['data'], 'Artifact upload slot data');
    final submissionNo = _requiredPositiveInt(data, 'submissionNo');
    final rawItems = data['items'];
    if (rawItems is! List || rawItems.isEmpty) {
      throw const DsnProviderApiException(
        'Artifact upload slot response must contain items',
        code: 'INVALID_UPLOAD_SLOT_RESPONSE',
      );
    }
    final items = <DsnArtifactUploadSlot>[];
    for (final value in rawItems) {
      final item = _map(value, 'Artifact upload slot item');
      final uploadRef = _requiredString(item, 'uploadRef');
      if (!RegExp(r'^upl_[A-Za-z0-9]+$').hasMatch(uploadRef)) {
        throw const DsnProviderApiException(
          'Artifact upload slot uploadRef is invalid',
          code: 'INVALID_UPLOAD_REF',
        );
      }
      final expiresAt = _requiredDate(item['expiresAt'], 'expiresAt');
      final maxBytes = _optionalInt(item['maxBytes']);
      if (maxBytes == null || maxBytes < 1) {
        throw const DsnProviderApiException(
          'Artifact upload slot maxBytes is invalid',
          code: 'INVALID_UPLOAD_SLOT_RESPONSE',
        );
      }
      items.add(DsnArtifactUploadSlot(
        uploadRef: uploadRef,
        expiresAt: expiresAt,
        maxBytes: maxBytes,
      ));
    }
    return DsnArtifactUploadSlotResult(
      metadata: metadata,
      submissionNo: submissionNo,
      items: List<DsnArtifactUploadSlot>.unmodifiable(items),
    );
  }

  DsnArtifactUploadResult _parseUpload(
    Map<String, dynamic> body, {
    required String expectedUploadRef,
  }) {
    final metadata = _parseMetadata(body);
    if (metadata.resourceVersion == null || metadata.resourceVersion! < 1) {
      throw const DsnProviderApiException(
        'Artifact upload response resource.version is required',
        code: 'RESOURCE_VERSION_MISSING',
      );
    }
    final data = _map(body['data'], 'Artifact upload data');
    final status = _requiredString(data, 'status');
    if (status != 'UPLOADED') {
      throw DsnProviderApiException(
        'Unexpected artifact upload status: $status',
        code: 'UNEXPECTED_UPLOAD_STATUS',
      );
    }
    final uploadRef = _requiredString(data, 'uploadRef');
    if (uploadRef != expectedUploadRef ||
        !RegExp(r'^upl_[A-Za-z0-9]+$').hasMatch(uploadRef)) {
      throw const DsnProviderApiException(
        'Artifact upload response uploadRef does not match the request',
        code: 'UPLOAD_REF_LINEAGE_CONFLICT',
      );
    }
    return DsnArtifactUploadResult(
      metadata: metadata,
      uploadRef: uploadRef,
      status: status,
      sha256: _requiredHash(data, 'sha256'),
      size: _requiredPositiveInt(data, 'size'),
      mimeType: _requiredString(data, 'mimeType'),
    );
  }

  Future<MultipartFile> _multipart(DsnArtifactUploadSource source) async {
    final mediaType = _mediaType(source.mimeType);
    if (source.bytes != null) {
      return MultipartFile.fromBytes(
        source.bytes!,
        filename: source.fileName,
        contentType: mediaType,
      );
    }
    final path = source.path;
    if (path == null || path.trim().isEmpty) {
      throw const DsnProviderApiException(
        'Artifact source has no bytes or file path',
        code: 'INVALID_ARTIFACT_SOURCE',
      );
    }
    return MultipartFile.fromFile(
      path,
      filename: source.fileName,
      contentType: mediaType,
    );
  }

  MediaType? _mediaType(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return null;
    try {
      return MediaType.parse(normalized);
    } on FormatException {
      throw const DsnProviderApiException(
        'Artifact MIME type is invalid',
        code: 'INVALID_ARTIFACT_MIME_TYPE',
      );
    }
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
    _validateIfMatchVersion(version);
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

  static void _validateOrderId(String orderId) {
    if (orderId.trim().isEmpty) {
      throw const DsnProviderApiException('Order ID is required');
    }
  }

  static void _validateIfMatchVersion(int version) {
    if (version < 0) {
      throw const DsnProviderApiException(
        'If-Match version must be non-negative',
      );
    }
  }

  static void _requireHash(String value, String field) {
    if (!RegExp(r'^sha256:[a-f0-9]{64}$').hasMatch(value.trim())) {
      throw DsnProviderApiException(
        '$field must be sha256:<64 lowercase hex>',
        code: 'INVALID_HASH',
      );
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

  @override
  Future<DsnArtifactUploadSlotResult> issueArtifactUploadSlots(
    String orderId, {
    required DsnArtifactUploadSlotInput input,
    required int ifMatchVersion,
    required String idempotencyKey,
  }) =>
      _delegate.issueArtifactUploadSlots(
        orderId,
        input: input,
        ifMatchVersion: ifMatchVersion,
        idempotencyKey: idempotencyKey,
      );

  @override
  Future<DsnArtifactUploadResult> uploadArtifact(
    String orderId, {
    required String uploadRef,
    required DsnArtifactUploadSource source,
    required String commitmentHash,
    required int submissionNo,
    required int ifMatchVersion,
  }) async {
    final result = await _delegate.uploadArtifact(
      orderId,
      uploadRef: uploadRef,
      source: source,
      commitmentHash: commitmentHash,
      submissionNo: submissionNo,
      ifMatchVersion: ifMatchVersion,
    );
    // Upload responses do not carry a business actorType; the Agent Dio
    // instance is the identity boundary for the binary write.
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

DateTime _requiredDate(dynamic value, String field) {
  final parsed = _optionalDate(value);
  if (parsed == null) {
    throw DsnProviderApiException('Missing DS 0.2 field: $field');
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
