import 'package:equatable/equatable.dart';

import 'banner.dart';
import 'home_category.dart';
import 'home_feed_item.dart';

/// 聚合首页所需的所有动态数据
class HomePageData extends Equatable {
  /// 轮播图列表
  final List<Banner> banners;
  
  /// 分类列表
  final List<HomeCategory> categories;
  
  /// 首屏信息流数据
  final List<HomeFeedItem> feedItems;

  const HomePageData({
    required this.banners,
    required this.categories,
    required this.feedItems,
  });

  /// 创建一个空的 HomePageData 对象，用于测试
  factory HomePageData.empty() {
    return const HomePageData(
      banners: [],
      categories: [],
      feedItems: [],
    );
  }

  @override
  List<Object?> get props => [banners, categories, feedItems];
}