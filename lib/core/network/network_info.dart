import 'package:internet_connection_checker/internet_connection_checker.dart';

/// 网络信息接口
abstract class NetworkInfo {
  /// 检查是否连接到互联网
  Future<bool> get isConnected;
}

/// 网络信息实现
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  NetworkInfoImpl({InternetConnectionChecker? connectionChecker}) 
      : connectionChecker = connectionChecker ?? InternetConnectionChecker();

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}

/// 模拟网络信息实现，始终返回已连接
class MockNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
} 