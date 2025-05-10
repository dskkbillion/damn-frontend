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