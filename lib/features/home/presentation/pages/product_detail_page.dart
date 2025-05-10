import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/product_detail.dart';
import '../cubit/product_detail_cubit.dart';
import '../widgets/product_images_carousel.dart';
// 导入收藏相关模块
import '../../../../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../../../../features/favorites/presentation/bloc/favorites_state.dart';
import '../../../../features/favorites/presentation/bloc/favorites_event.dart';

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
                      // 如果已收藏，则移除收藏
                      favoritesBloc.add(RemoveFromFavoritesEvent(favoriteIds: [productId]));
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
                    Text('加载失败: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProductDetailCubit>().getProductDetail(widget.productId);
                      },
                      child: const Text('重试'),
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
            return const Center(child: Text('请稍等...'));
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
          CircleAvatar(
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
          const SizedBox(width: 12),
          Expanded(
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
                        children: const [
                          Icon(Icons.check_circle, color: Colors.green, size: 14),
                          SizedBox(width: 2),
                          Text(
                            '多条数据json格式传',
                            style: TextStyle(
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
          // 咨询卖家按钮
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.chat_bubble_outline, size: 16),
                SizedBox(width: 4),
                Text('咨询卖家'),
              ],
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
            child: const Text(
              '已发布（审核通过）改名',
              style: TextStyle(
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
          
          // 描述区域
          GestureDetector(
            onTap: () {
              // 点击"更多"
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '更多',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[600],
                  ),
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
              const Text('交付次数', style: TextStyle(fontSize: 16)),
              Text('${variant.editNum}', style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('交付周期', style: TextStyle(fontSize: 16)),
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
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('立即购买功能待实现')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          '一键购买(1)',
          style: TextStyle(
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
      title: const Text(
        '常见问题',
        style: TextStyle(
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
    // 暂无案例展示数据，但添加UI占位
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '案例展示',
            style: TextStyle(
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
                '暂无案例展示',
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
                '评论(${product.evaluateNum})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // 跳转到评论详情页
                  final productId = int.tryParse(widget.productId) ?? 0;
                  if (productId > 0) {
                    GoRouter.of(context).push('/product/$productId/reviews');
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('查看全部', style: TextStyle(color: Colors.grey)),
                    Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 如果没有评价，显示"暂无评价"提示
          if (product.evaluateNum <= 0)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  '暂无评价',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
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
                        children: const [
                          Flexible(
                            child: Text(
                              '瑞123', 
                              style: TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '2025-03-12 11:20:05', 
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Text('基础', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('不错，很有耐心'),
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