import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/generated/l10n.dart'; // 导入国际化资源

import '../../domain/entities/banner.dart' as home_banner;
import '../../domain/entities/home_category.dart';
import '../../domain/entities/home_feed_item.dart';
import '../../domain/usecases/get_home_feed_usecase.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/category_list.dart';
import '../widgets/product_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

/// 首页
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 获取国际化资源
    final s = S.of(context);
    
    // 注意：在预览应用中，HomeBloc 已经在上层通过 BlocProvider 提供
    return HomeView(title: s.home_title);
  }
}

/// 首页视图
class HomeView extends StatefulWidget {
  final String title;
  
  const HomeView({Key? key, required this.title}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    // 加载首页数据
    context.read<HomeBloc>().add(const LoadHomeData());
    
    // 添加滚动监听
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    final state = context.read<HomeBloc>().state;
    if (state is HomeLoaded || state is HomeLoadingMore) {
      if (_isBottom && !_isLoadingMore(state) && _hasMore(state)) {
        final currentPage = state is HomeLoaded ? state.currentPage : 1;
        context.read<HomeBloc>().add(LoadMoreFeed(
          page: currentPage + 1,
          limit: HomeBloc.defaultLimit,
        ));
      }
    }
  }
  
  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // 当滚动到距离底部 200 像素时触发加载更多
    return currentScroll >= (maxScroll - 200);
  }
  
  bool _isLoadingMore(HomeState state) {
    return state is HomeLoadingMore;
  }
  
  bool _hasMore(HomeState state) {
    return state is HomeLoaded ? state.hasMore : true;
  }

  @override
  Widget build(BuildContext context) {
    // 获取国际化资源
    final s = S.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchBar(context),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeInitial || state is HomeLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is HomeLoaded || state is HomeRefreshing || state is HomeLoadingMore) {
            final banners = _getBanners(state);
            final categories = _getCategories(state);
            final feedItems = _getFeedItems(state);
            final isLoadingMore = state is HomeLoadingMore;
            final hasMore = state is HomeLoaded ? state.hasMore : true;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(const RefreshHomeData());
              },
              child: CustomScrollView(
                controller: _scrollController,
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
                          //     content: Text(s.home_banner_clicked(banner.targetType, banner.targetValue)),
                          //     duration: const Duration(seconds: 1),
                          //   ),
                          // );
                        },
                      ),
                    ),
                  ),

                  // 信息流列表 - 使用SliverPadding和SliverMasonryGrid
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
                            //     content: Text(s.home_product_card_clicked(item.name)),
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
                            //     content: Text(s.home_recommend_clicked(item.name)),
                            //     duration: const Duration(seconds: 1),
                            //   ),
                            // );
                          },
                          showRecommendButton: false,
                        );
                      },
                    ),
                  ),
                  
                  // 加载更多指示器
                  if (isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  
                  // 到底了提示
                  if (!hasMore)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            s.home_end_of_list,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
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
                    s.home_loading_failed(state.message),
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HomeBloc>().add(const LoadHomeData());
                    },
                    child: Text(s.home_retry),
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
    } else if (state is HomeLoadingMore) {
      return state.banners;
    } else if (state is HomeLoadMoreError) {
      return state.banners;
    }
    return [];
  }
  
  /// 构建搜索栏
  Widget _buildSearchBar(BuildContext context) {
    // 获取国际化资源
    final s = S.of(context);
    
    return GestureDetector(
      onTap: () {
        // 跳转到搜索页面
        context.push('/home/search');
      },
      child: Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
          children: [
            const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.search, color: Colors.grey),
          ),
          Expanded(
              child: Text(
                s.home_search_hint,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
          ),
      ),
    );
  }

  /// 获取分类列表
  List<HomeCategory> _getCategories(HomeState state) {
    if (state is HomeLoaded) {
      return state.categories;
    } else if (state is HomeRefreshing) {
      return state.categories;
    } else if (state is HomeLoadingMore) {
      return state.categories;
    } else if (state is HomeLoadMoreError) {
      return state.categories;
    }
    return [];
  }

  /// 获取信息流列表
  List<HomeFeedItem> _getFeedItems(HomeState state) {
    if (state is HomeLoaded) {
      return state.feedItems;
    } else if (state is HomeRefreshing) {
      return state.feedItems;
    } else if (state is HomeLoadingMore) {
      return state.feedItems;
    } else if (state is HomeLoadMoreError) {
      return state.feedItems;
    }
    return [];
  }
}