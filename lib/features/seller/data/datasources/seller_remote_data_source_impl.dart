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
      final response = await _dio.get('/api/shop/product/get', queryParameters: {
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
      // 使用ProductCreationData的toJson()方法获取API需要的格式
      final data = productData.toJson();
      
      // 打印请求数据，便于调试
      print('Creating product with data: $data');

      // 创建一个专用于商品创建的Dio实例，配置更长的超时时间
      final productCreateDio = Dio(BaseOptions(
        baseUrl: _dio.options.baseUrl,
        connectTimeout: const Duration(seconds: 60),  // 1分钟连接超时
        receiveTimeout: const Duration(seconds: 120), // 2分钟接收超时
        sendTimeout: const Duration(seconds: 120),    // 2分钟发送超时
      ));
      
      // 添加日志拦截器，便于调试
      productCreateDio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
      
      // 添加相同的拦截器（如果原dio有的话）
      try {
        for (final interceptor in _dio.interceptors) {
          if (interceptor is! LogInterceptor) { // 已经添加了日志拦截器
            productCreateDio.interceptors.add(interceptor);
          }
        }
      } catch (e) {
        print('Warning: Error copying interceptors: $e');
      }

      // 创建设置更长超时的Options
      final options = Options(
        sendTimeout: const Duration(seconds: 120),
        receiveTimeout: const Duration(seconds: 120),
      );
      
      // 使用新的Dio实例和更长的超时设置发送请求
      print('Sending product creation request with extended timeout (120s)');
      final response = await productCreateDio.post('/api/shop/product/create', data: data, options: options);
      
      _checkResponse(response);
      
      return true;
    } catch (e) {
      print('Error in createProduct: $e');
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<bool> updateProduct(ProductUpdateData productData) async {
    try {
      // 使用ProductUpdateData的toJson()方法获取API需要的格式
      final data = productData.toJson();
      
      // 打印请求数据，便于调试
      print('Updating product with data: $data');
      
      // 创建一个专用于商品更新的Dio实例，配置更长的超时时间
      final productUpdateDio = Dio(BaseOptions(
        baseUrl: _dio.options.baseUrl,
        connectTimeout: const Duration(seconds: 60),  // 1分钟连接超时
        receiveTimeout: const Duration(seconds: 120), // 2分钟接收超时
        sendTimeout: const Duration(seconds: 120),    // 2分钟发送超时
      ));
      
      // 添加日志拦截器，便于调试
      productUpdateDio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
      
      // 添加相同的拦截器（如果原dio有的话）
      try {
        for (final interceptor in _dio.interceptors) {
          if (interceptor is! LogInterceptor) { // 已经添加了日志拦截器
            productUpdateDio.interceptors.add(interceptor);
          }
        }
      } catch (e) {
        print('Warning: Error copying interceptors: $e');
      }

      // 创建设置更长超时的Options
      final options = Options(
        sendTimeout: const Duration(seconds: 120),
        receiveTimeout: const Duration(seconds: 120),
      );
      
      // 使用新的Dio实例和更长的超时设置发送请求
      print('Sending product update request with extended timeout (120s)');
      final response = await productUpdateDio.post('/api/shop/product/update', data: data, options: options);
      
      _checkResponse(response);
      
      return true;
    } catch (e) {
      print('Error in updateProduct: $e');
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
  Future<List<NotificationDto>> getNotificationList({
    String? messageType,
    int pageNum = 1,
    int pageSize = 10
  }) async {
    try {
      final params = <String, dynamic>{
        'pageNum': pageNum,
        'pageSize': pageSize
      };
      if (messageType != null) {
        params['messageType'] = messageType;
      }
      
      final response = await _dio.get('/api/member/notification/messages', queryParameters: params);
      
      _checkResponse(response);
      
      // 检查响应格式
      if (response.data == null || response.data is String) {
        print('Warning: Unexpected response format for notifications: ${response.data}');
        return []; // 返回空列表
      }
      
      // 通知列表在rows字段中，而不是data字段
      if (response.data.containsKey('rows')) {
        final rows = response.data['rows'];
        if (rows == null) {
          print('Warning: Notification rows is null');
          return [];
        }
        
        if (rows is! List) {
          print('Warning: Notification rows is not a List: $rows');
          return [];
        }
        
        return rows.map((json) => NotificationDto.fromJson(json)).toList();
      } 
      // 向后兼容检查，可能有时会返回data字段
      else if (response.data.containsKey('data')) {
        final data = response.data['data'];
        if (data == null) {
          print('Warning: Notification data is null');
          return [];
        }
        
        if (data is! List) {
          print('Warning: Notification data is not a List: $data');
          return [];
        }
        
        return data.map((json) => NotificationDto.fromJson(json)).toList();
      } 
      else {
        print('Warning: Notification response has neither rows nor data field: ${response.data}');
        return []; // 没有找到有效的数据字段
      }
    } catch (e) {
      print('Error in getNotificationList: $e');
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
  Future<List<SellerAuthenticationInfo>> getAuthenticationStatus() async {
    try {
      // 更新API端点路径
      final response = await _dio.get('/api/project/authentication/list');
      
      _checkResponse(response);
      
      // 根据API响应结构处理
      final data = response.data['rows'] as List<dynamic>; // 注意这里使用rows字段
      // 转换为SellerAuthenticationInfo对象列表
      return data.map((json) {
        // 创建类型和状态
        final typeValue = json['type'] ?? 'other';
        final statusValue = json['status'] ?? 'SHUT'; // OPEN表示启用，SHUT表示禁用
        
        // 检查是否有审核信息
        final hasAudit = json['authenticationAuditVo'] != null;
        
        // 确定认证状态
        AuthenticationStatus status = AuthenticationStatus.notSubmitted;
        String? rejectionReason;
        DateTime? submittedAt;
        Map<String, dynamic>? fields;
        
        if (hasAudit) {
          final auditInfo = json['authenticationAuditVo'];
          // 根据API返回解析审核状态
          if (auditInfo['auditStatus'] == 'approved') {
            status = AuthenticationStatus.approved;
          } else if (auditInfo['auditStatus'] == 'rejected') {
            status = AuthenticationStatus.rejected;
            rejectionReason = auditInfo['rejectReason'];
          } else if (auditInfo['auditStatus'] == 'pending') {
            status = AuthenticationStatus.pending;
          }
          
          // 解析提交时间
          if (auditInfo['createTime'] != null) {
            submittedAt = DateTime.tryParse(auditInfo['createTime']);
          }
          
          // 解析提交的特殊字段
          if (auditInfo['feature'] != null) {
            fields = auditInfo['feature'];
          }
        }
        
        return SellerAuthenticationInfo(
          authenticationId: json['id'] ?? 0,
          type: _mapToAuthenticationType(typeValue),
          status: status,
          name: json['name'] ?? '',
          enabled: statusValue == 'OPEN',
          icon: json['icon'],
          remarks: json['remarks'],
          fields: fields,
          rejectionReason: rejectionReason,
          submittedAt: submittedAt,
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
      case 'real_name': return AuthenticationType.idCard;
      case 'background': return AuthenticationType.education;
      case 'corporation': return AuthenticationType.company;
      default: return AuthenticationType.other;
    }
  }
  
  // 辅助方法：将AuthenticationType枚举映射到API值
  String _mapFromAuthenticationType(AuthenticationType type) {
    switch(type) {
      case AuthenticationType.idCard: return 'real_name';
      case AuthenticationType.education: return 'background';
      case AuthenticationType.company: return 'corporation';
      case AuthenticationType.profession: return 'other'; // 可能需要调整
      default: return 'other';
    }
  }

  @override
  Future<bool> submitAuthenticationApplication(AuthenticationApplicationData applicationData) async {
    try {
      // 创建不同认证类型的请求数据
      final Map<String, dynamic> requestData = {
        'authenticationId': applicationData.authenticationId,
        'images': applicationData.images?.split(',').where((s) => s.isNotEmpty).toList() ?? [],
      };
      
      // 根据认证类型添加特定字段
      switch (_mapToAuthenticationType(applicationData.authenticationType)) {
        case AuthenticationType.idCard:
          // 实名认证只需基本字段
          break;
        
        case AuthenticationType.education:
          // 学校认证需要remarks和feature
          requestData['remarks'] = applicationData.remark;
          requestData['feature'] = applicationData.feature ?? {};
          break;
        
        case AuthenticationType.company:
          // 公司认证需要name和feature
          requestData['name'] = applicationData.name;
          requestData['feature'] = applicationData.feature ?? {};
          break;
        
        default:
          // 其他类型认证
          if (applicationData.name?.isNotEmpty == true) {
            requestData['name'] = applicationData.name;
          }
          if (applicationData.remark?.isNotEmpty == true) {
            requestData['remarks'] = applicationData.remark;
          }
          if (applicationData.feature != null) {
            requestData['feature'] = applicationData.feature;
          }
      }
      
      // 发送请求
      final response = await _dio.post(
        '/api/project/authenticationAudit/add', 
        data: requestData
      );
      
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
    final data = response.data;
    if (data == null) {
      throw ServerException(message: '服务器返回空数据');
    }
    
    final int? code = data['code'];
    if (code != 200) {
      final String message = data['msg'] ?? '未知错误';
      throw ServerException(message: message);
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