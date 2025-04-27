/// 定义应用范围内的导航操作接口契约。
/// 功能模块（如 Orders）通过此接口发起导航请求，
/// 而具体的实现（如使用 go_router 或 Navigator 2.0）则在 App 层或 Core 层提供。
abstract class INavigationService {

  /// 导航到订单详情页面。
  Future<void> navigateToOrderDetail(String orderId);

  /// 导航到支付页面/流程。
  /// 参数可能需要根据支付流程的设计来确定。
  Future<void> navigateToPayment(String orderId /*, other params? */);

  /// 导航到售后申请页面。
  Future<void> navigateToAfterSaleApplication(String orderId);

  /// 导航到评价提交页面。
  Future<void> navigateToEvaluation(String orderId);

  /// 导航到物流追踪详情页面。
  Future<void> navigateToTrackingDetail(String orderId /*, String? shipmentId */);

  /// 导航到商品详情页面。
  Future<void> navigateToProductDetail(String productId);

  /// 导航到与卖家/客服的聊天页面。
  /// 参数可能需要根据聊天模块的设计来确定。
  Future<void> navigateToChat(dynamic chatArgs);

  /// 返回上一页。
  void goBack(); // 或者 void pop();

  // --- 可以根据需要添加更多导航方法 ---

  /// 通用导航方法 (根据需要添加)
  Future<void> navigateTo(String path, {Object? extra});
} 