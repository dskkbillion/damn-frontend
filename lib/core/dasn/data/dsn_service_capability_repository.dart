import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../domain/dsn_service_capability_models.dart';

/// Read-only Member App adapter for the server-owned service capability.
///
/// This route is intentionally under `/app/v1`, not `/agent/v1`: the page has
/// a Member JWT and must never forward an Agent credential just to discover a
/// service revision.
abstract class DsnServiceCapabilityRepository {
  Future<DsnServiceCapability> getServiceCapability(int serviceId);
}

class DioDsnServiceCapabilityRepository
    implements DsnServiceCapabilityRepository {
  DioDsnServiceCapabilityRepository(this.dio, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  /// The current fixed catalog seed used by the staging request entry.  A
  /// caller may supply another service id (for example from a catalog link),
  /// but it must still be resolved through the canonical endpoint.
  static const int defaultStagingServiceId = 582;

  final Dio dio;
  final Uuid _uuid;

  @override
  Future<DsnServiceCapability> getServiceCapability(int serviceId) async {
    if (serviceId <= 0) {
      throw const DsnServiceCapabilityFormatException(
        'Service ID must be a positive integer',
        code: 'INVALID_SERVICE_ID',
      );
    }
    try {
      final response = await dio.get(
        '/app/v1/capabilities/service/$serviceId',
        options: Options(headers: <String, dynamic>{
          'X-Operation-Trace-Id': 'trace-app-capability-read-${_uuid.v4()}',
        }),
      );
      return _parse(response.data, expectedServiceId: serviceId);
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  DsnServiceCapability _parse(dynamic value, {required int expectedServiceId}) {
    if (value is! Map) {
      throw const DsnServiceCapabilityFormatException(
        'Capability response is not an object',
      );
    }
    final envelope = Map<String, dynamic>.from(value);
    _validateEnvelope(envelope);
    final data = _map(envelope['data'], 'data');
    final capability = _map(data['capability'], 'data.capability');
    final expectedCapabilityId = 'service:$expectedServiceId';
    final capabilityId = _requiredString(capability, 'capabilityId');
    if (capabilityId != expectedCapabilityId) {
      throw const DsnServiceCapabilityFormatException(
        'Capability response does not match the requested service',
        code: 'CAPABILITY_ID_MISMATCH',
      );
    }

    final revision = _requiredHash(capability, 'revision');
    final resource = _map(envelope['resource'], 'resource');
    final resourceId = _requiredString(resource, 'id');
    if (resourceId != expectedCapabilityId) {
      throw const DsnServiceCapabilityFormatException(
        'Capability resource does not match the requested service',
        code: 'CAPABILITY_RESOURCE_MISMATCH',
      );
    }
    final resourceHash = _requiredHash(resource, 'hash');
    if (resourceHash != revision) {
      throw const DsnServiceCapabilityFormatException(
        'Capability resource hash does not match its manifest revision',
        code: 'CAPABILITY_REVISION_MISMATCH',
      );
    }

    final pricing = _map(capability['pricing'], 'capability.pricing');
    final amountMinor =
        _positiveInt(pricing['amountMinor'], 'capability.pricing.amountMinor');
    final currency = _requiredString(pricing, 'currency');
    final sla = _map(capability['sla'], 'capability.sla');
    final deliveryHours =
        _positiveInt(sla['deliveryHours'], 'capability.sla.deliveryHours');
    final maxRevisions =
        _nonNegativeInt(sla['maxRevisions'], 'capability.sla.maxRevisions');
    final outputTypes = _outputTypes(capability['outputTypes']);

    return DsnServiceCapability(
      serviceId: expectedServiceId,
      capabilityId: capabilityId,
      revision: revision,
      title: _requiredString(capability, 'title'),
      description: _optionalString(capability['description']),
      amountMinor: amountMinor,
      currency: currency,
      deliveryHours: deliveryHours,
      maxRevisions: maxRevisions,
      outputTypes: outputTypes,
    );
  }

  void _validateEnvelope(Map<String, dynamic> envelope) {
    const expected = <String, String>{
      'protocolVersion': 'dasn/0.1',
      'dsVersion': 'DS 0.1',
      'schemaVersion': '0.1',
      'state': 'CAPABILITY_AVAILABLE',
    };
    for (final entry in expected.entries) {
      if (envelope[entry.key] != entry.value) {
        throw DsnServiceCapabilityFormatException(
          'Capability envelope has an invalid ${entry.key}',
          code: 'INVALID_CAPABILITY_ENVELOPE',
        );
      }
    }
  }

  Map<String, dynamic> _map(dynamic value, String field) {
    if (value is! Map) {
      throw DsnServiceCapabilityFormatException(
        'Capability response is missing $field',
        code: 'MISSING_CAPABILITY_FIELD',
      );
    }
    return Map<String, dynamic>.from(value);
  }

  String _requiredString(Map<String, dynamic> value, String field) {
    final raw = value[field];
    if (raw is! String || raw.trim().isEmpty) {
      throw DsnServiceCapabilityFormatException(
        'Capability response is missing $field',
        code: 'MISSING_CAPABILITY_FIELD',
      );
    }
    return raw.trim();
  }

  String _optionalString(dynamic value) => value is String ? value.trim() : '';

  String _requiredHash(Map<String, dynamic> value, String field) {
    final hash = _requiredString(value, field);
    if (!RegExp(r'^sha256:[a-f0-9]{64}$').hasMatch(hash)) {
      throw DsnServiceCapabilityFormatException(
        'Capability $field must be sha256:<64 lowercase hex>',
        code: 'INVALID_CAPABILITY_REVISION',
      );
    }
    return hash;
  }

  int _positiveInt(dynamic raw, String field) {
    final value = _asInt(raw);
    if (value == null || value <= 0) {
      throw DsnServiceCapabilityFormatException(
        'Capability $field must be a positive integer',
        code: 'INVALID_CAPABILITY_FIELD',
      );
    }
    return value;
  }

  int _nonNegativeInt(dynamic raw, String field) {
    final value = _asInt(raw);
    if (value == null || value < 0) {
      throw DsnServiceCapabilityFormatException(
        'Capability $field must be a non-negative integer',
        code: 'INVALID_CAPABILITY_FIELD',
      );
    }
    return value;
  }

  int? _asInt(dynamic raw) {
    if (raw is num && raw is int) return raw;
    if (raw is num && raw == raw.truncate()) return raw.toInt();
    if (raw is String) return int.tryParse(raw.trim());
    return null;
  }

  List<String> _outputTypes(dynamic raw) {
    if (raw is! List || raw.isEmpty) {
      throw const DsnServiceCapabilityFormatException(
        'Capability outputTypes must be a non-empty list',
        code: 'INVALID_CAPABILITY_OUTPUT_TYPES',
      );
    }
    final values = <String>[];
    for (final item in raw) {
      if (item is! String || item.trim().isEmpty) {
        throw const DsnServiceCapabilityFormatException(
          'Capability outputTypes contains an invalid value',
          code: 'INVALID_CAPABILITY_OUTPUT_TYPES',
        );
      }
      final value = item.trim();
      if (values.contains(value)) {
        throw const DsnServiceCapabilityFormatException(
          'Capability outputTypes must be unique',
          code: 'INVALID_CAPABILITY_OUTPUT_TYPES',
        );
      }
      values.add(value);
    }
    return List<String>.unmodifiable(values);
  }

  DsnServiceCapabilityFormatException _mapError(DioException error) {
    final body = error.response?.data;
    final status = error.response?.statusCode;
    if (body is Map) {
      final detail = body['error'];
      if (detail is Map) {
        final map = Map<String, dynamic>.from(detail);
        return DsnServiceCapabilityFormatException(
          map['message']?.toString() ?? 'Capability read failed',
          code: map['code']?.toString() ??
              (status == 404
                  ? 'CAPABILITY_NOT_FOUND'
                  : 'CAPABILITY_READ_FAILED'),
        );
      }
      return DsnServiceCapabilityFormatException(
        body['msg']?.toString() ?? 'Capability read failed',
        code: body['errorCode']?.toString() ?? 'CAPABILITY_READ_FAILED',
      );
    }
    return DsnServiceCapabilityFormatException(
      error.message ?? 'Capability read failed',
      code: status == 404 ? 'CAPABILITY_NOT_FOUND' : 'CAPABILITY_READ_FAILED',
    );
  }
}
