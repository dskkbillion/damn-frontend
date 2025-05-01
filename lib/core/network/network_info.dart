import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:injectable/injectable.dart';

/// 网络信息接口
abstract class NetworkInfo {
  /// 检查设备是否连接到互联网
  Future<bool> get isConnected;
}

/// 网络信息实现类
// @LazySingleton(as: NetworkInfo) - 移除注解避免冲突
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}

/// 模拟网络信息实现，始终返回已连接
class MockNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}

/// Web平台网络信息实现
class WebNetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // Web平台无法可靠地检测网络状态，默认返回true
    return true;
  }
}
