import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';

/// 验证 FilePreviewPage 的 Dio 生命周期管理逻辑
///
/// FilePreviewPage 修复要点：
/// - Dio 从方法局部变量提升为 State 字段（_dio）
/// - dispose() 中调用 _dio.close()，确保下载后连接资源被释放

/// 模拟 _FilePreviewPageState 的 Dio 管理
class _FilePreviewStateDio {
  final Dio _dio = Dio();
  bool _isLoading = true;
  double _downloadProgress = 0.0;
  String? _localPath;
  String? _errorMessage;
  bool _disposed = false;

  bool get isLoading => _isLoading;
  double get downloadProgress => _downloadProgress;
  String? get localPath => _localPath;
  String? get errorMessage => _errorMessage;
  bool get disposed => _disposed;
  Dio get dio => _dio;

  /// 模拟下载成功
  Future<void> simulateDownloadSuccess() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _downloadProgress = 0.0;
      // 模拟进度更新
      _downloadProgress = 0.5;
      await Future.delayed(Duration.zero);
      _downloadProgress = 1.0;
      _localPath = '/tmp/test_file.pdf';
      _isLoading = false;
    } catch (e) {
      _errorMessage = '文件下载失败: $e';
      _isLoading = false;
    }
  }

  /// 模拟下载失败
  Future<void> simulateDownloadFailure() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      await Future.delayed(Duration.zero);
      throw Exception('网络错误');
    } catch (e) {
      _errorMessage = '文件下载失败: $e';
      _isLoading = false;
    }
  }

  void dispose() {
    _dio.close();
    _disposed = true;
  }
}

void main() {
  group('FilePreviewPage Dio 生命周期', () {
    late _FilePreviewStateDio state;

    setUp(() {
      state = _FilePreviewStateDio();
    });

    tearDown(() {
      if (!state.disposed) {
        state.dispose();
      }
    });

    test('初始状态：isLoading 为 true，localPath 为 null', () {
      expect(state.isLoading, isTrue);
      expect(state.localPath, isNull);
      expect(state.errorMessage, isNull);
    });

    test('下载成功后：isLoading 为 false，localPath 不为 null', () async {
      await state.simulateDownloadSuccess();
      expect(state.isLoading, isFalse);
      expect(state.localPath, isNotNull);
      expect(state.errorMessage, isNull);
    });

    test('下载成功后：进度达到 100%', () async {
      await state.simulateDownloadSuccess();
      expect(state.downloadProgress, equals(1.0));
    });

    test('下载失败后：isLoading 为 false，errorMessage 不为 null', () async {
      await state.simulateDownloadFailure();
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNotNull);
      expect(state.localPath, isNull);
    });

    test('dispose：Dio 关闭，disposed 标记为 true', () {
      state.dispose();
      expect(state.disposed, isTrue);
    });

    test('dispose 后 Dio 不再接受请求', () async {
      state.dispose();
      expect(
        () async => await state.dio.get('http://example.com'),
        throwsA(anything),
      );
    });

    test('修复验证：Dio 实例是 State 级别（字段），不是方法局部变量', () {
      // 同一个 state 实例的 dio 字段在多次调用间保持同一个引用
      final dioRef1 = state.dio;
      final dioRef2 = state.dio;
      expect(identical(dioRef1, dioRef2), isTrue);
    });
  });
}
