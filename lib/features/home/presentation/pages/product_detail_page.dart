import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/core/router/smart_router_utils.dart';

// 导入国际化
import '../../../../generated/l10n.dart';

import '../../domain/entities/product_detail.dart';
import '../cubit/product_detail_cubit.dart';
import '../widgets/product_images_carousel.dart';
// 导入收藏相关模块
import '../../../../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../../../../features/favorites/presentation/bloc/favorites_state.dart';
import '../../../../features/favorites/presentation/bloc/favorites_event.dart';
// 导入聊天模块
import '../../../../features/chat/domain/repositories/i_chat_repository.dart';

/// 商品详情页面
class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> with SingleTickerProviderStateMixin {
  int _selectedVariantIndex = 0;
  late TabController _tabController;
  // 获取聊天仓库
  late final IChatRepository _chatRepository = GetIt.I<IChatRepository>();
  // 加载状态
  bool _isCreatingChat = false;
  // 添加描述展开状态控制
  bool _isDescriptionExpanded = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedVariantIndex = _tabController.index;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 咨询卖家方法
  Future<void> _contactSeller(BuildContext context, int sellerId) async {
    if (_isCreatingChat) return; // 防止重复点击
    
    setState(() {
      _isCreatingChat = true;
    });
    
    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      // 获取当前商品ID
      final productId = int.tryParse(widget.productId);
      
      // 调用创建聊天API，包含商品ID
      final result = await _chatRepository.createRoom(
        sellerId,
        productId: productId, // 传入商品ID
      );
      
      // 关闭加载对话框
      Navigator.of(context, rootNavigator: true).pop();
      
      // 处理结果
      result.fold(
        (failure) {
          // 显示错误提示
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('创建聊天失败: ${failure.message}')),
          // );
        },
        (chatId) {
          // 导航到聊天页面
          GoRouter.of(context).push('/chat/$chatId');
        },
      );
    } catch (e) {
      // 关闭加载对话框
      Navigator.of(context, rootNavigator: true).pop();
      
      // 显示错误提示
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('发生错误: $e')),
      // );
    } finally {
      setState(() {
        _isCreatingChat = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
      create: (_) => GetIt.I<ProductDetailCubit>()..getProductDetail(widget.productId),
        ),
        BlocProvider(
          create: (_) => GetIt.I<FavoritesBloc>()
            ..add(CheckIsFavoriteEvent(
              type: 'org_product',
              objectIds: [int.tryParse(widget.productId) ?? 0],
            )),
        ),
      ],
      child: Scaffold(
        // 使用透明AppBar，只显示返回按钮和收藏按钮
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            BlocBuilder<FavoritesBloc, FavoritesState>(
              builder: (context, state) {
                final productId = int.tryParse(widget.productId) ?? 0;
                // 使用favoriteStatusMap来判断是否已收藏
                final isFavorite = state.favoriteStatusMap[productId] ?? false;
                
                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border, 
                    color: Colors.amber,
                  ),
              onPressed: () {
                    final favoritesBloc = context.read<FavoritesBloc>();
                    if (isFavorite) {
                      // 如果已收藏，则移除收藏（使用新的按商品ID移除事件）
                      favoritesBloc.add(RemoveFromFavoritesByObjectIdEvent(
                        type: 'org_product',
                        objectId: productId,
                      ));
                    } else {
                      // 如果未收藏，则添加收藏
                      favoritesBloc.add(AddToFavoritesEvent(
                        type: 'org_product',
                        objectId: productId,
                      ));
                    }
                  },
                );
              },
            ),
          ],
        ),
        extendBodyBehindAppBar: true, // 内容区域延伸到AppBar下方
        body: BlocBuilder<ProductDetailCubit, ProductDetailState>(
          builder: (context, state) {
            if (state is ProductDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProductDetailError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(S.of(context).product_detail_loading_failed(state.message)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProductDetailCubit>().getProductDetail(widget.productId);
                      },
                      child: Text(S.of(context).product_detail_retry),
                    ),
                  ],
                ),
              );
            } else if (state is ProductDetailLoaded) {
              final product = state.product;
              // 初始化TabController长度
              if (_tabController.length != (product.variants?.length ?? 0)) {
                _tabController = TabController(
                  length: product.variants?.length ?? 1, 
                  vsync: this,
                  initialIndex: _selectedVariantIndex < (product.variants?.length ?? 0) ? _selectedVariantIndex : 0,
                );
              }
              return _buildProductDetail(context, product);
            }
            return Center(child: Text(S.of(context).product_detail_please_wait));
          },
        ),
      ),
    );
  }

  Widget _buildProductDetail(BuildContext context, ProductDetail product) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 商品图片轮播
                _buildImageCarousel(product),
                
                // 卖家信息（移到顶部）
                _buildSellerInfo(product),
                
                // 商品基本信息
                _buildProductBasicInfo(product),
                
                // 套餐选择（改为Tab样式）
                if (product.variants != null && product.variants!.isNotEmpty)
                  _buildVariantTabs(product),
                
                // 选中套餐的交付信息
                if (product.variants != null && product.variants!.isNotEmpty)
                  _buildDeliveryInfo(product.variants![_selectedVariantIndex]),
                  
                // 购买按钮
                _buildBuyButton(product),
                
                // 常见问题（折叠面板）
                _buildFAQSection(product),
                
                // 案例展示
                _buildCaseShowcase(product),
                
                // 评价区域
                _buildReviewsSection(product),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageCarousel(ProductDetail product) {
    return ProductImagesCarousel(
      images: product.images,
      height: 300.0, // 调整高度
      onImageClicked: (index) {
        // 图片点击逻辑
      },
    );
  }

  Widget _buildSellerInfo(ProductDetail product) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // 头像，修复导航路径统一使用seller-profile
          GestureDetector(
            onTap: () {
              // 统一使用 seller-profile 路径，避免与Seller Shell路径冲突
              SmartRouterUtils.smartNavigate(
                context,
                '/seller-profile/${product.sellerId}',
                source: 'product_detail_avatar',
              );
            },
            child: CircleAvatar(
              radius: 20,
              backgroundImage: product.sellerAvatar != null
                  ? NetworkImage(product.sellerAvatar!)
                  : null,
              child: product.sellerAvatar == null
                  ? Text(product.sellerName.isNotEmpty
                      ? product.sellerName[0].toUpperCase()
                      : '?')
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // 卖家信息，保持相同的导航路径
          Expanded(
            child: GestureDetector(
              onTap: () {
                // 使用相同的路径，确保一致性
                SmartRouterUtils.smartNavigate(
                  context,
                  '/seller-profile/${product.sellerId}',
                  source: 'product_detail_seller_info',
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      Text(
                        product.sellerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      // 添加验证标签
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              S.of(context).product_detail_verified_label,
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(
                        ' ${product.score}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // 咨询卖家按钮，添加点击事件
          GestureDetector(
            onTap: () => _contactSeller(context, product.sellerId),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 16),
                  const SizedBox(width: 4),
                  Text(S.of(context).product_detail_contact_seller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductBasicInfo(ProductDetail product) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 状态标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              S.of(context).product_detail_published_status,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
          
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 描述区域 - 修复点击事件
          GestureDetector(
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  maxLines: _isDescriptionExpanded ? null : 2,
                  overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Spacer(),
                Text(
                      _isDescriptionExpanded 
                        ? S.of(context).product_detail_collapse 
                        : S.of(context).product_detail_more,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[600],
                    ),
                    ),
                    Icon(
                      _isDescriptionExpanded 
                        ? Icons.keyboard_arrow_up 
                        : Icons.keyboard_arrow_down,
                      color: Colors.blue[600],
                      size: 16,
                    ),
                  ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVariantTabs(ProductDetail product) {
    // 创建3个Tab：基础、标准、豪华
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey, width: 0.5),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: product.variants!.map((variant) => Tab(
              text: variant.name,
            )).toList(),
            labelColor: Colors.amber[800],
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.amber[800],
            indicatorWeight: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfo(ProductVariant variant) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(S.of(context).product_detail_delivery_times, style: const TextStyle(fontSize: 16)),
              Text('${variant.editNum}', style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
              Text(S.of(context).product_detail_delivery_period, style: const TextStyle(fontSize: 16)),
              Text('${variant.deliveryDay}', style: const TextStyle(fontSize: 16)),
            ],
            ),
        ],
      ),
    );
  }

  Widget _buildBuyButton(ProductDetail product) {
    final variant = product.variants != null && product.variants!.isNotEmpty
        ? product.variants![_selectedVariantIndex]
        : null;
    
    if (variant == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          // 导航到订单确认页面
          context.go(
            '/product-payment/${product.id}/confirm',
            extra: {
              'productId': product.id,
              'variantId': variant.id,
              'quantity': 1, // 默认购买数量为1
              'sellerId': product.sellerId,
              'productName': product.name,
              'price': variant.sellingPrice,
              'imageUrl': product.images?.isNotEmpty == true ? product.images!.first : null,
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          S.of(context).product_detail_buy_now,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFAQSection(ProductDetail product) {
    if (product.materials == null || product.materials!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return ExpansionTile(
      title: Text(
                      S.of(context).product_detail_faq,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
      trailing: const Icon(Icons.keyboard_arrow_down),
      children: product.materials!.map((material) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              material.question,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            if (material.answer != null && material.answer!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  material.answer!,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                          ],
                        ),
      )).toList(),
    );
  }

  Widget _buildCaseShowcase(ProductDetail product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).product_detail_case_showcase,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 12),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                S.of(context).product_detail_no_cases,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(ProductDetail product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).product_detail_reviews(product.evaluateNum),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // 跳转到评论详情页 - 使用智能导航
                  final productId = int.tryParse(widget.productId) ?? 0;
                  if (productId > 0) {
                    SmartRouterUtils.smartNavigate(
                      context,
                      '/product/:productId/reviews',
                      params: {'productId': productId.toString()},
                      source: 'product_detail_reviews_button',
                    );
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(S.of(context).product_detail_view_all, style: const TextStyle(color: Colors.grey)),
                    const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                  ],
          ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 如果没有评价，显示"暂无评价"提示
          if (product.evaluateNum <= 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  S.of(context).product_detail_no_reviews,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            )
          else
            // 有评价就显示示例评价
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage('https://via.placeholder.com/40'),
          ),
                const SizedBox(width: 12),
          Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              S.of(context).product_detail_sample_user, 
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '2025-03-12 11:20:05', 
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(S.of(context).product_detail_basic_package, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
              ),
                      const SizedBox(height: 4),
                      Text(S.of(context).product_detail_sample_review),
                    ],
            ),
                ),
              ],
          ),
        ],
      ),
    );
  }

  // 移除旧的方法，不再使用
  // Widget _buildVariantSelector(ProductDetail product) {...}
  // Widget _buildProductDetails(ProductDetail product) {...}
  // Widget _buildBottomBar(ProductDetail product) {...}
} 