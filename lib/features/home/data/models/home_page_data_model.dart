import '../../domain/entities/home_page_data.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'banner_model.dart';
import 'home_category_model.dart';
import 'home_feed_item_model.dart';

/// HomePageData 模型，用于序列化和反序列化 API 响应
class HomePageDataModel extends HomePageData {
  const HomePageDataModel({
    required List<BannerModel> banners,
    required List<HomeCategoryModel> categories,
    required List<HomeFeedItemModel> feedItems,
    String? feedId,
  }) : super(
          banners: banners,
          categories: categories,
          feedItems: feedItems,
          feedId: feedId,
        );

  /// 从 JSON 创建 HomePageDataModel 实例
  factory HomePageDataModel.fromJson(Map<String, dynamic> json) {
    AppLogger.d('Parsing HomePageDataModel from JSON: $json');
    
    // 处理 banners
    List<BannerModel> bannersList = [];
    if (json['banners'] != null && json['banners'] is List) {
      bannersList = (json['banners'] as List)
          .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['rows'] != null && json['rows'] is List) {
      // 处理API返回的rows字段
      bannersList = (json['rows'] as List)
          .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // 处理 categories
    List<HomeCategoryModel> categoriesList = [];
    if (json['categories'] != null && json['categories'] is List) {
      categoriesList = (json['categories'] as List)
          .map((e) => HomeCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // 处理 feedItems
    List<HomeFeedItemModel> feedItemsList = [];
    if (json['feedItems'] != null && json['feedItems'] is List) {
      feedItemsList = (json['feedItems'] as List)
          .map((e) => HomeFeedItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['products'] != null && json['products'] is List) {
      // 兼容 API 返回的 products 字段
      feedItemsList = (json['products'] as List)
          .map((e) => HomeFeedItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['rows'] != null && json['rows'] is List && bannersList.isEmpty) {
      // 如果rows字段没有被用于banners，则可能是feedItems
      feedItemsList = (json['rows'] as List)
          .map((e) => HomeFeedItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      // 处理嵌套在data字段中的数据
      final data = json['data'] as Map<String, dynamic>;
      if (data['products'] != null && data['products'] is List) {
        feedItemsList = (data['products'] as List)
            .map((e) => HomeFeedItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    return HomePageDataModel(
      banners: bannersList,
      categories: categoriesList,
      feedItems: feedItemsList,
      feedId: json['feedId'] as String?,
    );
  }

  /// 将 HomePageDataModel 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'banners': (banners as List<BannerModel>).map((e) => e.toJson()).toList(),
      'categories': (categories as List<HomeCategoryModel>).map((e) => e.toJson()).toList(),
      'feedItems': (feedItems as List<HomeFeedItemModel>).map((e) => e.toJson()).toList(),
      'feedId': feedId,
    };
  }

  /// 创建一个新的 HomePageDataModel 实例，并替换指定的属性
  HomePageDataModel copyWith({
    List<BannerModel>? banners,
    List<HomeCategoryModel>? categories,
    List<HomeFeedItemModel>? feedItems,
    String? feedId,
  }) {
    return HomePageDataModel(
      banners: banners ?? (this.banners as List<BannerModel>),
      categories: categories ?? (this.categories as List<HomeCategoryModel>),
      feedItems: feedItems ?? (this.feedItems as List<HomeFeedItemModel>),
      feedId: feedId ?? this.feedId,
    );
  }
}
