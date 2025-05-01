import 'package:equatable/equatable.dart';

import '../../domain/entities/common_user.dart';

/// 收藏事件基类
abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

/// 加载收藏的服务列表事件
class LoadFavoriteServicesEvent extends FavoritesEvent {
  final int pageNum;
  final int pageSize;
  final bool refresh;

  const LoadFavoriteServicesEvent({
    this.pageNum = 1,
    this.pageSize = 10,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [pageNum, pageSize, refresh];
}

/// 加载收藏的卖家列表事件
class LoadFavoriteSellersEvent extends FavoritesEvent {
  final int pageNum;
  final int pageSize;
  final bool refresh;

  const LoadFavoriteSellersEvent({
    this.pageNum = 1,
    this.pageSize = 10,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [pageNum, pageSize, refresh];
}

/// 添加收藏事件
class AddToFavoritesEvent extends FavoritesEvent {
  final String type;
  final int objectId;
  final Map<String, dynamic>? feature;

  const AddToFavoritesEvent({
    required this.type,
    required this.objectId,
    this.feature,
  });

  @override
  List<Object?> get props => [type, objectId, feature];
}

/// 从收藏中移除事件
class RemoveFromFavoritesEvent extends FavoritesEvent {
  final List<int> favoriteIds;

  const RemoveFromFavoritesEvent({
    required this.favoriteIds,
  });

  @override
  List<Object?> get props => [favoriteIds];
}

/// 检查对象是否已收藏事件
class CheckIsFavoriteEvent extends FavoritesEvent {
  final String type;
  final List<int> objectIds;

  const CheckIsFavoriteEvent({
    required this.type,
    required this.objectIds,
  });

  @override
  List<Object?> get props => [type, objectIds];
}

/// 关注卖家事件
class FollowSellerEvent extends FavoritesEvent {
  final CommonUser user;

  const FollowSellerEvent({
    required this.user,
  });

  @override
  List<Object?> get props => [user];
}

/// 取消关注卖家事件
class UnfollowSellerEvent extends FavoritesEvent {
  final CommonUser user;

  const UnfollowSellerEvent({
    required this.user,
  });

  @override
  List<Object?> get props => [user];
}

/// 切换标签页事件
class SwitchTabEvent extends FavoritesEvent {
  final int tabIndex;

  const SwitchTabEvent({
    required this.tabIndex,
  });

  @override
  List<Object?> get props => [tabIndex];
}

/// 清除错误事件
class ClearErrorEvent extends FavoritesEvent {}