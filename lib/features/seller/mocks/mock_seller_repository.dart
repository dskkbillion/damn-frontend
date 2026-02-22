import 'package:mockito/mockito.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dartz/dartz.dart';
// 导入 ISellerRepository 接口
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
// 导入所有需要的实体和枚举
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_store_profile.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/auto_reply_settings.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/time_settings.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_authentication_info.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_dashboard_data.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/order_refund.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_notification.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/enums/product_status.dart';
// 导入售后相关枚举
import 'package:dskk_flutter_refactor/features/seller/domain/entities/enums/order_refund_state.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/enums/refund_type.dart';

// // Seller模块仓库接口 (注释掉这里的重复定义)
// abstract class ISellerRepository {
//   // ... methods ...
// }

// class MockSellerRepository extends Mock implements ISellerRepository {
// 让 MockSellerRepository 实现 ISellerRepository 接口
class MockSellerRepository implements ISellerRepository {
  @override
  Future<Either<Failure, SellerStoreProfile>> getStoreProfile() async {
    AppLogger.d('MockSellerRepository: getStoreProfile called');
    return Future.value(Right(SellerStoreProfile(
      storeId: 'mock_store_123',
      storeName: '模拟卖家店铺',
      logoUrl: 'https://picsum.photos/150', // 使用 Picsum
      description: '这是一个模拟的店铺描述，用于测试显示。',
      onlineFlag: true,
      averageRating: 4.7,
      completionRate: 95.5,
      certifications: ['实名认证', '保证金'],
    )));
  }

  @override
  Future<Either<Failure, bool>> updateStoreProfile(dynamic profileData) async {
    AppLogger.d('MockSellerRepository: updateStoreProfile called with $profileData');
    return Future.value(const Right(true));
  }

  @override
  Future<Either<Failure, bool>> updateOnlineStatus(bool isOnline) async {
    AppLogger.d('MockSellerRepository: updateOnlineStatus called with $isOnline');
    return Future.value(const Right(true));
  }

  @override
  Future<Either<Failure, AutoReplySettings>> getAutoReplySettings() async {
    AppLogger.d('MockSellerRepository: getAutoReplySettings called');
    return Future.value(const Right(AutoReplySettings(isEnabled: true, content: '你好，现在暂时无法回复，稍后联系您。')));
  }

  @override
  Future<Either<Failure, bool>> setAutoReplySettings(AutoReplySettings settings) async {
    AppLogger.d('MockSellerRepository: setAutoReplySettings called with $settings');
    return Future.value(const Right(true));
  }

  @override
  Future<Either<Failure, TimeSettings>> getTimeSettings() async {
    AppLogger.d('MockSellerRepository: getTimeSettings called');
    return Future.value(const Right(TimeSettings(isOnline: true)));
  }

  @override
  Future<Either<Failure, bool>> updateTimeSettings(dynamic settings) async {
    AppLogger.d('MockSellerRepository: updateTimeSettings called with $settings');
    return Future.value(const Right(true));
  }

  @override
  Future<Either<Failure, List<SellerAuthenticationInfo>>> getAuthenticationStatus() async {
    AppLogger.d('MockSellerRepository: getAuthenticationStatus called');
    final now = DateTime.now();
    return Future.value(Right([
      SellerAuthenticationInfo(
        authenticationId: 1,
        type: AuthenticationType.idCard, // 使用实际存在的枚举成员
        status: AuthenticationStatus.approved,
        name: '身份认证', // 添加必须的name字段
        enabled: true, // 添加必须的enabled字段
        submittedAt: now.subtract(const Duration(days: 10)),
        rejectionReason: null,
        icon: 'person', // 可选，模拟图标
        remarks: '已完成身份信息核验',
      ),
      SellerAuthenticationInfo(
        authenticationId: 2,
        type: AuthenticationType.company, // 使用实际存在的枚举成员
        status: AuthenticationStatus.pending,
        name: '企业认证', // 添加必须的name字段
        enabled: true, // 添加必须的enabled字段
        submittedAt: now.subtract(const Duration(days: 1)),
        rejectionReason: null,
        icon: 'business',
        remarks: '等待工商信息核验',
      ),
      SellerAuthenticationInfo(
        authenticationId: 3,
        type: AuthenticationType.education, // 使用实际存在的枚举成员
        status: AuthenticationStatus.rejected,
        name: '学历认证', // 添加必须的name字段
        enabled: true, // 添加必须的enabled字段
        submittedAt: now.subtract(const Duration(days: 5)),
        rejectionReason: '提交资料不清晰，请重新上传。',
        icon: 'school',
        remarks: '认证未通过',
      ),
      // 可以添加一个未提交的认证
      SellerAuthenticationInfo(
        authenticationId: 4,
        type: AuthenticationType.profession,
        status: AuthenticationStatus.notSubmitted,
        name: '职业认证',
        enabled: true,
        icon: 'work',
        remarks: '提交职业资格证书进行认证',
      ),
    ]));
  }
  
