import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dskk_flutter_refactor/features/home/domain/entities/seller_product.dart';
import 'package:dskk_flutter_refactor/features/home/domain/usecases/get_seller_products.dart';
import 'package:dskk_flutter_refactor/features/home/domain/usecases/follow_seller.dart';
import 'package:dskk_flutter_refactor/features/home/domain/usecases/unfollow_seller.dart';

part 'seller_profile_event.dart';
part 'seller_profile_state.dart';

class SellerProfileBloc extends Bloc<SellerProfileEvent, SellerProfileState> {
  final GetSellerProducts getSellerProducts;
  final FollowSeller followSeller;
  final UnfollowSeller unfollowSeller;

  SellerProfileBloc({
    required this.getSellerProducts,
    required this.followSeller,
    required this.unfollowSeller,
  }) : super(SellerProfileInitial()) {
    on<LoadSellerProducts>(_onLoadSellerProducts);
    on<FollowSellerEvent>(_onFollowSeller);
    on<UnfollowSellerEvent>(_onUnfollowSeller);
  }

  Future<void> _onLoadSellerProducts(
    LoadSellerProducts event,
    Emitter<SellerProfileState> emit,
  ) async {
    emit(SellerProfileLoading());
    
    final result = await getSellerProducts.execute(event.sellerId);
    
    result.fold(
      (failure) => emit(SellerProfileError(message: failure.message)),
      (products) {
        // 从第一个商品中提取卖家信息
        final seller = products.isNotEmpty && products.first.tenant != null
            ? products.first.tenant
            : null;
        emit(SellerProfileLoaded(products: products, seller: seller));
      },
    );
  }

  Future<void> _onFollowSeller(
    FollowSellerEvent event,
    Emitter<SellerProfileState> emit,
  ) async {
    // 保存当前状态，以便操作失败时还原
    final currentState = state;
    if (currentState is SellerProfileLoaded) {
      // 先乐观更新UI
      final updatedSeller = currentState.seller != null
          ? SellerInfo(
              id: currentState.seller!.id,
              nickName: currentState.seller!.nickName,
              trueName: currentState.seller!.trueName,
              avatar: currentState.seller!.avatar,
              remarks: currentState.seller!.remarks,
              memberAttention: true, // 设置为已关注
            )
          : null;
      
      emit(SellerProfileLoaded(
        products: currentState.products,
        seller: updatedSeller,
      ));
      
      // 调用API执行实际关注操作
      final result = await followSeller.execute(event.sellerId);
      
      result.fold(
        (failure) {
          // 操作失败，还原状态
          emit(currentState);
          // 显示错误消息
          emit(SellerProfileError(message: failure.message));
          emit(currentState);
        },
        (success) {
          // 操作成功，状态已更新，无需额外处理
        },
      );
    }
  }

  Future<void> _onUnfollowSeller(
    UnfollowSellerEvent event,
    Emitter<SellerProfileState> emit,
  ) async {
    // 保存当前状态，以便操作失败时还原
    final currentState = state;
    if (currentState is SellerProfileLoaded) {
      // 先乐观更新UI
      final updatedSeller = currentState.seller != null
          ? SellerInfo(
              id: currentState.seller!.id,
              nickName: currentState.seller!.nickName,
              trueName: currentState.seller!.trueName,
              avatar: currentState.seller!.avatar,
              remarks: currentState.seller!.remarks,
              memberAttention: false, // 设置为未关注
            )
          : null;
      
      emit(SellerProfileLoaded(
        products: currentState.products,
        seller: updatedSeller,
      ));
      
      // 调用API执行实际取消关注操作
      final result = await unfollowSeller.execute(event.sellerId);
      
      result.fold(
        (failure) {
          // 操作失败，还原状态
          emit(currentState);
          // 显示错误消息
          emit(SellerProfileError(message: failure.message));
          emit(currentState);
        },
        (success) {
          // 操作成功，状态已更新，无需额外处理
        },
      );
    }
  }
} 