import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/error/exceptions.dart';
import 'package:dskk_flutter_refactor/features/seller/data/models/member_dto.dart';
import 'package:dskk_flutter_refactor/features/seller/data/models/notification_dto.dart';
import 'package:dskk_flutter_refactor/features/seller/data/models/order_refund_dto.dart';
import 'package:dskk_flutter_refactor/features/seller/data/datasources/i_seller_remote_data_source.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/auto_reply_settings.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_authentication_info.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_dashboard_data.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_store_profile.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/time_settings.dart';
import 'package:injectable/injectable.dart';

/// 卖家远程数据源实现类
@Injectable(as: ISellerRemoteDataSource)
class SellerRemoteDataSourceImpl implements ISellerRemoteDataSource {
  final Dio _dio;

  /// 构造函数，依赖注入Dio客户端
  SellerRemoteDataSourceImpl(this._dio);
  
  @override
  Future<SellerDashboardData> getDashboardData() async {
    print('[DataSource DEBUG] Entering getDashboardData'); // DEBUG LOG
    try {
      final response = await _dio.post('/api/project/statistics/index');
      _checkResponse(response);
      print('[DataSource DEBUG] API Response OK'); // DEBUG LOG
      
      final data = response.data['data'];
      if (data == null || data is! Map<String, dynamic>) {
        throw ServerException(message: 'Invalid dashboard data format received');
      }
      print('[DataSource DEBUG] Response data fetched: $data'); // DEBUG LOG

      // Map response data to SellerDashboardData, using actual keys from the response
      print('[DataSource DEBUG] Parsing income...'); // DEBUG LOG
      final income = SellerIncomeData(
        total: (data['totalEarnings'] ?? 0.0).toDouble(), // Use 'totalEarnings' from response
        today: (data['thisMonthTotalEarnings'] ?? 0.0).toDouble(), // Map appropriately, e.g., today's might not be directly available or use a different key
        pending: (data['pendingIncome'] ?? 0.0).toDouble(), // Assuming pendingIncome exists or map to relevant key
      );
      print('[DataSource DEBUG] Parsed income: $income'); // DEBUG LOG
      
      print('[DataSource DEBUG] Parsing orders...'); // DEBUG LOG
      final orders = SellerOrdersData(
        total: data['totalOrderNum'] ?? 0,       // Use 'totalOrderNum' from response
        pending: data['pendingOrderNum'] ?? 0,   // Use 'pendingOrderNum' from response
        completed: data['receiptOrderNum'] ?? 0, // Map 'receiptOrderNum' to completed, adjust if needed
        canceled: data['canceledOrders'] ?? 0,  // Assuming canceledOrders exists or map to relevant key
      );
      print('[DataSource DEBUG] Parsed orders: $orders'); // DEBUG LOG
      
      // Notifications and Rating seem to be missing in the response, handle gracefully
      print('[DataSource DEBUG] Parsing notifications...'); // DEBUG LOG
      final notifications = SellerNotificationsData(
        unread: data['unreadNotifications'] ?? 0, // Assuming unreadNotifications exists
      );
      print('[DataSource DEBUG] Parsed notifications: $notifications'); // DEBUG LOG
      
      print('[DataSource DEBUG] Parsing rating...'); // DEBUG LOG
      final double rating = (data['rating'] ?? 0.0).toDouble(); // Assuming rating exists
      print('[DataSource DEBUG] Parsed rating: $rating'); // DEBUG LOG

      // Weekly income data seems missing in the response, handle gracefully
      print('[DataSource DEBUG] Parsing statistics...'); // DEBUG LOG
      final statistics = SellerStatistics(
        weeklyIncome: [], // Return empty list as weeklyIncome is missing
      );
      print('[DataSource DEBUG] Parsed statistics: $statistics'); // DEBUG LOG
      
      print('[DataSource DEBUG] Creating final SellerDashboardData...'); // DEBUG LOG
      return SellerDashboardData(
        income: income,
        orders: orders,
        rating: rating,
        notifications: notifications,
        statistics: statistics,
      );
    } catch (e, s) { // Catch stacktrace as well
      print('[DataSource ERROR] Error in getDashboardData: $e'); // Log error
      print('[DataSource ERROR] Stacktrace: $s'); // Log stacktrace
      _handleError(e);
      rethrow; // Rethrow after handling to let BLoC know about the failure
    }
  }

