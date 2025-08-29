import 'dart:convert';
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
        requestData['state'] = state; // 保持原状态值，不转换大小写
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
      print('[SellerRemoteDataSource] 获取草稿列表 - 页码: $pageNum, 每页: $pageSize');
      
      // 使用正确的草稿API端点
      final response = await _dio.post('/api/shop/product/myDraft', data: {
        'pageNum': pageNum,
        'pageSize': pageSize,
      });
      
      _checkResponse(response);
      
      final data = response.data;
      print('[SellerRemoteDataSource] 草稿API响应: $data');
      
      // 处理分页数据
      final records = data['rows'] as List? ?? data['records'] as List? ?? [];
      final total = data['total'] as int? ?? records.length;
      
      print('[SellerRemoteDataSource] 草稿数量: ${records.length}, 总数: $total');
      
      return PaginatedListDto<dynamic>(
        total: total,
        records: records,
      );
    } catch (e) {
      print('[SellerRemoteDataSource] 草稿列表获取失败: $e');
      
      // 返回空列表而不是抛出异常，保证UI能正常显示
      return PaginatedListDto<dynamic>(
        total: 0,
        records: [],
      );
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
      // 后端期望小写状态值（与ProductState枚举定义一致）
      String apiState;
      switch (state.toLowerCase()) {
        case 'normal':
          apiState = 'on_sale'; // 映射normal到on_sale
          break;
        case 'on_sale':
          apiState = 'on_sale'; // 直接使用on_sale
          break;
        case 'disabled':
          apiState = 'disabled';
          break;
        case 'force_disabled':
          apiState = 'force_disabled';
          break;
        case 'reviewing':
          apiState = 'on_sale'; // 草稿发布时，将状态设置为on_sale
          break;
        default:
          apiState = state.toLowerCase();
      }
      
      print('[SellerRemoteDataSource] 🔄 使用专门的上下架端点更新商品状态: productId=$productId, state=$apiState');
      
      // 获取完整的商品信息
      final getResponse = await _dio.get('/api/shop/product/get', queryParameters: {
        'id': productId,
      });
      
      _checkResponse(getResponse);
      
      final productData = getResponse.data['data'];
      if (productData == null) {
        throw Exception('商品信息不存在');
      }
      
      print('[SellerRemoteDataSource] ✅ 获取商品信息成功，准备使用edit端点更新状态');
      
      // 构建完整的商品数据，但只修改状态字段
      final editData = {
        'id': productData['id'],
        'tenantId': productData['tenantId'],
        'images': productData['images'] ?? [],
        'name': productData['name'] ?? '',
        'description': productData['description'] ?? '',
        'selectionMode': productData['selectionMode'] ?? 'CUSTOMIZE',
        'state': apiState, // 这是我们要更新的字段
        'statusAudit': productData['statusAudit'] ?? 'SUCCESS',
        'variants': productData['variants'] ?? [],
        'productMaterials': productData['productMaterials'] ?? [],
        // 草稿发布时，需要将productType从draft改为product
        'productType': (state.toLowerCase() == 'reviewing' && productData['productType'] == 'draft') 
            ? 'product' 
            : (productData['productType'] ?? 'product'),
        // 价格相关字段，确保格式正确
        'originalPrice': productData['originalPrice'] ?? 0.00,
        'sellingPrice': productData['sellingPrice'] ?? 0.00,
        'costPrice': productData['costPrice'] ?? 0.00,
        'freightPrice': productData['freightPrice'] ?? 0.0,
        // 其他必需字段
        'inventory': productData['inventory'] ?? 0,
        'buyedNumber': productData['buyedNumber'] ?? 0,
        'viewNumber': productData['viewNumber'] ?? 0,
        'minimumBuy': productData['minimumBuy'] ?? 1,
        'top': productData['top'] ?? false,
        // 添加可能缺失的字段
        'keyword': productData['keyword'] ?? '',
        'content': productData['content'] ?? '',
        'categoryId': productData['categoryId'],
        'mainImage': productData['mainImage'],
        'winImages': productData['winImages'] ?? [],
        'auditRemark': productData['auditRemark'],
      };
      
      print('[SellerRemoteDataSource] 📤 使用edit端点发送上下架请求，数据字段数: ${editData.keys.length}');
      
      // 使用专门的上下架端点
      final response = await _dio.post('/api/shop/product/edit', data: editData);
      
      _checkResponse(response);
      
      print('[SellerRemoteDataSource] ✅ 商品状态更新成功 (使用edit端点)');
      return true;
    } catch (e) {
      print('[SellerRemoteDataSource] ❌ 商品状态更新失败: $e');
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
      
      // 特别调试winImages字段
      if (data['winImages'] != null && data['winImages'] is List) {
        final winImagesList = data['winImages'] as List;
        print('[DEBUG] 创建商品时的winImages: 数量=${winImagesList.length}, 内容=$winImagesList');
      } else {
        print('[DEBUG] 创建商品时的winImages为空或格式不正确: ${data['winImages']}');
      }

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
      print('[SellerRemoteDataSource] 🔄 更新商品信息: productId=${productData.id}');
      
      // 获取完整的商品信息
      final getResponse = await _dio.get('/api/shop/product/get', queryParameters: {
        'id': productData.id,
      });
      
      _checkResponse(getResponse);
      
      final existingData = getResponse.data['data'];
      if (existingData == null) {
        throw Exception('商品信息不存在');
      }
      
      print('[SellerRemoteDataSource] ✅ 获取商品信息成功，准备合并更新数据');
      
      // 构建完整的商品数据，合并现有数据和更新数据
      final mergedData = _mergeProductData(existingData, productData);
      
      // 打印请求数据，便于调试
      print('Updating product with merged data: $mergedData');
      
      // 特别调试productMaterials字段
      if (mergedData['productMaterials'] != null && mergedData['productMaterials'] is List) {
        final materialsList = mergedData['productMaterials'] as List;
        print('[DEBUG] 最终发送的productMaterials: 数量=${materialsList.length}, 内容=$materialsList');
      } else {
        print('[DEBUG] 最终发送的productMaterials为空或格式不正确: ${mergedData['productMaterials']}');
      }
      
      // 特别调试winImages字段
      if (mergedData['winImages'] != null && mergedData['winImages'] is List) {
        final winImagesList = mergedData['winImages'] as List;
        print('[DEBUG] 最终发送的winImages: 数量=${winImagesList.length}, 内容=$winImagesList');
      } else {
        print('[DEBUG] 最终发送的winImages为空或格式不正确: ${mergedData['winImages']}');
      }
      
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
      // 修复：始终使用update端点，因为edit端点不会保存productMaterials
      // update端点会正确处理productMaterials的保存
      final endpoint = '/api/shop/product/update';
      print('Using endpoint: $endpoint for all product updates to ensure productMaterials are saved');
      final response = await productUpdateDio.post(endpoint, data: mergedData, options: options);
      
      _checkResponse(response);
      
      print('[SellerRemoteDataSource] ✅ 商品更新成功');
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
      final response = await _dio.get('/api/member/notification/read', queryParameters: {
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
      // 使用正确的POST方法并传递分页参数
      final response = await _dio.post('/api/project/authentication/list', data: {
        'pageNum': 1,
        'pageSize': 100, // 获取所有认证项
      });
      
      _checkResponse(response);
      
      // 根据实际API响应结构处理 - 数据直接在response.data['rows']中
      final data = response.data['rows'] as List<dynamic>? ?? [];
      
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
          final auditStatus = auditInfo['auditStatus']?.toString();
          
          print('[DataSource] 认证审核信息: $auditInfo');
          print('[DataSource] 审核状态: $auditStatus');
          
          // 修复：使用更准确的状态映射，并添加调试信息
          switch (auditStatus?.toLowerCase()) {
            case 'pass':
            case 'approved':
            case '1':
              status = AuthenticationStatus.approved;
              print('[DataSource] 状态映射为: approved');
              break;
            case 'fail':
            case 'rejected':
            case '2':
              status = AuthenticationStatus.rejected;
              rejectionReason = auditInfo['rejectReason']?.toString();
              print('[DataSource] 状态映射为: rejected, 原因: $rejectionReason');
              break;
            case 'pending':
            case 'wait':
            case 'waiting':
            case '0':
            case 'null':
            case null:
              status = AuthenticationStatus.pending;
              print('[DataSource] 状态映射为: pending');
              break;
            default:
              // 修复：如果有审核信息但状态不明确，默认为pending
              status = AuthenticationStatus.pending;
              print('[DataSource] 未知状态 [$auditStatus]，默认映射为: pending');
          }
          
          // 解析提交时间
          if (auditInfo['createTime'] != null) {
            submittedAt = DateTime.tryParse(auditInfo['createTime']);
          }
          
          // 解析提交的基本信息和图片
          Map<String, dynamic> parsedFields = {};
          
          // 修复：增强图片解析逻辑并添加调试信息
          if (auditInfo['images'] != null) {
            final images = auditInfo['images'];
            print('[DataSource] 解析认证图片: $images (类型: ${images.runtimeType})');
            
            if (images is List && images.isNotEmpty) {
              final imageUrls = images.map((img) => img.toString()).where((url) => url.isNotEmpty).toList();
              parsedFields['images'] = imageUrls;
              print('[DataSource] 图片列表解析结果: $imageUrls');
            } else if (images is String && images.isNotEmpty) {
              final imageUrls = images.split(',').where((img) => img.trim().isNotEmpty).map((img) => img.trim()).toList();
              parsedFields['images'] = imageUrls;
              print('[DataSource] 图片字符串解析结果: $imageUrls');
            } else {
              print('[DataSource] 图片数据为空或格式不正确');
            }
          } else {
            print('[DataSource] 没有找到图片字段');
          }
          
          // 获取提交的姓名/公司名称
          if (auditInfo['name'] != null && auditInfo['name'].toString().isNotEmpty) {
            parsedFields['name'] = auditInfo['name'].toString();
          }
          
          // 获取备注信息
          if (auditInfo['remarks'] != null && auditInfo['remarks'].toString().isNotEmpty) {
            parsedFields['remarks'] = auditInfo['remarks'].toString();
          }
          
          // 解析提交的特殊字段 (feature)
          if (auditInfo['feature'] != null) {
            if (auditInfo['feature'] is Map<String, dynamic>) {
              parsedFields['feature'] = auditInfo['feature'];
            } else if (auditInfo['feature'] is String) {
              // 如果feature是JSON字符串，尝试解析
              try {
                final featureData = json.decode(auditInfo['feature']);
                if (featureData is Map<String, dynamic>) {
                  parsedFields['feature'] = featureData;
                }
              } catch (e) {
                // 解析失败，直接作为字符串存储
                parsedFields['feature'] = auditInfo['feature'];
              }
            }
          }
          
          fields = parsedFields.isNotEmpty ? parsedFields : null;
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
      case 'other': return AuthenticationType.profession; // 修复：other类型映射为职业认证
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
        'authenticationType': applicationData.authenticationType, // 添加认证类型字段
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
    // 后端API成功时返回code=0，部分API返回code=200
    if (code != 200 && code != 0) {
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

  /// 合并现有商品数据和更新数据
  Map<String, dynamic> _mergeProductData(Map<String, dynamic> existingData, ProductUpdateData updateData) {
    // 转换更新数据为JSON格式
    final updateJson = updateData.toJson();
    
    // 调试日志：检查productMaterials和winImages的处理
    print('[DEBUG] _mergeProductData - updateJson[productMaterials]: ${updateJson['productMaterials']}');
    print('[DEBUG] _mergeProductData - existingData[productMaterials]: ${existingData['productMaterials']}');
    print('[DEBUG] _mergeProductData - updateJson[winImages]: ${updateJson['winImages']}');
    print('[DEBUG] _mergeProductData - existingData[winImages]: ${existingData['winImages']}');
    
    // 构建完整的商品数据，确保所有必需字段都存在
    final mergedData = {
      // 基础信息（必需）
      'id': updateData.id,
      'tenantId': existingData['tenantId'],
      'selectionMode': existingData['selectionMode'] ?? 'CUSTOMIZE',
      // 修复：对于草稿商品，不要改变审核状态
      'statusAudit': existingData['productType'] == 'draft' 
          ? (existingData['statusAudit'] ?? 'SUCCESS')  // 草稿保持原状态
          : 'WAIT',  // 正式商品更新后需要重新审核
      'productType': existingData['productType'] ?? 'product',
      
      // 商品基本信息
      'name': updateJson['name'] ?? existingData['name'] ?? '',
      'description': updateJson['description'] ?? existingData['description'] ?? '',
      'categoryId': updateJson['categoryId'] ?? existingData['categoryId'],
      'state': updateJson['state'] ?? existingData['state'] ?? 'on_sale',
      
      // 图片处理
      'images': updateJson['images'] ?? existingData['images'] ?? [],
      'mainImage': updateJson['mainImage'] ?? existingData['mainImage'] ?? 
                   (updateJson['images'] is List && (updateJson['images'] as List).isNotEmpty 
                    ? (updateJson['images'] as List).first 
                    : existingData['mainImage']),
      'winImages': updateJson['winImages'] ?? existingData['winImages'] ?? [],
      
      // 价格相关字段（确保都是数值类型）
      'originalPrice': updateJson['originalPrice'] ?? existingData['originalPrice'] ?? 0.00,
      'sellingPrice': updateJson['sellingPrice'] ?? existingData['sellingPrice'] ?? 0.00,
      'costPrice': existingData['costPrice'] ?? 0.00,
      'freightPrice': existingData['freightPrice'] ?? 0.0,
      
      // 库存和统计字段
      'inventory': existingData['inventory'] ?? 0,
      'buyedNumber': existingData['buyedNumber'] ?? 0,
      'viewNumber': existingData['viewNumber'] ?? 0,
      'minimumBuy': existingData['minimumBuy'] ?? 1,
      'top': existingData['top'] ?? false,
      
      // 其他字段
      'keyword': existingData['keyword'] ?? '',
      'content': existingData['content'] ?? '',
      'auditRemark': existingData['auditRemark'],
      
      // 商品变体和材料（从updateJson获取，如果没有则使用现有数据）
      'variants': updateJson['variants'] ?? existingData['variants'] ?? [],
      'productMaterials': updateJson['productMaterials'] ?? existingData['productMaterials'] ?? [],
    };
    
    // 如果有详情图，添加到数据中
    if (updateJson['detailImages'] != null) {
      mergedData['detailImages'] = updateJson['detailImages'];
    } else if (existingData['detailImages'] != null) {
      mergedData['detailImages'] = existingData['detailImages'];
    }
    
    // 如果有详情内容，添加到数据中
    if (updateJson['detailContent'] != null) {
      mergedData['detailContent'] = updateJson['detailContent'];
    } else if (existingData['detailContent'] != null) {
      mergedData['detailContent'] = existingData['detailContent'];
    }
    
    return mergedData;
  }
} 