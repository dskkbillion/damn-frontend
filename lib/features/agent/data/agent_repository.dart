import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../domain/agent_models.dart';

class AgentApiException implements Exception {
  final String message;
  final String? code;
  const AgentApiException(this.message, [this.code]);
  @override
  String toString() => message;
}

abstract class AgentRepository {
  Future<AgentAuthorization> inspectAuthorization(String userCode);
  Future<void> approveAuthorization(String userCode, Set<String> scopes);
  Future<void> denyAuthorization(String userCode);
  Future<AgentSessionPage> listSessions({int? beforeId, int limit = 20});
  Future<AgentSessionDetail> getSession(int id);
  Future<AgentSession> reduceScopes(int id, Set<String> scopes);
  Future<void> revokeSession(int id);
  Future<int> revokeAllSessions();
  Future<List<AgentRequestDraft>> listRequests();
  Future<AgentRequestDraft> getRequest(int id);

  /// Create a HUMAN-originated canonical DS request.  The server derives the
  /// member identity from the App JWT and freezes a Trusted App snapshot;
  /// callers must not send buyer/provider/session fields.
  Future<AgentRequestDraft> createHumanRequest({
    required int serviceId,
    required String capabilityRevision,
    required String title,
    required String brief,
    int? budgetMaxMinor,
  }) =>
      throw UnimplementedError();

  /// Submit the App-reviewed request through the canonical DS 0.1 boundary.
  /// Implementations must reuse the same key for a retry of the same version.
  Future<void> submitRequest(int id,
          {required int version, required String specHash}) =>
      throw UnimplementedError();
  Future<AgentRequestDraft> approveRequest(int id);
  Future<AgentRequestDraft> abandonRequest(int id);
}

