import 'entities/analytics_event.dart';
import 'services/analytics_api_service.dart';
import 'services/device_info_service.dart';
import 'services/user_identification_service.dart';
import 'services/event_buffer.dart';

/// 分析管理器
/// 埋点系统的核心接口，提供统一的事件记录方法
class AnalyticsManager {
  final AnalyticsApiService _apiService;
  final DeviceInfoService _deviceService;
  final UserIdentificationService _userService;
  final EventBuffer _eventBuffer;

  AnalyticsManager(
    this._apiService,
    this._deviceService,
    this._userService,
    this._eventBuffer,
  );

  /// 记录通用事件
  Future<void> trackEvent({
    required String businessType,
    String? path,
    int? businessId,
    Map<String, dynamic>? feature,
    int? interval,
  }) async {
    try {
      print('[AnalyticsManager] 开始记录事件: $businessType, 路径: $path, ID: $businessId');
      
      final event = AnalyticsEvent(
        path: path,
        businessType: businessType,
        businessId: businessId,
        feature: feature,
        deviceInfo: await _deviceService.getDeviceInfo(),
        userSign: await _userService.getUserSign(),
        interval: interval,
      );

      print('[AnalyticsManager] 事件创建成功: ${event.toJson()}');
      _eventBuffer.addEvent(event);
      print('[AnalyticsManager] 事件已添加到缓冲区');
    } catch (e) {
      print('[AnalyticsManager] 记录事件失败: $e');
      // 不抛出异常，避免影响正常业务流程
    }
  }

  /// 记录页面浏览事件
  Future<void> trackPageView({
    required String path,
    int? businessId,
    String? pageType,
    String? source,
    int? stayDuration,
    Map<String, dynamic>? additionalData,
  }) async {
    print('[AnalyticsManager] 记录页面浏览事件: $path, 类型: $pageType, 来源: $source');
    
    final feature = <String, dynamic>{
      'page_type': pageType ?? 'unknown',
      'is_visitor': await _userService.isGuest(),
      if (source != null) 'source': source,
      if (additionalData != null) ...additionalData,
    };

    await trackEvent(
      businessType: 'pv',
      path: path,
      businessId: businessId,
      feature: feature,
      interval: stayDuration,
    );
  }

  /// 记录点击事件
  Future<void> trackClick({
    required String path,
    required int targetId,
    required String clickType,
    int? position,
    String? source,
    Map<String, dynamic>? additionalData,
  }) async {
    print('[AnalyticsManager] 记录点击事件: $path, 目标ID: $targetId, 类型: $clickType');
    
    final feature = <String, dynamic>{
      'click_type': clickType,
      'is_visitor': await _userService.isGuest(),
      if (position != null) 'position': position,
      if (source != null) 'source': source,
      if (additionalData != null) ...additionalData,
    };

    await trackEvent(
      businessType: 'click',
      path: path,
      businessId: targetId,
      feature: feature,
    );
  }

  /// 记录商品浏览事件
  Future<void> trackProductView({
    required int productId,
    String? source,
    int? position,
    String? scenario,
    String? recId,
    Map<String, dynamic>? additionalData,
  }) async {
    final feature = <String, dynamic>{
      'view_type': 'product',
      'is_visitor': await _userService.isGuest(),
      if (source != null) 'source': source,
      if (position != null) 'position': position,
      if (scenario != null) 'scenario': scenario,
      if (recId != null) 'rec_id': recId,
      if (additionalData != null) ...additionalData,
    };

    await trackEvent(
      businessType: 'pv',
      path: '/product/$productId',
      businessId: productId,
      feature: feature,
    );
  }

  /// 记录商品点击事件（推荐系统专用）
  Future<void> trackRecommendationClick({
    required int itemId,
    required String scenario,
    required int position,
    required String recId,
    Map<String, dynamic>? additionalData,
  }) async {
    final feature = <String, dynamic>{
      'click_type': 'recommendation',
      'source': 'recommendation',
      'scenario': scenario,
      'position': position,
      'rec_id': recId,
      'is_visitor': await _userService.isGuest(),
      if (additionalData != null) ...additionalData,
    };

    await trackEvent(
      businessType: 'click',
      path: '/product/$itemId',
      businessId: itemId,
      feature: feature,
    );
  }

