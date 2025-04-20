import 'network_info.dart';

/// 模拟的网络信息实现，总是返回已连接状态
/// 主要用于浏览器环境和开发测试
class MockNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}
