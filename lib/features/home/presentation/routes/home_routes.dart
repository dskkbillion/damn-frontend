import 'package:go_router/go_router.dart';

/// Home模块的路由定义
/// 
/// ⚠️ 警告：此路由配置已废弃！
/// 所有Home路由现在统一在 lib/app/navigation/app_router.dart 中管理
/// 使用 SmartRouter 系统避免 Navigator Key 冲突
/// 
/// 请勿在新代码中使用此路由配置
class HomeRoutes {
  // 私有构造函数，防止实例化
  HomeRoutes._();

  // 路由路径常量（保留用于引用）
  /// 主页路径
  static const String homePath = '/home';
  
  /// 产品详情路径（子路由，完整路径为 /home/product/:productId）
  static const String productDetailPath = 'product/:productId';
  
  /// 搜索路径（子路由，完整路径为 /home/search）
  static const String searchPath = 'search';
  
  /// 分类详情路径（子路由，完整路径为 /home/category/:categoryId）
  static const String categoryDetailPath = 'category/:categoryId';
  
  // 路由名称常量
  /// 主页名称
  static const String homeName = 'home';
  
  /// 产品详情名称
  static const String productDetailName = 'productDetail';
  
  /// 搜索名称
  static const String searchName = 'search';
  
  /// 分类详情名称
  static const String categoryDetailName = 'categoryDetail';

  // 通过静态getter暴露路由列表
  /// 获取Home模块的所有路由
  /// 
  /// ⚠️ 已废弃：返回空列表避免与主应用路由冲突
  /// 所有路由现在在 lib/app/navigation/app_router.dart 中统一管理
  static List<RouteBase> get routes => [];
}