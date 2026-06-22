part of 'seller_profile_bloc.dart';

abstract class SellerProfileEvent extends Equatable {
  const SellerProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadSellerProducts extends SellerProfileEvent {
  final int sellerId;

  const LoadSellerProducts({required this.sellerId});

  @override
  List<Object> get props => [sellerId];
}

/// #383 静默刷新卖家在线状态：轮询触发，只重拉 onlineFlag，不 emit Loading、不动 products，避免轮询时页面闪烁。
class RefreshSellerOnlineStatus extends SellerProfileEvent {
  final int sellerId;

  const RefreshSellerOnlineStatus({required this.sellerId});

  @override
  List<Object> get props => [sellerId];
}

class FollowSellerEvent extends SellerProfileEvent {
  final int sellerId;

  const FollowSellerEvent({required this.sellerId});

  @override
  List<Object> get props => [sellerId];
}

class UnfollowSellerEvent extends SellerProfileEvent {
  final int sellerId;

  const UnfollowSellerEvent({required this.sellerId});

  @override
  List<Object> get props => [sellerId];
} 