import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 创建安全存储实例
  final secureStorage = const FlutterSecureStorage();
  
  // 设置token和userId
  // 注意：这里使用的是示例值，请替换为实际的token和userId
  await secureStorage.write(
    key: 'auth_token',
    value: 'eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6ImRlMTVjNTY0LTQ0NDYtNDhiNy1iNDEwLWM0MjI2YTg1OWY1MiJ9.SRBboA2sai7wK_KVVPeIYZ-XeShNMk8DeT78pxWR6MpigNw0f1W85UeMDC324pr7xCLXJ_KqqnsSlOUK9DPSxg'
  );
  await secureStorage.write(
    key: 'user_id',
    value: '10318'
  );
  
  print('认证信息已设置完成！');
  print('Token和UserId已存储在安全存储中。');
  print('现在可以运行main_home.dart查看home模块。');
}