  @override
  Future<Either<Failure, SellerDashboardData>> getDashboardData() async {
    AppLogger.d('MockSellerRepository: getDashboardData called');
    // 模拟数据 - 确保创建了正确的实体对象
    final incomeData = SellerIncomeData(
      total: 10000.0,
      today: 1200.0,
      pending: 3000.0,
    );
    final ordersData = SellerOrdersData(
      total: 50,
      pending: 10,
      completed: 35,
      canceled: 5,
    );
    final notificationsData = SellerNotificationsData(unread: 5);
    final statisticsData = SellerStatistics(
      weeklyIncome: [
        WeeklyIncomeItem(date: '2023-11-01', amount: 800.0),
        WeeklyIncomeItem(date: '2023-11-02', amount: 1200.0),
        WeeklyIncomeItem(date: '2023-11-03', amount: 600.0),
        WeeklyIncomeItem(date: '2023-11-04', amount: 1500.0),
        WeeklyIncomeItem(date: '2023-11-05', amount: 900.0),
        WeeklyIncomeItem(date: '2023-11-06', amount: 1100.0),
        WeeklyIncomeItem(date: '2023-11-07', amount: 1300.0),
      ],
    );
    
    final dashboardData = SellerDashboardData(
      income: incomeData,
      orders: ordersData,
      rating: 4.8,
      notifications: notificationsData,
      statistics: statisticsData,
    );
    
    return Future.value(Right(dashboardData)); // 返回正确创建的实体
  }
  
  @override
  Future<Either<Failure, PaginatedList<SellerManagedProduct>>> getSellerProductList({
    required int pageNum,
    required int pageSize,
    String? state,
  }) async {
    AppLogger.d('MockSellerRepository: getSellerProductList called');
    final items = List.generate(pageSize, (index) => SellerManagedProduct(
      id: 2000 + (pageNum - 1) * pageSize + index,
      name: '测试商品 ${state ?? "在售"} ${(pageNum - 1) * pageSize + index + 1}',
      price: 100.0 + (index * 10),
      images: 'https://picsum.photos/200/300?random=${2000 + index}', // 使用 Picsum
      description: '这是测试商品 ${(pageNum - 1) * pageSize + index + 1} 的详细描述',
      status: ProductStatus.fromValue(state ?? 'NORMAL'),
      createTime: DateTime.now().subtract(Duration(days: index)),
      updateTime: DateTime.now().subtract(Duration(hours: index)),
      sales: 10 + index,
      category: ProductCategory(id: 10, name: '测试分类'),
      variants: [ProductOptionValue(id: 1, optionName: '规格', optionValue: '默认', price: 100.0 + (index * 10), stock: 50)],
      productMaterials: [ProductMaterial(id: 1, question: '定制需求?', type: 'TEXT')],
    ));
    return Future.value(Right(PaginatedList(total: 100, items: items)));
  }
  
  @override
  Future<Either<Failure, PaginatedList<SellerManagedProduct>>> getSellerDraftList({
    required int pageNum,
    required int pageSize,
  }) async {
    AppLogger.d('MockSellerRepository: getSellerDraftList called');
    final items = List.generate(pageSize, (index) => SellerManagedProduct(
      id: 3000 + (pageNum - 1) * pageSize + index,
      name: '草稿商品 ${(pageNum - 1) * pageSize + index + 1}',
      price: 100.0 + (index * 10),
      images: 'https://picsum.photos/200/300?random=${3000 + index}',
      description: '这是草稿商品 ${(pageNum - 1) * pageSize + index + 1} 的详细描述',
      status: ProductStatus.draft,
      createTime: DateTime.now().subtract(Duration(days: index)),
      updateTime: DateTime.now().subtract(Duration(hours: index)),
      category: ProductCategory(id: 10, name: '测试分类'),
    ));
    return Future.value(Right(PaginatedList(total: 20, items: items)));
  }
  
  @override
  Future<Either<Failure, bool>> createProduct(dynamic productData) async {
    AppLogger.d('MockSellerRepository: createProduct called with $productData');
    return Future.value(const Right(true));
  }
  
  @override
  Future<Either<Failure, bool>> updateProduct(dynamic productData) async {
    AppLogger.d('MockSellerRepository: updateProduct called with $productData');
    return Future.value(const Right(true));
  }
  
  @override
  Future<Either<Failure, bool>> deleteProduct(List<int> productIds) async {
    AppLogger.d('MockSellerRepository: deleteProduct called with $productIds');
    return Future.value(const Right(true));
  }
  
  @override
  Future<Either<Failure, List<SellerNotification>>> getNotificationList({String? messageType}) async {
    AppLogger.d('MockSellerRepository: getNotificationList called with type: $messageType');
    final now = DateTime.now();
    return Future.value(Right([
      SellerNotification(notificationId: '1', type: NotificationType.order, title: '新订单', content: '您有新的订单需要处理', isRead: false, createdAt: now.subtract(Duration(hours: 1))),
      SellerNotification(notificationId: '2', type: NotificationType.system, title: '系统更新', content: '系统将在今晚维护', isRead: true, createdAt: now.subtract(Duration(days: 1))),
    ]));
  }
  
