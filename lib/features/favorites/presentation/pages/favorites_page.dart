import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/common_user.dart';
import '../../domain/entities/favorite.dart';
import '../bloc/favorites_bloc.dart';
import '../bloc/favorites_event.dart';
import '../bloc/favorites_state.dart';
import '../widgets/empty_favorites.dart';
import '../widgets/favorite_seller_item.dart';
import '../widgets/favorite_service_item.dart';
import '../../../../app/navigation/app_router_config.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import '../../../../core/utils/haptic_utils.dart';

/// 收藏页面
class FavoritesPage extends ConsumerStatefulWidget {
  /// 构造函数
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> with SingleTickerProviderStateMixin {
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

  /// 底部导航栏点击处理
  void _onBottomNavTap(int index) {
    // 添加轻微震动反馈
    HapticUtils.lightTabFeedback();
    
    switch (index) {
      case 0: // AI助手
        context.go('/ai-docs');
        break;
      case 1: // 首页
        context.go('/home');
        break;
      case 2: // 消息
        context.go('/chat');
        break;
      case 3: // 个人中心
        context.go('/profile');
        break;
      case 4: // 开发选项
        context.go('/dev');
        break;
    }
  }

  /// 构建底部导航栏
  Widget _buildBottomNavigationBar() {
    // 读取是否显示开发tab的配置
    final showDevTab = ref.watch(showDevTabProvider);
    // 获取国际化资源
    final s = AppLocalizations.of(context)!;
    
    // 根据配置构建导航栏项目
    final List<BottomNavigationBarItem> items = [
      BottomNavigationBarItem(
        icon: SvgPicture.asset(
          'assets/icons/nav/dskk_logo.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
        ),
        activeIcon: SvgPicture.asset(
          'assets/icons/nav/dskk_logo.svg',
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(const Color(0xFFD0903D), BlendMode.srcIn),
        ),
        label: s.nav_ai_assistant,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.home_outlined),
        activeIcon: const Icon(Icons.home),
        label: s.nav_home,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.chat_bubble_outline),
        activeIcon: const Icon(Icons.chat_bubble),
        label: s.nav_messages,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person_outline),
        activeIcon: const Icon(Icons.person),
        label: s.nav_profile,
      ),
    ];
    
    // 仅在配置为显示开发tab时添加
    if (showDevTab) {
      items.add(BottomNavigationBarItem(
        icon: const Icon(Icons.developer_mode_outlined),
        activeIcon: const Icon(Icons.developer_mode),
        label: s.nav_dev,
      ));
    }

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFD0903D),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: items,
      currentIndex: 3, // 设置为个人中心tab，因为收藏功能属于个人中心
      onTap: _onBottomNavTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.favorites_title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBack,
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.favorites_tab_services),
            Tab(text: AppLocalizations.of(context)!.favorites_tab_sellers),
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
                  label: AppLocalizations.of(context)!.favorites_close,
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
      // 添加底部导航栏
      bottomNavigationBar: _buildBottomNavigationBar(),
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
        padding: const EdgeInsets.only(top: 8, bottom: 80), // 增加底部padding为底部导航栏留空间
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
              // 使用正确的事件类型，通过服务ID删除收藏
              context.read<FavoritesBloc>().add(
                RemoveFromFavoritesByObjectIdEvent(
                  type: 'org_product', // 服务类型
                  objectId: service.id, // 服务ID
                ),
              );
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
        padding: const EdgeInsets.only(top: 8, bottom: 80), // 增加底部padding为底部导航栏留空间
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
                type: 'MEMBER', // 🔥 修复：与Home模块保持一致，固定使用MEMBER类型
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