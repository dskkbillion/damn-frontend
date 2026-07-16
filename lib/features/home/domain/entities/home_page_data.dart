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

  /// 模型端生成的稳定瀑布流会话；为空时使用旧商品列表的 seed 分页降级。
  final String? feedId;

  const HomePageData({
    required this.banners,
    required this.categories,
    required this.feedItems,
    this.feedId,
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
  List<Object?> get props => [banners, categories, feedItems, feedId];
}
