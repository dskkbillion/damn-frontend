import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart'; // 导入国际化资源
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

import '../../domain/entities/banner.dart' as home_banner;
import '../../domain/entities/home_feed_item.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/product_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:dskk_flutter_refactor/core/widgets/skeleton/skeleton_page.dart';
import 'package:dskk_flutter_refactor/core/widgets/skeleton/skeleton_card.dart';

/// 首页
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context);
    
    // 注意：在预览应用中，HomeBloc 已经在上层通过 BlocProvider 提供
    return HomeView(title: appLocalizations.home_title);
  }
}

/// 首页视图
class HomeView extends StatefulWidget {
  final String title;
  
  const HomeView({super.key, required this.title});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ScrollController _scrollController = ScrollController();
  DateTime? _lastLoadMoreTriggeredAt;

  @override
  void initState() {
    super.initState();
    // 加载首页数据
    context.read<HomeBloc>().add(const LoadHomeData());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 240) return;

    final homeState = context.read<HomeBloc>().state;
    if (homeState is! HomeLoaded ||
        homeState.hasReachedMax ||
        homeState.isLoadingMore) {
      return;
    }

    final now = DateTime.now();
    if (_lastLoadMoreTriggeredAt != null &&
        now.difference(_lastLoadMoreTriggeredAt!) <
            const Duration(milliseconds: 500)) {
      return;
    }

    _lastLoadMoreTriggeredAt = now;
    context.read<HomeBloc>().add(const LoadMoreHomeData());
  }

  @override
  Widget build(BuildContext context) {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchBar(context),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeInitial || state is HomeLoading) {
            return SkeletonPage(
              itemCount: 6,
              itemBuilder: (_, __) => const SkeletonCard(),
            );
          } else if (state is HomeLoaded || state is HomeRefreshing) {
            final banners = _getBanners(state);
            final feedItems = _getFeedItems(state);

            return RefreshIndicator(
              onRefresh: () {
                final completer = Completer<void>();
                final subscription = context.read<HomeBloc>().stream.listen((state) {
                  if (state is! HomeRefreshing && !completer.isCompleted) {
                    completer.complete();
                  }
                });
                context.read<HomeBloc>().add(const RefreshHomeData());
                return completer.future.whenComplete(() => subscription.cancel());
              },
              child: CustomScrollView(
                key: const PageStorageKey<String>('buyer_home_scroll'),
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // 轮播图
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: BannerCarousel(
                        banners: banners,
                        onBannerClicked: (banner) {
                          context.read<HomeBloc>().add(BannerClicked(
                                bannerId: banner.id,
                                targetType: banner.targetType,
                                targetValue: banner.targetValue,
                              ));
                          // 显示点击信息
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   SnackBar(
                          //     content: Text(appLocalizations.home_banner_clicked(banner.targetType, banner.targetValue)),
                          //     duration: const Duration(seconds: 1),
                          //   ),
                          // );
                        },
                      ),
                    ),
                  ),

                  // 信息流列表 - 使用SliverPadding和SliverMasonryGrid
                  if (feedItems.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Container(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.explore_outlined,
                                size: 64,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                appLocalizations.home_no_content,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                appLocalizations.home_pull_to_refresh,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16.0,
                        crossAxisSpacing: 10.0,
                        childCount: feedItems.length,
                        itemBuilder: (context, index) {
                          final item = feedItems[index];
                          // 根据索引生成不同的宽高比，使瀑布流更自然
                          final aspectRatio = 0.8 + (index % 3) * 0.2;
                          
                          return ProductCard(
                            item: item,
                            aspectRatio: aspectRatio,
                            onCardClicked: () {
                              context.read<HomeBloc>().add(ProductCardClicked(
                                    productId: item.id,
                                  ));
                              // 显示点击信息
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   SnackBar(
                              //     content: Text(appLocalizations.home_product_card_clicked(item.name)),
                              //     duration: const Duration(seconds: 1),
                              //   ),
                              // );
                            },
                            onRecommendClicked: () {
                              context.read<HomeBloc>().add(RecommendButtonClicked(
                                    productId: item.id,
                                    productName: item.name,
                                  ));
                              // 显示点击信息
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   SnackBar(
                              //     content: Text(appLocalizations.home_recommend_clicked(item.name)),
                              //     duration: const Duration(seconds: 1),
                              //   ),
                              // );
                            },
                            showRecommendButton: false,
                          );
                        },
                      ),
                    ),

                  // 底部刷新按钮
                  if (feedItems.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: (state is HomeRefreshing || (state is HomeLoaded && state.isRefreshing))
                              ? Column(
                                  children: [
                                    const CircularProgressIndicator(),
                                    const SizedBox(height: 12),
                                    Text(
                                      appLocalizations.home_refreshing_recommendations,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    if (state is HomeLoaded && state.isLoadingMore) ...[
                                      const CircularProgressIndicator(),
                                      const SizedBox(height: 12),
                                      Text(
                                        appLocalizations.home_loading_more,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          // 先滚动到顶部
                                          _scrollController.animateTo(
                                            0,
                                            duration: const Duration(milliseconds: 500),
                                            curve: Curves.easeInOut,
                                          ).then((_) {
                                            // 滚动完成后触发刷新
                                            if (mounted) {
                                              context.read<HomeBloc>().add(const RefreshHomeData());
                                            }
                                          });
                                        },
                                        icon: Icon(
                                          Icons.arrow_upward,
                                          color: Theme.of(context).primaryColor,
                                          size: 28,
                                        ),
                                        tooltip: appLocalizations.home_back_to_top_refresh,
                                        padding: const EdgeInsets.all(12),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      appLocalizations.home_back_to_top_refresh,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          } else if (state is HomeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    appLocalizations.home_loading_failed(state.message),
                    style: const TextStyle(color: AppColors.error),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HomeBloc>().add(const LoadHomeData());
                    },
                    child: Text(appLocalizations.home_retry),
                  ),
                ],
              ),
            );
          }

          // 默认返回空白页面
          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// 获取轮播图列表
  List<home_banner.Banner> _getBanners(HomeState state) {
    if (state is HomeLoaded) {
      return state.banners;
    } else if (state is HomeRefreshing) {
      return state.banners;
    }
    return [];
  }
  
  /// 构建搜索栏
  Widget _buildSearchBar(BuildContext context) {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context);
    
    return GestureDetector(
      onTap: () {
        // 跳转到搜索页面
        context.push('/home/search');
      },
      child: Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.borderPrimary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Row(
          children: [
            const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.search, color: AppColors.textTertiary),
          ),
          Expanded(
              child: Text(
                appLocalizations.home_search_hint,
                style: const TextStyle(color: AppColors.textTertiary),
              ),
            ),
          ],
          ),
      ),
    );
  }

  /// 获取信息流列表
  List<HomeFeedItem> _getFeedItems(HomeState state) {
    if (state is HomeLoaded) {
      return state.feedItems;
    } else if (state is HomeRefreshing) {
      return state.feedItems;
    }
    return [];
  }
}
