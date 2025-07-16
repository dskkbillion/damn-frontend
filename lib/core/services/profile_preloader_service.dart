import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../../app/app_mode.dart';
import '../cache/domain/interfaces/i_cache_manager.dart';
import '../../features/profile/domain/repositories/i_user_profile_repository.dart';
import '../../features/profile/domain/entities/user_profile.dart';
import '../../features/orders/domain/repositories/i_order_repository.dart';
import '../../features/orders/domain/entities/order_status.dart';
import '../../features/seller/domain/repositories/i_seller_repository.dart';
import '../../features/seller/domain/entities/seller_dashboard_data.dart';

/// 个人资料页面预加载服务
/// 
/// 负责预加载买家和卖家"我的"页面的关键数据，确保模式切换时秒开
class ProfilePreloaderService {
  static const String _buyerCacheGroup = 'buyer_profile';
  static const String _sellerCacheGroup = 'seller_profile';
  static const Duration _cacheExpiry = Duration(minutes: 10);
  
  final ICacheManager _cacheManager;
  final IUserProfileRepository _userProfileRepository;
  final IOrderRepository _orderRepository;
  final ISellerRepository _sellerRepository;
  
  // 预加载任务管理
  final Map<String, Completer<void>> _loadingTasks = {};
  final Set<String> _completedTasks = {};
  
  ProfilePreloaderService({
    required ICacheManager cacheManager,
    required IUserProfileRepository userProfileRepository,
    required IOrderRepository orderRepository,
    required ISellerRepository sellerRepository,
  }) : _cacheManager = cacheManager,
       _userProfileRepository = userProfileRepository,
       _orderRepository = orderRepository,
       _sellerRepository = sellerRepository;

  /// 预加载买家"我的"页面数据
  Future<void> preloadBuyerProfile() async {
    const taskKey = 'buyer_profile_data';
    
    // 检查是否已在加载中
    if (_loadingTasks.containsKey(taskKey)) {
      return _loadingTasks[taskKey]!.future;
    }
    
    // 检查是否已完成
    if (_completedTasks.contains(taskKey)) {
      return;
    }
    
    final completer = Completer<void>();
    _loadingTasks[taskKey] = completer;
    
    try {
      // 并行加载多个数据源
      await Future.wait([
        _preloadUserProfile(),
        _preloadBuyerOrderStats(),
        _preloadFavoritesCount(),
        _preloadWalletBalance(),
      ]);
      
      _completedTasks.add(taskKey);
      completer.complete();
      
      print('[ProfilePreloader] 买家数据预加载完成');
    } catch (e) {
      print('[ProfilePreloader] 买家数据预加载失败: $e');
      completer.completeError(e);
    } finally {
      _loadingTasks.remove(taskKey);
    }
  }

  /// 预加载卖家"我的"页面数据
  Future<void> preloadSellerProfile() async {
    const taskKey = 'seller_profile_data';
    
    // 检查是否已在加载中
    if (_loadingTasks.containsKey(taskKey)) {
      return _loadingTasks[taskKey]!.future;
    }
    
    // 检查是否已完成
    if (_completedTasks.contains(taskKey)) {
      return;
    }
    
    final completer = Completer<void>();
    _loadingTasks[taskKey] = completer;
    
    try {
      // 并行加载多个数据源
      await Future.wait([
        _preloadSellerDashboardData(),
        _preloadSellerOrderStats(),
        _preloadSellerAuthStatus(),
        _preloadStoreProfile(),
      ]);
      
      _completedTasks.add(taskKey);
      completer.complete();
      
      print('[ProfilePreloader] 卖家数据预加载完成');
    } catch (e) {
      print('[ProfilePreloader] 卖家数据预加载失败: $e');
      completer.completeError(e);
    } finally {
      _loadingTasks.remove(taskKey);
    }
  }

  /// 根据模式预加载对应数据
  Future<void> preloadForMode(AppMode mode) async {
    switch (mode) {
      case AppMode.buyer:
        await preloadBuyerProfile();
        break;
      case AppMode.seller:
        await preloadSellerProfile();
        break;
    }
  }

