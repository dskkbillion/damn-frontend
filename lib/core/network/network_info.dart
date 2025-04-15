import 'package:internet_connection_checker/internet_connection_checker.dart';

/// 网络信息接口，用于检查网络连接状态
abstract class NetworkInfo {
  /// 检查是否连接到网络
  Future<bool> get isConnected;
}

/// 网络信息实现类
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}