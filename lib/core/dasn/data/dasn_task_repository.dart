import 'package:dio/dio.dart';

import '../domain/dasn_task_view.dart';

class DasnTaskApiException implements Exception {
  const DasnTaskApiException(this.message, {this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Read-only transport adapter for the DS 0.1 task projection endpoints.
abstract class DasnTaskRepository {
  Future<DasnTaskView> getTask(String taskTraceId);
  Future<DasnTaskView> getReceipt(String taskTraceId);
}

class DioDasnTaskRepository implements DasnTaskRepository {
  DioDasnTaskRepository(this.dio);

  final Dio dio;

  @override
  Future<DasnTaskView> getTask(String taskTraceId) async =>
      _get(taskTraceId, receipt: false);

  @override
  Future<DasnTaskView> getReceipt(String taskTraceId) async =>
      _get(taskTraceId, receipt: true);

  Future<DasnTaskView> _get(String taskTraceId, {required bool receipt}) async {
    _validateTaskTraceId(taskTraceId);
    try {
      final response = await dio.get(
        // The trusted App uses its normal member session.  Agent/CLI clients
        // continue to use the normative /agent/v1/tasks facade separately.
        '/app/v1/tasks/${Uri.encodeComponent(taskTraceId)}'
        '${receipt ? '/receipt' : ''}',
      );
      final body = response.data;
      if (body is! Map) {
        throw const DasnTaskApiException('Invalid DSN task response');
      }
      return DasnTaskView.fromJson(Map<String, dynamic>.from(body));
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  static void _validateTaskTraceId(String value) {
    if (!RegExp(r'^ttr_[A-Za-z0-9-]{16,100}$').hasMatch(value)) {
      throw const DasnTaskApiException('Invalid task trace id');
    }
  }

  DasnTaskApiException _mapError(DioException error) {
    final body = error.response?.data;
    if (body is Map && body['error'] is Map) {
      final detail = Map<String, dynamic>.from(body['error'] as Map);
      return DasnTaskApiException(
        detail['message']?.toString() ?? 'DSN task request failed',
        code: detail['code']?.toString(),
        statusCode: error.response?.statusCode,
      );
    }
    return DasnTaskApiException(
      error.message ?? 'Network request failed',
      statusCode: error.response?.statusCode,
    );
  }
}
