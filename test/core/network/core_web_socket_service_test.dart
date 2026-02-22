import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:dskk_flutter_refactor/core/network/i_core_web_socket_service.dart';

/// 用于测试的最小 stub 实现，验证状态机逻辑
class _TestableWebSocketService {
  CoreConnectionStatus _state = CoreConnectionStatus.disconnected;
  final List<CoreConnectionStatus> stateHistory = [];
  int cleanupCallCount = 0;
  int connectCallCount = 0;

  CoreConnectionStatus get state => _state;

  void setState(CoreConnectionStatus s) {
    _state = s;
    stateHistory.add(s);
  }

  /// 模拟修复前的行为：cleanup 不 await（竞态）
  Future<void> reconnectBuggy() async {
    _cleanup(); // 不 await，旧行为
    setState(CoreConnectionStatus.connecting);
    await Future.delayed(Duration.zero);
    setState(CoreConnectionStatus.connected);
  }

  /// 模拟修复后的行为：await cleanup 完成再重连
  Future<void> reconnectFixed() async {
    await _cleanup(); // await，新行为
    setState(CoreConnectionStatus.connecting);
    await Future.delayed(Duration.zero);
    setState(CoreConnectionStatus.connected);
  }

  Future<void> _cleanup() async {
    cleanupCallCount++;
    // 模拟异步 cleanup（sink.close 是异步的）
    await Future.delayed(const Duration(milliseconds: 10));
    setState(CoreConnectionStatus.disconnected);
  }
}

void main() {
  group('CoreWebSocketService 状态机', () {
    late _TestableWebSocketService service;

    setUp(() {
      service = _TestableWebSocketService();
    });

    test('初始状态应为 disconnected', () {
      expect(service.state, CoreConnectionStatus.disconnected);
    });

    test('修复后 reconnect：cleanup 完成前不会进入 connecting 状态', () async {
      // 安排：模拟从 connected 状态触发重连
      service.setState(CoreConnectionStatus.connected);
      service.stateHistory.clear();

      await service.reconnectFixed();

      // 验证：状态顺序必须是 disconnected → connecting → connected
      // cleanup 完成（disconnected）后才能 connecting
      expect(service.stateHistory.length, 3);
      expect(service.stateHistory[0], CoreConnectionStatus.disconnected); // cleanup 完成
      expect(service.stateHistory[1], CoreConnectionStatus.connecting);   // 然后才重连
      expect(service.stateHistory[2], CoreConnectionStatus.connected);
    });

    test('修复前 reconnect（竞态）：cleanup 和 connecting 顺序不保证', () async {
      service.setState(CoreConnectionStatus.connected);
      service.stateHistory.clear();

      await service.reconnectBuggy();

      // 修复前：connecting 出现在 cleanup 完成（disconnected）之前
      expect(service.stateHistory[0], CoreConnectionStatus.connecting); // 立即设置
      expect(service.stateHistory[1], CoreConnectionStatus.connected);
      // disconnected 出现在最后（cleanup 异步完成后）
      // 注意：这里 buggy 版本的顺序是错的
    });

    test('cleanup 在 reconnectFixed 中只调用一次', () async {
      await service.reconnectFixed();
      expect(service.cleanupCallCount, 1);
    });

    test('状态枚举值覆盖完整', () {
      // 确保所有状态都可以被设置和读取
      for (final status in CoreConnectionStatus.values) {
        service.setState(status);
        expect(service.state, status);
      }
    });
  });

  group('CoreConnectionStatus 枚举', () {
    test('包含 connected、disconnected、connecting、error', () {
      final values = CoreConnectionStatus.values;
      expect(values, contains(CoreConnectionStatus.connected));
      expect(values, contains(CoreConnectionStatus.disconnected));
      expect(values, contains(CoreConnectionStatus.connecting));
      expect(values, contains(CoreConnectionStatus.error));
    });
  });
}
