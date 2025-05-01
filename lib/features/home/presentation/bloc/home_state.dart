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

  const HomeRefreshing({
    required this.banners,
    required this.categories,
    required this.feedItems,
  });

  @override
  List<Object> get props => [banners, categories, feedItems];
}

/// 加载更多中状态
class HomeLoadingMore extends HomeState {
  /// 轮播图列表
  final List<home_banner.Banner> banners;
  
  /// 分类列表
  final List<HomeCategory> categories;
  
  /// 信息流列表
  final List<HomeFeedItem> feedItems;
  
  /// 当前页码
  final int currentPage;

  const HomeLoadingMore({
    required this.banners,
    required this.categories,
    required this.feedItems,
    required this.currentPage,
  });

  @override
  List<Object> get props => [banners, categories, feedItems, currentPage];
}

/// 加载成功状态
class HomeLoaded extends HomeState {
  /// 轮播图列表
  final List<home_banner.Banner> banners;
  
  /// 分类列表
  final List<HomeCategory> categories;
  
  /// 信息流列表
  final List<HomeFeedItem> feedItems;
  
  /// 当前页码
  final int currentPage;
  
  /// 是否有更多数据
  final bool hasMore;

  const HomeLoaded({
    required this.banners,
    required this.categories,
    required this.feedItems,
    this.currentPage = 1,
    this.hasMore = true,
  });

  @override
  List<Object> get props => [banners, categories, feedItems, currentPage, hasMore];

  /// 创建一个新的 HomeLoaded 实例，并替换指定的属性
  HomeLoaded copyWith({
    List<home_banner.Banner>? banners,
    List<HomeCategory>? categories,
    List<HomeFeedItem>? feedItems,
    int? currentPage,
    bool? hasMore,
  }) {
    return HomeLoaded(
      banners: banners ?? this.banners,
      categories: categories ?? this.categories,
      feedItems: feedItems ?? this.feedItems,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
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

/// 加载更多失败状态
class HomeLoadMoreError extends HomeState {
  /// 轮播图列表
  final List<home_banner.Banner> banners;
  
  /// 分类列表
  final List<HomeCategory> categories;
  
  /// 信息流列表
  final List<HomeFeedItem> feedItems;
  
  /// 当前页码
  final int currentPage;
  
  /// 错误消息
  final String message;

  const HomeLoadMoreError({
    required this.banners,
    required this.categories,
    required this.feedItems,
    required this.currentPage,
    required this.message,
  });

  @override
  List<Object> get props => [banners, categories, feedItems, currentPage, message];
}