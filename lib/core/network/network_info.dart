import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// 网络连接信息抽象接口
abstract class NetworkInfo {
  /// 检查是否连接到网络
  Future<bool> get isConnected;
}

/// 网络连接信息实现类
class NetworkInfoImpl implements NetworkInfo {
  // Assuming connectionChecker is provided non-null by DI
  final InternetConnectionChecker connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected async {
    // 在Web平台上始终返回true，因为Web平台可能无法使用InternetConnectionChecker
    if (kIsWeb) {
      return true;
    }
    // 非Web平台使用connectionChecker
    return await connectionChecker.hasConnection;
  }
}
