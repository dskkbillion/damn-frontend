import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/app/app.dart';
import 'package:dskk_flutter_refactor/app/di/injection_container.dart';
import 'package:dskk_flutter_refactor/core/config/app_config.dart';

/// 订单模块模拟数据预览入口
/// 
/// 这个入口会默认启用模拟数据模式，用于展示和测试订单功能
/// 
/// 运行命令：
/// flutter run -t lib/previews/order_mock_preview.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 启用模拟数据模式
  AppConfig.enableMockMode();
  print('=== 订单模拟数据预览模式 ===');
  print('已启用模拟数据，可以在订单列表页面切换真实/模拟数据');
  
  // 初始化依赖注入
  await InjectionContainer.init();
  
  // 运行应用
  runApp(const DSKKApp());
}