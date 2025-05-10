import 'package:go_router/go_router.dart';
import 'home_navigation_service.dart';
import '../routes/home_routes.dart';

/// Home模块的实际导航服务实现
/// 使用GoRouter进行真实导航
class RealHomeNavigationService implements HomeNavigationService {
  final GoRouter router;
  
  RealHomeNavigationService(this.router);
  
  @override
  void navigateToProductDetail(String productId) {
    print('RealHomeNavigationService: 导航到产品详情页 ID=$productId');
    // 使用命名路由导航到产品详情页
    router.pushNamed(
      HomeRoutes.productDetailName,
      pathParameters: {'productId': productId},
    );
  }
  
  @override
  void navigateToSearch(String? query) {
    print('RealHomeNavigationService: 导航到搜索页 query=$query');
    // 导航到搜索页，可选传递查询参数
    final queryParams = query != null ? {'q': query} : <String, String>{};
    router.pushNamed(
      HomeRoutes.searchName,
      queryParameters: queryParams,
    );
  }
  
  @override
  void navigateToCategoryDetail(String categoryId) {
    print('RealHomeNavigationService: 导航到分类详情页 ID=$categoryId');
    // 导航到分类详情页
    router.pushNamed(
      HomeRoutes.categoryDetailName,
      pathParameters: {'categoryId': categoryId},
    );
  }
  
  @override
  void navigateToUrl(String url) {
    print('RealHomeNavigationService: 导航到外部链接 url=$url');
    // 这里需要使用平台特定的方法来打开URL
    // 在实际实现中可能需要使用url_launcher包
    // 例如: await launchUrl(Uri.parse(url));
  }
  
  @override
  void showRecommendConfirmation(String productId, String productName) {
    print('RealHomeNavigationService: 显示推荐确认对话框 ID=$productId, 名称=$productName');
    // 这通常是UI层面的操作，需要传入BuildContext
    // 在实际实现中，可能需要传递一个回调到UI层
  }
} 