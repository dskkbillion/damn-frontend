import 'dart:convert';

import 'package:dskk_flutter_refactor/core/error/exceptions.dart';
import 'package:dskk_flutter_refactor/features/seller/data/datasources/i_seller_local_data_source.dart';
import 'package:dskk_flutter_refactor/features/seller/data/models/notification_dto.dart';
import 'package:dskk_flutter_refactor/features/seller/data/models/order_refund_dto.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/auto_reply_settings.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_dashboard_data.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_store_profile.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/time_settings.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 卖家本地数据源实现类
@Injectable(as: ISellerLocalDataSource)
class SellerLocalDataSourceImpl implements ISellerLocalDataSource {
  final SharedPreferences _sharedPreferences;

  // 缓存Key名常量
  static const String _dashboardDataKey = 'CACHED_DASHBOARD_DATA';
  static const String _storeProfileKey = 'CACHED_STORE_PROFILE';
  static const String _autoReplySettingsKey = 'CACHED_AUTO_REPLY_SETTINGS';
  static const String _timeSettingsKey = 'CACHED_TIME_SETTINGS';
  static const String _tenantAuditListKey = 'CACHED_TENANT_AUDIT_LIST';
  
  /// 构造函数，依赖注入SharedPreferences
  SellerLocalDataSourceImpl(this._sharedPreferences);

  @override
  Future<void> cacheDashboardData(SellerDashboardData data) async {
    // Dashboard数据复杂，需要开发自定义序列化方法
    // 这里暂时不实现
    throw UnimplementedError();
  }

  @override
  Future<SellerDashboardData?> getCachedDashboardData() async {
    // 同上，不实现
    throw UnimplementedError();
  }

  @override
  Future<void> cacheProductList(List<Map<String, dynamic>> products, String? state) async {
    final key = 'CACHED_PRODUCT_LIST_${state ?? 'ALL'}';
    await _sharedPreferences.setString(key, json.encode(products));
  }

  @override
  Future<List<Map<String, dynamic>>?> getCachedProductList(String? state) async {
    final key = 'CACHED_PRODUCT_LIST_${state ?? 'ALL'}';
    final jsonString = _sharedPreferences.getString(key);
    
    if (jsonString == null) {
      return null;
    }
    
    try {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheProductDetail(int productId, Map<String, dynamic> product) async {
    final key = 'CACHED_PRODUCT_DETAIL_$productId';
    await _sharedPreferences.setString(key, json.encode(product));
  }

  @override
  Future<Map<String, dynamic>?> getCachedProductDetail(int productId) async {
    final key = 'CACHED_PRODUCT_DETAIL_$productId';
    final jsonString = _sharedPreferences.getString(key);
    
    if (jsonString == null) {
      return null;
    }
    
    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheStoreProfile(SellerStoreProfile profile) async {
    // Store profile复杂，需要开发自定义序列化方法
    // 这里暂时不实现
    throw UnimplementedError();
  }

  @override
  Future<SellerStoreProfile?> getCachedStoreProfile() async {
    // 同上，不实现
    throw UnimplementedError();
  }

  @override
  Future<void> cacheAutoReplySettings(AutoReplySettings settings) async {
    final Map<String, dynamic> data = {
      'isEnabled': settings.isEnabled,
      'content': settings.content,
    };
    
    await _sharedPreferences.setString(_autoReplySettingsKey, json.encode(data));
  }

  @override
  Future<AutoReplySettings?> getCachedAutoReplySettings() async {
    final jsonString = _sharedPreferences.getString(_autoReplySettingsKey);
    
    if (jsonString == null) {
      return null;
    }
    
    try {
      final Map<String, dynamic> data = json.decode(jsonString);
      return AutoReplySettings(
        isEnabled: data['isEnabled'] ?? false,
        content: data['content'],
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheTimeSettings(TimeSettings settings) async {
    final Map<String, dynamic> data = {
      'isOnline': settings.isOnline,
      // 其他TimeSettings字段...
    };
    
    await _sharedPreferences.setString(_timeSettingsKey, json.encode(data));
  }

  @override
  Future<TimeSettings?> getCachedTimeSettings() async {
    final jsonString = _sharedPreferences.getString(_timeSettingsKey);
    
    if (jsonString == null) {
      return null;
    }
    
    try {
      final Map<String, dynamic> data = json.decode(jsonString);
      return TimeSettings(
        isOnline: data['isOnline'] ?? false,
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheNotifications(List<NotificationDto> notifications, String? messageType) async {
    final key = 'CACHED_NOTIFICATIONS_${messageType ?? 'ALL'}';
    final jsonList = notifications.map((notification) => notification.toJson()).toList();
    await _sharedPreferences.setString(key, json.encode(jsonList));
  }

  @override
  Future<List<NotificationDto>?> getCachedNotifications(String? messageType) async {
    final key = 'CACHED_NOTIFICATIONS_${messageType ?? 'ALL'}';
    final jsonString = _sharedPreferences.getString(key);
    
    if (jsonString == null) {
      return null;
    }
    
    try {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded
          .map((item) => NotificationDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheTenantAuditList(List<OrderRefundDto> refunds) async {
    final jsonList = refunds.map((refund) => refund.toJson()).toList();
    await _sharedPreferences.setString(_tenantAuditListKey, json.encode(jsonList));
  }

  @override
  Future<List<OrderRefundDto>?> getCachedTenantAuditList() async {
    final jsonString = _sharedPreferences.getString(_tenantAuditListKey);
    
    if (jsonString == null) {
      return null;
    }
    
    try {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded
          .map((item) => OrderRefundDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheRefundDetail(int refundId, OrderRefundDto refund) async {
    final key = 'CACHED_REFUND_DETAIL_$refundId';
    await _sharedPreferences.setString(key, json.encode(refund.toJson()));
  }

  @override
  Future<OrderRefundDto?> getCachedRefundDetail(int refundId) async {
    final key = 'CACHED_REFUND_DETAIL_$refundId';
    final jsonString = _sharedPreferences.getString(key);
    
    if (jsonString == null) {
      return null;
    }
    
    try {
      final Map<String, dynamic> decoded = json.decode(jsonString);
      return OrderRefundDto.fromJson(decoded);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> clearCache() async {
    // 清除所有卖家模块相关缓存
    final keys = _sharedPreferences.getKeys().where((key) => 
      key.startsWith('CACHED_') && 
      (key.contains('PRODUCT') || 
       key.contains('REFUND') || 
       key.contains('NOTIFICATION') ||
       key == _dashboardDataKey ||
       key == _storeProfileKey ||
       key == _autoReplySettingsKey ||
       key == _timeSettingsKey ||
       key == _tenantAuditListKey)
    );
    
    for (final key in keys) {
      await _sharedPreferences.remove(key);
    }
  }
} 