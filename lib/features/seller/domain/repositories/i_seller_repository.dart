import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/auto_reply_settings.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_authentication_info.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_dashboard_data.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_notification.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_store_profile.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/time_settings.dart';

/// 卖家模块数据仓库接口
abstract class ISellerRepository {
  /// 获取卖家仪表盘数据
  Future<Either<Failure, SellerDashboardData>> getDashboardData();

  /// 获取卖家商品列表 (已发布/全部)
  Future<Either<Failure, PaginatedList<SellerManagedProduct>>> getSellerProductList({
    required int pageNum,
    required int pageSize,
    String? state,
  });

  /// 获取卖家商品列表 (草稿箱)
  Future<Either<Failure, PaginatedList<SellerManagedProduct>>> getSellerDraftList({
    required int pageNum,
    required int pageSize,
  });

  /// 获取商品详情
  Future<Either<Failure, SellerManagedProduct>> getProductDetail(int productId);

  /// 更新商品状态 (上架/下架)
  Future<Either<Failure, bool>> updateProductStatus(int productId, String state);

  /// 创建商品
  Future<Either<Failure, bool>> createProduct(ProductCreationData productData);

  /// 更新商品
  Future<Either<Failure, bool>> updateProduct(ProductUpdateData productData);

  /// 删除商品
  Future<Either<Failure, bool>> deleteProduct(List<int> productIds);

  /// 获取店铺资料
  Future<Either<Failure, SellerStoreProfile>> getStoreProfile();

  /// 更新店铺资料
  Future<Either<Failure, bool>> updateStoreProfile(StoreProfileUpdateData profileData);

  /// 更新卖家在线状态
  Future<Either<Failure, bool>> updateOnlineStatus(bool isOnline);

  /// 获取自动回复设置
  Future<Either<Failure, AutoReplySettings>> getAutoReplySettings();

  /// 设置自动回复
  Future<Either<Failure, bool>> setAutoReplySettings(AutoReplySettings settings);

  /// 获取时间设置
  Future<Either<Failure, TimeSettings>> getTimeSettings();

  /// 更新时间设置
  Future<Either<Failure, bool>> updateTimeSettings(TimeSettingsData settings);

  /// 获取通知列表
  Future<Either<Failure, List<SellerNotification>>> getNotificationList({String? messageType});

  /// 标记通知为已读
  Future<Either<Failure, bool>> markNotificationAsRead(String notificationId);

  /// 标记所有通知为已读
  Future<Either<Failure, bool>> markAllNotificationsAsRead({String? messageTypes});

  /// 获取未读通知数量
  Future<Either<Failure, int>> getUnreadNotificationCount();

  /// 获取认证状态/信息列表
  Future<Either<Failure, List<SellerAuthenticationInfo>>> getAuthenticationStatus();

  /// 提交认证申请
  Future<Either<Failure, bool>> submitAuthenticationApplication(AuthenticationApplicationData applicationData);

  /// 获取卖家售后审核列表
  Future<Either<Failure, PaginatedList<OrderRefund>>> getTenantAuditList({
    required int pageNum,
    required int pageSize,
  });

  /// 审核售后申请
  Future<Either<Failure, bool>> auditRefund({
    required int id,
    required String refundState,
    String? auditRemark,
  });

  /// 获取售后详情
  Future<Either<Failure, OrderRefund>> getRefundDetail(int refundId);

  /// 提交订单交付
  Future<Either<Failure, bool>> addOrderDelivery({
    required int orderId,
    required String content,
    required List<String> files,
  });
}

/// 分页列表通用封装
class PaginatedList<T> {
  /// 总记录数
  final int total;
  
  /// 当前页数据列表
  final List<T> items;

  const PaginatedList({
    required this.total,
    required this.items,
  });
}

/// 售后/退款数据模型
class OrderRefund {
  /// 售后ID
  final int id;
  
  /// 创建者ID
  final int? creatorId;
  
  /// 状态
  final String refundState;
  
  /// 类型
  final String refundType;
  
  /// 原因
  final String? refundReason;
  
  /// 备注
  final String? refundRemarks;
  
  /// 金额
  final double? refundAmount;
  
  /// 审核备注
  final String? auditRemark;
  
  /// 创建时间
  final DateTime createTime;
  
  /// 图片列表 (逗号分隔)
  final String? images;
  
  /// 相关订单信息
  final Map<String, dynamic>? order;
  
  /// 相关订单商品项
  final Map<String, dynamic>? orderProductItem;

  const OrderRefund({
    required this.id,
    required this.refundState,
    required this.refundType,
    required this.createTime,
    this.creatorId,
    this.refundReason,
    this.refundRemarks,
    this.refundAmount,
    this.auditRemark,
    this.images,
    this.order,
    this.orderProductItem,
  });
} 