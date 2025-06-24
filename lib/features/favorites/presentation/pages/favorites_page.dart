import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/common_user.dart';
import '../../domain/entities/favorite.dart';
import '../bloc/favorites_bloc.dart';
import '../bloc/favorites_event.dart';
import '../bloc/favorites_state.dart';
import '../widgets/empty_favorites.dart';
import '../widgets/favorite_seller_item.dart';
import '../widgets/favorite_service_item.dart';

/// 收藏页面
class FavoritesPage extends StatefulWidget {
  /// 构造函数
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _servicesScrollController = ScrollController();
  final ScrollController _sellersScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    // 添加滚动监听器，用于实现上拉加载更多
    _servicesScrollController.addListener(_onServicesScroll);
    _sellersScrollController.addListener(_onSellersScroll);
    
    // 初始加载服务列表
    context.read<FavoritesBloc>().add(const LoadFavoriteServicesEvent());
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _servicesScrollController.removeListener(_onServicesScroll);
    _servicesScrollController.dispose();
    _sellersScrollController.removeListener(_onSellersScroll);
    _sellersScrollController.dispose();
    super.dispose();
  }

  /// 处理标签页切换
  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      context.read<FavoritesBloc>().add(SwitchTabEvent(tabIndex: _tabController.index));
    }
  }

  /// 服务列表滚动监听
  void _onServicesScroll() {
    if (_isBottom(_servicesScrollController)) {
      final state = context.read<FavoritesBloc>().state;
      if (!state.isServicesLoading && !state.hasReachedServicesEnd) {
        context.read<FavoritesBloc>().add(
              LoadFavoriteServicesEvent(
                pageNum: state.servicesPageNum,
              ),
            );
      }
    }
  }

  /// 卖家列表滚动监听
  void _onSellersScroll() {
    if (_isBottom(_sellersScrollController)) {
      final state = context.read<FavoritesBloc>().state;
      if (!state.isSellersLoading && !state.hasReachedSellersEnd) {
        context.read<FavoritesBloc>().add(
              LoadFavoriteSellersEvent(
                pageNum: state.sellersPageNum,
              ),
            );
      }
    }
  }

  /// 判断是否滚动到底部
  bool _isBottom(ScrollController controller) {
    if (!controller.hasClients) return false;
    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.offset;
    // 当滚动到距离底部100像素时，触发加载更多
    return currentScroll >= (maxScroll - 100);
  }
  
  /// 安全返回处理
  void _handleBack() {
    // 使用Router获取重定向到个人中心页面
    try {
      context.pop();
    } catch (e) {
      // 如果无法返回，则跳转到首页或个人中心页
      context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBack,
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '服务'),
            Tab(text: '卖家'),
          ],
        ),
      ),
      body: BlocConsumer<FavoritesBloc, FavoritesState>(
        listener: (context, state) {
          // 显示错误信息
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                action: SnackBarAction(
                  label: '关闭',
                  onPressed: () {
                    context.read<FavoritesBloc>().add(ClearErrorEvent());
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              // 服务标签页
              _buildServicesTab(context, state),
              // 卖家标签页
              _buildSellersTab(context, state),
            ],
          );
        },
      ),
    );
  }

  /// 构建服务标签页
  Widget _buildServicesTab(BuildContext context, FavoritesState state) {
    if (state.isServicesLoading && state.services.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.services.isEmpty) {
      return EmptyFavorites(tabIndex: 0);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<FavoritesBloc>().add(const LoadFavoriteServicesEvent(refresh: true));
      },
      child: ListView.builder(
        controller: _servicesScrollController,
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: state.services.length + (state.isServicesLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.services.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final service = state.services[index];
          return FavoriteServiceItem(
            service: service,
            onTap: () {
              // 跳转到服务详情页
              // 这里需要通过导航服务实现
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(content: Text('查看服务详情: ${service.title}')),
              // );
            },
            onRemove: () {
              // 从收藏中移除
              if (service is Favorite) {
                context.read<FavoritesBloc>().add(
                      RemoveFromFavoritesEvent(
                        favoriteIds: [service.id],
                      ),
                    );
              } else {
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(content: Text('无法移除收藏，缺少收藏ID')),
                // );
              }
            },
          );
        },
      ),
    );
  }

  /// 构建卖家标签页
  Widget _buildSellersTab(BuildContext context, FavoritesState state) {
    if (state.isSellersLoading && state.sellers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.sellers.isEmpty) {
      return EmptyFavorites(tabIndex: 1);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<FavoritesBloc>().add(const LoadFavoriteSellersEvent(refresh: true));
      },
      child: ListView.builder(
        controller: _sellersScrollController,
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: state.sellers.length + (state.isSellersLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.sellers.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final seller = state.sellers[index];
          return FavoriteSellerItem(
            seller: seller,
            onTap: () {
              // 跳转到卖家详情页
              // 这里需要通过导航服务实现
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(content: Text('查看卖家详情: ${seller.nickName}')),
              // );
            },
            onUnfollow: () {
              // 取消关注卖家
              final user = CommonUser(
                referId: seller.referId,
                type: seller.type,
                nickName: seller.nickName,
                avatar: seller.avatar,
                trueName: seller.trueName,
                mobile: seller.mobile,
                gender: seller.gender,
                status: seller.status,
              );
              context.read<FavoritesBloc>().add(UnfollowSellerEvent(user: user));
            },
          );
        },
      ),
    );
  }
}