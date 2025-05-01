import 'package:equatable/equatable.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_dashboard_data.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_store_profile.dart';

/// 卖家主页/仪表盘状态基类
class SellerHomeState extends Equatable {
  /// 是否正在加载
  final bool isLoading;
  
  /// 是否有错误
  final bool hasError;
  
  /// 错误信息
  final String? errorMessage;
  
  /// 仪表盘数据
  final SellerDashboardData? dashboardData;
  
  /// 店铺信息
  final SellerStoreProfile? storeProfile;
  
  /// 当前导航路径
  final String? currentNavPath;
  
  /// 构造函数
  const SellerHomeState({
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.dashboardData,
    this.storeProfile,
    this.currentNavPath,
  });
  
  @override
  List<Object?> get props => [
    isLoading,
    hasError,
    errorMessage,
    dashboardData,
    storeProfile,
    currentNavPath,
  ];
  
  /// 初始状态
  factory SellerHomeState.initial() {
    return const SellerHomeState(
      isLoading: false,
    );
  }
  
  /// 加载中状态
  SellerHomeState copyWithLoading() {
    return SellerHomeState(
      isLoading: true,
      hasError: false,
      errorMessage: null,
      dashboardData: dashboardData,
      storeProfile: storeProfile,
      currentNavPath: currentNavPath,
    );
  }
  
  /// 加载成功状态
  SellerHomeState copyWithLoaded({
    SellerDashboardData? dashboardData,
    SellerStoreProfile? storeProfile,
  }) {
    return SellerHomeState(
      isLoading: false,
      hasError: false,
      errorMessage: null,
      dashboardData: dashboardData ?? this.dashboardData,
      storeProfile: storeProfile ?? this.storeProfile,
      currentNavPath: currentNavPath,
    );
  }
  
  /// 加载失败状态
  SellerHomeState copyWithError(String errorMessage) {
    return SellerHomeState(
      isLoading: false,
      hasError: true,
      errorMessage: errorMessage,
      dashboardData: dashboardData,
      storeProfile: storeProfile,
      currentNavPath: currentNavPath,
    );
  }
  
  /// 导航状态
  SellerHomeState copyWithNavigation(String path) {
    return SellerHomeState(
      isLoading: isLoading,
      hasError: hasError,
      errorMessage: errorMessage,
      dashboardData: dashboardData,
      storeProfile: storeProfile,
      currentNavPath: path,
    );
  }
  
  /// 复制一个新状态
  SellerHomeState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    SellerDashboardData? dashboardData,
    SellerStoreProfile? storeProfile,
    String? currentNavPath,
  }) {
    return SellerHomeState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      dashboardData: dashboardData ?? this.dashboardData,
      storeProfile: storeProfile ?? this.storeProfile,
      currentNavPath: currentNavPath ?? this.currentNavPath,
    );
  }
}

/// 卖家主页加载中状态
class SellerHomeLoading extends SellerHomeState {
  /// 构造函数
  const SellerHomeLoading() : super(isLoading: true);
}

/// 卖家主页加载成功状态
class SellerHomeLoaded extends SellerHomeState {
  /// 构造函数
  const SellerHomeLoaded({
    SellerDashboardData? dashboardData,
    SellerStoreProfile? storeProfile,
    String? currentNavPath,
  }) : super(
    isLoading: false,
    dashboardData: dashboardData,
    storeProfile: storeProfile,
    currentNavPath: currentNavPath,
  );
}

/// 卖家主页加载失败状态
class SellerHomeError extends SellerHomeState {
  /// 错误
  final Failure failure;
  
  /// 构造函数
  SellerHomeError({
    required this.failure,
    String? currentNavPath,
  }) : super(
    isLoading: false,
    hasError: true,
    errorMessage: failure.message,
    currentNavPath: currentNavPath,
  );
  
  @override
  List<Object?> get props => [...super.props, failure];
} 