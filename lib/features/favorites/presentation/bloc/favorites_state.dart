import 'package:equatable/equatable.dart';

import '../../domain/entities/favorite_service.dart';
import '../../domain/entities/favorite_seller.dart';

/// 收藏状态基类
class FavoritesState extends Equatable {
  /// 当前选中的标签页索引（0: 服务, 1: 卖家）
  final int currentTabIndex;
  
  /// 服务列表
  final List<FavoriteService> services;
  
  /// 卖家列表
  final List<FavoriteSeller> sellers;
  
  /// 服务列表是否正在加载
  final bool isServicesLoading;
  
  /// 卖家列表是否正在加载
  final bool isSellersLoading;
  
  /// 服务列表是否已加载全部
  final bool hasReachedServicesEnd;
  
  /// 卖家列表是否已加载全部
  final bool hasReachedSellersEnd;
  
  /// 服务列表当前页码
  final int servicesPageNum;
  
  /// 卖家列表当前页码
  final int sellersPageNum;
  
  /// 错误信息
  final String? errorMessage;
  
  /// 对象是否已收藏的映射（键为对象ID，值为是否已收藏）
  final Map<int, bool> favoriteStatusMap;

  /// 构造函数
  const FavoritesState({
    this.currentTabIndex = 0,
    this.services = const [],
    this.sellers = const [],
    this.isServicesLoading = false,
    this.isSellersLoading = false,
    this.hasReachedServicesEnd = false,
    this.hasReachedSellersEnd = false,
    this.servicesPageNum = 1,
    this.sellersPageNum = 1,
    this.errorMessage,
    this.favoriteStatusMap = const {},
  });

  /// 初始状态
  factory FavoritesState.initial() {
    return const FavoritesState();
  }

  /// 创建一个新的FavoritesState实例，并更新指定的字段
  FavoritesState copyWith({
    int? currentTabIndex,
    List<FavoriteService>? services,
    List<FavoriteSeller>? sellers,
    bool? isServicesLoading,
    bool? isSellersLoading,
    bool? hasReachedServicesEnd,
    bool? hasReachedSellersEnd,
    int? servicesPageNum,
    int? sellersPageNum,
    String? errorMessage,
    Map<int, bool>? favoriteStatusMap,
  }) {
    return FavoritesState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      services: services ?? this.services,
      sellers: sellers ?? this.sellers,
      isServicesLoading: isServicesLoading ?? this.isServicesLoading,
      isSellersLoading: isSellersLoading ?? this.isSellersLoading,
      hasReachedServicesEnd: hasReachedServicesEnd ?? this.hasReachedServicesEnd,
      hasReachedSellersEnd: hasReachedSellersEnd ?? this.hasReachedSellersEnd,
      servicesPageNum: servicesPageNum ?? this.servicesPageNum,
      sellersPageNum: sellersPageNum ?? this.sellersPageNum,
      errorMessage: errorMessage,
      favoriteStatusMap: favoriteStatusMap ?? this.favoriteStatusMap,
    );
  }

  @override
  List<Object?> get props => [
        currentTabIndex,
        services,
        sellers,
        isServicesLoading,
        isSellersLoading,
        hasReachedServicesEnd,
        hasReachedSellersEnd,
        servicesPageNum,
        sellersPageNum,
        errorMessage,
        favoriteStatusMap,
      ];
}