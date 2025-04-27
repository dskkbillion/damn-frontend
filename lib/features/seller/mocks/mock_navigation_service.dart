import 'package:mockito/mockito.dart';
import 'package:dskk_flutter_refactor/core/navigation/services/navigation_service.dart';

class MockNavigationService extends Mock implements INavigationService {
  @override
  Future<void> navigateTo(String route, {Map<String, dynamic>? arguments}) async {
    return Future.value();
  }
  
  @override
  Future<void> navigateBack() async {
    return Future.value();
  }
  
  @override
  Future<void> showDialog({required String title, required String content, String? confirmText}) async {
    return Future.value();
  }
  
  @override
  Future<bool> showConfirmDialog({
    required String title, 
    required String content, 
    String confirmText = "确认", 
    String cancelText = "取消"
  }) async {
    return Future.value(true); // 默认返回确认
  }
} 