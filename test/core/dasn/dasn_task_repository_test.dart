import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/dasn/data/dasn_task_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads task projection with a fresh operation trace', () async {
    final dio = Dio();
    String? path;
    String? trace;
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      path = options.path;
      trace = options.headers['X-Operation-Trace-Id']?.toString();
      handler.resolve(Response(
        requestOptions: options,
        data: _taskEnvelope(),
      ));
    }));

    final view = await DioDasnTaskRepository(dio)
        .getTask('ttr_1234567890abcdef');

    expect(path, '/app/v1/tasks/ttr_1234567890abcdef');
    expect(trace, startsWith('trace-app-task-read-'));
    expect(view.taskTraceId, 'ttr_1234567890abcdef');
  });

  test('reads receipt projection with a distinct receipt trace', () async {
    final dio = Dio();
    String? path;
    String? trace;
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      path = options.path;
      trace = options.headers['X-Operation-Trace-Id']?.toString();
      handler.resolve(Response(
        requestOptions: options,
        data: _taskEnvelope(),
      ));
    }));

    await DioDasnTaskRepository(dio).getReceipt('ttr_1234567890abcdef');

    expect(path, '/app/v1/tasks/ttr_1234567890abcdef/receipt');
    expect(trace, startsWith('trace-app-task-receipt-'));
  });
}

Map<String, dynamic> _taskEnvelope() => <String, dynamic>{
      'taskTraceId': 'ttr_1234567890abcdef',
      'operationTraceId': 'trace-task-test',
      'task': <String, dynamic>{
        'taskLifecycle': 'RUNNING',
        'responsibilityAction': 'NONE',
        'syncStatus': 'SYNCED',
        'waitingOn': 'NONE',
        'nextActions': <dynamic>[],
      },
      'data': <String, dynamic>{},
    };
