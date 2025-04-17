import 'dart:io' show Platform; // 需要导入 dart:io 来检测平台

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

@injectable // 标记为可注入
class AppInfoInterceptor extends Interceptor {
  final PackageInfo _packageInfo; // 依赖注入 PackageInfo

  AppInfoInterceptor(this._packageInfo); // 构造函数接收 PackageInfo

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 添加后端期望的头信息
    options.headers['clienttype'] = '1'; // 固定值
    options.headers['client'] = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'unknown'); // 根据平台设置
    options.headers['version'] = '100'; // Use fixed value '100' as per example

    print('[AppInfoInterceptor] Added clienttype, client, and fixed version (100) headers.'); // Update log for clarity
    
    // 继续请求流程
    handler.next(options);
  }
} 