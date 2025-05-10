import 'package:dskk_flutter_refactor/features/seller/data/models/member_dto.dart';
import 'package:dskk_flutter_refactor/features/seller/data/models/notification_dto.dart';
import 'package:dskk_flutter_refactor/features/seller/data/models/order_refund_dto.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/auto_reply_settings.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_authentication_info.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_dashboard_data.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_store_profile.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/time_settings.dart';

/// 卖家远程数据源接口
abstract class ISellerRemoteDataSource {
  /// 获取卖家仪表盘数据
  Future<SellerDashboardData> getDashboardData();

  /// 获取卖家商品列表 (已发布/全部)
  Future<PaginatedListDto<dynamic>> getSellerProductList({
    required int pageNum,
    required int pageSize,
    String? state,
  });

  /// 获取卖家商品列表 (草稿箱)
  Future<PaginatedListDto<dynamic>> getSellerDraftList({
    required int pageNum,
    required int pageSize,
  });

  /// 获取商品详情
  Future<dynamic> getProductDetail(int productId);

  /// 更新商品状态 (上架/下架)
  Future<bool> updateProductStatus(int productId, String state);

  /// 创建商品
  Future<bool> createProduct(ProductCreationData productData);

  /// 更新商品
  Future<bool> updateProduct(ProductUpdateData productData);

  /// 删除商品
  Future<bool> deleteProduct(List<int> productIds);

  /// 获取店铺资料
  Future<SellerStoreProfile> getStoreProfile();

  /// 更新店铺资料
  Future<bool> updateStoreProfile(StoreProfileUpdateData profileData);

  /// 更新卖家在线状态
  Future<bool> updateOnlineStatus(bool isOnline);

  /// 获取自动回复设置
  Future<AutoReplySettings> getAutoReplySettings();

  /// 设置自动回复
  Future<bool> setAutoReplySettings(AutoReplySettings settings);

  /// 获取时间设置
  Future<TimeSettings> getTimeSettings();

  /// 更新时间设置
  Future<bool> updateTimeSettings(TimeSettingsData settings);

  /// 获取通知列表
  Future<List<NotificationDto>> getNotificationList({
    String? messageType,
    int pageNum = 1,
    int pageSize = 10
  });

  /// 标记通知为已读
  Future<bool> markNotificationAsRead(String notificationId);

  /// 标记所有通知为已读
  Future<bool> markAllNotificationsAsRead({String? messageTypes});

  /// 获取未读通知数量
  Future<int> getUnreadNotificationCount();

  /// 获取认证状态/信息列表
  Future<List<SellerAuthenticationInfo>> getAuthenticationStatus();

  /// 提交认证申请
  Future<bool> submitAuthenticationApplication(AuthenticationApplicationData applicationData);

  /// 获取卖家售后审核列表
  Future<PaginatedListDto<OrderRefundDto>> getTenantAuditList({
    required int pageNum,
    required int pageSize,
  });

  /// 审核售后申请
  Future<bool> auditRefund({
    required int id,
    required String refundState,
    String? auditRemark,
  });

  /// 获取售后详情
  Future<OrderRefundDto> getRefundDetail(int refundId);

  /// 提交订单交付
  Future<bool> addOrderDelivery({
    required int orderId,
    required String content,
    required List<String> files,
  });

  // TODO: Define ShopVerificationStatus type and uncomment this method
  // Future<ShopVerificationStatus> getShopVerificationStatus();
} 