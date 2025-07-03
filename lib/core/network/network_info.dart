import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:injectable/injectable.dart';

/// 网络信息接口
abstract class NetworkInfo {
  /// 检查设备是否连接到互联网
  Future<bool> get isConnected;
}

/// 网络信息实现类 - 生产环境使用
@LazySingleton(as: NetworkInfo)
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}

/// Web平台网络信息实现
class WebNetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // Web平台无法可靠地检测网络状态，默认返回true
    return true;
  }
}