  @override
  Future<Either<Failure, bool>> markNotificationAsRead(String notificationId) async {
    AppLogger.d('MockSellerRepository: markNotificationAsRead called with $notificationId');
    return Future.value(const Right(true));
  }
  
  @override
  Future<Either<Failure, bool>> markAllNotificationsAsRead({String? messageTypes}) async {
    AppLogger.d('MockSellerRepository: markAllNotificationsAsRead called with types: $messageTypes');
    return Future.value(const Right(true));
  }
  
  @override
  Future<Either<Failure, int>> getUnreadNotificationCount() async {
    AppLogger.d('MockSellerRepository: getUnreadNotificationCount called');
    return Future.value(const Right(3));
  }
  
  @override
  Future<Either<Failure, bool>> submitAuthenticationApplication(dynamic applicationData) async {
    AppLogger.d('MockSellerRepository: submitAuthenticationApplication called with $applicationData');
    return Future.value(const Right(true));
  }

  @override
  Future<Either<Failure, PaginatedList<OrderRefund>>> getTenantAuditList({
    required int pageNum,
    required int pageSize,
  }) async {
    AppLogger.d('MockSellerRepository: getTenantAuditList called (page: $pageNum)');
    final items = List.generate(pageSize, (index) => OrderRefund(
      id: 4000 + (pageNum - 1) * pageSize + index,
      orderId: 1000 + index,
      orderSn: 'ORD2023110${1000 + index}',
      refundSn: 'REF${4000 + index}',
      refundPrice: (10000 + (index * 5000)), // 分
      reason: '商品不符合描述',
      credentials: [
        'https://picsum.photos/100?random=${4000+index}a',
        'https://picsum.photos/100?random=${4000+index}b',
      ],
      state: OrderRefundState.waitAudit,
      type: index % 2 == 0 ? RefundType.onlyMoney : RefundType.moneyAndProduct,
      applyTime: DateTime.now().subtract(Duration(days: index)),
    ));
    return Future.value(Right(PaginatedList(total: 30, items: items)));
  }
  
  @override
  Future<Either<Failure, bool>> auditRefund({
    required int id,
    required String refundState, // ISellerRepository 定义的是 String
    String? auditRemark,
  }) async {
    AppLogger.d('MockSellerRepository: auditRefund called for $id with state $refundState');
    return Future.value(const Right(true));
  }
  
  @override
  Future<Either<Failure, OrderRefund>> getRefundDetail(int refundId) async {
    AppLogger.d('MockSellerRepository: getRefundDetail called for $refundId');
    return Future.value(Right(OrderRefund(
      id: refundId,
      orderId: 1001,
      orderSn: 'ORD20231101001',
      refundSn: 'REF$refundId',
      refundPrice: 15000,
      reason: '商品不符合描述，颜色与网站展示不一致',
      credentials: [
        'https://picsum.photos/200?random=${refundId}a',
        'https://picsum.photos/200?random=${refundId}b',
      ],
      state: OrderRefundState.waitAudit,
      type: RefundType.onlyMoney,
      applyTime: DateTime.now().subtract(const Duration(days: 2)),
    )));
  }
  
  @override
  Future<Either<Failure, bool>> addOrderDelivery({
    required int orderId,
    required String content,
    required List<String> files,
  }) async {
    AppLogger.d('MockSellerRepository: addOrderDelivery called for order $orderId');
    return Future.value(const Right(true));
  }

  @override
  Future<Either<Failure, SellerManagedProduct>> getProductDetail(int productId) async {
    AppLogger.d('MockSellerRepository: getProductDetail called for $productId');
    return Future.value(Right(SellerManagedProduct(
      id: productId,
      name: '测试商品详情 $productId',
      price: 150.0,
      images: 'https://picsum.photos/200?random=$productId',
      description: '这是测试商品 $productId 的详细描述...',
      status: ProductStatus.normal,
      createTime: DateTime.now().subtract(const Duration(days: 5)),
      updateTime: DateTime.now().subtract(const Duration(days: 1)),
      sales: 25,
      category: const ProductCategory(id: 10, name: '测试分类'),
      variants: [
        const ProductOptionValue(id: 1, optionName: '规格', optionValue: '标准版', price: 150.0, stock: 100),
        const ProductOptionValue(id: 2, optionName: '规格', optionValue: '豪华版', price: 250.0, stock: 50),
      ],
      productMaterials: [
        const ProductMaterial(id: 1, question: '您的需求是什么?', type: 'TEXT'),
        const ProductMaterial(id: 2, question: '请上传参考资料', type: 'FILE'),
      ],
    )));
  }
  
  @override
  Future<Either<Failure, bool>> updateProductStatus(int productId, String state) async {
     AppLogger.d('MockSellerRepository: updateProductStatus called for $productId to state $state');
    return Future.value(const Right(true));
  }
} 