import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../domain/dsn_buyer_agent_models.dart';
import '../domain/dsn_order_models.dart';
import 'dsn_order_repository.dart';

/// Shared contract for the external Buyer Agent/CLI adapter.
///
/// Calling `/agent/v1/requests/{id}/commitment` requires an Agent session and
/// a server-side BoundedGrant; an App JWT must not be upgraded or forwarded as
/// that credential.  The concrete Dio implementation below is for an
/// explicitly Agent-authenticated runner/client.  The Trusted App still only
/// prepares a credential-free handoff and reads the resulting order from the
/// normal task projection and payment routes.
///
/// The request body is exactly [DsnBuyerAgentCommitmentInput.toJson].  The
/// caller supplies the Agent route's If-Match request version and an
/// idempotency key; neither is a hidden field inside the six-fact input.
abstract interface class DsnBuyerAgentCommitmentRepository {
  Future<DsnOrder> createCommitment(
    int requestId, {
    required DsnBuyerAgentCommitmentInput input,
    required int ifMatchVersion,
    required String idempotencyKey,
  });
}

/// Canonical Buyer Agent commitment transport.
///
/// The caller must provide a Dio instance whose authentication interceptor is
/// already bound to the Agent session.  This adapter deliberately does not
/// accept a Member JWT, Grant, or session value and never places credentials
/// in the six-fact request body.  The Trusted App uses the separate handoff
/// model above; it must not construct this adapter with its normal Member Dio.
class DioDsnBuyerAgentCommitmentRepository
    implements DsnBuyerAgentCommitmentRepository {
  DioDsnBuyerAgentCommitmentRepository(this.dio, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final Dio dio;
  final Uuid _uuid;

  @override
  Future<DsnOrder> createCommitment(
    int requestId, {
    required DsnBuyerAgentCommitmentInput input,
    required int ifMatchVersion,
    required String idempotencyKey,
  }) async {
    _validateRequestId(requestId);
    _validatePreconditions(ifMatchVersion, idempotencyKey);
    final body = await _machine(
      () => dio.post(
        '/agent/v1/requests/$requestId/commitment',
        options: Options(headers: <String, dynamic>{
          'Idempotency-Key': idempotencyKey.trim(),
          'If-Match': '"$ifMatchVersion"',
          // A retry keeps the logical idempotency key but receives a fresh
          // operation trace for independent runtime correlation.
          'X-Operation-Trace-Id': 'trace-agent-commitment-${_uuid.v4()}',
        }),
        data: input.toJson(),
      ),
      expectedState: 'ORDER_COMMITMENT_CREATED',
    );
    return _parseOrder(body, requestId, input);
  }

  Future<Map<String, dynamic>> _machine(
    Future<Response<dynamic>> Function() operation, {
    required String expectedState,
  }) async {
    try {
      final response = await operation();
      final raw = response.data;
      if (raw is! Map) {
        throw const DsnOrderApiException('Invalid DS 0.1 response');
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
          throw DsnOrderApiException('DS 0.1 response is missing $field');
        }
      }
      if (body['protocolVersion'] != 'dasn/0.1' ||
          body['dsVersion'] != 'DS 0.1' ||
          body['schemaVersion'] != '0.1' ||
          body['state'] != expectedState ||
          body['taskTraceId'] is! String ||
          (body['taskTraceId'] as String).trim().isEmpty ||
          body['operationTraceId'] is! String ||
          (body['operationTraceId'] as String).trim().isEmpty ||
          body['resource'] is! Map ||
          body['nextActions'] is! List ||
          body['data'] is! Map) {
        throw const DsnOrderApiException('DS 0.1 response facts are invalid');
      }
      return body;
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  DsnOrder _parseOrder(
    Map<String, dynamic> body,
    int requestId,
    DsnBuyerAgentCommitmentInput input,
  ) {
    final data = _map(body['data'], 'commitment data');
    final resource = _map(body['resource'], 'commitment resource');
    final resourceVersion = _requiredPositiveInt(resource, 'version');
    final dataVersion = _requiredPositiveInt(data, 'commitmentVersion');
    if (resourceVersion != dataVersion) {
      throw const DsnOrderApiException(
        'Commitment response versions do not match',
        code: 'COMMITMENT_VERSION_MISMATCH',
      );
    }
    if (_requiredInt(data, 'requestId') != requestId ||
        _requiredString(data, 'confirmationRef') != input.confirmationRef) {
      throw const DsnOrderApiException(
        'Commitment response is not bound to the requested handoff',
        code: 'COMMITMENT_HANDOFF_MISMATCH',
      );
    }
    return DsnOrder(
      orderId: _requiredString(data, 'orderId'),
      taskTraceId: _requiredString(body, 'taskTraceId'),
      commitmentId: _requiredString(data, 'commitmentId'),
      confirmationRef: _requiredString(data, 'confirmationRef'),
      amountMinor: _requiredInt(data, 'amountMinor'),
      currency: _requiredString(data, 'currency'),
      orderState: _requiredString(data, 'orderState'),
      commitmentVersion: resourceVersion,
      offerId: data['offerId']?.toString(),
      replayed: data['replayed'] == true,
    );
  }

  void _validatePreconditions(int version, String key) {
    if (version < 0) {
      throw const DsnOrderApiException(
        'If-Match version must be non-negative',
        code: 'INVALID_COMMITMENT_VERSION',
      );
    }
    final length = key.trim().length;
    if (length < 16 || length > 255) {
      throw const DsnOrderApiException(
        'Idempotency-Key must contain 16-255 characters',
        code: 'INVALID_IDEMPOTENCY_KEY',
      );
    }
  }

  static void _validateRequestId(int requestId) {
    if (requestId < 1) {
      throw const DsnOrderApiException(
        'Request ID must be positive',
        code: 'INVALID_REQUEST_ID',
      );
    }
  }
}

Map<String, dynamic> _map(dynamic value, String label) {
  if (value is! Map) throw DsnOrderApiException('Invalid $label');
  return Map<String, dynamic>.from(value);
}

String _requiredString(Map<String, dynamic> map, String field) {
  final value = map[field];
  if (value is! String || value.trim().isEmpty) {
    throw DsnOrderApiException('Missing DS 0.1 field: $field');
  }
  return value.trim();
}

int _requiredInt(Map<String, dynamic> map, String field) {
  final value = map[field];
  if (value is num && value == value.truncateToDouble()) return value.toInt();
  if (value is String && RegExp(r'^(0|[1-9][0-9]*)$').hasMatch(value.trim())) {
    final parsed = int.tryParse(value.trim());
    if (parsed != null) return parsed;
  }
  throw DsnOrderApiException('Invalid DS 0.1 field: $field');
}

int _requiredPositiveInt(Map<String, dynamic> map, String field) {
  final value = _requiredInt(map, field);
  if (value < 1) throw DsnOrderApiException('Invalid DS 0.1 field: $field');
  return value;
}

DsnOrderApiException _mapError(DioException error) {
  final body = error.response?.data;
  if (body is Map) {
    final machineError = body['error'];
    if (machineError is Map) {
      return DsnOrderApiException(
        machineError['message']?.toString() ?? 'DS 0.1 request failed',
        code: machineError['code']?.toString(),
        statusCode: error.response?.statusCode,
      );
    }
    return DsnOrderApiException(
      body['msg']?.toString() ?? 'DS 0.1 request failed',
      code: body['errorCode']?.toString(),
      statusCode: error.response?.statusCode,
    );
  }
  return DsnOrderApiException(
    error.message ?? 'Network request failed',
    statusCode: error.response?.statusCode,
  );
}
