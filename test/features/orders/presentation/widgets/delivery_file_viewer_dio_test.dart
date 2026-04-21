
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';

/// 验证 DeliveryFileViewer 的 Dio 生命周期管理逻辑（状态机）
///
/// 不依赖真实网络，只测试 Dio 实例的创建和关闭行为。
/// Widget 层面的集成测试需要 mock 网络层，超出当前范围。

/// 模拟 _DeliveryFileViewerState 中的 Dio 生命周期管理
class _DioLifecycleManager {
  final Dio _dio = Dio();
  CancelToken? _cancelToken;
  bool _isDownloading = false;
  bool _disposed = false;

  bool get isDownloading => _isDownloading;
  bool get disposed => _disposed;

  void startDownload() {
    _cancelToken = CancelToken();
    _isDownloading = true;
  }

  void cancelDownload() {
    _cancelToken?.cancel();
    _isDownloading = false;
  }

  void finishDownload() {
    _isDownloading = false;
  }

  void dispose() {
    _cancelToken?.cancel();
    _dio.close();
    _disposed = true;
  }

  bool get isCancelTokenCancelled => _cancelToken?.isCancelled ?? false;
}

void main() {
  group('DeliveryFileViewer Dio 生命周期管理', () {
    late _DioLifecycleManager manager;

    setUp(() {
      manager = _DioLifecycleManager();
    });

    tearDown(() {
      if (!manager.disposed) {
        manager.dispose();
      }
    });

    test('初始状态：未在下载', () {
      expect(manager.isDownloading, isFalse);
      expect(manager.disposed, isFalse);
    });

    test('startDownload 后：isDownloading 为 true', () {
      manager.startDownload();
      expect(manager.isDownloading, isTrue);
    });

    test('cancelDownload：isDownloading 变为 false，cancelToken 被取消', () {
      manager.startDownload();
      manager.cancelDownload();
      expect(manager.isDownloading, isFalse);
      expect(manager.isCancelTokenCancelled, isTrue);
    });

    test('finishDownload：isDownloading 变为 false', () {
      manager.startDownload();
      manager.finishDownload();
      expect(manager.isDownloading, isFalse);
    });

    test('dispose：cancelToken 被取消，Dio 关闭，disposed 标记为 true', () {
      manager.startDownload();
      manager.dispose();
      expect(manager.disposed, isTrue);
      expect(manager.isCancelTokenCancelled, isTrue);
    });

    test('dispose 时若未在下载：不抛出异常', () {
      expect(() => manager.dispose(), returnsNormally);
      expect(manager.disposed, isTrue);
    });

    test('CancelToken 在 dispose 后标记为已取消', () {
      manager.startDownload();
      final token = manager._cancelToken;
      manager.dispose();
      expect(token?.isCancelled, isTrue);
    });
  });

  group('Dio 实例关闭行为', () {
    test('close() 后 Dio 不再接受新请求', () async {
      final dio = Dio();
      dio.close();
      // 关闭后发请求应抛出异常（DioException 或 StateError）
      expect(
        () async => await dio.get('http://example.com'),
        throwsA(anything),
      );
    });

    test('close(force: false) 正常关闭（不强制终止进行中请求）', () {
      final dio = Dio();
      expect(() => dio.close(force: false), returnsNormally);
    });
  });
}
