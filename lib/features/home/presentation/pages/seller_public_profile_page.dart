import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

// 导入国际化
import '../../../../generated/l10n.dart';
// 导入配置
import '../../../../app/navigation/app_router_config.dart';
// 导入震动工具类
import '../../../../core/utils/haptic_utils.dart';

import 'package:dskk_flutter_refactor/features/home/domain/entities/seller_product.dart';
import 'package:dskk_flutter_refactor/features/home/presentation/bloc/seller_profile_bloc.dart';

class SellerPublicProfilePage extends ConsumerStatefulWidget {
  final int sellerId;

  const SellerPublicProfilePage({
    Key? key,
    required this.sellerId,
  }) : super(key: key);

  @override
  ConsumerState<SellerPublicProfilePage> createState() => _SellerPublicProfilePageState();
}

class _SellerPublicProfilePageState extends ConsumerState<SellerPublicProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 底部导航栏点击处理
  void _onNavTap(int index) {
    HapticUtils.lightTabFeedback();
    
    switch (index) {
      case 0: // AI助手
        context.go('/ai_chat');
        break;
      case 1: // 主页
        context.go('/home');
        break;
      case 2: // 消息
        context.go('/chat');
        break;
      case 3: // 我的
        context.go('/profile');
        break;
      case 4: // 开发（如果启用）
        context.go('/dev_menu');
        break;
    }
  }

  // 构建底部导航栏
  Widget _buildBottomNavigationBar() {
    final showDevTab = ref.watch(showDevTabProvider);
    final s = S.of(context);
    
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
      currentIndex: 1, // 默认选中主页，因为卖家资料是从商品详情进入的
      onTap: _onNavTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<SellerProfileBloc>()
        ..add(LoadSellerProducts(sellerId: widget.sellerId)),
      child: Scaffold(
        body: MultiBlocListener(
          listeners: [
            // 监听关注/取消关注的状态变化
            BlocListener<SellerProfileBloc, SellerProfileState>(
              listener: (context, state) {
                if (state is SellerProfileError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state is SellerProfileFollowError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is SellerProfileUnfollowError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
          child: BlocBuilder<SellerProfileBloc, SellerProfileState>(
          builder: (context, state) {
            if (state is SellerProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SellerProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(S.of(context).product_detail_loading_failed(state.message)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<SellerProfileBloc>()
                          ..add(LoadSellerProducts(sellerId: widget.sellerId));
                      },
                      child: Text(S.of(context).product_detail_retry),
                    ),
                  ],
                ),
              );
            } else if (state is SellerProfileLoaded) {
              return _buildSellerProfile(context, state);
            }
            return Center(child: Text(S.of(context).product_detail_please_wait));
          },
          ),
        ),
        // 添加底部导航栏
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildSellerProfile(BuildContext context, SellerProfileLoaded state) {
    final seller = state.seller;
    
    return Column(
      children: [
        // 简洁的卖家头部信息
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.amber[700],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Row(
                  children: [
                    // 返回按钮
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        seller?.nickName ?? S.of(context).seller_profile_default_title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // 平衡返回按钮
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // 页面内容
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 卖家头像
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: seller?.avatar != null 
                          ? NetworkImage(seller!.avatar!) 
                          : null,
                      child: seller?.avatar == null 
                          ? const Icon(Icons.person, size: 40, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    
                    // 卖家信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            seller?.nickName ?? S.of(context).seller_profile_seller,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // 显示真实的粉丝数量
                          Text(
                            S.of(context).seller_profile_followers(seller?.fansCount ?? 0),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            seller?.remarks ?? S.of(context).seller_profile_no_description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 关注按钮
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: seller?.memberAttention == true
                        ? () => context.read<SellerProfileBloc>().add(UnfollowSellerEvent(sellerId: widget.sellerId))
                        : () => context.read<SellerProfileBloc>().add(FollowSellerEvent(sellerId: widget.sellerId)),
                    style: FilledButton.styleFrom(
                      backgroundColor: seller?.memberAttention == true 
                          ? Colors.grey[300] 
                          : Colors.amber[700],
                      foregroundColor: seller?.memberAttention == true 
                          ? Colors.black 
                          : Colors.white,
                    ),
                    child: Text(seller?.memberAttention == true ? S.of(context).seller_profile_followed : S.of(context).seller_profile_follow),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 标签页
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: S.of(context).seller_profile_about_merchant),
                    Tab(text: S.of(context).seller_profile_my_services),
                  ],
                  labelColor: Colors.amber[800],
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.amber[800],
                ),
                
                const SizedBox(height: 8),
                
                SizedBox(
                  height: 500, // 固定高度，可调整
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // 关于商家
                      _buildAboutSeller(seller),
                      
                      // 我的服务 (商品列表) - 使用网格布局
                      _buildProductsGrid(state.products),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSeller(SellerInfo? seller) {
    if (seller == null) {
      return Center(child: Text(S.of(context).seller_profile_no_merchant_info));
    }
    
    return ListView(
      children: [
        _buildInfoItem(S.of(context).seller_profile_member_level, S.of(context).seller_profile_level_two, Icons.grade),
        _buildInfoItem(S.of(context).seller_profile_seller_rating, '5.0', Icons.star),
        _buildInfoItem(S.of(context).seller_profile_response_time, S.of(context).seller_profile_response_hours, Icons.access_time),
        _buildInfoItem(S.of(context).seller_profile_certification_status, seller.trueName != null ? S.of(context).seller_profile_certified : S.of(context).seller_profile_not_certified, Icons.verified_user),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: Colors.amber[800]),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 新的商品网格布局，使用MasonryGridView
  Widget _buildProductsGrid(List<SellerProduct> products) {
    if (products.isEmpty) {
      return Center(child: Text(S.of(context).seller_profile_no_products));
    }
    
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 10,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        // 根据索引变化宽高比，使瀑布流更自然
        final aspectRatio = 0.8 + (index % 3) * 0.2;
        
        return GestureDetector(
          onTap: () {
            // 使用标准Go Router导航
            context.go('/home/product/${product.id}');
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 商品图片
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                  ),
                  child: AspectRatio(
                    aspectRatio: aspectRatio,
                    child: _buildProductImage(product),
                  ),
                ),
                
                // 商品信息
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 评分和评价数
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '5.0', // 固定评分
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(0)', // 固定评价数
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // 商品名称
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // 价格
                      Text(
                        '¥${product.sellingPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // 商品图片加载组件
  Widget _buildProductImage(SellerProduct product) {
    // 检查是否有图片URL
    if (product.images.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: product.images.first,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.grey[400],
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  S.of(context).seller_profile_image_load_failed,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // 如果没有图片URL，显示占位图
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag,
                color: Colors.grey[400],
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                product.name.isNotEmpty ? product.name.substring(0, product.name.length > 10 ? 10 : product.name.length) : S.of(context).seller_profile_no_image,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }
  }
} 