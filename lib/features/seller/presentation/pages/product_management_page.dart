import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/enums/product_status.dart';
import '../../domain/entities/seller_managed_product.dart';
import '../bloc/product_management/product_management_bloc.dart';
import '../bloc/product_management/product_management_event.dart';
import '../bloc/product_management/product_management_state.dart';
import '../routes/seller_routes.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_state.dart';
import '../widgets/product_card.dart';
import '../widgets/status_tag.dart';

/// 商品管理页面
class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({Key? key}) : super(key: key);

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _onSaleScrollController = ScrollController();
  final ScrollController _draftScrollController = ScrollController();
  final ScrollController _offShelfScrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    _onSaleScrollController.addListener(() => _onScrollEnd(_onSaleScrollController, 0));
    _draftScrollController.addListener(() => _onScrollEnd(_draftScrollController, 1));
    _offShelfScrollController.addListener(() => _onScrollEnd(_offShelfScrollController, 2));
    
    context.read<ProductManagementBloc>().add(const LoadProductList());
  }
  
  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      context.read<ProductManagementBloc>().add(ChangeProductTab(tabIndex: _tabController.index));
    }
  }
  
  void _onScrollEnd(ScrollController controller, int tabIndex) {
    if (controller.position.pixels >= controller.position.maxScrollExtent - 200) {
      final state = context.read<ProductManagementBloc>().state;
      
      if (state.tabIndex != tabIndex) {
        return;
      }
      
      bool hasMore = false;
      switch (tabIndex) {
        case 0:
          hasMore = state.hasMoreOnSaleProducts;
          break;
        case 1:
          hasMore = state.hasMoreDraftProducts;
          break;
        case 2:
          hasMore = state.hasMoreOffShelfProducts;
          break;
      }
      
      if (hasMore && !state.isLoading) {
        ProductStatus status;
        switch (tabIndex) {
          case 0:
            status = ProductStatus.normal;
            break;
          case 1:
            status = ProductStatus.draft;
            break;
          case 2:
            status = ProductStatus.disabled;
            break;
          default:
            status = ProductStatus.normal;
        }
        
        context.read<ProductManagementBloc>().add(LoadProductList(
          status: status,
          loadMore: true,
        ));
      }
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _onSaleScrollController.dispose();
    _draftScrollController.dispose();
    _offShelfScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Column(
        children: [
          // 顶部空间
          SizedBox(height: MediaQuery.of(context).padding.top + 8),
          // TabBar直接放在Column顶部
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '在售'),
              Tab(text: '草稿箱'),
              Tab(text: '已下架'),
            ],
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          // BlocListener内容包装在Expanded中确保填充剩余空间
          Expanded(
            child: BlocListener<ProductManagementBloc, ProductManagementState>(
              listenWhen: (previous, current) =>
                  previous.navigationPath != current.navigationPath &&
                  current.navigationPath != null,
              listener: (context, state) {
                // Use push for navigating to create/edit screens
                // This keeps the management page in the stack
                context.push(state.navigationPath!);
              },
              // Previous BlocListener for error messages
              // We need to nest listeners or combine logic if needed
              // For simplicity, let's nest them for now.
              child: BlocListener<ProductManagementBloc, ProductManagementState>(
                listenWhen: (previous, current) =>
                    previous.errorMessage != current.errorMessage && current.errorMessage != null,
                listener: (context, state) {
                  if (state.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage!),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProductList(
                      context,
                      0,
                      ProductStatus.normal,
                      _onSaleScrollController,
                    ),
                    
                    _buildProductList(
                      context,
                      1,
                      ProductStatus.draft,
                      _draftScrollController,
                    ),
                    
                    _buildProductList(
                      context,
                      2,
                      ProductStatus.disabled,
                      _offShelfScrollController,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<ProductManagementBloc>().add(const NavigateToProductCreate());
        },
        child: const Icon(Icons.add),
        tooltip: '创建商品',
      ),
    );
  }
  
  Widget _buildProductList(
    BuildContext context,
    int tabIndex,
    ProductStatus status,
    ScrollController scrollController,
  ) {
    return BlocBuilder<ProductManagementBloc, ProductManagementState>(
      buildWhen: (previous, current) {
        if (current.tabIndex != tabIndex) return false;
        
        return previous.isLoading != current.isLoading ||
          _getProductListByStatus(previous, status) != _getProductListByStatus(current, status) ||
          previous.processingProductIds != current.processingProductIds;
      },
      builder: (context, state) {
        final products = _getProductListByStatus(state, status);
        print('[ProductManagementPage] Builder executing for Tab: $tabIndex ($status)');
        print('[ProductManagementPage] State: isLoading=${state.isLoading}, hasError=${state.hasError}');
        print('[ProductManagementPage] Products from state (via _getProductListByStatus): ${products?.length ?? 'null'}');
        if (products != null && products.isNotEmpty) {
          print('[ProductManagementPage] First product in list: ID=${products.first.id}, Name=${products.first.name}');
        }
        
        if (state.isLoading && _getProductListByStatus(state, status) == null) {
          return const LoadingState();
        }
        
        if (products == null || products.isEmpty) {
          return EmptyState.noProducts(
            text: _getEmptyStateText(status),
            onAddPressed: () {
              context.read<ProductManagementBloc>().add(const NavigateToProductCreate());
            },
          );
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            context.read<ProductManagementBloc>().add(LoadProductList(
              status: status,
              forceRefresh: true,
            ));
            return Future.delayed(const Duration(milliseconds: 300));
          },
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(12.0),
            itemCount: products.length + 1,
            itemBuilder: (context, index) {
              if (index == products.length) {
                bool hasMore = false;
                switch (tabIndex) {
                  case 0:
                    hasMore = state.hasMoreOnSaleProducts;
                    break;
                  case 1:
                    hasMore = state.hasMoreDraftProducts;
                    break;
                  case 2:
                    hasMore = state.hasMoreOffShelfProducts;
                    break;
                }
                
                return _buildLoadMoreIndicator(hasMore, state.isLoading);
              }
              
              final product = products[index];
              return _buildProductItem(context, product, state);
            },
          ),
        );
      },
    );
  }
  
  Widget _buildProductItem(
    BuildContext context,
    SellerManagedProduct product,
    ProductManagementState state,
  ) {
    print('[ProductManagementPage] _buildProductItem: Product ID=${product.id}, Status=${product.status}, TabIndex=${state.tabIndex}');

    final isProcessing = state.processingProductIds.contains(product.id);
    
    List<Widget> actions = [];
    
    switch (product.status) {
      case ProductStatus.normal:
        actions.add(
          _buildActionButton(
            context,
            '下架',
            Icons.arrow_downward,
            isProcessing,
            () => _updateProductStatus(product.id, ProductStatus.disabled),
          ),
        );
        break;
      case ProductStatus.draft:
        actions.add(
          _buildActionButton(
            context,
            '上架',
            Icons.arrow_upward,
            isProcessing,
            () => _updateProductStatus(product.id, ProductStatus.normal),
          ),
        );
        actions.add(
          _buildActionButton(
            context,
            '删除',
            Icons.delete_outline,
            isProcessing,
            () => _deleteProduct(product.id),
          ),
        );
        break;
      case ProductStatus.disabled:
        actions.add(
          _buildActionButton(
            context,
            '上架',
            Icons.arrow_upward,
            isProcessing,
            () => _updateProductStatus(product.id, ProductStatus.normal),
          ),
        );
        break;
      default:
        break;
    }
    
    actions.add(
      _buildActionButton(
        context,
        '编辑',
        Icons.edit_outlined,
        isProcessing,
        () {
          context.read<ProductManagementBloc>().add(
            NavigateToProductEdit(productId: product.id),
          );
        },
      ),
    );
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          context.read<ProductManagementBloc>().add(
            NavigateToProductDetail(productId: product.id),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: product.images.isNotEmpty
                        ? Image.network(
                            product.images,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported, color: Colors.grey),
                            ),
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                  ),
                  
                  const SizedBox(width: 12.0),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // StatusTag( // 注释掉页面内直接构建的状态标签
                            //   text: product.status.displayName,
                            //   type: _getStatusType(product.status),
                            // ),
                          ],
                        ),
                        
                        const SizedBox(height: 4.0),
                        
                        Text(
                          '¥${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        
                        const SizedBox(height: 4.0),
                        
                        Row(
                          children: [
                            Text(
                              '库存: --',
                              style: TextStyle(
                                fontSize: 13.0,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Text(
                              '销量: ${product.sales ?? 0}',
                              style: TextStyle(
                                fontSize: 13.0,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              if (actions.isNotEmpty) ...[
                const Divider(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (int i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8.0),
                      actions[i],
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    bool isDisabled,
    VoidCallback onPressed,
  ) {
    return OutlinedButton.icon(
      onPressed: isDisabled ? null : onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        minimumSize: const Size(0, 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
    );
  }
  
  Widget _buildLoadMoreIndicator(bool hasMore, bool isLoading) {
    if (!hasMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Text('没有更多商品了', style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.0),
          ),
        ),
      );
    }
    
    return const SizedBox(height: 60);
  }
  
  void _updateProductStatus(int productId, ProductStatus targetStatus) {
    context.read<ProductManagementBloc>().add(UpdateProductStatus(
      productId: productId,
      targetStatus: targetStatus,
    ));
  }
  
  void _deleteProduct(int productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个商品吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ProductManagementBloc>().add(DeleteProduct(productId: productId));
            },
            child: const Text('删除'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
  
  List<SellerManagedProduct>? _getProductListByStatus(ProductManagementState state, ProductStatus status) {
    switch (status) {
      case ProductStatus.normal:
        return state.onSaleProducts;
      case ProductStatus.draft:
        return state.draftProducts;
      case ProductStatus.disabled:
        return state.offShelfProducts;
      default:
        return null;
    }
  }
  
  String _getEmptyStateText(ProductStatus status) {
    switch (status) {
      case ProductStatus.normal:
        return '暂无在售商品';
      case ProductStatus.draft:
        return '暂无草稿商品';
      case ProductStatus.disabled:
        return '暂无已下架商品';
      default:
        return '暂无商品数据';
    }
  }
  
  Color _getStatusColor(ProductStatus status) {
    switch (status) {
      case ProductStatus.normal:
        return Colors.green;
      case ProductStatus.draft:
        return Colors.orange;
      case ProductStatus.disabled:
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
  
  /// 根据商品状态获取标签类型
  StatusTagType _getStatusType(ProductStatus status) {
    switch (status) {
      case ProductStatus.normal:
        return StatusTagType.success;
      case ProductStatus.draft:
        return StatusTagType.info;
      case ProductStatus.disabled:
      case ProductStatus.rejected:
      case ProductStatus.soldOut:
        return StatusTagType.defaultTag;
      case ProductStatus.reviewing:
        return StatusTagType.warning;
      default:
        return StatusTagType.defaultTag;
    }
  }
} 