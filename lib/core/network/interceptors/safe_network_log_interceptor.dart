import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';

typedef NetworkLogSink = void Function(String message);

/// Logs network lifecycle metadata without headers, query values, or bodies.
///
/// Dio's built-in [LogInterceptor] prints request headers by default and can
/// expose bearer tokens after the authentication interceptor runs. Keeping the
/// formatter here deliberately small makes secrets unavailable to the sink.
class SafeNetworkLogInterceptor extends Interceptor {
  SafeNetworkLogInterceptor({NetworkLogSink? log})
      : _log = log ?? ((message) => AppLogger.d(message, 'HTTP'));

  final NetworkLogSink _log;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log('--> ${options.method} ${_path(options)}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final request = response.requestOptions;
    _log(
      '<-- ${response.statusCode ?? 'unknown'} '
      '${request.method} ${_path(request)}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final request = err.requestOptions;
    _log(
      '<-- ERROR ${err.response?.statusCode ?? err.type.name} '
      '${request.method} ${_path(request)}',
    );
    handler.next(err);
  }

  String _path(RequestOptions options) {
    final path = options.uri.path;
    return path.isEmpty ? '/' : path;
  }
}
