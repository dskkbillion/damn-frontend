import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// 导入国际化
import '../../../../generated/l10n.dart';

import 'package:dskk_flutter_refactor/features/home/domain/entities/seller_product.dart';
import 'package:dskk_flutter_refactor/features/home/presentation/bloc/seller_profile_bloc.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/repositories/i_chat_repository.dart';

class SellerPublicProfilePage extends StatefulWidget {
  final int sellerId;

  const SellerPublicProfilePage({
    Key? key,
    required this.sellerId,
  }) : super(key: key);

  @override
  State<SellerPublicProfilePage> createState() => _SellerPublicProfilePageState();
}

class _SellerPublicProfilePageState extends State<SellerPublicProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final IChatRepository _chatRepository = GetIt.I<IChatRepository>();
  bool _isCreatingChat = false;

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

  Future<void> _contactSeller(BuildContext context, int sellerId) async {
    if (_isCreatingChat) return;
    
    setState(() {
      _isCreatingChat = true;
    });
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      final result = await _chatRepository.createRoom(sellerId);
      
      Navigator.of(context, rootNavigator: true).pop();
      
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).seller_profile_chat_failed(failure.message))),
          );
        },
        (chatId) {
          GoRouter.of(context).push('/chat/$chatId');
        },
      );
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).seller_profile_error_occurred(e.toString()))),
      );
    } finally {
      setState(() {
        _isCreatingChat = false;
      });
    }
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
      ),
    );
  }

  Widget _buildSellerProfile(BuildContext context, SellerProfileLoaded state) {
    final seller = state.seller;
    
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200.0,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              seller?.nickName ?? S.of(context).seller_profile_default_title,
              style: const TextStyle(color: Colors.white),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.amber.shade700, Colors.amber.shade900],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
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
                
                // 操作按钮
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final bloc = context.read<SellerProfileBloc>();
                          // 根据当前关注状态切换
                          if (seller?.memberAttention == true) {
                            // 已关注，执行取消关注
                            bloc.add(UnfollowSellerEvent(sellerId: widget.sellerId));
                          } else {
                            // 未关注，执行关注
                            bloc.add(FollowSellerEvent(sellerId: widget.sellerId));
                          }
                        },
                        style: ElevatedButton.styleFrom(
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
                    const SizedBox(width: 12),
                    CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      child: IconButton(
                        icon: const Icon(Icons.chat_bubble_outline, color: Colors.black),
                        onPressed: () => _contactSeller(context, widget.sellerId),
                      ),
                    ),
                  ],
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
            // 修复：使用Home模块内的路由路径
            GoRouter.of(context).push('/home/product/${product.id}');
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