  @override
  Future<PaginatedListDto<dynamic>> getSellerProductList({
    required int pageNum, // 参数保留，但不在请求中使用
    required int pageSize, // 参数保留，但不在请求中使用
    String? state,
  }) async {
    try {
      // 保持移除 pageNum 和 pageSize 参数，因为目标接口不支持分页
      final requestData = <String, dynamic>{};
      if (state != null) {
        requestData['state'] = state.toLowerCase();
      }

      // 修改 API 端点为 /api/shop/product/myList
      final response = await _dio.post('/api/shop/product/myList', 
        data: requestData,
      );
      
      _checkResponse(response);
      
      return PaginatedListDto.fromJson(
        response.data,
        (itemJson) => itemJson, // 商品列表暂时返回原始Map
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<PaginatedListDto<dynamic>> getSellerDraftList({
    required int pageNum,
    required int pageSize,
  }) async {
    try {
      final response = await _dio.post('/api/shop/product/draft/list', data: {
        'pageNum': pageNum,
        'pageSize': pageSize,
      });
      
      _checkResponse(response);
      
      return PaginatedListDto.fromJson(
        response.data,
        (itemJson) => itemJson, // 草稿列表暂时返回原始Map
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<dynamic> getProductDetail(int productId) async {
    try {
      final response = await _dio.get('/api/shop/product/detail', queryParameters: {
        'id': productId,
      });
      
      _checkResponse(response);
      
      return response.data['data'];
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<bool> updateProductStatus(int productId, String state) async {
    try {
      final response = await _dio.post('/api/shop/product/updateStatus', data: {
        'id': productId,
        'state': state,
      });
      
      _checkResponse(response);
      
      return true;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<bool> createProduct(ProductCreationData productData) async {
    try {
      // 转换ProductCreationData为API需要的格式
      Map<String, dynamic> data = {
        // 根据ProductCreationData的结构填充
      };
      
      final response = await _dio.post('/api/shop/product/create', data: data);
      
      _checkResponse(response);
      
      return true;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<bool> updateProduct(ProductUpdateData productData) async {
    try {
      // 转换ProductUpdateData为API需要的格式
      Map<String, dynamic> data = {
        // 根据ProductUpdateData的结构填充
      };
      
      final response = await _dio.post('/api/shop/product/update', data: data);
      
      _checkResponse(response);
      
      return true;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<bool> deleteProduct(List<int> productIds) async {
    try {
      final response = await _dio.post('/api/shop/product/delete', data: productIds);
      
      _checkResponse(response);
      
      return true;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<SellerStoreProfile> getStoreProfile() async {
    try {
      final response = await _dio.get('/api/member/info');
      
      _checkResponse(response);
      
      // 根据实际API响应结构处理
      final data = response.data['data'];
      
      return SellerStoreProfile(
        storeId: data['id']?.toString() ?? '',
        storeName: data['nickName'] ?? data['storeName'] ?? '',
        logoUrl: data['avatar'],
        description: data['description'],
        // 其他字段初始化...
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<bool> updateStoreProfile(StoreProfileUpdateData profileData) async {
    try {
      // 转换为API需要的格式
      Map<String, dynamic> data = {
        // 根据profileData结构填充
      };
      
      final response = await _dio.post('/api/member/update', data: data);
      
      _checkResponse(response);
      
      return true;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<bool> updateOnlineStatus(bool isOnline) async {
    try {
      final response = await _dio.post('/api/member/update', data: {
        'onlineFlag': isOnline,
      });
      
      _checkResponse(response);
      
      return true;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<AutoReplySettings> getAutoReplySettings() async {
    try {
      final response = await _dio.get('/api/member/info');
      
      _checkResponse(response);
      
      // 从Member信息中解析自动回复设置
      final data = response.data['data'];
      final memberDto = MemberDto.fromJson(data);
      
      return memberDto.toAutoReplySettings();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<bool> setAutoReplySettings(AutoReplySettings settings) async {
    try {
      final response = await _dio.post('/api/member/update', data: {
        'recoverFlag': settings.isEnabled,
        'recoverContent': settings.content,
      });
      
      _checkResponse(response);
      
      return true;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<TimeSettings> getTimeSettings() async {
    try {
      final response = await _dio.get('/api/member/info');
      
      _checkResponse(response);
      
      // 从Member信息中解析时间设置
      final data = response.data['data'];
      final memberDto = MemberDto.fromJson(data);
      
      return memberDto.toTimeSettings();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<bool> updateTimeSettings(TimeSettingsData settings) async {
    try {
      // 转换为API需要的格式
      final data = settings.toJson();
      
      final response = await _dio.post('/api/member/update', data: data);
      
      _checkResponse(response);
      
      return true;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<List<NotificationDto>> getNotificationList({String? messageType}) async {
    try {
      final params = <String, dynamic>{};
      if (messageType != null) {
        params['messageType'] = messageType;
      }
      
      final response = await _dio.get('/api/member/notification/messages', queryParameters: params);
      
      _checkResponse(response);
      
      final data = response.data['data'] as List<dynamic>;
      return data.map((json) => NotificationDto.fromJson(json)).toList();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final response = await _dio.post('/api/member/notification/read', data: {
        'id': notificationId,
      });
      
      _checkResponse(response);
      
      return true;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<bool> markAllNotificationsAsRead({String? messageTypes}) async {
    try {
      final params = <String, dynamic>{};
      if (messageTypes != null) {
        params['messageTypes'] = messageTypes;
      }
      
      final response = await _dio.post('/api/member/notification/mark-read', data: params);
      
      _checkResponse(response);
      
      return true;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<int> getUnreadNotificationCount() async {
    try {
      final response = await _dio.get('/api/member/notification/unreads');
      
      _checkResponse(response);
      
      return response.data['data'] as int;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<List<SellerAuthenticationInfo>> getAuthenticationStatusList() async {
    try {
      final response = await _dio.get('/api/member/authentication/status');
      
      _checkResponse(response);
      
      // 根据API响应结构处理
      final data = response.data['data'] as List<dynamic>;
      // 转换为SellerAuthenticationInfo对象列表
      return data.map((json) {
        // 导入的SellerAuthenticationInfo包含AuthenticationType和AuthenticationStatus嵌套类型
        // 但在dart中嵌套类型通常不能直接访问，所以这里创建枚举值的逻辑可能需要调整
        
        // 创建类型和状态
        final typeValue = json['type'] ?? 'OTHER';
        final statusValue = json['status'];
        
        return SellerAuthenticationInfo(
          authenticationId: json['id'] ?? 0,
          type: _mapToAuthenticationType(typeValue),
          status: _mapToAuthenticationStatus(statusValue),
          name: json['name'] ?? '', // 使用接口返回的名称，如果没有则使用空字符串
          enabled: json['enabled'] == 'OPEN' || json['enabled'] == true,
          icon: json['icon'],
          remarks: json['remark'],
          rejectionReason: json['rejectionReason'],
          submittedAt: json['submittedAt'] != null ? DateTime.tryParse(json['submittedAt']) : null,
        );
      }).toList();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }
  
  // 辅助方法：将API值映射到AuthenticationType枚举
  AuthenticationType _mapToAuthenticationType(String value) {
    switch(value) {
      case 'ID_CARD': return AuthenticationType.idCard;
      case 'EDUCATION': return AuthenticationType.education;
      case 'PROFESSION': return AuthenticationType.profession;
      case 'COMPANY': return AuthenticationType.company;
      default: return AuthenticationType.other;
    }
  }
  
  // 辅助方法：将API值映射到AuthenticationStatus枚举
  AuthenticationStatus _mapToAuthenticationStatus(String? value) {
    switch(value) {
      case 'PENDING': return AuthenticationStatus.pending;
      case 'APPROVED': return AuthenticationStatus.approved;
      case 'REJECTED': return AuthenticationStatus.rejected;
      default: return AuthenticationStatus.notSubmitted;
    }
  }

  @override
  Future<bool> submitAuthenticationApplication(AuthenticationApplicationData applicationData) async {
    try {
      // 转换为API需要的格式
      Map<String, dynamic> data = {
        // 根据applicationData结构填充
      };
      
      final response = await _dio.post('/api/member/authentication/apply', data: data);
      
      _checkResponse(response);
      
      return true;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<PaginatedListDto<OrderRefundDto>> getTenantAuditList({
    required int pageNum,
    required int pageSize,
  }) async {
    try {
      final response = await _dio.post('/api/shop/order-refund/tenantAudit', data: {
        'pageNum': pageNum,
        'pageSize': pageSize,
      });
      
      _checkResponse(response);
      
      // 提供解析单个记录的函数 (OrderRefundDto.fromJson)
      final result = PaginatedListDto.fromJson(
        response.data,
        OrderRefundDto.fromJson,
      );
      
      // 直接返回结果
      return result;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<bool> auditRefund({
    required int id,
    required String refundState,
    String? auditRemark,
  }) async {
    try {
      final data = {
        'id': id,
        'refundState': refundState,
      };
      
      if (auditRemark != null) {
        data['auditRemark'] = auditRemark;
      }
      
      final response = await _dio.post('/api/shop/order-refund/audit', data: data);
      
      _checkResponse(response);
      
      return true;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<OrderRefundDto> getRefundDetail(int refundId) async {
    try {
      final response = await _dio.get('/api/shop/order-refund/detail', queryParameters: {
        'id': refundId,
      });
      
      _checkResponse(response);
      
      final data = response.data['data'];
      return OrderRefundDto.fromJson(data);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<bool> addOrderDelivery({
    required int orderId,
    required String content,
    required List<String> files,
  }) async {
    try {
      final response = await _dio.post('/api/project/orderDelivery/add', data: {
        'orderId': orderId,
        'content': content,
        'files': files,
      });
      
      _checkResponse(response);
      
      return true;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<List<SellerAuthenticationInfo>> getAuthenticationStatus() async {
    // TODO: Implement actual API call for getAuthenticationStatus
    print('WARNING: Using placeholder implementation for getAuthenticationStatus in SellerRemoteDataSourceImpl');
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network delay
    return []; // Return empty list as placeholder
  }

  @override
  Future<dynamic> getShopVerificationStatus() async {
    // TODO: Implement actual API call for getShopVerificationStatus
    // TODO: Define ShopVerificationStatus type and return correctly
    print('WARNING: Using placeholder implementation for getShopVerificationStatus in SellerRemoteDataSourceImpl');
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network delay
    // return ShopVerificationStatus.unknown; 
    return null; // Return null as placeholder
  }

  /// 检查响应状态码
  void _checkResponse(Response response) {
    if (response.statusCode != 200) {
      throw ServerException(message: response.statusMessage ?? '服务器错误');
    }
    
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('code') && data['code'] != 200) {
      throw ServerException(message: data['msg'] ?? '服务器错误');
    }
  }

  /// 处理错误
  void _handleError(dynamic error) {
    if (error is DioException) {
      throw ServerException(message: error.message ?? '网络错误');
    } else if (error is! ServerException) {
      throw ServerException(message: error.toString());
    }
  }
} 