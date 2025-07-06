import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/common_user.dart';
import '../../domain/entities/favorite_service.dart';
import '../../domain/entities/favorite_seller.dart';
import '../../domain/usecases/add_to_favorites_usecase.dart';
import '../../domain/usecases/check_is_favorite_usecase.dart';
import '../../domain/usecases/follow_seller_usecase.dart';
import '../../domain/usecases/get_favorite_services_usecase.dart';
import '../../domain/usecases/get_favorite_sellers_usecase.dart';
import '../../domain/usecases/remove_from_favorites_usecase.dart';
import '../../domain/usecases/remove_from_favorites_by_object_id_usecase.dart';
import '../../domain/usecases/unfollow_seller_usecase.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

/// 收藏Bloc
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoriteServicesUseCase getFavoriteServicesUseCase;
  final GetFavoriteSellersUseCase getFavoriteSellersUseCase;
  final AddToFavoritesUseCase addToFavoritesUseCase;
  final RemoveFromFavoritesUseCase removeFromFavoritesUseCase;
  final RemoveFromFavoritesByObjectIdUseCase removeFromFavoritesByObjectIdUseCase;
  final CheckIsFavoriteUseCase checkIsFavoriteUseCase;
  final FollowSellerUseCase followSellerUseCase;
  final UnfollowSellerUseCase unfollowSellerUseCase;

  /// 构造函数
  FavoritesBloc({
    required this.getFavoriteServicesUseCase,
    required this.getFavoriteSellersUseCase,
    required this.addToFavoritesUseCase,
    required this.removeFromFavoritesUseCase,
    required this.removeFromFavoritesByObjectIdUseCase,
    required this.checkIsFavoriteUseCase,
    required this.followSellerUseCase,
    required this.unfollowSellerUseCase,
  }) : super(FavoritesState.initial()) {
    on<LoadFavoriteServicesEvent>(_onLoadFavoriteServices);
    on<LoadFavoriteSellersEvent>(_onLoadFavoriteSellers);
    on<AddToFavoritesEvent>(_onAddToFavorites);
    on<RemoveFromFavoritesEvent>(_onRemoveFromFavorites);
    on<RemoveFromFavoritesByObjectIdEvent>(_onRemoveFromFavoritesByObjectId);
    on<CheckIsFavoriteEvent>(_onCheckIsFavorite);
    on<FollowSellerEvent>(_onFollowSeller);
    on<UnfollowSellerEvent>(_onUnfollowSeller);
    on<SwitchTabEvent>(_onSwitchTab);
    on<ClearErrorEvent>(_onClearError);
  }

  /// 处理加载收藏的服务列表事件
  Future<void> _onLoadFavoriteServices(
    LoadFavoriteServicesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    // 如果是刷新，则重置页码
    if (event.refresh) {
      emit(state.copyWith(
        isServicesLoading: true,
        servicesPageNum: 1,
        hasReachedServicesEnd: false,
        errorMessage: null,
      ));
    } else {
      // 如果已经到达末尾，则不再加载
      if (state.hasReachedServicesEnd) {
        return;
      }
      emit(state.copyWith(
        isServicesLoading: true,
        errorMessage: null,
      ));
    }

    final result = await getFavoriteServicesUseCase(
      GetFavoriteServicesParams(
        pageNum: event.refresh ? 1 : event.pageNum,
        pageSize: event.pageSize,
      ),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          isServicesLoading: false,
          errorMessage: '加载收藏服务失败',
        ));
      },
      (services) {
        final List<FavoriteService> newServices = event.refresh
            ? services
            : [...state.services, ...services];

        emit(state.copyWith(
          services: newServices,
          isServicesLoading: false,
          servicesPageNum: event.refresh ? 2 : state.servicesPageNum + 1,
          hasReachedServicesEnd: services.isEmpty,
        ));
      },
    );
  }

  /// 处理加载收藏的卖家列表事件
  Future<void> _onLoadFavoriteSellers(
    LoadFavoriteSellersEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    // 如果是刷新，则重置页码
    if (event.refresh) {
      emit(state.copyWith(
        isSellersLoading: true,
        sellersPageNum: 1,
        hasReachedSellersEnd: false,
        errorMessage: null,
      ));
    } else {
      // 如果已经到达末尾，则不再加载
      if (state.hasReachedSellersEnd) {
        return;
      }
      emit(state.copyWith(
        isSellersLoading: true,
        errorMessage: null,
      ));
    }

    final result = await getFavoriteSellersUseCase(
      GetFavoriteSellersParams(
        pageNum: event.refresh ? 1 : event.pageNum,
        pageSize: event.pageSize,
      ),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          isSellersLoading: false,
          errorMessage: '加载收藏卖家失败',
        ));
      },
      (sellers) {
        final List<FavoriteSeller> newSellers = event.refresh
            ? sellers
            : [...state.sellers, ...sellers];

        emit(state.copyWith(
          sellers: newSellers,
          isSellersLoading: false,
          sellersPageNum: event.refresh ? 2 : state.sellersPageNum + 1,
          hasReachedSellersEnd: sellers.isEmpty,
        ));
      },
    );
  }

  /// 处理添加收藏事件
  Future<void> _onAddToFavorites(
    AddToFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(errorMessage: null));

    final result = await addToFavoritesUseCase(
      AddToFavoritesParams(
        type: event.type,
        objectId: event.objectId,
        feature: event.feature,
      ),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          errorMessage: '添加收藏失败',
        ));
      },
      (_) {
        // 更新收藏状态映射
        final Map<int, bool> updatedMap = Map.from(state.favoriteStatusMap);
        updatedMap[event.objectId] = true;

        emit(state.copyWith(
          favoriteStatusMap: updatedMap,
        ));

        // 如果当前是服务标签页，且添加的是服务类型，则刷新服务列表
        if (state.currentTabIndex == 0 && event.type == 'org_product') {
          add(const LoadFavoriteServicesEvent(refresh: true));
        }
        // 如果当前是卖家标签页，且添加的是卖家类型，则刷新卖家列表
        else if (state.currentTabIndex == 1 && event.type == 'org') {
          add(const LoadFavoriteSellersEvent(refresh: true));
        }
      },
    );
  }

  /// 处理从收藏中移除事件
  Future<void> _onRemoveFromFavorites(
    RemoveFromFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(errorMessage: null));

    final result = await removeFromFavoritesUseCase(
      RemoveFromFavoritesParams(favoriteIds: event.favoriteIds),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          errorMessage: '移除收藏失败',
        ));
      },
      (_) {
        // 根据当前标签页刷新列表
        if (state.currentTabIndex == 0) {
          add(const LoadFavoriteServicesEvent(refresh: true));
        } else {
          add(const LoadFavoriteSellersEvent(refresh: true));
        }
      },
    );
  }

  /// 处理检查对象是否已收藏事件
  Future<void> _onCheckIsFavorite(
    CheckIsFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(errorMessage: null));

    final result = await checkIsFavoriteUseCase(
      CheckIsFavoriteParams(
        type: event.type,
        objectIds: event.objectIds,
      ),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          errorMessage: '检查收藏状态失败',
        ));
      },
      (statusMap) {
        // 更新收藏状态映射
        final Map<int, bool> updatedMap = Map.from(state.favoriteStatusMap);
        updatedMap.addAll(statusMap);

        emit(state.copyWith(
          favoriteStatusMap: updatedMap,
        ));
      },
    );
  }

  /// 处理关注卖家事件
  Future<void> _onFollowSeller(
    FollowSellerEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(errorMessage: null));

    final result = await followSellerUseCase(event.user);

    result.fold(
      (failure) {
        emit(state.copyWith(
          errorMessage: '关注卖家失败',
        ));
      },
      (_) {
        // 如果当前是卖家标签页，则刷新卖家列表
        if (state.currentTabIndex == 1) {
          add(const LoadFavoriteSellersEvent(refresh: true));
        }
      },
    );
  }

  /// 处理取消关注卖家事件
  Future<void> _onUnfollowSeller(
    UnfollowSellerEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(errorMessage: null));

    final result = await unfollowSellerUseCase(event.user);

    result.fold(
      (failure) {
        emit(state.copyWith(
          errorMessage: '取消关注卖家失败',
        ));
      },
      (_) {
        // 如果当前是卖家标签页，则刷新卖家列表
        if (state.currentTabIndex == 1) {
          add(const LoadFavoriteSellersEvent(refresh: true));
        }
      },
    );
  }

  /// 处理切换标签页事件
  void _onSwitchTab(
    SwitchTabEvent event,
    Emitter<FavoritesState> emit,
  ) {
    emit(state.copyWith(
      currentTabIndex: event.tabIndex,
      errorMessage: null,
    ));

    // 如果切换到服务标签页，且服务列表为空，则加载服务列表
    if (event.tabIndex == 0 && state.services.isEmpty) {
      add(const LoadFavoriteServicesEvent());
    }
    // 如果切换到卖家标签页，且卖家列表为空，则加载卖家列表
    else if (event.tabIndex == 1 && state.sellers.isEmpty) {
      add(const LoadFavoriteSellersEvent());
    }
  }

  /// 处理按商品ID从收藏中移除事件
  Future<void> _onRemoveFromFavoritesByObjectId(
    RemoveFromFavoritesByObjectIdEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(errorMessage: null));

    final result = await removeFromFavoritesByObjectIdUseCase(
      RemoveFromFavoritesByObjectIdParams(
        type: event.type,
        objectId: event.objectId,
      ),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          errorMessage: '移除收藏失败',
        ));
      },
      (_) {
        // 更新收藏状态映射
        final Map<int, bool> updatedMap = Map.from(state.favoriteStatusMap);
        updatedMap[event.objectId] = false;

        emit(state.copyWith(
          favoriteStatusMap: updatedMap,
        ));

        // 根据当前标签页刷新列表
        if (state.currentTabIndex == 0 && event.type == 'org_product') {
          add(const LoadFavoriteServicesEvent(refresh: true));
        } else if (state.currentTabIndex == 1 && (event.type == 'org' || event.type == 'attentionMember')) {
          // 🔥 处理收藏机构或关注成员的移除
          add(const LoadFavoriteSellersEvent(refresh: true));
        }
      },
    );
  }

  /// 处理清除错误事件
  void _onClearError(
    ClearErrorEvent event,
    Emitter<FavoritesState> emit,
  ) {
    emit(state.copyWith(errorMessage: null));
  }
}