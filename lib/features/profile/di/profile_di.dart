import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import '../injection_container.dart';

/// Profile模块的依赖注入类
class ProfileDI {
  /// 初始化Profile模块的所有依赖
  static Future<void> init(GetIt getIt) async {
    AppLogger.d('[ProfileDI] Initializing Profile module dependencies');
    
    // 调用现有的初始化方法
    await initProfileDependencies(getIt);
    
    AppLogger.d('[ProfileDI] Profile module dependencies initialized');
  }
} 