  /// 记录购物车操作事件
  Future<void> trackCartAction({
    required int productId,
    required String action, // "add", "remove", "update_quantity"
    int? quantity,
    double? price,
    String? sourcePage,
    Map<String, dynamic>? additionalData,
  }) async {
    final feature = <String, dynamic>{
      'action': action,
      'is_visitor': await _userService.isGuest(),
      if (quantity != null) 'quantity': quantity,
      if (price != null) 'price': price,
      if (sourcePage != null) 'source_page': sourcePage,
      if (additionalData != null) ...additionalData,
    };

    await trackEvent(
      businessType: 'cart',
      path: '/cart',
      businessId: productId,
      feature: feature,
    );
  }

  /// 记录搜索事件
  Future<void> trackSearch({
    required String query,
    String? searchType,
    int? resultCount,
    Map<String, dynamic>? additionalData,
  }) async {
    final feature = <String, dynamic>{
      'search_query': query,
      'search_type': searchType ?? 'text',
      'is_visitor': await _userService.isGuest(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      if (resultCount != null) 'result_count': resultCount,
      if (additionalData != null) ...additionalData,
    };

    await trackEvent(
      businessType: 'search',
      path: '/search',
      feature: feature,
    );
  }

  /// 记录订单相关事件
  Future<void> trackOrder({
    required String action, // "create", "pay", "cancel", "confirm"
    required int orderId,
    double? amount,
    int? itemCount,
    Map<String, dynamic>? additionalData,
  }) async {
    final feature = <String, dynamic>{
      'action': action,
      'is_visitor': await _userService.isGuest(),
      if (amount != null) 'amount': amount,
      if (itemCount != null) 'item_count': itemCount,
      if (additionalData != null) ...additionalData,
    };

    String businessType;
    switch (action) {
      case 'pay':
        businessType = 'pay';
        break;
      case 'create':
        businessType = 'order';
        break;
      default:
        businessType = 'order_action';
    }

    await trackEvent(
      businessType: businessType,
      path: '/orders/$orderId',
      businessId: orderId,
      feature: feature,
    );
  }

  /// 记录聊天事件
  Future<void> trackChat({
    required String action, // "send_message", "enter_room", "leave_room"
    required int chatRoomId,
    String? messageType,
    int? messageLength,
    Map<String, dynamic>? additionalData,
  }) async {
    final feature = <String, dynamic>{
      'action': action,
      'is_visitor': await _userService.isGuest(),
      if (messageType != null) 'message_type': messageType,
      if (messageLength != null) 'message_length': messageLength,
      if (additionalData != null) ...additionalData,
    };

    await trackEvent(
      businessType: 'chat',
      path: '/chat/$chatRoomId',
      businessId: chatRoomId,
      feature: feature,
    );
  }

  /// 记录用户登录事件
  Future<void> trackUserLogin({
    required String loginMethod,
    required int userId,
    bool success = true,
    Map<String, dynamic>? additionalData,
  }) async {
    final feature = <String, dynamic>{
      'login_method': loginMethod,
      'login_success': success,
      'device_id': await _deviceService.getDeviceId(),
      if (additionalData != null) ...additionalData,
    };

    await trackEvent(
      businessType: 'login',
      path: '/login',
      businessId: userId,
      feature: feature,
    );

    // 登录成功后清除游客标识
    if (success) {
      await _userService.clearGuestId();
    }
  }

  /// 强制上报所有缓存事件
  Future<void> flush() async {
    await _eventBuffer.flush();
  }

  /// 获取缓存事件数量
  int get bufferedEventCount => _eventBuffer.bufferedEventCount;

  /// 检查是否正在上报
  bool get isUploading => _eventBuffer.isUploading;

  /// 测试连接
  Future<bool> testConnection() async {
    return await _apiService.testConnection();
  }

  /// 释放资源
  void dispose() {
    _eventBuffer.dispose();
  }
} 