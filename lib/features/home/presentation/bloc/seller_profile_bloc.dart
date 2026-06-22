import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:dskk_flutter_refactor/features/home/domain/entities/seller_product.dart';
import 'package:dskk_flutter_refactor/features/home/domain/usecases/get_seller_products.dart';
import 'package:dskk_flutter_refactor/features/home/domain/usecases/follow_seller.dart';
import 'package:dskk_flutter_refactor/features/home/domain/usecases/unfollow_seller.dart';
import 'package:dskk_flutter_refactor/features/home/domain/usecases/get_seller_info.dart';

part 'seller_profile_event.dart';
part 'seller_profile_state.dart';

class SellerProfileBloc extends Bloc<SellerProfileEvent, SellerProfileState> {
  final GetSellerProducts getSellerProducts;
  final FollowSeller followSeller;
  final UnfollowSeller unfollowSeller;
  final GetSellerInfo getSellerInfo;

  SellerProfileBloc({
    required this.getSellerProducts,
    required this.followSeller,
    required this.unfollowSeller,
    required this.getSellerInfo,
  }) : super(SellerProfileInitial()) {
    on<LoadSellerProducts>(_onLoadSellerProducts);
    on<RefreshSellerOnlineStatus>(_onRefreshSellerOnlineStatus);
    on<FollowSellerEvent>(_onFollowSeller);
    on<UnfollowSellerEvent>(_onUnfollowSeller);
  }

