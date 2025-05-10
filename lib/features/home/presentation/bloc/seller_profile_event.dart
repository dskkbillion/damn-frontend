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