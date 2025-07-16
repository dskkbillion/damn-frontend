import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/core/navigation/services/i_navigation_service.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/services/profile_preloader_service.dart';
import 'package:dskk_flutter_refactor/app/app_mode.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_dashboard_data.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_store_profile.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_dashboard_data_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_store_profile_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/seller_home/seller_home_event.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/seller_home/seller_home_state.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/routes/seller_routes.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

/// 卖家主页/仪表盘Bloc
@injectable
class SellerHomeBloc extends Bloc<SellerHomeEvent, SellerHomeState> {
  /// 获取卖家仪表盘数据UseCase
  final GetSellerDashboardDataUseCase _getDashboardDataUseCase;
  
  /// 获取店铺资料UseCase
  final GetStoreProfileUseCase _getStoreProfileUseCase;
  
  /// 构造函数，注入依赖
  SellerHomeBloc(
    this._getDashboardDataUseCase,
    this._getStoreProfileUseCase,
  ) : super(SellerHomeState.initial()) {
    print('[SellerHomeBloc] Created');
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
    on<NavigateToOrders>(_onNavigateToOrders);
    on<NavigateToChat>(_onNavigateToChat);
  }
  
  /// 处理加载仪表盘数据事件
  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<SellerHomeState> emit,
  ) async {
    print('[SellerHomeBloc] Received LoadDashboardData event, forceRefresh: ${event.forceRefresh}');
    
    // 如果不是强制刷新，先尝试从缓存获取数据
    if (!event.forceRefresh) {
      try {
        final preloaderService = GetIt.instance<ProfilePreloaderService>();
        
        // 尝试从缓存获取仪表盘数据
        final cachedDashboard = await preloaderService.getCachedData<SellerDashboardData>(
          'seller_dashboard', 
          AppMode.seller,
        );
        
        // 尝试从缓存获取店铺信息
        final cachedStoreProfile = await preloaderService.getCachedData<SellerStoreProfile>(
          'seller_store_profile', 
          AppMode.seller,
        );
        
        if (cachedDashboard != null && cachedStoreProfile != null) {
          print('[SellerHomeBloc] Using cached data, emitting SellerHomeLoaded state');
          emit(SellerHomeLoaded(
            dashboardData: cachedDashboard,
            storeProfile: cachedStoreProfile,
          ));
          return;
        } else {
          print('[SellerHomeBloc] Cache miss, will fetch from network');
        }
      } catch (e) {
        print('[SellerHomeBloc] Failed to get cached data: $e');
      }
    }
    
    print('[SellerHomeBloc] Emitting SellerHomeLoading state');
    emit(const SellerHomeLoading());
    
    try {
      print('[SellerHomeBloc] Calling getDashboardDataUseCase');
      final dashboardResult = await _getDashboardDataUseCase(NoParams());
      print('[SellerHomeBloc] getDashboardDataUseCase returned: ${dashboardResult.isRight() ? "Success" : "Failure"}');

      print('[SellerHomeBloc] Calling getStoreProfileUseCase');
      final storeProfileResult = await _getStoreProfileUseCase(NoParams());
      print('[SellerHomeBloc] getStoreProfileUseCase returned: ${storeProfileResult.isRight() ? "Success" : "Failure"}');
      
      if (dashboardResult.isLeft() || storeProfileResult.isLeft()) {
        print('[SellerHomeBloc] One or both UseCases failed');
        dashboardResult.fold(
          (failure) {
            print('[SellerHomeBloc] Dashboard failed: $failure. Emitting SellerHomeError');
            emit(SellerHomeError(failure: failure));
          },
          (_) => storeProfileResult.fold(
            (failure) {
              print('[SellerHomeBloc] StoreProfile failed: $failure. Emitting SellerHomeError');
              emit(SellerHomeError(failure: failure));
            },
            (_) {}, 
          ),
        );
      } else {
        print('[SellerHomeBloc] Both UseCases succeeded');
        dashboardResult.fold(
          (_) {}, 
          (dashboardData) => storeProfileResult.fold(
            (_) {}, 
            (storeProfile) {
               print('[SellerHomeBloc] Emitting SellerHomeLoaded state');
               emit(SellerHomeLoaded(
                dashboardData: dashboardData,
                storeProfile: storeProfile,
              ));
            }
          ),
        );
      }
    } catch (e) {
      print('[SellerHomeBloc] Exception during data loading: $e. Emitting SellerHomeError');
      emit(SellerHomeError(failure: CacheFailure(message: '未知错误: $e')));
    }
  }
  
  /// 处理刷新仪表盘数据事件
  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<SellerHomeState> emit,
  ) async {
    emit(const SellerHomeLoading());
    
    // 获取仪表盘数据
    final dashboardResult = await _getDashboardDataUseCase(NoParams());
    
    // 获取店铺信息
    final storeProfileResult = await _getStoreProfileUseCase(NoParams());
    
    if (dashboardResult.isLeft() || storeProfileResult.isLeft()) {
      // 处理错误情况
      dashboardResult.fold(
        (failure) => emit(SellerHomeError(failure: failure)),
        (_) => storeProfileResult.fold(
          (failure) => emit(SellerHomeError(failure: failure)),
          (_) {}, // 不会到达此处
        ),
      );
    } else {
      // 处理成功情况
      dashboardResult.fold(
        (_) {}, // 不会到达此处
        (dashboardData) => storeProfileResult.fold(
          (_) {}, // 不会到达此处
          (storeProfile) => emit(SellerHomeLoaded(
            dashboardData: dashboardData,
            storeProfile: storeProfile,
          )),
        ),
      );
    }
  }
  
  /// 处理导航到订单列表页面事件
  Future<void> _onNavigateToOrders(
    NavigateToOrders event,
    Emitter<SellerHomeState> emit,
  ) async {
    String path = '/orders';
    if (event.orderType != null && event.orderType!.isNotEmpty) {
      path += '?type=${event.orderType}';
    }
    // 使用 navigateTo，路径是 Orders 模块的，暂时不确定是否正确
    print('Warning: Navigation to orders ($path) requested but INavigationService dependency removed.');
  }
  
  /// 处理导航到聊天列表页面事件
  Future<void> _onNavigateToChat(
    NavigateToChat event,
    Emitter<SellerHomeState> emit,
  ) async {
    print('Warning: Navigation to chat requested but INavigationService dependency removed.');
  }
} 