  /// #383 静默轮询刷新卖家在线状态：只在已加载态下重拉 getSellerInfo，
  /// 用最新 onlineFlag 重建 seller，其余字段保留；不 emit Loading、不动 products。
  /// 轮询失败静默（仅记日志），不打扰用户。
  Future<void> _onRefreshSellerOnlineStatus(
    RefreshSellerOnlineStatus event,
    Emitter<SellerProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SellerProfileLoaded || currentState.seller == null) {
      return;
    }
    final sellerInfoResult = await getSellerInfo.execute(event.sellerId);
    sellerInfoResult.fold(
      (failure) {
        AppLogger.d('[SellerProfileBloc] #383 轮询在线状态失败(静默): ${failure.message}');
      },
      (latest) {
        if (latest == null || emit.isDone) return;
        final old = currentState.seller!;
        // 只让在线状态跟随后端最新值变化，其余展示字段保持当前已加载值，避免轮询造成无关闪烁。
        if (latest.onlineFlag == old.onlineFlag) return;
        AppLogger.d('[SellerProfileBloc] #383 在线状态变更: ${old.onlineFlag} -> ${latest.onlineFlag}');
        emit(SellerProfileLoaded(
          products: currentState.products,
          seller: SellerInfo(
            id: old.id,
            nickName: old.nickName,
            trueName: old.trueName,
            avatar: old.avatar,
            remarks: old.remarks,
            memberAttention: old.memberAttention,
            fansCount: old.fansCount,
            levelName: old.levelName,
            score: old.score,
            collectNum: old.collectNum,
            authenticated: old.authenticated,
            evaluates: old.evaluates,
            onlineFlag: latest.onlineFlag,
          ),
        ));
      },
    );
  }

  Future<void> _onLoadSellerProducts(
    LoadSellerProducts event,
    Emitter<SellerProfileState> emit,
  ) async {
    emit(SellerProfileLoading());
    
    final productsResult = await getSellerProducts.execute(event.sellerId);
    
    await productsResult.fold(
      (failure) async => emit(SellerProfileError(message: failure.message)),
      (products) async {
        // 🔥 优先使用getSellerInfo获取准确的卖家信息（包括真实的粉丝数）
        SellerInfo? seller;
        final sellerInfoResult = await getSellerInfo.execute(event.sellerId);
        sellerInfoResult.fold(
          (failure) {
            AppLogger.d('获取卖家信息失败: ${failure.message}');
            // 如果getSellerInfo失败，才回退到使用商品列表中的tenant信息
            seller = products.isNotEmpty && products.first.tenant != null
            ? products.first.tenant
            : null;
          },
          (sellerInfo) {
            // ✅ 使用从project/details API获取的准确信息（包含真实粉丝数）
            seller = sellerInfo;
          },
        );
        
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
      AppLogger.d('[SellerProfileBloc] 开始关注用户: ${event.sellerId}');
      
      // 先乐观更新UI（快速响应用户操作）
      final updatedSeller = currentState.seller != null
          ? SellerInfo(
              id: currentState.seller!.id,
              nickName: currentState.seller!.nickName,
              trueName: currentState.seller!.trueName,
              avatar: currentState.seller!.avatar,
              remarks: currentState.seller!.remarks,
              memberAttention: true, // 设置为已关注
              fansCount: currentState.seller!.fansCount + 1, // 粉丝数量+1
              // #365 保留新字段
              levelName: currentState.seller!.levelName,
              score: currentState.seller!.score,
              collectNum: currentState.seller!.collectNum,
              authenticated: currentState.seller!.authenticated,
              evaluates: currentState.seller!.evaluates,
              // #383 保留在线状态
              onlineFlag: currentState.seller!.onlineFlag,
            )
          : null;

      emit(SellerProfileLoaded(
        products: currentState.products,
        seller: updatedSeller,
      ));

      // 调用API执行实际关注操作
      AppLogger.d('[SellerProfileBloc] 调用关注API...');
      final result = await followSeller.execute(event.sellerId);
      
      result.fold(
        (failure) {
          AppLogger.d('[SellerProfileBloc] 关注API失败: ${failure.message}');
          // 操作失败，还原状态并显示错误
          if (!emit.isDone) {
            emit(SellerProfileLoaded(
              products: currentState.products,
              seller: currentState.seller,
            ));
            emit(SellerProfileFollowError(message: '关注失败: ${failure.message}'));
          }
        },
        (success) async {
          AppLogger.d('[SellerProfileBloc] 关注API成功');
          
          // 🔥 重新获取真实的卖家信息（包含准确的粉丝数）
          final sellerInfoResult = await getSellerInfo.execute(event.sellerId);
          sellerInfoResult.fold(
            (failure) {
              AppLogger.d('[SellerProfileBloc] 获取更新后的卖家信息失败: ${failure.message}');
              // 如果获取失败，保持乐观更新的状态
              if (!emit.isDone) {
                emit(SellerProfileLoaded(
                  products: currentState.products,
                  seller: updatedSeller,
                ));
              }
            },
            (realSellerInfo) {
              AppLogger.d('[SellerProfileBloc] 获取到真实的粉丝数: ${realSellerInfo?.fansCount}');
              // 使用真实的卖家信息更新状态
              if (!emit.isDone) {
                emit(SellerProfileLoaded(
                  products: currentState.products,
                  seller: realSellerInfo,
                ));
              }
            },
          );
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
      AppLogger.d('[SellerProfileBloc] 开始取消关注用户: ${event.sellerId}');
      
      // 先乐观更新UI（快速响应用户操作）
      final updatedSeller = currentState.seller != null
          ? SellerInfo(
              id: currentState.seller!.id,
              nickName: currentState.seller!.nickName,
              trueName: currentState.seller!.trueName,
              avatar: currentState.seller!.avatar,
              remarks: currentState.seller!.remarks,
              memberAttention: false, // 设置为未关注
              fansCount: currentState.seller!.fansCount - 1, // 粉丝数量-1
              // #365 保留新字段
              levelName: currentState.seller!.levelName,
              score: currentState.seller!.score,
              collectNum: currentState.seller!.collectNum,
              authenticated: currentState.seller!.authenticated,
              evaluates: currentState.seller!.evaluates,
              // #383 保留在线状态
              onlineFlag: currentState.seller!.onlineFlag,
            )
          : null;
      
      emit(SellerProfileLoaded(
        products: currentState.products,
        seller: updatedSeller,
      ));
      
      // 调用API执行实际取消关注操作
      AppLogger.d('[SellerProfileBloc] 调用取消关注API...');
      final result = await unfollowSeller.execute(event.sellerId);
      
      result.fold(
        (failure) {
          AppLogger.d('[SellerProfileBloc] 取消关注API失败: ${failure.message}');
          // 操作失败，还原状态并显示错误
          if (!emit.isDone) {
            emit(SellerProfileLoaded(
              products: currentState.products,
              seller: currentState.seller,
            ));
            emit(SellerProfileUnfollowError(message: '取消关注失败: ${failure.message}'));
          }
        },
        (success) async {
          AppLogger.d('[SellerProfileBloc] 取消关注API成功');
          
          // 🔥 重新获取真实的卖家信息（包含准确的粉丝数）
          final sellerInfoResult = await getSellerInfo.execute(event.sellerId);
          sellerInfoResult.fold(
            (failure) {
              AppLogger.d('[SellerProfileBloc] 获取更新后的卖家信息失败: ${failure.message}');
              // 如果获取失败，保持乐观更新的状态
              if (!emit.isDone) {
                emit(SellerProfileLoaded(
                  products: currentState.products,
                  seller: updatedSeller,
                ));
              }
            },
            (realSellerInfo) {
              AppLogger.d('[SellerProfileBloc] 获取到真实的粉丝数: ${realSellerInfo?.fansCount}');
              // 使用真实的卖家信息更新状态
              if (!emit.isDone) {
                emit(SellerProfileLoaded(
                  products: currentState.products,
                  seller: realSellerInfo,
                ));
              }
            },
          );
        },
      );
    }
  }
} 