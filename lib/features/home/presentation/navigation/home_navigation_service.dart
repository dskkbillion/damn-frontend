/// Home模块的导航服务接口
/// 
/// 定义Home模块的导航方法接口，解耦业务逻辑和路由实现
/// 业务逻辑（如HomeBloc）通过依赖注入使用导航服务，而不直接依赖路由实现
abstract class HomeNavigationService {
  /// 导航到产品详情页
  /// 
  /// [productId] 产品ID
  void navigateToProductDetail(String productId);
  
  /// 导航到搜索页
  /// 
  /// [query] 搜索关键词，可选
  void navigateToSearch(String? query);
  
  /// 导航到分类详情页
  /// 
  /// [categoryId] 分类ID
  void navigateToCategoryDetail(String categoryId);
  
  /// 导航到外部链接
  /// 
  /// [url] 外部链接URL
  void navigateToUrl(String url);
  
  /// 显示推荐确认对话框
  /// 
  /// [productId] 产品ID
  /// [productName] 产品名称
  void showRecommendConfirmation(String productId, String productName);
}