  /// 预加载两个模式的数据（应用启动时调用）
  Future<void> preloadBothModes({
    AppMode priorityMode = AppMode.buyer,
    Duration delayBetweenModes = const Duration(seconds: 3),
  }) async {
    // 优先加载当前模式
    await preloadForMode(priorityMode);
    
    // 延迟加载另一个模式
    await Future.delayed(delayBetweenModes);
    final otherMode = priorityMode == AppMode.buyer ? AppMode.seller : AppMode.buyer;
    await preloadForMode(otherMode);
  }

  // === 私有方法：具体数据预加载 ===

  /// 预加载用户基本信息（为指定模式）
  Future<void> _preloadUserProfile({String? group}) async {
    try {
      final result = await _userProfileRepository.getUserProfile();
      result.fold(
        (failure) => print('[ProfilePreloader] 预加载用户信息失败: ${failure.message}'),
        (userProfile) async {
          // 如果指定了group，使用指定的；否则同时缓存到两个group
          if (group != null) {
            await _cacheManager.set(
              'user_profile',
              userProfile,
              group: group,
              ttl: _cacheExpiry,
            );
          } else {
            // 同时缓存到买家和卖家组，因为用户信息是共享的
            await Future.wait([
              _cacheManager.set(
                'user_profile',
                userProfile,
                group: _buyerCacheGroup,
                ttl: _cacheExpiry,
              ),
              _cacheManager.set(
                'user_profile',
                userProfile,
                group: _sellerCacheGroup,
                ttl: _cacheExpiry,
              ),
            ]);
          }
        },
      );
    } catch (e) {
      print('[ProfilePreloader] 预加载用户信息失败: $e');
    }
  }

  /// 预加载买家订单统计
  Future<void> _preloadBuyerOrderStats() async {
    try {
      // 获取各状态订单的第一页来统计数量
      final futures = await Future.wait([
        _orderRepository.getOrderList(
          status: OrderStatus.awaitingPayment,
          page: 1,
          limit: 50,
          userRole: 'buyer',
        ),
        _orderRepository.getOrderList(
          status: OrderStatus.awaitingDelivery,
          page: 1,
          limit: 50,
          userRole: 'buyer',
        ),
        _orderRepository.getOrderList(
          status: OrderStatus.orderCompleted,
          page: 1,
          limit: 50,
          userRole: 'buyer',
        ),
      ]);
      
      final orderStats = {
        'awaitingPayment': futures[0].fold((l) => 0, (orders) => orders.length),
        'awaitingDelivery': futures[1].fold((l) => 0, (orders) => orders.length),
        'completed': futures[2].fold((l) => 0, (orders) => orders.length),
      };
      
      await _cacheManager.set(
        'buyer_order_stats',
        orderStats,
        group: _buyerCacheGroup,
        ttl: _cacheExpiry,
      );
    } catch (e) {
      print('[ProfilePreloader] 预加载买家订单统计失败: $e');
    }
  }

  /// 预加载收藏数量
  Future<void> _preloadFavoritesCount() async {
    try {
      // 这里需要根据实际的收藏仓库接口调整
      // final favoritesCount = await _favoritesRepository.getFavoritesCount();
      const favoritesCount = 0; // 临时占位
      
      await _cacheManager.set(
        'favorites_count',
        favoritesCount,
        group: _buyerCacheGroup,
        ttl: _cacheExpiry,
      );
    } catch (e) {
      print('[ProfilePreloader] 预加载收藏数量失败: $e');
    }
  }

  /// 预加载钱包余额
  Future<void> _preloadWalletBalance() async {
    try {
      // 这里需要根据实际的钱包仓库接口调整
      // final walletBalance = await _walletRepository.getBalance();
      const walletBalance = 0.0; // 临时占位
      
      await _cacheManager.set(
        'wallet_balance',
        walletBalance,
        group: _buyerCacheGroup,
        ttl: _cacheExpiry,
      );
    } catch (e) {
      print('[ProfilePreloader] 预加载钱包余额失败: $e');
    }
  }

