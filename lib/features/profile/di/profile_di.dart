import 'package:get_it/get_it.dart';
import '../injection_container.dart';

/// Profile模块的依赖注入类
class ProfileDI {
  /// 初始化Profile模块的所有依赖
  static Future<void> init(GetIt getIt) async {
    print('[ProfileDI] Initializing Profile module dependencies');
    
    // 调用现有的初始化方法
    await initProfileDependencies(getIt);
    
    print('[ProfileDI] Profile module dependencies initialized');
  }
} 