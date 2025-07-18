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
import 'product_edit_page.dart';
import 'product_preview_page.dart';
import '../../../../core/navigation/navigation_helper.dart';

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
        listener: (context, state) async {
          // 检查是否是编辑页面的导航
          if (state.navigationPath!.contains('/edit') || state.navigationPath! == SellerRoutes.productCreate) {
            // 直接导航到ProductEditPage并传递回调
            String? productId;
            bool isPreviewMode = false;
            bool isCreateMode = state.navigationPath! == SellerRoutes.productCreate;
            
            if (state.navigationPath!.contains('/edit')) {
              // 先分离查询参数和路径
              final pathWithoutQuery = state.navigationPath!.split('?')[0];
              final queryString = state.navigationPath!.contains('?') 
                  ? state.navigationPath!.split('?')[1] 
                  : '';
              
              // 从路径 /seller/products/243/edit 中提取商品ID (243)
              final parts = pathWithoutQuery.split('/');
              final editIndex = parts.indexWhere((part) => part == 'edit');
              if (editIndex > 0) {
                productId = parts[editIndex - 1]; // 获取edit前面的部分
              }
              
              // 检查查询参数中是否包含preview=true
              if (queryString.contains('preview=true')) {
                isPreviewMode = true;
              }
            }
            
            print('=== DEBUG NAVIGATION ===');
            print('[ProductManagementPage] Full navigation path: ${state.navigationPath}');
            print('[ProductManagementPage] Path without query: ${state.navigationPath!.split('?')[0]}');
            print('[ProductManagementPage] Query string: ${state.navigationPath!.contains('?') ? state.navigationPath!.split('?')[1] : 'none'}');
            print('[ProductManagementPage] Path parts: ${state.navigationPath!.split('?')[0].split('/')}');
            print('[ProductManagementPage] Edit index found: ${state.navigationPath!.split('?')[0].split('/').indexWhere((part) => part == 'edit')}');
            print('[ProductManagementPage] Extracted productId: $productId, isPreviewMode: $isPreviewMode');
            print('[ProductManagementPage] About to create ${isPreviewMode ? 'ProductPreviewPage' : 'ProductEditPage'} with productId: $productId');
            print('======================');
            
            // 如果是预览模式，使用新的ProductPreviewPage
            if (isPreviewMode) {
              // 先导入必要的页面
              await NavigationHelper.pushDetailPage(
                context,
                ProductPreviewPage(productId: productId),
              );
            } else {
              final needRefresh = await NavigationHelper.pushDetailPage(
                context,
                ProductEditPage(
                  productId: productId,
                  isPreviewMode: false,
                  onDraftSaved: () {
                      print('[ProductManagementPage] onDraftSaved callback called');
                      print('[ProductManagementPage] Current tab index: ${_tabController.index}');
                      
                      // 强制刷新草稿列表，不管当前在哪个Tab
                      try {
                        context.read<ProductManagementBloc>().add(const LoadProductList(
                          status: ProductStatus.draft,
                          forceRefresh: true,
                        ));
                        print('[ProductManagementPage] LoadProductList event dispatched successfully');
                      } catch (e) {
                        print('[ProductManagementPage] Error dispatching LoadProductList: $e');
                      }
                    },
                  ),
              );
              
              // 如果返回值为true，说明需要刷新列表
              if (needRefresh == true) {
                print('[ProductManagementPage] Product ${isCreateMode ? "created" : "edited"} successfully, refreshing lists');
                
                // 如果是创建商品，切换到在售Tab并刷新
                if (isCreateMode) {
                  _tabController.animateTo(0); // 切换到在售Tab
                  context.read<ProductManagementBloc>().add(const LoadProductList(
                    status: ProductStatus.normal,
                    forceRefresh: true,
                  ));
                } else {
                  // 如果是编辑商品，刷新当前Tab
                  final currentStatus = _getStatusByTabIndex(_tabController.index);
                  context.read<ProductManagementBloc>().add(LoadProductList(
                    status: currentStatus,
                    forceRefresh: true,
                  ));
                }
              }
            }
          } else {
            // 其他导航使用原来的方式
            context.push(state.navigationPath!);
          }
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
  
  /// 根据Tab索引获取对应的商品状态
  ProductStatus _getStatusByTabIndex(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return ProductStatus.normal;
      case 1:
        return ProductStatus.draft;
      case 2:
        return ProductStatus.disabled;
      default:
        return ProductStatus.normal;
    }
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
            () => _confirmOffShelfProduct(product.id, product.name),
          ),
        );
        break;
        
      case ProductStatus.reviewing:
        // 审核中的商品不能进行状态操作，只显示状态标识
        actions.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.hourglass_empty, size: 16, color: Colors.orange[700]),
                const SizedBox(width: 4),
                Text(
                  '等待审核',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
        break;
        
      case ProductStatus.rejected:
        actions.add(
          _buildActionButton(
            context,
            '重新提交',
            Icons.refresh,
            isProcessing,
            () {
              // 重新提交审核（实际上是重新编辑后发布）
              context.read<ProductManagementBloc>().add(
                NavigateToProductEdit(productId: product.id),
              );
            },
          ),
        );
        break;
        
      case ProductStatus.draft:
        actions.add(
          _buildActionButton(
            context,
            '发布',
            Icons.publish,
            isProcessing,
            () => _updateProductStatus(product.id, ProductStatus.reviewing),
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
        
      default:
        break;
    }
    
    // 所有状态的商品都可以编辑（除了审核中的）
    if (product.status != ProductStatus.reviewing) {
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
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          // 只有非草稿状态的商品才能预览
          if (product.status != ProductStatus.draft) {
            context.read<ProductManagementBloc>().add(
              NavigateToProductDetail(productId: product.id),
            );
          } else {
            // 草稿状态显示提示信息
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('草稿状态的商品需要先发布才能预览'),
                duration: Duration(seconds: 2),
              ),
            );
          }
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
                    child: _buildProductImage(product),
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
                            const SizedBox(width: 8),
                            _buildStatusTag(product.status),
                          ],
                        ),
                        
                        const SizedBox(height: 4.0),
                        
                        Text(
                          '¥${_getBasicTierPrice(product).toStringAsFixed(2)}',
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
  
  /// 获取基础档价格
  double _getBasicTierPrice(SellerManagedProduct product) {
    // 如果没有variants，返回默认价格
    if (product.variants == null || product.variants!.isEmpty) {
      return product.price;
    }
    
    // 查找基础档价格
    final basicTierVariant = product.variants!.firstWhere(
      (variant) => variant.name == 'Basic Tier' || variant.optionValue == 'Basic Tier',
      orElse: () => product.variants!.first, // 如果没找到基础档，使用第一个
    );
    
    return basicTierVariant.sellingPrice > 0 ? basicTierVariant.sellingPrice : basicTierVariant.price;
  }

  void _updateProductStatus(int productId, ProductStatus targetStatus) {
    context.read<ProductManagementBloc>().add(UpdateProductStatus(
      productId: productId,
      targetStatus: targetStatus,
    ));
  }

  /// 确认下架商品
  void _confirmOffShelfProduct(int productId, String productName) {
    // 在显示对话框前先获取bloc引用，避免Provider作用域问题
    final bloc = context.read<ProductManagementBloc>();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('确认下架'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('确定要下架商品 "$productName" 吗？'),
            const SizedBox(height: 8),
            const Text(
              '下架后：',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const Text('• 买家将无法看到和购买此商品'),
            const Text('• 您可以随时重新上架'),
            const Text('• 商品数据会被保留'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // 使用之前获取的bloc引用，避免Provider作用域问题
              bloc.add(UpdateProductStatus(
                productId: productId,
                targetStatus: ProductStatus.disabled,
              ));
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange[700],
            ),
            child: const Text('确认下架'),
          ),
        ],
      ),
    );
  }
  
  void _deleteProduct(int productId) {
    // 在显示对话框前先获取bloc引用，避免Provider作用域问题
    final bloc = context.read<ProductManagementBloc>();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个商品吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // 使用之前获取的bloc引用，避免Provider作用域问题
              bloc.add(DeleteProduct(productId: productId));
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
        // 在售列表包含：已上架、审核中、审核失败的商品
        final List<SellerManagedProduct> result = [];
        if (state.onSaleProducts != null) {
          print('[_getProductListByStatus] onSaleProducts count: ${state.onSaleProducts!.length}');
          for (var product in state.onSaleProducts!) {
            print('[_getProductListByStatus] Product ${product.id}: status=${product.status}, statusValue=${product.status.value}');
          }
          result.addAll(state.onSaleProducts!.where((product) => 
            product.status == ProductStatus.normal ||
            product.status == ProductStatus.reviewing ||
            product.status == ProductStatus.rejected
          ));
          print('[_getProductListByStatus] Filtered result count: ${result.length}');
        } else {
          print('[_getProductListByStatus] onSaleProducts is null');
        }
        return result.isEmpty ? null : result;
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
      case ProductStatus.unknown:
        return Colors.amber; // 琥珀色表示未知状态
      case ProductStatus.reviewing:
        return Colors.blue;
      case ProductStatus.rejected:
      case ProductStatus.soldOut:
        return Colors.red;
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
      case ProductStatus.unknown:
        return StatusTagType.warning; // 未知状态用警告色
    }
  }

  /// 构建商品图片
  Widget _buildProductImage(SellerManagedProduct product) {
    // 调试日志
    print('[_buildProductImage] Product ${product.id} - images: "${product.images}"');
    print('[_buildProductImage] Product ${product.id} - status: ${product.status}');
    
    // 从逗号分隔的字符串中获取第一张图片
    String? firstImage;
    if (product.images.isNotEmpty) {
      final imageList = product.images.split(',');
      print('[_buildProductImage] Product ${product.id} - imageList: $imageList');
      if (imageList.isNotEmpty) {
        firstImage = imageList.first.trim();
        print('[_buildProductImage] Product ${product.id} - firstImage: "$firstImage"');
      }
    }
    
    if (firstImage != null && firstImage.isNotEmpty) {
      return Image.network(
        firstImage,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('[_buildProductImage] Image load error for ${product.id}: $error');
          return Container(
            width: 80,
            height: 80,
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported, color: Colors.grey),
          );
        },
      );
    }
    
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[300],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }

  /// 构建状态标签
  Widget _buildStatusTag(ProductStatus status) {
    Color bgColor;
    Color textColor;
    String text;
    
    switch (status) {
      case ProductStatus.reviewing:
        bgColor = Colors.orange[50]!;
        textColor = Colors.orange[700]!;
        text = '审核中';
        break;
      case ProductStatus.rejected:
        bgColor = Colors.red[50]!;
        textColor = Colors.red[700]!;
        text = '审核失败';
        break;
      case ProductStatus.normal:
        bgColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        text = '已上架';
        break;
      case ProductStatus.disabled:
        bgColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
        text = '已下架';
        break;
      case ProductStatus.draft:
        bgColor = Colors.blue[50]!;
        textColor = Colors.blue[700]!;
        text = '草稿';
        break;
      default:
        bgColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
        text = '未知';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
} 