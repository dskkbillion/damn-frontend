import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../domain/dsn_mandate_models.dart';

/// App-only DS 0.2 Mandate boundary.
///
/// The normal Member-authenticated Dio instance is the only transport allowed
/// here. This intentionally has no Agent-authenticated implementation and no
/// parameters for a Grant, scope or session secret.
abstract interface class DsnMandateRepository {
  /// Creates a short-lived opaque binding for a concrete, Member-visible
  /// Provider task. The selected session is issuance audit only.
  Future<DsnMandateResourceBinding> bindProviderTask(
    String taskTraceId, {
    required String agentSessionId,
    required String idempotencyKey,
  });

  /// Creates a short-lived opaque binding for a concrete buyer request with
  /// an accepted offer. The selected session is issuance audit only.
  Future<DsnMandateResourceBinding> bindBuyerRequest(
    int requestId, {
    required String agentSessionId,
    required String idempotencyKey,
  });

  Future<DsnMandatePreview> createPreview(
    DsnMandatePreviewInput input, {
    required String idempotencyKey,
  });

  Future<DsnMandate> confirmPreview(
    String previewId, {
    required String approvalRef,
    required String expectedPreviewHash,
    required String expectedReviewHash,
    required String idempotencyKey,
  });

  Future<List<DsnMandate>> list({DsnMandateState? status});

  Future<DsnMandate> get(String mandateId);

  Future<DsnMandate> revoke(
    DsnMandate mandate, {
    required String idempotencyKey,
  });
}