class DioAgentRepository implements AgentRepository {
  final Dio dio;
  DioAgentRepository(this.dio, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;
  String? _humanRequestIdempotencyKey;

  @override
  Future<AgentAuthorization> inspectAuthorization(String userCode) async =>
      AgentAuthorization.fromJson(await _request(() => dio.get(
            '/api/agent-auth/device/authorization',
            queryParameters: {'userCode': userCode},
          )));

  @override
  Future<void> approveAuthorization(String userCode, Set<String> scopes) async {
    await _call(() => dio.post('/api/agent-auth/device/approve',
        data: {'userCode': userCode, 'scopes': scopes.toList()}));
  }

  @override
  Future<void> denyAuthorization(String userCode) async {
    await _call(() =>
        dio.post('/api/agent-auth/device/deny', data: {'userCode': userCode}));
  }

  @override
  Future<AgentSessionPage> listSessions(
          {int? beforeId, int limit = 20}) async =>
      AgentSessionPage.fromJson(Map<String, dynamic>.from(await _request(
          () => dio.get('/api/agent-auth/sessions', queryParameters: {
                if (beforeId != null) 'beforeId': beforeId,
                'limit': limit,
              })) as Map));

  @override
  Future<AgentSessionDetail> getSession(int id) async =>
      AgentSessionDetail.fromJson(
          await _request(() => dio.get('/api/agent-auth/sessions/$id')));

  @override
  Future<AgentSession> reduceScopes(int id, Set<String> scopes) async =>
      AgentSession.fromJson(await _request(() => dio.patch(
          '/api/agent-auth/sessions/$id/scopes',
          data: {'scopes': scopes.toList()})));

  @override
  Future<void> revokeSession(int id) async {
    await _call(() => dio.delete('/api/agent-auth/sessions/$id'));
  }

  @override
  Future<int> revokeAllSessions() async =>
      (await _request(() => dio.delete('/api/agent-auth/sessions')) as num)
          .toInt();

  @override
  Future<List<AgentRequestDraft>> listRequests() async {
    // HUMAN buyer requests use the canonical DS0.2 App read boundary.  Do
    // not fall back to `/api/agent-requests`: that compatibility endpoint
    // returns an AjaxResult shape and would make the App depend on a route
    // explicitly excluded from the DS runtime acceptance.
    final body = await _request(
      () => dio.get(
        '/app/v1/requests',
        options: _traceOptions('request-list'),
      ),
      machineResponse: true,
    );
    return _parseCanonicalRequestCollection(body);
  }

  @override
  Future<AgentRequestDraft> getRequest(int id) async =>
      _parseCanonicalRequest(
        await _request(
          () => dio.get(
            '/app/v1/requests/$id',
            // The task/request read is part of the same traceable DS ingress
            // boundary as submission and ordering; do not rely on gateway
            // generated traces for App recovery evidence.
            options: _traceOptions('request-read'),
          ),
          machineResponse: true,
        ),
      );

  @override
  Future<AgentRequestDraft> createHumanRequest({
    required int serviceId,
    required String capabilityRevision,
    required String title,
    required String brief,
    int? budgetMaxMinor,
  }) async {
    if (serviceId <= 0 ||
        title.trim().isEmpty ||
        brief.trim().isEmpty ||
        !RegExp(r'^sha256:[a-f0-9]{64}$').hasMatch(capabilityRevision)) {
      throw const AgentApiException('Request fields are invalid');
    }
    // The human request page keeps this repository instance across a retry.
    // Reuse the same logical key so an unknown result cannot create a second
    // draft; a new page/route receives a new repository and a new operation.
    final key = _humanRequestIdempotencyKey ??=
        'human-request:${DateTime.now().microsecondsSinceEpoch}';
    final response = await _request(
      () => dio.post(
        '/app/v1/requests',
        options: Options(headers: {
          'Idempotency-Key': key,
          'X-Operation-Trace-Id': 'trace-app-request-create-${_uuid.v4()}',
        }),
        data: <String, dynamic>{
          'capabilityId': 'service:$serviceId',
          'capabilityRevision': capabilityRevision,
          'goal': title.trim(),
          'deliverables': <String>[brief.trim()],
          'acceptanceCriteria': <String>['按需求说明完成并由买方在 App 中验收'],
          if (budgetMaxMinor != null) 'budgetMaxMinor': budgetMaxMinor,
          'currency': 'CREDITS',
        },
      ),
      machineResponse: true,
    );
    if (response is! Map) {
      throw const AgentApiException('Invalid server response');
    }
    final data = response['data'];
    if (data is! Map || data['requestId'] == null) {
      throw const AgentApiException('The server did not return a request id');
    }
    final requestId = int.tryParse(data['requestId'].toString());
    if (requestId == null || requestId <= 0) {
      throw const AgentApiException(
          'The server returned an invalid request id');
    }
    return getRequest(requestId);
  }

  @override
  Future<void> submitRequest(int id,
      {required int version, required String specHash}) async {
    if (version < 0 || !RegExp(r'^sha256:[a-f0-9]{64}$').hasMatch(specHash)) {
      throw const AgentApiException('Request submission facts are unavailable');
    }
    // The canonical App boundary requires an Idempotency-Key of at least
    // sixteen characters.  Keep the key stable for retries of the same
    // request/version while retaining enough room for small numeric IDs.
    final key = 'app-submit:$id:$version:v1';
    await _request(
        () => dio.post(
              '/app/v1/requests/$id/submissions',
              options: Options(headers: {
                'Idempotency-Key': key,
                'If-Match': '"$version"',
                'X-Operation-Trace-Id':
                    'trace-app-request-submit-${_uuid.v4()}',
              }),
              data: {'expectedSpecHash': specHash},
            ),
        machineResponse: true);
  }

  @override
  Future<AgentRequestDraft> approveRequest(int id) async =>
      AgentRequestDraft.fromJson(
          await _request(() => dio.post('/api/agent-requests/$id/approve')));

  @override
  Future<AgentRequestDraft> abandonRequest(int id) async =>
      _parseCanonicalRequest(
        await _request(
          () => dio.post(
            '/app/v1/requests/$id/abandon',
            options: Options(headers: <String, dynamic>{
              'Idempotency-Key': 'app-abandon:$id:v1',
              'X-Operation-Trace-Id': 'trace-app-request-abandon-${_uuid.v4()}',
            }),
          ),
          machineResponse: true,
        ),
      );

  AgentRequestDraft _parseCanonicalRequest(dynamic value) {
    if (value is! Map) {
      throw const AgentApiException('Invalid DS request response');
    }
    final envelope = Map<String, dynamic>.from(value);
    final data = envelope['data'];
    if (data is! Map) {
      throw const AgentApiException('DS request response is missing data');
    }
    final normalized = Map<String, dynamic>.from(data);
    normalized['id'] ??= normalized['requestId'];
    normalized['status'] ??= envelope['state'];
    _normalizeRequestNumbers(normalized);
    return AgentRequestDraft.fromJson(normalized);
  }

  List<AgentRequestDraft> _parseCanonicalRequestCollection(dynamic value) {
    if (value is! Map) {
      throw const AgentApiException('Invalid DS request collection response');
    }
    final envelope = Map<String, dynamic>.from(value);
    final data = envelope['data'];
    if (data is! Map || data['requests'] is! List) {
      throw const AgentApiException(
          'DS request collection response is missing requests');
    }
    return (data['requests'] as List).map((item) {
      if (item is! Map) {
        throw const AgentApiException('Invalid DS request collection item');
      }
      final normalized = Map<String, dynamic>.from(item);
      normalized['id'] ??= normalized['requestId'];
      normalized['status'] ??= normalized['state'];
      _normalizeRequestNumbers(normalized);
      // The collection intentionally returns a summary.  Full brief and
      // timestamps are fetched from the canonical detail route on review.
      normalized['brief'] ??= '';
      return AgentRequestDraft.fromJson(normalized);
    }).toList();
  }

  void _normalizeRequestNumbers(Map<String, dynamic> value) {
    for (final field in <String>[
      'id',
      'requestId',
      'version',
      'serviceId',
      'providerMemberId',
      'chatId',
      'initialMessageId',
    ]) {
      final raw = value[field];
      if (raw is String) {
        final parsed = int.tryParse(raw.trim());
        if (parsed != null) value[field] = parsed;
      }
    }
  }

  Future<void> _call(Future<Response<dynamic>> Function() operation) async {
    await _request(operation);
  }

  Future<dynamic> _request(Future<Response<dynamic>> Function() operation,
      {bool machineResponse = false}) async {
    try {
      final response = await operation();
      return machineResponse ? response.data : _data(response);
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  dynamic _data(Response<dynamic> response) {
    final body = response.data;
    if (body is! Map) throw const AgentApiException('Invalid server response');
    final map = Map<String, dynamic>.from(body);
    if ((map['code'] as num?)?.toInt() != 200) {
      throw AgentApiException(map['msg']?.toString() ?? 'Request failed',
          map['errorCode']?.toString());
    }
    return map['data'];
  }

  AgentApiException _mapError(DioException error) {
    final body = error.response?.data;
    if (body is Map) {
      final machineError = body['error'];
      if (machineError is Map) {
        return AgentApiException(
          machineError['message']?.toString() ?? 'Request failed',
          machineError['code']?.toString(),
        );
      }
      return AgentApiException(body['msg']?.toString() ?? 'Request failed',
          body['errorCode']?.toString());
    }
    return AgentApiException(error.message ?? 'Network request failed');
  }

  Options _traceOptions(String action) => Options(headers: <String, dynamic>{
        'X-Operation-Trace-Id': 'trace-app-$action-${_uuid.v4()}',
      });
}
