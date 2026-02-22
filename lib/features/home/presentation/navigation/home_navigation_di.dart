import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:go_router/go_router.dart';

import 'home_navigation_service.dart';
import 'real_home_navigation_service.dart';

/// Home导航模块的依赖注入配置
class HomeNavigationDI {
  // 私有构造函数，防止实例化
  HomeNavigationDI._();
  
  /// 注册真实的导航服务
  /// 
  /// 在主应用初始化时调用，以确保使用真实的导航服务
  static void registerRealNavigationService(GetIt sl, GoRouter router) {
    // 允许重新注册依赖
    sl.allowReassignment = true;
    
    // 注册真实的导航服务，替换预览环境中的简单实现
    sl.registerLazySingleton<HomeNavigationService>(
      () => RealHomeNavigationService(router),
    );
    
    // 恢复默认设置
    sl.allowReassignment = false;
    
    AppLogger.d('[HomeNavigationDI] 已注册RealHomeNavigationService');
  }
  
  /// 检查当前注册的HomeNavigationService类型
  static bool isUsingRealNavigationService(GetIt sl) {
    try {
      final service = sl<HomeNavigationService>();
      return service is RealHomeNavigationService;
    } catch (e) {
      return false;
    }
  }
} 