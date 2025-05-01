import 'package:equatable/equatable.dart';

/// Home 模块的事件基类
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

/// 加载首页数据事件
class LoadHomeData extends HomeEvent {
  const LoadHomeData();
}

/// 刷新首页数据事件
class RefreshHomeData extends HomeEvent {
  const RefreshHomeData();
}

/// 加载更多信息流数据事件
class LoadMoreFeed extends HomeEvent {
  /// 页码，从1开始
  final int page;
  
  /// 每页数量
  final int limit;

  const LoadMoreFeed({
    required this.page,
    required this.limit,
  });

  @override
  List<Object> get props => [page, limit];
}

/// 点击轮播图事件
class BannerClicked extends HomeEvent {
  /// 轮播图ID
  final String bannerId;
  
  /// 目标类型
  final String targetType;
  
  /// 目标值
  final String targetValue;

  const BannerClicked({
    required this.bannerId,
    required this.targetType,
    required this.targetValue,
  });

  @override
  List<Object> get props => [bannerId, targetType, targetValue];
}

/// 点击分类事件
class CategoryClicked extends HomeEvent {
  /// 分类ID
  final String categoryId;
  
  /// 目标类型
  final String targetType;
  
  /// 目标值
  final String targetValue;

  const CategoryClicked({
    required this.categoryId,
    required this.targetType,
    required this.targetValue,
  });

  @override
  List<Object> get props => [categoryId, targetType, targetValue];
}

/// 点击商品/服务卡片事件
class ProductCardClicked extends HomeEvent {
  /// 商品/服务ID
  final String productId;

  const ProductCardClicked({
    required this.productId,
  });

  @override
  List<Object> get props => [productId];
}

/// 点击"让ta看看"按钮事件
class RecommendButtonClicked extends HomeEvent {
  /// 商品/服务ID
  final String productId;
  
  /// 商品/服务名称
  final String productName;

  const RecommendButtonClicked({
    required this.productId,
    required this.productName,
  });

  @override
  List<Object> get props => [productId, productName];
}