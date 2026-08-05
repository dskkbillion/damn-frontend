import 'package:dio/dio.dart';

import '../domain/dsn_provider_task_models.dart';

/// Read-only Provider Task Center transport.
///
/// This is intentionally not backed by `/api/agent-requests`: that endpoint
/// is the buyer's request list and using it for Provider work would mix
/// principals.  The backend read projection is therefore a separate
/// canonical contract at `/provider/v1/tasks` and
/// `/provider/v1/tasks/{taskTraceId}`.
abstract class DsnProviderTaskRepository {
  Future<DsnProviderTaskPage> listAssignedTasks(
      {String? cursor, int limit = 20});
  Future<DsnProviderTask> getAssignedTask(String taskTraceId);
}

class DioDsnProviderTaskRepository implements DsnProviderTaskRepository {
  DioDsnProviderTaskRepository(this.dio);

  final Dio dio;

  @override
  Future<DsnProviderTaskPage> listAssignedTasks(
      {String? cursor, int limit = 20}) async {
    try {
      final response = await dio.get(
        '/provider/v1/tasks',
        queryParameters: <String, dynamic>{
          if (cursor != null && cursor.trim().isNotEmpty) 'cursor': cursor,
          'limit': limit,
        },
      );
      return DsnProviderTaskPage.fromJson(_body(response));
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<DsnProviderTask> getAssignedTask(String taskTraceId) async {
    if (!RegExp(r'^ttr_[A-Za-z0-9-]{16,100}$').hasMatch(taskTraceId.trim())) {
      throw const DsnProviderTaskApiException(
        'Task trace ID is invalid',
        code: 'INVALID_TASK_TRACE_ID',
      );
    }
    try {
      final response = await dio.get(
        '/provider/v1/tasks/${Uri.encodeComponent(taskTraceId.trim())}',
      );
      return DsnProviderTask.fromDetailEnvelope(_body(response));
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Map<String, dynamic> _body(Response<dynamic> response) {
    final body = response.data;
    if (body is! Map) {
      throw const DsnProviderTaskApiException(
        'Provider task response is not an object',
        code: 'INVALID_PROVIDER_TASK_RESPONSE',
      );
    }
    return Map<String, dynamic>.from(body);
  }

  DsnProviderTaskApiException _mapError(DioException error) {
    final body = error.response?.data;
    if (body is Map && body['error'] is Map) {
      final detail = Map<String, dynamic>.from(body['error'] as Map);
      final status = error.response?.statusCode;
      // A 404/405 is kept distinct from ordinary transport failure.  The
      // Task Center renders it as an explicit backend-read capability gap
      // instead of falling back to a buyer-scoped endpoint.
      final code = detail['code']?.toString() ??
          (status == 404 || status == 405
              ? 'PROVIDER_TASK_READ_NOT_AVAILABLE'
              : null);
      return DsnProviderTaskApiException(
        detail['message']?.toString() ?? 'Provider task read failed',
        code: code,
        statusCode: status,
      );
    }
    final status = error.response?.statusCode;
    return DsnProviderTaskApiException(
      error.message ?? 'Provider task read failed',
      code: status == 404 || status == 405
          ? 'PROVIDER_TASK_READ_NOT_AVAILABLE'
          : null,
      statusCode: status,
    );
  }
}

/// Explicit Provider Agent read adapter over the canonical Provider Task
/// projection.  [agentDio] must be configured with a live Agent session; this
/// wrapper exists so an App route cannot accidentally reuse its Member Dio and
/// claim to have exercised the Provider Agent identity.
class DioDsnProviderAgentTaskRepository implements DsnProviderTaskRepository {
  DioDsnProviderAgentTaskRepository(Dio agentDio)
      : _delegate = DioDsnProviderTaskRepository(agentDio);

  final DioDsnProviderTaskRepository _delegate;

  @override
  Future<DsnProviderTaskPage> listAssignedTasks({
    String? cursor,
    int limit = 20,
  }) =>
      _delegate.listAssignedTasks(cursor: cursor, limit: limit);

  @override
  Future<DsnProviderTask> getAssignedTask(String taskTraceId) =>
      _delegate.getAssignedTask(taskTraceId);
}

class DsnProviderTaskApiException implements Exception {
  const DsnProviderTaskApiException(
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
