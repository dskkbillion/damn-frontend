import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../domain/entities/home_feed_item.dart';
import '../../domain/usecases/get_home_feed_usecase.dart';
import '../../domain/usecases/get_home_page_data_usecase.dart';
import '../navigation/home_navigation_service.dart';
import 'home_event.dart';
import 'home_state.dart';

/// Home 模块的 Bloc，负责处理事件和管理状态
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomePageDataUseCase getHomePageData;
  final GetHomeFeedUseCase getHomeFeed;
  final HomeNavigationService navigationService;

  /// 默认每页数量
  static const int defaultLimit = 10;
  int _currentPage = 1;

  HomeBloc({
    required this.getHomePageData,
    required this.getHomeFeed,
    required this.navigationService,
  }) : super(const HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
    on<LoadMoreHomeData>(_onLoadMoreHomeData);
    on<BannerClicked>(_onBannerClicked);
    on<CategoryClicked>(_onCategoryClicked);
    on<ProductCardClicked>(_onProductCardClicked);
    on<RecommendButtonClicked>(_onRecommendButtonClicked);
  }

  /// 处理加载首页数据事件
  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    
    final result = await getHomePageData(NoParams());
    
    result.fold(
      (failure) => emit(HomeError(message: _mapFailureToMessage(failure))),
      (homePageData) {
        _currentPage = 1;
        emit(HomeLoaded(
          banners: homePageData.banners,
          categories: homePageData.categories,
          feedItems: homePageData.feedItems,
          hasReachedMax: homePageData.feedItems.length < defaultLimit,
        ));
      },
    );
  }

  /// 处理刷新首页数据事件
  Future<void> _onRefreshHomeData(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is HomeLoaded) {
      emit(HomeRefreshing(
        banners: currentState.banners,
        categories: currentState.categories,
        feedItems: currentState.feedItems,
        hasReachedMax: currentState.hasReachedMax,
      ));
      
      final result = await getHomePageData(NoParams());
      
      result.fold(
        (failure) => emit(HomeError(message: _mapFailureToMessage(failure))),
        (homePageData) {
          _currentPage = 1;
          emit(HomeLoaded(
            banners: homePageData.banners,
            categories: homePageData.categories,
            feedItems: homePageData.feedItems,
            hasReachedMax: homePageData.feedItems.length < defaultLimit,
          ));
        },
      );
    } else {
      add(const LoadHomeData());
    }
  }

  Future<void> _onLoadMoreHomeData(
    LoadMoreHomeData event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! HomeLoaded ||
        currentState.hasReachedMax ||
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));
    final nextPage = _currentPage + 1;
    final result = await getHomeFeed(
      HomeFeedParams(page: nextPage, limit: defaultLimit),
    );

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMore: false)),
      (feedItems) {
        final existingIds = currentState.feedItems.map((item) => item.id).toSet();
        final appendedItems = feedItems.where((item) => !existingIds.contains(item.id)).toList();
        final hasReachedMax = feedItems.length < defaultLimit;
        _currentPage = nextPage;
        AppLogger.d(
          'HomeBloc loadMore: page=$nextPage, apiReturned=${feedItems.length}, '
          'afterDedup=${appendedItems.length}, hasReachedMax=$hasReachedMax',
        );
        emit(
          currentState.copyWith(
            feedItems: List<HomeFeedItem>.of(currentState.feedItems)..addAll(appendedItems),
            hasReachedMax: hasReachedMax,
            isLoadingMore: false,
          ),
        );
      },
    );
  }


  /// 处理点击轮播图事件
  void _onBannerClicked(
    BannerClicked event,
    Emitter<HomeState> emit,
  ) {
    // 根据轮播图的目标类型进行不同的导航
    switch (event.targetType) {
      case 'product':
        navigationService.navigateToProductDetail(event.targetValue);
        break;
      case 'category':
        navigationService.navigateToCategoryDetail(event.targetValue);
        break;
      case 'url':
        navigationService.navigateToUrl(event.targetValue);
        break;
      default:
        // 如果目标类型未知，不进行导航
        break;
    }
  }

  /// 处理点击分类事件
  void _onCategoryClicked(
    CategoryClicked event,
    Emitter<HomeState> emit,
  ) {
    // 导航到分类详情页
    navigationService.navigateToCategoryDetail(event.categoryId);
  }

  /// 处理点击商品/服务卡片事件
  void _onProductCardClicked(
    ProductCardClicked event,
    Emitter<HomeState> emit,
  ) {
    // 导航到产品详情页
    navigationService.navigateToProductDetail(event.productId);
  }

  /// 处理点击"让ta看看"按钮事件
  void _onRecommendButtonClicked(
    RecommendButtonClicked event,
    Emitter<HomeState> emit,
  ) {
    // 显示推荐确认对话框
    navigationService.showRecommendConfirmation(
      event.productId,
      event.productName,
    );
  }

  /// 将 Failure 映射为错误消息
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return (failure as ServerFailure).message ?? '服务器错误';
      case CacheFailure:
        return '缓存错误';
      default:
        return '未知错误';
    }
  }
}
