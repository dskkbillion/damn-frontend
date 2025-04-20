import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// 网络信息接口
abstract class NetworkInfo {
  /// 检查设备是否连接到互联网
  Future<bool> get isConnected;
}

/// 使用 InternetConnectionChecker 实现网络信息接口
class NetworkInfoImpl implements NetworkInfo {
<<<<<<< HEAD
  // Assuming connectionChecker is provided non-null by DI
=======
>>>>>>> origin/refactor/profile-module
  final InternetConnectionChecker connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
<<<<<<< HEAD
  Future<bool> get isConnected async {
    // 在Web平台上始终返回true，因为Web平台可能无法使用InternetConnectionChecker
    if (kIsWeb) {
      return true;
    }
    // 非Web平台使用connectionChecker
    return await connectionChecker.hasConnection;
=======
  Future<bool> get isConnected => connectionChecker.hasConnection;
}

/// Web平台网络信息实现
class WebNetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // Web平台无法可靠地检测网络状态，默认返回true
    return true;
>>>>>>> origin/refactor/profile-module
  }
}