  /// 预加载卖家仪表板数据
  Future<void> _preloadSellerDashboardData() async {
    try {
      final result = await _sellerRepository.getDashboardData();
      result.fold(
        (failure) => print('[ProfilePreloader] 预加载卖家仪表板数据失败: ${failure.message}'),
        (dashboardData) async {
          await _cacheManager.set(
            'seller_dashboard',
            dashboardData,
            group: _sellerCacheGroup,
            ttl: _cacheExpiry,
          );
        },
      );
    } catch (e) {
      print('[ProfilePreloader] 预加载卖家仪表板数据失败: $e');
    }
  }

  /// 预加载卖家订单统计
  Future<void> _preloadSellerOrderStats() async {
    try {
      // 卖家订单统计通常包含在仪表板数据中，这里可以获取卖家的订单列表来统计
      final orderListResult = await _orderRepository.getOrderList(
        page: 1,
        limit: 50,
        userRole: 'seller',
      );
      
      orderListResult.fold(
        (failure) => print('[ProfilePreloader] 预加载卖家订单统计失败: ${failure.message}'),
        (orders) async {
          final orderStats = {
            'total': orders.length,
            'awaitingPayment': orders.where((o) => o.state == OrderStatus.awaitingPayment).length,
            'inProgress': orders.where((o) => o.state == OrderStatus.awaitingDelivery).length,
            'completed': orders.where((o) => o.state == OrderStatus.orderCompleted).length,
          };
          
          await _cacheManager.set(
            'seller_order_stats',
            orderStats,
            group: _sellerCacheGroup,
            ttl: _cacheExpiry,
          );
        },
      );
    } catch (e) {
      print('[ProfilePreloader] 预加载卖家订单统计失败: $e');
    }
  }

  /// 预加载卖家认证状态
  Future<void> _preloadSellerAuthStatus() async {
    try {
      final result = await _sellerRepository.getAuthenticationStatus();
      result.fold(
        (failure) => print('[ProfilePreloader] 预加载卖家认证状态失败: ${failure.message}'),
        (authStatusList) async {
          await _cacheManager.set(
            'seller_auth_status',
            authStatusList,
            group: _sellerCacheGroup,
            ttl: _cacheExpiry,
          );
        },
      );
    } catch (e) {
      print('[ProfilePreloader] 预加载卖家认证状态失败: $e');
    }
  }

  /// 预加载店铺信息
  Future<void> _preloadStoreProfile() async {
    try {
      final result = await _sellerRepository.getStoreProfile();
      result.fold(
        (failure) => print('[ProfilePreloader] 预加载店铺信息失败: ${failure.message}'),
        (storeProfile) async {
          await _cacheManager.set(
            'store_profile',
            storeProfile,
            group: _sellerCacheGroup,
            ttl: _cacheExpiry,
          );
        },
      );
    } catch (e) {
      print('[ProfilePreloader] 预加载店铺信息失败: $e');
    }
  }

  /// 获取预加载的数据
  Future<T?> getCachedData<T>(String key, AppMode mode) async {
    final group = mode == AppMode.buyer ? _buyerCacheGroup : _sellerCacheGroup;
    return await _cacheManager.get<T>(key, group: group);
  }

  /// 清理指定模式的缓存
  Future<void> clearCache(AppMode mode) async {
    final group = mode == AppMode.buyer ? _buyerCacheGroup : _sellerCacheGroup;
    await _cacheManager.clearGroup(group);
    
    // 清理完成状态
    final taskKey = mode == AppMode.buyer ? 'buyer_profile_data' : 'seller_profile_data';
    _completedTasks.remove(taskKey);
  }

  /// 清理所有缓存
  Future<void> clearAllCache() async {
    await Future.wait([
      _cacheManager.clearGroup(_buyerCacheGroup),
      _cacheManager.clearGroup(_sellerCacheGroup),
    ]);
    _completedTasks.clear();
  }
}

/// ProfilePreloader Provider
final profilePreloaderProvider = Provider<ProfilePreloaderService>((ref) {
  try {
    return GetIt.instance<ProfilePreloaderService>();
  } catch (_) {
    // 如果 GetIt 中没有注册，手动创建
    return ProfilePreloaderService(
      cacheManager: GetIt.instance<ICacheManager>(),
      userProfileRepository: GetIt.instance<IUserProfileRepository>(),
      orderRepository: GetIt.instance<IOrderRepository>(),
      sellerRepository: GetIt.instance<ISellerRepository>(),
    );
  }
});