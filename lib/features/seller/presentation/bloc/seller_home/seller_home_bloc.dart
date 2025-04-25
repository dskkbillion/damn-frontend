import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/core/navigation/services/i_navigation_service.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_dashboard_data.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_store_profile.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_dashboard_data_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_store_profile_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/seller_home/seller_home_event.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/seller_home/seller_home_state.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

/// 卖家主页/仪表盘Bloc
@injectable
class SellerHomeBloc extends Bloc<SellerHomeEvent, SellerHomeState> {
  /// 获取卖家仪表盘数据UseCase
  final GetSellerDashboardDataUseCase _getDashboardDataUseCase;
  
  /// 获取店铺资料UseCase
  final GetStoreProfileUseCase _getStoreProfileUseCase;
  
  /// 导航服务
  final INavigationService _navigationService;
  
  /// 构造函数，注入依赖
  SellerHomeBloc(
    this._getDashboardDataUseCase,
    this._getStoreProfileUseCase,
    this._navigationService,
  ) : super(SellerHomeState.initial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
    on<NavigateToOrders>(_onNavigateToOrders);
    on<NavigateToNotifications>(_onNavigateToNotifications);
    on<NavigateToChat>(_onNavigateToChat);
    on<NavigateToProducts>(_onNavigateToProducts);
    on<NavigateToAfterSales>(_onNavigateToAfterSales);
    on<NavigateToStoreSettings>(_onNavigateToStoreSettings);
    on<NavigateToAuthentication>(_onNavigateToAuthentication);
    on<NavigateToTimeManagement>(_onNavigateToTimeManagement);
    on<NavigateToAutoReply>(_onNavigateToAutoReply);
  }
  
  /// 处理加载仪表盘数据事件
  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<SellerHomeState> emit,
  ) async {
    if (state.isLoading == false) {
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
    // 由于INavigationService中没有通用的导航方法，这里根据实际情况调整
    // 可能需要扩展INavigationService接口添加更多通用导航方法
    
    // 根据订单类型构建导航路径
    String path = '/orders';
    if (event.orderType != null && event.orderType!.isNotEmpty) {
      path += '?type=${event.orderType}';
    }
    
    _navigationService.goBack(); // 临时替代，实际应该跳转到订单列表
    emit(state.copyWithNavigation(path));
  }
  
  /// 处理导航到通知列表页面事件
  Future<void> _onNavigateToNotifications(
    NavigateToNotifications event,
    Emitter<SellerHomeState> emit,
  ) async {
    // 临时实现，实际应有相应的导航方法
    _navigationService.goBack();
    emit(state.copyWithNavigation('/seller/notifications'));
  }
  
  /// 处理导航到聊天列表页面事件
  Future<void> _onNavigateToChat(
    NavigateToChat event,
    Emitter<SellerHomeState> emit,
  ) async {
    _navigationService.navigateToChat(null); // 这里应传入合适的参数
    emit(state.copyWithNavigation('/chat'));
  }
  
  /// 处理导航到商品管理页面事件
  Future<void> _onNavigateToProducts(
    NavigateToProducts event,
    Emitter<SellerHomeState> emit,
  ) async {
    // 临时实现，实际应有相应的导航方法
    _navigationService.goBack();
    emit(state.copyWithNavigation('/seller/products'));
  }
  
  /// 处理导航到售后管理页面事件
  Future<void> _onNavigateToAfterSales(
    NavigateToAfterSales event,
    Emitter<SellerHomeState> emit,
  ) async {
    // 临时实现，实际应有相应的导航方法
    _navigationService.goBack();
    emit(state.copyWithNavigation('/seller/after-sales'));
  }
  
  /// 处理导航到店铺设置页面事件
  Future<void> _onNavigateToStoreSettings(
    NavigateToStoreSettings event,
    Emitter<SellerHomeState> emit,
  ) async {
    // 临时实现，实际应有相应的导航方法
    _navigationService.goBack();
    emit(state.copyWithNavigation('/seller/store-settings'));
  }
  
  /// 处理导航到认证管理页面事件
  Future<void> _onNavigateToAuthentication(
    NavigateToAuthentication event,
    Emitter<SellerHomeState> emit,
  ) async {
    // 临时实现，实际应有相应的导航方法
    _navigationService.goBack();
    emit(state.copyWithNavigation('/seller/authentication'));
  }
  
  /// 处理导航到时间管理页面事件
  Future<void> _onNavigateToTimeManagement(
    NavigateToTimeManagement event,
    Emitter<SellerHomeState> emit,
  ) async {
    // 临时实现，实际应有相应的导航方法
    _navigationService.goBack();
    emit(state.copyWithNavigation('/seller/time-management'));
  }
  
  /// 处理导航到自动回复设置页面事件
  Future<void> _onNavigateToAutoReply(
    NavigateToAutoReply event,
    Emitter<SellerHomeState> emit,
  ) async {
    // 临时实现，实际应有相应的导航方法
    _navigationService.goBack();
    emit(state.copyWithNavigation('/seller/auto-reply'));
  }
} 