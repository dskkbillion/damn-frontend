import 'package:equatable/equatable.dart';

import '../../domain/entities/banner.dart' as home_banner;
import '../../domain/entities/home_category.dart';
import '../../domain/entities/home_feed_item.dart';

/// Home 模块的状态基类
abstract class HomeState extends Equatable {
  const HomeState();
  
  @override
  List<Object> get props => [];
}

/// 初始状态
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// 加载中状态
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// 刷新中状态（已有数据，但正在刷新）
class HomeRefreshing extends HomeState {
  /// 轮播图列表
  final List<home_banner.Banner> banners;
  
  /// 分类列表
  final List<HomeCategory> categories;
  
  /// 信息流列表
  final List<HomeFeedItem> feedItems;
  final bool hasReachedMax;

  const HomeRefreshing({
    required this.banners,
    required this.categories,
    required this.feedItems,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [banners, categories, feedItems, hasReachedMax];
}


/// 加载成功状态
class HomeLoaded extends HomeState {
  /// 轮播图列表
  final List<home_banner.Banner> banners;

  /// 分类列表
  final List<HomeCategory> categories;

  /// 信息流列表
  final List<HomeFeedItem> feedItems;
  final bool hasReachedMax;
  final bool isLoadingMore;

  /// 是否正在后台刷新（已有缓存数据，远程请求进行中）
  final bool isRefreshing;

  /// #384 当前随机排序种子，loadMore 复用此 seed 保持分页稳定
  final int? seed;

  const HomeLoaded({
    required this.banners,
    required this.categories,
    required this.feedItems,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.seed,
  });

  @override
  List<Object> get props => [banners, categories, feedItems, hasReachedMax, isLoadingMore, isRefreshing, seed ?? -1];

  /// 创建一个新的 HomeLoaded 实例，并替换指定的属性
  HomeLoaded copyWith({
    List<home_banner.Banner>? banners,
    List<HomeCategory>? categories,
    List<HomeFeedItem>? feedItems,
    bool? hasReachedMax,
    bool? isLoadingMore,
    bool? isRefreshing,
    int? seed,
  }) {
    return HomeLoaded(
      banners: banners ?? this.banners,
      categories: categories ?? this.categories,
      feedItems: feedItems ?? this.feedItems,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      seed: seed ?? this.seed,
    );
  }
}

/// 加载失败状态
class HomeError extends HomeState {
  /// 错误消息
  final String message;

  const HomeError({required this.message});

  @override
  List<Object> get props => [message];
}
