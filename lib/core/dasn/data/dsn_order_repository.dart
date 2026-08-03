import 'package:dio/dio.dart';

import '../domain/dsn_order_models.dart';

class DsnOrderApiException implements Exception {
  const DsnOrderApiException(this.message, {this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Canonical Trusted App buyer boundary for the DS 0.1 P0 flow.
abstract class DsnOrderRepository {
  Future<DsnProviderOffer> getProviderOffer(int requestId);

  Future<DsnOrderPreview> createPreview(
    int requestId, {
    required String expectedSpecHash,
    required String quoteHash,
    required String idempotencyKey,
  });

  Future<DsnConfirmationRef> issueConfirmationRef(
    int requestId, {
    required String previewId,
    required List<String> allowedActions,
    required String idempotencyKey,
  });

  Future<DsnOrder> createOrder(
    int requestId, {
    required DsnOrderPreview preview,
    required DsnConfirmationRef confirmation,
    required int ifMatchVersion,
    required String idempotencyKey,
  });

  Future<DsnPaymentAttempt> createPaymentAttempt(
    DsnOrder order, {
    required DsnOrderPreview preview,
    required DsnConfirmationRef confirmation,
    required String idempotencyKey,
  });

  Future<DsnPaymentAttempt> getPaymentAttempt(String paymentAttemptId);
}

class DioDsnOrderRepository implements DsnOrderRepository {
  DioDsnOrderRepository(this.dio);

  final Dio dio;

  @override
  Future<DsnProviderOffer> getProviderOffer(int requestId) async {
    final body = await _machine(
      () => dio.get('/app/v1/requests/$requestId/provider-offer'),
      expectedState: 'PROVIDER_OFFER_ACCEPTED',
    );
    final data = _map(body['data'], 'provider offer data');
    return DsnProviderOffer(
      requestId: _requiredInt(data, 'requestId'),
      taskTraceId: _requiredString(body, 'taskTraceId'),
      offerId: _requiredString(data, 'offerId'),
      acceptanceId: _requiredString(data, 'acceptanceId'),
      providerId: _requiredString(data, 'providerId'),
      capabilityId: _requiredString(data, 'capabilityId'),
      variantId: _requiredString(data, 'variantId'),
      offerVersion: _requiredInt(data, 'offerVersion'),
      specHash: _requiredHash(data, 'specHash'),
      quoteHash: _requiredHash(data, 'quoteHash'),
      quantity: _requiredInt(data, 'quantity'),
      amountMinor: _requiredInt(data, 'amountMinor'),
      currency: _requiredString(data, 'currency'),
      capacity: _optionalInt(data['capacity']),
      expiresAt: _optionalDate(data['expiresAt']),
      deliveryDeadline: _optionalDate(data['deliveryDeadline']),
      maxRevisions: _optionalInt(data['maxRevisions']),
      sla: data['sla']?.toString(),
      acceptance: data['acceptance']?.toString(),
    );
  }

  @override
  Future<DsnOrderPreview> createPreview(
    int requestId, {
    required String expectedSpecHash,
    required String quoteHash,
    required String idempotencyKey,
  }) async {
    final body = await _machine(
      () => dio.post(
        '/app/v1/requests/$requestId/order-previews',
        options: Options(headers: {'Idempotency-Key': idempotencyKey}),
        data: <String, dynamic>{
          'expectedSpecHash': expectedSpecHash,
          'quoteHash': quoteHash,
        },
      ),
      expectedState: 'PREVIEW_ISSUED',
    );
    final data = _map(body['data'], 'order preview data');
    final expiresAt = _requiredDate(data, 'expiresAt');
    return DsnOrderPreview(
      requestId: _requiredInt(data, 'requestId'),
      taskTraceId: _requiredString(body, 'taskTraceId'),
      previewId: _requiredString(data, 'previewId'),
      providerId: _requiredString(data, 'providerId'),
      providerOfferId: _requiredString(data, 'providerOfferId'),
      providerAcceptanceId: _requiredString(data, 'providerAcceptanceId'),
      offerVersion: _requiredInt(data, 'offerVersion'),
      specHash: _requiredHash(data, 'specHash'),
      quoteHash: _requiredHash(data, 'quoteHash'),
      amountMinor: _requiredInt(data, 'amountMinor'),
      currency: _requiredString(data, 'currency'),
      quantity: _requiredInt(data, 'quantity'),
      expiresAt: expiresAt,
      deliveryDeadline: _optionalDate(data['deliveryDeadline']),
      maxRevisions: _optionalInt(data['maxRevisions']),
      candidateHash: _optionalHash(body['resource'] is Map
          ? Map<String, dynamic>.from(body['resource'] as Map)['hash']
          : null),
    );
  }

  @override
  Future<DsnConfirmationRef> issueConfirmationRef(
    int requestId, {
    required String previewId,
    required List<String> allowedActions,
    required String idempotencyKey,
  }) async {
    final body = await _machine(
      () => dio.post(
        '/app/v1/requests/$requestId/confirmation-refs',
        options: Options(headers: {'Idempotency-Key': idempotencyKey}),
        data: <String, dynamic>{
          'previewId': previewId,
          'paymentMethodType': 'CREDITS',
          'allowedActions': List<String>.from(allowedActions),
        },
      ),
      expectedState: 'CONFIRMATION_REF_ISSUED',
    );
    final data = _map(body['data'], 'confirmation reference data');
    return DsnConfirmationRef(
      confirmationRef: _requiredString(data, 'confirmationRef'),
      requestId: _requiredInt(data, 'requestId'),
      taskTraceId: _requiredString(body, 'taskTraceId'),
      previewId: _requiredString(data, 'previewId'),
      specHash: _requiredHash(data, 'specHash'),
      quoteHash: _requiredHash(data, 'quoteHash'),
      amountMinor: _requiredInt(data, 'amountMinor'),
      currency: _requiredString(data, 'currency'),
      paymentMethodType: _requiredString(data, 'paymentMethodType'),
      allowedActions: _requiredStringList(data, 'allowedActions'),
      expiresAt: _optionalDate(data['expiresAt']),
    );
  }

  @override
  Future<DsnOrder> createOrder(
    int requestId, {
    required DsnOrderPreview preview,
    required DsnConfirmationRef confirmation,
    required int ifMatchVersion,
    required String idempotencyKey,
  }) async {
    final body = await _machine(
      () => dio.post(
        '/app/v1/requests/$requestId/orders',
        options: Options(headers: {
          'Idempotency-Key': idempotencyKey,
          'If-Match': '"$ifMatchVersion"',
        }),
        data: <String, dynamic>{
          'previewId': preview.previewId,
          'providerAcceptanceId': preview.providerAcceptanceId,
          'offerVersion': preview.offerVersion,
          'expectedSpecHash': preview.specHash,
          'expectedQuoteHash': preview.quoteHash,
          'confirmationRef': confirmation.confirmationRef,
        },
      ),
      expectedState: 'ORDER_COMMITMENT_CREATED',
    );
    final data = _map(body['data'], 'order data');
    return DsnOrder(
      orderId: _requiredString(data, 'orderId'),
      taskTraceId: _requiredString(body, 'taskTraceId'),
      commitmentId: _requiredString(data, 'commitmentId'),
      confirmationRef: _requiredString(data, 'confirmationRef'),
      amountMinor: _requiredInt(data, 'amountMinor'),
      currency: _requiredString(data, 'currency'),
      orderState: _requiredString(data, 'orderState'),
      offerId: data['offerId']?.toString(),
      replayed: data['replayed'] == true,
    );
  }

  @override
  Future<DsnPaymentAttempt> createPaymentAttempt(
    DsnOrder order, {
    required DsnOrderPreview preview,
    required DsnConfirmationRef confirmation,
    required String idempotencyKey,
  }) async {
    final body = await _machine(
      () => dio.post(
        '/app/v1/orders/${order.orderId}/payment-attempts',
        options: Options(headers: {
          'Idempotency-Key': idempotencyKey,
          'If-Match': '"${preview.offerVersion}"',
        }),
        data: <String, dynamic>{
          'confirmationRef': confirmation.confirmationRef,
          'amountMinor': preview.amountMinor,
          'currency': 'CREDITS',
          'paymentMethodType': 'CREDITS',
          'fundingSource': 'INTERNAL_CREDITS',
        },
      ),
      expectedState: null,
    );
    return _payment(body);
  }

  @override
  Future<DsnPaymentAttempt> getPaymentAttempt(String paymentAttemptId) async {
    final body = await _machine(
      () => dio.get('/app/v1/payment-attempts/$paymentAttemptId'),
      expectedState: null,
    );
    return _payment(body);
  }

  Future<Map<String, dynamic>> _machine(
    Future<Response<dynamic>> Function() operation, {
    required String? expectedState,
  }) async {
    try {
      final response = await operation();
      final raw = response.data;
      if (raw is! Map) {
        throw const DsnOrderApiException('Invalid DS 0.1 response');
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
          throw DsnOrderApiException('DS 0.1 response is missing $field');
        }
      }
      if (body['taskTraceId'] is! String ||
          (body['taskTraceId'] as String).trim().isEmpty ||
          body['operationTraceId'] is! String ||
          (body['operationTraceId'] as String).trim().isEmpty ||
          body['resource'] is! Map ||
          body['nextActions'] is! List ||
          body['data'] is! Map) {
        throw const DsnOrderApiException('DS 0.1 response facts are invalid');
      }
      if (expectedState != null && body['state'] != expectedState) {
        throw DsnOrderApiException(
          'Unexpected DS 0.1 state: ${body['state']}',
          code: 'UNEXPECTED_STATE',
        );
      }
      return body;
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  DsnPaymentAttempt _payment(Map<String, dynamic> body) {
    final data = _map(body['data'], 'payment data');
    final payment = _map(body['paymentAttempt'], 'payment attempt');
    return DsnPaymentAttempt(
      paymentAttemptId: _requiredString(payment, 'paymentAttemptId'),
      orderId: _requiredString(data, 'orderId'),
      taskTraceId: _requiredString(body, 'taskTraceId'),
      state: _requiredString(body, 'state'),
      fundsDisposition: _requiredString(payment, 'fundsDisposition'),
      effectiveCommitment: payment['effectiveCommitment'] == true,
      amountMinor: _requiredInt(data, 'amountMinor'),
      currency: _requiredString(data, 'currency'),
      confirmationRef: _requiredString(data, 'confirmationRef'),
      nextAction: payment['nextAction']?.toString(),
      replayed: data['replayed'] == true,
    );
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
  final parsed = _wireInt(value, field);
  if (parsed < 0) throw DsnOrderApiException('Invalid DS 0.1 field: $field');
  return parsed;
}

int _wireInt(dynamic value, String field) {
  if (value is num) {
    if (!value.isFinite || value != value.truncateToDouble()) {
      throw DsnOrderApiException('Invalid DS 0.1 field: $field');
    }
    return value.toInt();
  }
  if (value is String) {
    final text = value.trim();
    // The canonical machine response uses string resource IDs.  Accept only
    // an integer decimal representation; never truncate a decimal or coerce
    // arbitrary text into a business fact.
    if (!RegExp(r'^(0|[1-9][0-9]*)$').hasMatch(text)) {
      throw DsnOrderApiException('Invalid DS 0.1 field: $field');
    }
    try {
      return int.parse(text);
    } on FormatException {
      throw DsnOrderApiException('Invalid DS 0.1 field: $field');
    }
  }
  throw DsnOrderApiException('Missing DS 0.1 field: $field');
}

int? _optionalInt(dynamic value) => value is num ? value.toInt() : null;

String _requiredHash(Map<String, dynamic> map, String field) {
  final value = _requiredString(map, field);
  if (!RegExp(r'^sha256:[a-f0-9]{64}$').hasMatch(value)) {
    throw DsnOrderApiException('Invalid DS 0.1 hash: $field');
  }
  return value;
}

String? _optionalHash(dynamic value) {
  if (value == null) return null;
  if (value is! String || !RegExp(r'^sha256:[a-f0-9]{64}$').hasMatch(value)) {
    throw const DsnOrderApiException('Invalid DS 0.1 resource hash');
  }
  return value;
}

DateTime _requiredDate(Map<String, dynamic> map, String field) {
  final value = _optionalDate(map[field]);
  if (value == null) throw DsnOrderApiException('Missing DS 0.1 field: $field');
  return value;
}

DateTime? _optionalDate(dynamic value) {
  if (value == null) return null;
  if (value is! String) throw const DsnOrderApiException('Invalid DS 0.1 date');
  final parsed = DateTime.tryParse(value);
  if (parsed == null) throw const DsnOrderApiException('Invalid DS 0.1 date');
  return parsed;
}

List<String> _requiredStringList(Map<String, dynamic> map, String field) {
  final value = map[field];
  if (value is! List || value.any((item) => item is! String)) {
    throw DsnOrderApiException('Missing DS 0.1 field: $field');
  }
  return List<String>.unmodifiable(value.cast<String>());
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
