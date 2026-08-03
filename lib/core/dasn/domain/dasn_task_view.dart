import 'task_projection.dart';

/// Transport adapter for the DS 0.1 read-only task/receipt envelope.
///
/// Product facts remain opaque maps here; only the tri-axis `task` object is
/// interpreted by the generic interaction reducer.  This keeps order,
/// payment, delivery and dispute changes out of the core state machine.
class DasnTaskView {
  DasnTaskView({
    required this.taskTraceId,
    required this.operationTraceId,
    required this.projection,
    this.data = const <String, dynamic>{},
  });

  final String taskTraceId;
  final String operationTraceId;
  final TaskProjection projection;
  final Map<String, dynamic> data;

  Map<String, dynamic>? get receipt {
    final raw = data['receipt'];
    return raw is Map ? Map<String, dynamic>.from(raw) : null;
  }

  factory DasnTaskView.fromJson(Map<String, dynamic> json) {
    final taskTraceId = _requiredString(json, 'taskTraceId');
    final operationTraceId = _requiredString(json, 'operationTraceId');
    final rawTask = json['task'];
    if (rawTask is! Map) {
      throw DasnProjectionFormatException(
        'DASN response.task must be an object',
        rawTask,
      );
    }
    final rawData = json['data'];
    if (rawData != null && rawData is! Map) {
      throw DasnProjectionFormatException(
        'DASN response.data must be an object when present',
        rawData,
      );
    }
    return DasnTaskView(
      taskTraceId: taskTraceId,
      operationTraceId: operationTraceId,
      projection: TaskProjection.fromJson(Map<String, dynamic>.from(rawTask)),
      data: rawData == null
          ? const <String, dynamic>{}
          : Map<String, dynamic>.from(rawData as Map),
    );
  }

  factory DasnTaskView.fromMap(Map<String, dynamic> json) =>
      DasnTaskView.fromJson(json);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'taskTraceId': taskTraceId,
        'operationTraceId': operationTraceId,
        'task': projection.toJson(),
        if (data.isNotEmpty) 'data': data,
      };

  static String _requiredString(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value is! String || value.trim().isEmpty) {
      throw DasnProjectionFormatException(
        'DASN response.$field must be a non-empty string',
        value,
      );
    }
    return value;
  }
}
