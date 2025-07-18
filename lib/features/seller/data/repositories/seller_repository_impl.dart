import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/exceptions.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/network/network_info.dart';
import 'package:dskk_flutter_refactor/features/seller/data/datasources/i_seller_local_data_source.dart';
import 'package:dskk_flutter_refactor/features/seller/data/datasources/i_seller_remote_data_source.dart';
import 'package:dskk_flutter_refactor/features/seller/data/models/order_refund_dto.dart';
import 'package:dskk_flutter_refactor/features/seller/data/models/seller_managed_product_dto.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/auto_reply_settings.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/enums/product_status.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_authentication_info.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_dashboard_data.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_notification.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_store_profile.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/time_settings.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/order_refund.dart';
import 'package:injectable/injectable.dart';

/// 卖家模块仓库实现类
@Injectable(as: ISellerRepository)
class SellerRepositoryImpl implements ISellerRepository {
  final ISellerRemoteDataSource _remoteDataSource;
  final ISellerLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  /// 构造函数，注入依赖
  SellerRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  /// 获取卖家仪表盘数据
  @override
  Future<Either<Failure, SellerDashboardData>> getDashboardData() async {
    if (await _networkInfo.isConnected) {
      try {
        final dashboardData = await _remoteDataSource.getDashboardData();
        // 2. Call Local Data Source to cache
        // await _localDataSource.cacheDashboardData(dashboardData); // Temporarily commented out to avoid UnimplementedError
        return Right(dashboardData);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final localData = await _localDataSource.getCachedDashboardData();
        if (localData != null) {
          return Right(localData);
        } else {
          return Left(NetworkFailure(message: '无网络连接，且无本地缓存数据'));
        }
      } on CacheException {
        return Left(CacheFailure(message: '本地缓存读取失败'));
      }
    }
  }

