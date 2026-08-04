import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../domain/dsn_delivery_decision_models.dart';

class DsnDeliveryDecisionApiException implements Exception {
  const DsnDeliveryDecisionApiException(
    this.message, {
    this.code,
    this.statusCode,
  });

  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Canonical Trusted App buyer decision transport.
///
/// The authenticated member is derived by the server. The request body only
/// carries the selected append-only delivery facts and the decision. Every
/// write uses the exact commitment version as If-Match and a stable
/// Idempotency-Key supplied by the caller.
abstract class DsnDeliveryDecisionRepository {
  Future<DsnDeliveryDecisionResult> submitDecision(
    DsnDeliveryDecisionInput input, {
    required String idempotencyKey,
  });
}

class DioDsnDeliveryDecisionRepository
    implements DsnDeliveryDecisionRepository {
  DioDsnDeliveryDecisionRepository(this.dio, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final Dio dio;
  final Uuid _uuid;

  @override
  Future<DsnDeliveryDecisionResult> submitDecision(
    DsnDeliveryDecisionInput input, {
    required String idempotencyKey,
  }) async {
    _validateInput(input, idempotencyKey);
    final body = await _machine(
      () => dio.post(
        '/app/v1/orders/${input.orderId}/acceptance-decisions',
        options: Options(headers: <String, dynamic>{
          'Idempotency-Key': idempotencyKey.trim(),
          'If-Match': '"${input.commitmentVersion}"',
          'X-Operation-Trace-Id': 'trace-buyer-decision-${_uuid.v4()}',
        }),
        data: input.toJson(),
      ),
    );
    return _parseResult(body, input.decision);
  }

  void _validateInput(DsnDeliveryDecisionInput input, String idempotencyKey) {
    if (input.orderId < 1) {
      throw const DsnDeliveryDecisionApiException(
        'Order ID must be positive',
        code: 'INVALID_ORDER_ID',
      );
    }
    if (input.deliveryId.trim().isEmpty ||
        input.submissionNo < 1 ||
        input.commitmentVersion < 1) {
      throw const DsnDeliveryDecisionApiException(
        'Delivery decision facts are invalid',
        code: 'INVALID_DECISION',
      );
    }
    final keyLength = idempotencyKey.trim().length;
    if (keyLength < 16 || keyLength > 128) {
      throw const DsnDeliveryDecisionApiException(
        'Idempotency-Key must contain 16-128 characters',
        code: 'INVALID_IDEMPOTENCY_KEY',
      );
    }
    final hash = input.expectedSubmissionHash;
    if (hash != null && !RegExp(r'^sha256:[a-f0-9]{64}$').hasMatch(hash)) {
      throw const DsnDeliveryDecisionApiException(
        'Expected submission hash is invalid',
        code: 'INVALID_HASH',
      );
    }
    if (input.reason != null && input.reason!.length > 4000) {
      throw const DsnDeliveryDecisionApiException(
        'Decision reason exceeds 4000 characters',
        code: 'INVALID_REASON',
      );
    }
  }

  Future<Map<String, dynamic>> _machine(
    Future<Response<dynamic>> Function() operation,
  ) async {
    try {
      final response = await operation();
      final raw = response.data;
      if (raw is! Map) {
        throw const DsnDeliveryDecisionApiException(
          'Invalid DS 0.1 decision response',
          code: 'INVALID_RESPONSE',
        );
      }
      final body = Map<String, dynamic>.from(raw);
      for (final field in <String>[
        'protocolVersion',
        'dsVersion',
        'schemaVersion',
        'state',
        'taskTraceId',
        'operationTraceId',
        'resource',
        'nextActions',
        'data',
      ]) {
        if (!body.containsKey(field) || body[field] == null) {
          throw DsnDeliveryDecisionApiException(
            'DS 0.1 response is missing $field',
            code: 'INVALID_RESPONSE',
          );
        }
      }
      if (body['protocolVersion'] != 'dasn/0.1' ||
          body['dsVersion'] != 'DS 0.1' ||
          body['schemaVersion'] != '0.1' ||
          body['taskTraceId'] is! String ||
          (body['taskTraceId'] as String).trim().isEmpty ||
          body['operationTraceId'] is! String ||
          (body['operationTraceId'] as String).trim().isEmpty ||
          body['resource'] is! Map ||
          body['nextActions'] is! List ||
          body['data'] is! Map) {
        throw const DsnDeliveryDecisionApiException(
          'DS 0.1 response facts are invalid',
          code: 'INVALID_RESPONSE',
        );
      }
      return body;
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  DsnDeliveryDecisionResult _parseResult(
    Map<String, dynamic> body,
    DsnDeliveryDecisionAction requested,
  ) {
    final state = _requiredString(body, 'state');
    if (state != requested.responseState) {
      throw DsnDeliveryDecisionApiException(
        'Unexpected DS 0.1 decision state: $state',
        code: 'UNEXPECTED_STATE',
      );
    }
    final data = _map(body['data'], 'decision data');
    final action = DsnDeliveryDecisionAction.fromWire(
      _requiredString(data, 'action'),
    );
    if (action == null || action != requested) {
      throw const DsnDeliveryDecisionApiException(
        'Decision response does not match the requested action',
        code: 'INVALID_RESPONSE',
      );
    }
    final actorType = _requiredString(data, 'actorType');
    if (actorType != 'PRINCIPAL') {
      throw const DsnDeliveryDecisionApiException(
        'Final delivery decisions require a Principal actor',
        code: 'INVALID_RESPONSE',
      );
    }
    return DsnDeliveryDecisionResult(
      state: state,
      taskTraceId: _requiredString(body, 'taskTraceId'),
      operationTraceId: _requiredString(body, 'operationTraceId'),
      decisionId: _requiredString(data, 'decisionId'),
      orderId: _requiredPositiveInt(data, 'orderId'),
      commitmentId: _requiredString(data, 'commitmentId'),
      commitmentVersion: _requiredPositiveInt(data, 'commitmentVersion'),
      deliveryId: _requiredString(data, 'deliveryId'),
      submissionNo: _requiredPositiveInt(data, 'submissionNo'),
      action: action,
      actorType: actorType,
      createdAt: _optionalDate(data['createdAt']),
    );
  }
}

Map<String, dynamic> _map(dynamic value, String label) {
  if (value is! Map) {
    throw DsnDeliveryDecisionApiException(
      'Invalid $label',
      code: 'INVALID_RESPONSE',
    );
  }
  return Map<String, dynamic>.from(value);
}

String _requiredString(Map<String, dynamic> map, String field) {
  final value = map[field];
  if (value is! String || value.trim().isEmpty) {
    throw DsnDeliveryDecisionApiException(
      'Missing DS 0.1 field: $field',
      code: 'INVALID_RESPONSE',
    );
  }
  return value.trim();
}

int _requiredPositiveInt(Map<String, dynamic> map, String field) {
  final value = map[field];
  if (value is num && value == value.truncateToDouble() && value >= 1) {
    return value.toInt();
  }
  if (value is String && RegExp(r'^[1-9][0-9]*$').hasMatch(value.trim())) {
    final parsed = int.tryParse(value.trim());
    if (parsed != null) return parsed;
  }
  throw DsnDeliveryDecisionApiException(
    'Invalid DS 0.1 field: $field',
    code: 'INVALID_RESPONSE',
  );
}

DateTime? _optionalDate(dynamic value) {
  if (value == null) return null;
  if (value is! String) {
    throw const DsnDeliveryDecisionApiException(
      'Invalid DS 0.1 date',
      code: 'INVALID_RESPONSE',
    );
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    throw const DsnDeliveryDecisionApiException(
      'Invalid DS 0.1 date',
      code: 'INVALID_RESPONSE',
    );
  }
  return parsed;
}

DsnDeliveryDecisionApiException _mapError(DioException error) {
  final body = error.response?.data;
  if (body is Map && body['error'] is Map) {
    final detail = Map<String, dynamic>.from(body['error'] as Map);
    return DsnDeliveryDecisionApiException(
      detail['message']?.toString() ?? 'DS 0.1 decision failed',
      code: detail['code']?.toString(),
      statusCode: error.response?.statusCode,
    );
  }
  return DsnDeliveryDecisionApiException(
    error.message ?? 'Network request failed',
    statusCode: error.response?.statusCode,
  );
}
