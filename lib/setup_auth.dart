import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 创建安全存储实例
  const secureStorage = FlutterSecureStorage();
  
  // 设置token和userId
  // 注意：这里使用的是示例值，请替换为实际的token和userId
  await secureStorage.write(
    key: 'auth_token',
    value: 'PLACEHOLDER_TOKEN_FOR_DEV'
  );
  await secureStorage.write(
    key: 'user_id',
    value: '10318'
  );
  
  AppLogger.d('认证信息已设置完成！');
  AppLogger.d('Token和UserId已存储在安全存储中。');
  AppLogger.d('现在可以运行main_home.dart查看home模块。');
}