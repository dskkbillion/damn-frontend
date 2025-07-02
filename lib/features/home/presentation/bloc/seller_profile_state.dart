part of 'seller_profile_bloc.dart';

abstract class SellerProfileState extends Equatable {
  const SellerProfileState();

  @override
  List<Object?> get props => [];
}

class SellerProfileInitial extends SellerProfileState {}

class SellerProfileLoading extends SellerProfileState {}

class SellerProfileLoaded extends SellerProfileState {
  final List<SellerProduct> products;
  final SellerInfo? seller;

  const SellerProfileLoaded({
    required this.products,
    this.seller,
  });

  @override
  List<Object?> get props => [products, seller];
}

class SellerProfileError extends SellerProfileState {
  final String message;

  const SellerProfileError({required this.message});

  @override
  List<Object> get props => [message];
}

class SellerProfileFollowSuccess extends SellerProfileState {
  final String message;

  const SellerProfileFollowSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class SellerProfileFollowError extends SellerProfileState {
  final String message;

  const SellerProfileFollowError({required this.message});

  @override
  List<Object> get props => [message];
}

class SellerProfileUnfollowSuccess extends SellerProfileState {
  final String message;

  const SellerProfileUnfollowSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class SellerProfileUnfollowError extends SellerProfileState {
  final String message;

  const SellerProfileUnfollowError({required this.message});

  @override
  List<Object> get props => [message];
} 