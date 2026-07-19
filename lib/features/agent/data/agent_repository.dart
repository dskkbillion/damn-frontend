import 'package:dio/dio.dart';
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
  Future<AgentRequestDraft> approveRequest(int id);
  Future<AgentRequestDraft> abandonRequest(int id);
}

class DioAgentRepository implements AgentRepository {
  final Dio dio;
  DioAgentRepository(this.dio);

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
    final data = await _request(() => dio.get('/api/agent-requests')) as List;
    return data
        .map((item) =>
            AgentRequestDraft.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  @override
  Future<AgentRequestDraft> getRequest(int id) async =>
      AgentRequestDraft.fromJson(
          await _request(() => dio.get('/api/agent-requests/$id')));

  @override
  Future<AgentRequestDraft> approveRequest(int id) async =>
      AgentRequestDraft.fromJson(
          await _request(() => dio.post('/api/agent-requests/$id/approve')));

  @override
  Future<AgentRequestDraft> abandonRequest(int id) async =>
      AgentRequestDraft.fromJson(
          await _request(() => dio.post('/api/agent-requests/$id/abandon')));

  Future<void> _call(Future<Response<dynamic>> Function() operation) async {
    await _request(operation);
  }

  Future<dynamic> _request(
      Future<Response<dynamic>> Function() operation) async {
    try {
      final response = await operation();
      return _data(response);
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
      return AgentApiException(body['msg']?.toString() ?? 'Request failed',
          body['errorCode']?.toString());
    }
    return AgentApiException(error.message ?? 'Network request failed');
  }
}
