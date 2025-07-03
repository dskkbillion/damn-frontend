import 'package:go_router/go_router.dart';

/// 卖家模块路由配置
/// 
/// ⚠️ 警告：此路由配置已废弃！
/// 所有卖家路由现在统一在 lib/app/navigation/app_router.dart 中管理
/// 使用 SmartRouter 系统避免 Navigator Key 冲突
/// 
/// 请勿在新代码中使用此路由配置
class SellerRoutes {
  /// 路由基础路径
  static const String basePath = '/seller';
  
  /// 路由路径定义（仅保留路径常量用于引用）
  static const String home = basePath;
  static const String products = '$basePath/products';
  static const String productCreate = '$basePath/products/create';
  static const String productEdit = '$basePath/products/:id/edit';
  static const String authentication = '$basePath/authentication';
  static const String authenticationApply = '$basePath/authentication/:type/apply';
  static const String authenticationDetail = '$basePath/authentication/:type/detail';
  static const String timeManagement = '$basePath/time';
  static const String autoReply = '$basePath/auto-reply';
  static const String notifications = '$basePath/notifications';
  static const String afterSalesReview = '$basePath/after-sales';
  static const String afterSalesDetail = '$basePath/after-sales/:id';
  static const String storeSettings = '$basePath/settings';
  static const String statistics = '$basePath/statistics';
  static const String wallet = '$basePath/wallet';
  
  /// 获取卖家模块路由
  /// 
  /// ⚠️ 已废弃：返回空列表避免与主应用路由冲突
  /// 所有路由现在在 lib/app/navigation/app_router.dart 中统一管理
  static List<RouteBase> get routes => [];
  
  /// 根据路径和参数构建完整路径
  /// 
  /// 保留此工具方法用于路径构建
  static String buildPath(String path, {Map<String, String>? params}) {
    if (params == null || params.isEmpty) {
      return path;
    }
    
    String result = path;
    for (final entry in params.entries) {
      result = result.replaceAll(':${entry.key}', entry.value);
    }
    return result;
  }
} 