  /// 获取卖家商品列表 (已发布/全部)
  @override
  Future<Either<Failure, PaginatedList<SellerManagedProduct>>> getSellerProductList({
    required int pageNum,
    required int pageSize,
    String? state,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.getSellerProductList(
          pageNum: pageNum,
          pageSize: pageSize,
          state: state,
        );
        
        // 将结果转换为Domain实体
        final products = (result.records ?? [])
            .map((item) => _mapToSellerManagedProduct(item))
            .toList();
        
        // 缓存结果
        await _localDataSource.cacheProductList(
          result.records?.cast<Map<String, dynamic>>() ?? [],
          state,
        );
        
        return Right(PaginatedList(
          total: result.total ?? 0,
          items: products,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final localProducts = await _localDataSource.getCachedProductList(state);
        if (localProducts != null) {
          final products = localProducts
              .map((item) => _mapToSellerManagedProduct(item))
              .toList();
          
          return Right(PaginatedList(
            total: products.length,
            items: products,
          ));
        } else {
          return Left(NetworkFailure(message: '无网络连接，且无本地缓存数据'));
        }
      } on CacheException {
        return Left(CacheFailure(message: '本地缓存读取失败'));
      }
    }
  }

  /// 获取卖家商品列表 (草稿箱)
  @override
  Future<Either<Failure, PaginatedList<SellerManagedProduct>>> getSellerDraftList({
    required int pageNum,
    required int pageSize,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        // 调用正确的远程数据源方法获取草稿列表
        final result = await _remoteDataSource.getSellerDraftList(
          pageNum: pageNum,
          pageSize: pageSize,
        );
        
        // 将结果转换为Domain实体
        final products = (result.records ?? [])
            .map((item) => _mapToSellerManagedProduct(item)) // 复用映射逻辑
            .toList();
        
        // 可以在这里考虑是否需要缓存草稿列表，如果需要则调用 localDataSource
        // await _localDataSource.cacheDraftList( ... );
        
        return Right(PaginatedList(
          total: result.total ?? 0,
          items: products,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '获取草稿列表服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: '获取草稿列表失败: ${e.toString()}'));
      }
    } else {
      // 草稿通常不进行离线缓存，直接返回网络错误
      // 如果需要支持离线查看草稿，则需要添加本地缓存逻辑
      return Left(NetworkFailure(message: '无网络连接，无法获取草稿列表'));
    }
  }

  /// 获取商品详情
  @override
  Future<Either<Failure, SellerManagedProduct>> getProductDetail(int productId) async {
    if (await _networkInfo.isConnected) {
      try {
        final productData = await _remoteDataSource.getProductDetail(productId);
        
        // 缓存结果
        await _localDataSource.cacheProductDetail(
          productId,
          productData as Map<String, dynamic>,
        );
        
        return Right(_mapToSellerManagedProduct(productData));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final localProduct = await _localDataSource.getCachedProductDetail(productId);
        if (localProduct != null) {
          return Right(_mapToSellerManagedProduct(localProduct));
        } else {
          return Left(NetworkFailure(message: '无网络连接，且无本地缓存数据'));
        }
      } on CacheException {
        return Left(CacheFailure(message: '本地缓存读取失败'));
      }
    }
  }

  /// 更新商品状态 (上架/下架)
  @override
  Future<Either<Failure, bool>> updateProductStatus(int productId, String state) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.updateProductStatus(productId, state);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: '无网络连接，无法更新商品状态'));
    }
  }

  /// 创建商品
  @override
  Future<Either<Failure, bool>> createProduct(ProductCreationData productData) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.createProduct(productData);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: '无网络连接，无法创建商品'));
    }
  }

  /// 更新商品
  @override
  Future<Either<Failure, bool>> updateProduct(ProductUpdateData productData) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.updateProduct(productData);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: '无网络连接，无法更新商品'));
    }
  }

  /// 删除商品
  @override
  Future<Either<Failure, bool>> deleteProduct(List<int> productIds) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.deleteProduct(productIds);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: '无网络连接，无法删除商品'));
    }
  }

  /// 获取店铺资料
  @override
  Future<Either<Failure, SellerStoreProfile>> getStoreProfile() async {
    if (await _networkInfo.isConnected) {
      try {
        final profile = await _remoteDataSource.getStoreProfile();
        // await _localDataSource.cacheStoreProfile(profile); // Temporarily commented out to avoid UnimplementedError
        return Right(profile);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final localProfile = await _localDataSource.getCachedStoreProfile();
        if (localProfile != null) {
          return Right(localProfile);
        } else {
          return Left(NetworkFailure(message: '无网络连接，且无本地缓存数据'));
        }
      } on CacheException {
        return Left(CacheFailure(message: '本地缓存读取失败'));
      }
    }
  }

  /// 更新店铺资料
  @override
  Future<Either<Failure, bool>> updateStoreProfile(StoreProfileUpdateData profileData) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.updateStoreProfile(profileData);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: '无网络连接，无法更新店铺资料'));
    }
  }

  /// 更新卖家在线状态
  @override
  Future<Either<Failure, bool>> updateOnlineStatus(bool isOnline) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.updateOnlineStatus(isOnline);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: '无网络连接，无法更新在线状态'));
    }
  }

  /// 获取自动回复设置
  @override
  Future<Either<Failure, AutoReplySettings>> getAutoReplySettings() async {
    if (await _networkInfo.isConnected) {
      try {
        final settings = await _remoteDataSource.getAutoReplySettings();
        await _localDataSource.cacheAutoReplySettings(settings);
        return Right(settings);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final localSettings = await _localDataSource.getCachedAutoReplySettings();
        if (localSettings != null) {
          return Right(localSettings);
        } else {
          return Left(NetworkFailure(message: '无网络连接，且无本地缓存数据'));
        }
      } on CacheException {
        return Left(CacheFailure(message: '本地缓存读取失败'));
      }
    }
  }

  /// 设置自动回复
  @override
  Future<Either<Failure, bool>> setAutoReplySettings(AutoReplySettings settings) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.setAutoReplySettings(settings);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: '无网络连接，无法设置自动回复'));
    }
  }

  /// 获取时间设置
  @override
  Future<Either<Failure, TimeSettings>> getTimeSettings() async {
    if (await _networkInfo.isConnected) {
      try {
        final settings = await _remoteDataSource.getTimeSettings();
        await _localDataSource.cacheTimeSettings(settings);
        return Right(settings);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final localSettings = await _localDataSource.getCachedTimeSettings();
        if (localSettings != null) {
          return Right(localSettings);
        } else {
          return Left(NetworkFailure(message: '无网络连接，且无本地缓存数据'));
        }
      } on CacheException {
        return Left(CacheFailure(message: '本地缓存读取失败'));
      }
    }
  }

  /// 更新时间设置
  @override
  Future<Either<Failure, bool>> updateTimeSettings(TimeSettingsData settings) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.updateTimeSettings(settings);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: '无网络连接，无法更新时间设置'));
    }
  }

  /// 获取通知列表
  @override
  Future<Either<Failure, List<SellerNotification>>> getNotificationList({
    String? messageType,
    int pageNum = 1,
    int pageSize = 10
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final notificationDtos = await _remoteDataSource.getNotificationList(
          messageType: messageType,
          pageNum: pageNum,
          pageSize: pageSize
        );
        
        // 将DTO转换为领域实体
        final notifications = notificationDtos.map((dto) => dto.toEntity()).toList();
        
        // 缓存通知
        await _localDataSource.cacheNotifications(notificationDtos, messageType);
        
        return Right(notifications);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final localNotifications = await _localDataSource.getCachedNotifications(messageType);
        if (localNotifications != null) {
          return Right(localNotifications.map((dto) => dto.toEntity()).toList());
        } else {
          return Left(NetworkFailure(message: '无网络连接，且无本地缓存数据'));
        }
      } on CacheException {
        return Left(CacheFailure(message: '本地缓存读取失败'));
      }
    }
  }

  /// 标记通知为已读
  @override
  Future<Either<Failure, bool>> markNotificationAsRead(String notificationId) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.markNotificationAsRead(notificationId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: '无网络连接，无法标记通知为已读'));
    }
  }

  /// 标记所有通知为已读
  @override
  Future<Either<Failure, bool>> markAllNotificationsAsRead({String? messageTypes}) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.markAllNotificationsAsRead(messageTypes: messageTypes);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: '无网络连接，无法标记所有通知为已读'));
    }
  }

  /// 获取未读通知数量
  @override
  Future<Either<Failure, int>> getUnreadNotificationCount() async {
    if (await _networkInfo.isConnected) {
      try {
        final count = await _remoteDataSource.getUnreadNotificationCount();
        return Right(count);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: '无网络连接，无法获取未读通知数量'));
    }
  }

  /// 获取认证状态/信息列表
  @override
  Future<Either<Failure, List<SellerAuthenticationInfo>>> getAuthenticationStatus() async {
    if (await _networkInfo.isConnected) {
      try {
        // 调用远程数据源的getAuthenticationStatus方法
        final authList = await _remoteDataSource.getAuthenticationStatus();
        return Right(authList);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: '网络连接失败，请检查网络设置'));
    }
  }

  /// 提交认证申请
  @override
  Future<Either<Failure, bool>> submitAuthenticationApplication(AuthenticationApplicationData applicationData) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.submitAuthenticationApplication(applicationData);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: '无网络连接，无法提交认证申请'));
    }
  }

  /// 获取卖家售后审核列表
  @override
  Future<Either<Failure, PaginatedList<OrderRefund>>> getTenantAuditList({
    required int pageNum,
    required int pageSize,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.getTenantAuditList(
          pageNum: pageNum,
          pageSize: pageSize,
        );
        
        // 将DTO转换为Domain实体
        final refunds = (result.records ?? [])
            .map((dto) => (dto as OrderRefundDto).toEntity())
            .toList();
        
        // 缓存结果
        await _localDataSource.cacheTenantAuditList(
          result.records?.cast<OrderRefundDto>() ?? [],
        );
        
        return Right(PaginatedList(
          total: result.total ?? 0,
          items: refunds,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final localRefunds = await _localDataSource.getCachedTenantAuditList();
        if (localRefunds != null) {
          final refunds = localRefunds.map((dto) => dto.toEntity()).toList();
          return Right(PaginatedList(
            total: refunds.length,
            items: refunds,
          ));
        } else {
          return Left(NetworkFailure(message: '无网络连接，且无本地缓存数据'));
        }
      } on CacheException {
        return Left(CacheFailure(message: '本地缓存读取失败'));
      }
    }
  }

  /// 审核售后申请
  @override
  Future<Either<Failure, bool>> auditRefund({
    required int id,
    required String refundState,
    String? auditRemark,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.auditRefund(
          id: id,
          refundState: refundState,
          auditRemark: auditRemark,
        );
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: '无网络连接，无法审核售后申请'));
    }
  }

  /// 获取售后详情
  @override
  Future<Either<Failure, OrderRefund>> getRefundDetail(int refundId) async {
    if (await _networkInfo.isConnected) {
      try {
        final refundDto = await _remoteDataSource.getRefundDetail(refundId);
        
        // 缓存结果
        await _localDataSource.cacheRefundDetail(refundId, refundDto);
        
        return Right(refundDto.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final localRefund = await _localDataSource.getCachedRefundDetail(refundId);
        if (localRefund != null) {
          return Right(localRefund.toEntity());
        } else {
          return Left(NetworkFailure(message: '无网络连接，且无本地缓存数据'));
        }
      } on CacheException {
        return Left(CacheFailure(message: '本地缓存读取失败'));
      }
    }
  }

  /// 提交订单交付
  @override
  Future<Either<Failure, bool>> addOrderDelivery({
    required int orderId,
    required String content,
    required List<String> files,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.addOrderDelivery(
          orderId: orderId,
          content: content,
          files: files,
        );
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: '无网络连接，无法提交订单交付'));
    }
  }

  /// 将API响应数据映射为SellerManagedProduct实体
  SellerManagedProduct _mapToSellerManagedProduct(dynamic data) {
    // Use DTO for proper mapping with variants and materials
    final dto = SellerManagedProductDto.fromJson(data as Map<String, dynamic>);
    return dto.toEntity();
  }
} 