class DioDsnMandateRepository implements DsnMandateRepository {
  DioDsnMandateRepository(this.dio, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final Dio dio;
  final Uuid _uuid;

  @override
  Future<DsnMandateResourceBinding> bindProviderTask(
    String taskTraceId, {
    required String agentSessionId,
    required String idempotencyKey,
  }) async {
    _requiredText(taskTraceId, 'taskTraceId');
    _requiredText(agentSessionId, 'agentSessionId');
    _validateIdempotencyKey(idempotencyKey);
    final data = await _machine(
      () => dio.post(
        '/app/v1/provider-tasks/${Uri.encodeComponent(taskTraceId.trim())}/mandate-resource-bindings',
        data: <String, dynamic>{'agentSessionId': agentSessionId.trim()},
        options: _writeOptions(idempotencyKey, 'mandate-provider-binding'),
      ),
      expectedStates: null,
    );
    final binding = _parseBinding(data);
    _requireOnlyTemplate(
      binding,
      DsnMandateTemplateCode.providerFixedTaskV1,
    );
    return binding;
  }

  @override
  Future<DsnMandateResourceBinding> bindBuyerRequest(
    int requestId, {
    required String agentSessionId,
    required String idempotencyKey,
  }) async {
    if (requestId < 1) {
      throw const DsnMandateApiException('requestId must be positive');
    }
    _requiredText(agentSessionId, 'agentSessionId');
    _validateIdempotencyKey(idempotencyKey);
    final data = await _machine(
      () => dio.post(
        '/app/v1/requests/$requestId/buyer-mandate-resource-bindings',
        data: <String, dynamic>{'agentSessionId': agentSessionId.trim()},
        options: _writeOptions(idempotencyKey, 'mandate-buyer-binding'),
      ),
      expectedStates: null,
    );
    final binding = _parseBinding(data);
    _requireOnlyTemplate(
      binding,
      DsnMandateTemplateCode.buyerFixedCommitmentV1,
    );
    return binding;
  }

  @override
  Future<DsnMandatePreview> createPreview(
    DsnMandatePreviewInput input, {
    required String idempotencyKey,
  }) async {
    _validatePreview(input, idempotencyKey);
    final data = await _machine(
      () => dio.post(
        '/app/v1/mandates/previews',
        data: input.toJson(),
        options: _writeOptions(idempotencyKey, 'mandate-preview'),
      ),
      expectedStates: const {'MANDATE_PREVIEW_CREATED'},
    );
    return _parsePreview(data);
  }

  @override
  Future<DsnMandate> confirmPreview(
    String previewId, {
    required String approvalRef,
    required String expectedPreviewHash,
    required String expectedReviewHash,
    required String idempotencyKey,
  }) async {
    _requiredText(previewId, 'previewId');
    _requiredText(approvalRef, 'approvalRef');
    _validateHash(expectedPreviewHash, 'expectedPreviewHash');
    _validateHash(expectedReviewHash, 'expectedReviewHash');
    _validateIdempotencyKey(idempotencyKey);
    final data = await _machine(
      () => dio.post(
        '/app/v1/mandates/previews/${Uri.encodeComponent(previewId.trim())}/confirm',
        data: <String, dynamic>{
          'approvalRef': approvalRef.trim(),
          'expectedPreviewHash': expectedPreviewHash.trim(),
          'expectedReviewHash': expectedReviewHash.trim(),
          'decision': 'CONFIRM',
        },
        options: _writeOptions(idempotencyKey, 'mandate-confirm'),
      ),
      expectedStates: const {'MANDATE_CREATED'},
    );
    return _parseMandate(data);
  }

  @override
  Future<List<DsnMandate>> list({DsnMandateState? status}) async {
    final data = await _machine(
      () => dio.get(
        '/app/v1/mandates',
        queryParameters: <String, dynamic>{
          if (status != null) 'status': status.wireValue,
        },
        options: _readOptions('mandate-list'),
      ),
      expectedStates: null,
    );
    final rawItems = data['items'];
    if (rawItems is! List) {
      throw const DsnMandateApiException('Mandate list is missing items');
    }
    return rawItems.map((item) {
      if (item is! Map) {
        throw const DsnMandateApiException('Invalid Mandate list item');
      }
      return _parseMandate(Map<String, dynamic>.from(item));
    }).toList(growable: false);
  }

  @override
  Future<DsnMandate> get(String mandateId) async {
    _requiredText(mandateId, 'mandateId');
    final data = await _machine(
      () => dio.get(
        '/app/v1/mandates/${Uri.encodeComponent(mandateId.trim())}',
        options: _readOptions('mandate-detail'),
      ),
      expectedStates: null,
    );
    return _parseMandate(data);
  }

  @override
  Future<DsnMandate> revoke(
    DsnMandate mandate, {
    required String idempotencyKey,
  }) async {
    _requiredText(mandate.mandateId, 'mandateId');
    if (mandate.mandateVersion < 1) {
      throw const DsnMandateApiException('Mandate version must be positive');
    }
    _validateIdempotencyKey(idempotencyKey);
    final data = await _machine(
      () => dio.post(
        '/app/v1/mandates/${Uri.encodeComponent(mandate.mandateId)}/revoke',
        data: <String, dynamic>{
          'expectedMandateVersion': mandate.mandateVersion,
          'reason': 'USER_REQUESTED',
        },
        options: _writeOptions(
          idempotencyKey,
          'mandate-revoke',
          ifMatchVersion: mandate.mandateVersion,
        ),
      ),
      expectedStates: const {'MANDATE_REVOKED'},
    );
    return _parseMandate(data);
  }

  Options _readOptions(String action) => Options(headers: <String, dynamic>{
        'X-Operation-Trace-Id': 'trace-app-$action-${_uuid.v4()}',
      });

  Options _writeOptions(
    String idempotencyKey,
    String action, {
    int? ifMatchVersion,
  }) =>
      Options(headers: <String, dynamic>{
        'Idempotency-Key': idempotencyKey.trim(),
        if (ifMatchVersion != null) 'If-Match': '"$ifMatchVersion"',
        'X-Operation-Trace-Id': 'trace-app-$action-${_uuid.v4()}',
      });

  Future<Map<String, dynamic>> _machine(
    Future<Response<dynamic>> Function() operation, {
    required Set<String>? expectedStates,
  }) async {
    try {
      final response = await operation();
      final raw = response.data;
      if (raw is! Map) {
        throw const DsnMandateApiException('Invalid DS 0.2 response');
      }
      final body = Map<String, dynamic>.from(raw);
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
          throw DsnMandateApiException('DS 0.2 response is missing $field');
        }
      }
      if (body['schemaVersion'] != '0.1' ||
          body['state'] is! String ||
          (expectedStates != null && !expectedStates.contains(body['state'])) ||
          !_nonEmpty(body['taskTraceId']) ||
          !_nonEmpty(body['operationTraceId']) ||
          body['resource'] is! Map ||
          body['nextActions'] is! List ||
          body['data'] is! Map) {
        throw const DsnMandateApiException('Invalid DS 0.2 response facts');
      }
      final resource = Map<String, dynamic>.from(body['resource'] as Map);
      _requiredText(resource['id']?.toString() ?? '', 'resource.id');
      return Map<String, dynamic>.from(body['data'] as Map);
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  static DsnMandatePreview _parsePreview(Map<String, dynamic> data) =>
      DsnMandatePreview(
        previewId:
            _requiredText(data['previewId']?.toString() ?? '', 'previewId'),
        templateCode: DsnMandateTemplateCode.parse(
          _requiredText(data['templateCode']?.toString() ?? '', 'templateCode'),
        ),
        templateVersion:
            _positiveInt(data['templateVersion'], 'templateVersion'),
        subjectRole: DsnMandateSubjectRole.parse(
          _requiredText(data['subjectRole']?.toString() ?? '', 'subjectRole'),
        ),
        agentClientId: _optionalText(data['agentClientId']),
        resourceRef: _optionalText(data['resourceRef']),
        previewHash: _hash(data['previewHash'], 'previewHash'),
        allowedActionClasses: _actions(data['allowedActionClasses']),
        review: _review(data['review']),
        approvalRef: _requiredText(
          data['approvalRef']?.toString() ?? '',
          'approvalRef',
        ),
        reviewHash: _hash(data['reviewHash'], 'reviewHash'),
        expiresAt: _date(data['expiresAt'], 'expiresAt'),
        state: _previewState(data['state']),
      );

  static DsnMandate _parseMandate(Map<String, dynamic> data) {
    if (_optionalText(data['approvalRef']) != null) {
      throw const DsnMandateApiException(
        'Mandate read must not expose approvalRef',
        code: 'MANDATE_APPROVAL_REF_EXPOSED',
      );
    }
    return DsnMandate(
      mandateId:
          _requiredText(data['mandateId']?.toString() ?? '', 'mandateId'),
      templateCode: DsnMandateTemplateCode.parse(
        _requiredText(data['templateCode']?.toString() ?? '', 'templateCode'),
      ),
      templateVersion: _positiveInt(data['templateVersion'], 'templateVersion'),
      subjectRole: DsnMandateSubjectRole.parse(
        _requiredText(data['subjectRole']?.toString() ?? '', 'subjectRole'),
      ),
      agentClientId: _optionalText(data['agentClientId']),
      mandateVersion: _positiveInt(data['mandateVersion'], 'mandateVersion'),
      mandateHash: _hash(data['mandateHash'], 'mandateHash'),
      state: DsnMandateState.parse(
        _requiredText(data['state']?.toString() ?? '', 'state'),
      ),
      revokedAt: _optionalDate(data['revokedAt']),
    );
  }

  static void _validatePreview(DsnMandatePreviewInput input, String key) {
    _requiredText(input.resourceRef, 'resourceRef');
    _validateIdempotencyKey(key);
  }

  static DsnMandateResourceBinding _parseBinding(Map<String, dynamic> data) {
    const expected = <String>{
      'resourceRef',
      'expiresAt',
      'resourceHash',
      'allowedTemplateCodes',
    };
    if (data.keys.toSet().length != expected.length ||
        !data.keys.toSet().containsAll(expected)) {
      throw const DsnMandateApiException(
        'Invalid Mandate resource binding response',
        code: 'MANDATE_RESOURCE_BINDING_INVALID',
      );
    }
    final rawTemplates = data['allowedTemplateCodes'];
    if (rawTemplates is! List || rawTemplates.isEmpty) {
      throw const DsnMandateApiException(
        'Mandate resource binding is missing allowedTemplateCodes',
        code: 'MANDATE_RESOURCE_BINDING_INVALID',
      );
    }
    final templates = rawTemplates.map((value) {
      return DsnMandateTemplateCode.parse(
        _requiredText(value?.toString() ?? '', 'allowedTemplateCode'),
      );
    }).toList(growable: false);
    if (templates.toSet().length != templates.length) {
      throw const DsnMandateApiException(
        'Mandate resource binding has duplicate template codes',
        code: 'MANDATE_RESOURCE_BINDING_INVALID',
      );
    }
    return DsnMandateResourceBinding(
      resourceRef: _requiredText(
        data['resourceRef']?.toString() ?? '',
        'resourceRef',
      ),
      expiresAt: _date(data['expiresAt'], 'expiresAt'),
      resourceHash: _hash(data['resourceHash'], 'resourceHash'),
      allowedTemplateCodes: templates,
    );
  }

  static void _requireOnlyTemplate(
    DsnMandateResourceBinding binding,
    DsnMandateTemplateCode expected,
  ) {
    if (binding.allowedTemplateCodes.length != 1 ||
        binding.allowedTemplateCodes.single != expected) {
      throw const DsnMandateApiException(
        'Mandate resource binding returned an invalid template scope',
        code: 'MANDATE_RESOURCE_BINDING_TEMPLATE_INVALID',
      );
    }
  }

  static void _validateIdempotencyKey(String key) {
    final length = key.trim().length;
    if (length < 16 || length > 128) {
      throw const DsnMandateApiException(
        'Idempotency-Key must contain 16-128 characters',
      );
    }
  }

  static void _validateHash(String value, String label) {
    if (!RegExp(r'^sha256:[a-f0-9]{64}$').hasMatch(value.trim())) {
      throw DsnMandateApiException('$label must be sha256:<64 lowercase hex>');
    }
  }

  static String _hash(dynamic value, String label) {
    final hash = _requiredText(value?.toString() ?? '', label);
    _validateHash(hash, label);
    return hash;
  }

  static String _previewState(dynamic value) {
    const allowed = {'PREVIEWED', 'EXPIRED', 'CONFLICT'};
    final state = _requiredText(value?.toString() ?? '', 'preview state');
    if (!allowed.contains(state)) {
      throw const DsnMandateApiException('Invalid Mandate preview state');
    }
    return state;
  }

  static List<String> _actions(dynamic value) {
    if (value is! List || value.isEmpty) {
      throw const DsnMandateApiException(
          'Mandate preview is missing allowedActions');
    }
    final actions = value.map((action) {
      final text = _requiredText(action?.toString() ?? '', 'allowed action');
      if (!RegExp(r'^[A-Z][A-Z0-9_]{2,127}$').hasMatch(text)) {
        throw const DsnMandateApiException('Invalid Mandate allowed action');
      }
      return text;
    }).toList(growable: false);
    return actions;
  }

  static DsnMandateReviewCard _review(dynamic value) {
    if (value is! Map) {
      throw const DsnMandateApiException('Mandate preview is missing review');
    }
    final review = Map<String, dynamic>.from(value);
    const expected = <String>{
      'capability',
      'provider',
      'buyer',
      'variant',
      'quantity',
      'capacity',
      'sla',
      'currency',
      'amountMinor',
      'quoteHash',
      'maxDeliverySeconds',
    };
    if (review.keys.toSet().length != expected.length ||
        !review.keys.toSet().containsAll(expected) ||
        review['sla'] is! Map ||
        review['currency'] != 'CREDITS') {
      throw const DsnMandateApiException('Invalid Mandate review card');
    }
    return DsnMandateReviewCard(
      capability:
          _requiredText(review['capability']?.toString() ?? '', 'capability'),
      provider: _requiredText(review['provider']?.toString() ?? '', 'provider'),
      buyer: _requiredText(review['buyer']?.toString() ?? '', 'buyer'),
      variant: _requiredText(review['variant']?.toString() ?? '', 'variant'),
      quantity: _positiveInt(review['quantity'], 'quantity'),
      capacity: _positiveInt(review['capacity'], 'capacity'),
      sla: Map<String, dynamic>.unmodifiable(
        Map<String, dynamic>.from(review['sla'] as Map),
      ),
      currency: 'CREDITS',
      amountMinor: _nonNegativeInt(review['amountMinor'], 'amountMinor'),
      quoteHash: _hash(review['quoteHash'], 'quoteHash'),
      maxDeliverySeconds:
          _positiveInt(review['maxDeliverySeconds'], 'maxDeliverySeconds'),
    );
  }

  static int _nonNegativeInt(dynamic value, String label) {
    final parsed = value is num
        ? (value == value.truncateToDouble() ? value.toInt() : null)
        : int.tryParse(value?.toString().trim() ?? '');
    if (parsed == null || parsed < 0) {
      throw DsnMandateApiException('Invalid $label');
    }
    return parsed;
  }

  static int _positiveInt(dynamic value, String label) {
    final parsed = value is num
        ? (value == value.truncateToDouble() ? value.toInt() : null)
        : int.tryParse(value?.toString().trim() ?? '');
    if (parsed == null || parsed < 1) {
      throw DsnMandateApiException('Invalid $label');
    }
    return parsed;
  }

  static DateTime _date(dynamic value, String label) {
    final parsed = DateTime.tryParse(value?.toString() ?? '')?.toUtc();
    if (parsed == null) throw DsnMandateApiException('Invalid $label');
    return parsed;
  }

  static DateTime? _optionalDate(dynamic value) =>
      value == null ? null : _date(value, 'date');

  static String? _optionalText(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static String _requiredText(String value, String label) {
    final text = value.trim();
    if (text.isEmpty) throw DsnMandateApiException('$label is required');
    return text;
  }

  static bool _nonEmpty(dynamic value) =>
      value is String && value.trim().isNotEmpty;

  static DsnMandateApiException _mapError(DioException error) {
    final body = error.response?.data;
    if (body is Map) {
      final machine = body['error'];
      if (machine is Map) {
        return DsnMandateApiException(
          machine['message']?.toString() ?? 'Mandate request failed',
          code: machine['code']?.toString(),
          statusCode: error.response?.statusCode,
        );
      }
      return DsnMandateApiException(
        body['msg']?.toString() ?? 'Mandate request failed',
        code: body['errorCode']?.toString(),
        statusCode: error.response?.statusCode,
      );
    }
    return DsnMandateApiException(
      error.message ?? 'Network request failed',
      statusCode: error.response?.statusCode,
    );
  }
}
