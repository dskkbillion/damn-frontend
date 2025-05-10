import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/banner.dart' as home_banner;
import '../../domain/entities/home_category.dart';
import '../../domain/entities/home_feed_item.dart';
import '../../domain/usecases/get_home_feed_usecase.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/category_list.dart';
import '../widgets/home_feed_list.dart';

/// 首页
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 注意：在预览应用中，HomeBloc 已经在上层通过 BlocProvider 提供
    return const HomeView(title: '首页');
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
  @override
  void initState() {
    super.initState();
    // 加载首页数据
    context.read<HomeBloc>().add(const LoadHomeData());
  }

  @override
  Widget build(BuildContext context) {
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
          final currentPage = state is HomeLoaded ? state.currentPage : 1;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(const RefreshHomeData());
            },
            child: ListView(
              children: [
                // 轮播图
                Padding(
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('点击了轮播图: ${banner.targetType} - ${banner.targetValue}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),

                // 信息流标题 - 直接放在轮播图下方
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '推荐服务',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // 显示点击信息
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('点击了查看更多'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: const Text('查看更多'),
                      ),
                    ],
                  ),
                ),

                // 信息流列表
                SizedBox(
                  height: 600, // 固定高度，简化实现
                  child: HomeFeedList(
                    feedItems: feedItems,
                    isLoadingMore: isLoadingMore,
                    hasMore: hasMore,
                    onProductCardClicked: (item) {
                      context.read<HomeBloc>().add(ProductCardClicked(
                            productId: item.id,
                          ));
                      // 显示点击信息
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('点击了服务卡片: ${item.name}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    onRecommendClicked: (item) {
                      context.read<HomeBloc>().add(RecommendButtonClicked(
                            productId: item.id,
                            productName: item.name,
                          ));
                      // 显示点击信息
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('点击了"让ta看看"按钮: ${item.name}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    onLoadMore: () {
                      if (!isLoadingMore && hasMore) {
                        context.read<HomeBloc>().add(LoadMoreFeed(
                              page: currentPage + 1,
                              limit: HomeBloc.defaultLimit,
                            ));
                      }
                    },
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
                  '加载失败: ${state.message}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<HomeBloc>().add(const LoadHomeData());
                  },
                  child: const Text('重试'),
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
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.search, color: Colors.grey),
            ),
            Expanded(
              child: Text(
                '搜索服务',
                style: TextStyle(color: Colors.grey),
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