import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/core/navigation/services/i_navigation_service.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
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
  
  /// 导航服务
  final INavigationService _navigationService;
  
  /// 构造函数，注入依赖
  SellerHomeBloc(
    this._getDashboardDataUseCase,
    this._getStoreProfileUseCase,
    this._navigationService,
  ) : super(SellerHomeState.initial()) {
    print('[SellerHomeBloc] Created');
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
    print('[SellerHomeBloc] Received LoadDashboardData event');
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
    await _navigationService.navigateTo(path); 
    // emit(state.copyWithNavigation(path)); // 通常不需要 Bloc 记录导航路径
  }
  
  /// 处理导航到通知列表页面事件
  Future<void> _onNavigateToNotifications(
    NavigateToNotifications event,
    Emitter<SellerHomeState> emit,
  ) async {
    await _navigationService.navigateTo(SellerRoutes.notifications); // 使用 navigateTo
  }
  
  /// 处理导航到聊天列表页面事件
  Future<void> _onNavigateToChat(
    NavigateToChat event,
    Emitter<SellerHomeState> emit,
  ) async {
    await _navigationService.navigateToChat(null); // 使用 navigateToChat
  }
  
  /// 处理导航到商品管理页面事件
  Future<void> _onNavigateToProducts(
    NavigateToProducts event,
    Emitter<SellerHomeState> emit,
  ) async {
    await _navigationService.navigateTo(SellerRoutes.products); // 使用 navigateTo
  }
  
  /// 处理导航到售后管理页面事件
  Future<void> _onNavigateToAfterSales(
    NavigateToAfterSales event,
    Emitter<SellerHomeState> emit,
  ) async {
    await _navigationService.navigateTo(SellerRoutes.afterSalesReview); // 使用 navigateTo
  }
  
  /// 处理导航到店铺设置页面事件
  Future<void> _onNavigateToStoreSettings(
    NavigateToStoreSettings event,
    Emitter<SellerHomeState> emit,
  ) async {
    await _navigationService.navigateTo(SellerRoutes.storeSettings); // 使用 navigateTo
  }
  
  /// 处理导航到认证管理页面事件
  Future<void> _onNavigateToAuthentication(
    NavigateToAuthentication event,
    Emitter<SellerHomeState> emit,
  ) async {
    await _navigationService.navigateTo(SellerRoutes.authentication); // 使用 navigateTo
  }
  
  /// 处理导航到时间管理页面事件
  Future<void> _onNavigateToTimeManagement(
    NavigateToTimeManagement event,
    Emitter<SellerHomeState> emit,
  ) async {
    await _navigationService.navigateTo(SellerRoutes.timeManagement); // 使用 navigateTo
  }
  
  /// 处理导航到自动回复设置页面事件
  Future<void> _onNavigateToAutoReply(
    NavigateToAutoReply event,
    Emitter<SellerHomeState> emit,
  ) async {
    await _navigationService.navigateTo(SellerRoutes.autoReply); // 使用 navigateTo
  }
} 