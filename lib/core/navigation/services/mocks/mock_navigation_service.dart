import 'package:dskk_flutter_refactor/core/navigation/services/i_navigation_service.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';

/// INavigationService 的手动 Mock 实现，主要用于记录导航调用。
class MockNavigationService implements INavigationService {

  String? lastNavigatedRoute;
  Map<String, dynamic> lastNavigationArguments = {};

  void clearLastNavigation() {
    lastNavigatedRoute = null;
    lastNavigationArguments.clear();
  }

  void _logNavigation(String routeName, Map<String, dynamic> args) {
    lastNavigatedRoute = routeName;
    lastNavigationArguments = args;
    AppLogger.d('[MockNavigationService] Navigating to $routeName with args: $args');
  }

  @override
  Future<void> navigateToOrderDetail(String orderId) async {
     _logNavigation('OrderDetail', {'orderId': orderId});
  }

  @override
  Future<void> navigateToPayment(String orderId) async {
    _logNavigation('Payment', {'orderId': orderId /*, ... */});
  }

  @override
  Future<void> navigateToAfterSaleApplication(String orderId) async {
     _logNavigation('AfterSaleApplication', {'orderId': orderId});
  }

  @override
  Future<void> navigateToEvaluation(String orderId) async {
     _logNavigation('Evaluation', {'orderId': orderId});
  }

  @override
  Future<void> navigateToTrackingDetail(String orderId /*, String? shipmentId */) async {
     _logNavigation('TrackingDetail', {'orderId': orderId /*, 'shipmentId': shipmentId */});
  }

  @override
  Future<void> navigateToProductDetail(String productId) async {
    _logNavigation('ProductDetail', {'productId': productId});
  }

  @override
  Future<void> navigateToChat(/* Session info or Seller ID */ dynamic chatArgs) async {
     _logNavigation('Chat', {'chatArgs': chatArgs});
  }

  @override
  void goBack() {
    AppLogger.d('[MockNavigationService] Going back (pop).');
    // 在测试中可能不需要记录 goBack 的具体状态，但可以根据需要添加
  }

  @override
  Future<void> navigateTo(String path, {Object? extra}) async {
    _logNavigation(path, {'extra': extra});
  }
} 