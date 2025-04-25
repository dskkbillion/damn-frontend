import 'package:dskk_flutter_refactor/features/seller/data/models/notification_dto.dart';
import 'package:dskk_flutter_refactor/features/seller/data/models/order_refund_dto.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/auto_reply_settings.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_dashboard_data.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_store_profile.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/time_settings.dart';

/// 卖家本地数据源接口
abstract class ISellerLocalDataSource {
  /// 缓存卖家仪表盘数据
  Future<void> cacheDashboardData(SellerDashboardData data);
  
  /// 获取缓存的卖家仪表盘数据
  Future<SellerDashboardData?> getCachedDashboardData();
  
  /// 缓存卖家商品列表
  Future<void> cacheProductList(List<Map<String, dynamic>> products, String? state);
  
  /// 获取缓存的卖家商品列表
  Future<List<Map<String, dynamic>>?> getCachedProductList(String? state);
  
  /// 缓存商品详情
  Future<void> cacheProductDetail(int productId, Map<String, dynamic> product);
  
  /// 获取缓存的商品详情
  Future<Map<String, dynamic>?> getCachedProductDetail(int productId);
  
  /// 缓存店铺资料
  Future<void> cacheStoreProfile(SellerStoreProfile profile);
  
  /// 获取缓存的店铺资料
  Future<SellerStoreProfile?> getCachedStoreProfile();
  
  /// 缓存自动回复设置
  Future<void> cacheAutoReplySettings(AutoReplySettings settings);
  
  /// 获取缓存的自动回复设置
  Future<AutoReplySettings?> getCachedAutoReplySettings();
  
  /// 缓存时间设置
  Future<void> cacheTimeSettings(TimeSettings settings);
  
  /// 获取缓存的时间设置
  Future<TimeSettings?> getCachedTimeSettings();
  
  /// 缓存通知列表
  Future<void> cacheNotifications(List<NotificationDto> notifications, String? messageType);
  
  /// 获取缓存的通知列表
  Future<List<NotificationDto>?> getCachedNotifications(String? messageType);
  
  /// 缓存售后审核列表
  Future<void> cacheTenantAuditList(List<OrderRefundDto> refunds);
  
  /// 获取缓存的售后审核列表
  Future<List<OrderRefundDto>?> getCachedTenantAuditList();
  
  /// 缓存售后详情
  Future<void> cacheRefundDetail(int refundId, OrderRefundDto refund);
  
  /// 获取缓存的售后详情
  Future<OrderRefundDto?> getCachedRefundDetail(int refundId);
  
  /// 清除所有缓存
  Future<void> clearCache();
} 