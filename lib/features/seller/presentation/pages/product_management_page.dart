import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/enums/product_status.dart';
import '../../domain/entities/seller_managed_product.dart';
import '../bloc/product_management/product_management_bloc.dart';
import '../bloc/product_management/product_management_event.dart';
import '../bloc/product_management/product_management_state.dart';
import '../routes/seller_routes.dart';
import '../widgets/empty_state.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/widgets/app_network_image.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/widgets/seller_page_skeleton.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';

/// 商品管理页面
class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final ScrollController _onSaleScrollController = ScrollController();
  final ScrollController _offShelfScrollController = ScrollController();

  // Track if we're currently changing tabs to prevent scroll events
  bool _isChangingTab = false;

  // Track last navigation time to prevent duplicate navigation
  DateTime? _lastNavigationTime;
  static const _navigationDebounceMs = 500; // 500ms防抖
  
  @override
  void initState() {
    super.initState();
    
    // 轻咨询模式：移除草稿tab，只有2个tab（在售和下架）
    _tabController = TabController(length: 2, vsync: this);
    // 原3个tab代码（包含草稿）
    // _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    _onSaleScrollController.addListener(() => _onScrollEnd(_onSaleScrollController, 0));
    // 轻咨询模式：草稿tab已移除，下架变成index 1
    _offShelfScrollController.addListener(() => _onScrollEnd(_offShelfScrollController, 1));
    // 原草稿tab监听器（已注释）
    // _draftScrollController.addListener(() => _onScrollEnd(_draftScrollController, 1));
    // 原下架tab监听器（index was 2）
    // _offShelfScrollController.addListener(() => _onScrollEnd(_offShelfScrollController, 2));
    
    // 添加生命周期观察者
    WidgetsBinding.instance.addObserver(this);
    
    context.read<ProductManagementBloc>().add(const LoadProductList());
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 当应用从后台回到前台时刷新数据
    if (state == AppLifecycleState.resumed) {
      AppLogger.d('[ProductManagementPage] App resumed, refreshing current tab');
      final currentStatus = _getStatusByTabIndex(_tabController.index);
      context.read<ProductManagementBloc>().add(LoadProductList(
        status: currentStatus,
        forceRefresh: true,
      ));
    }
  }
  
  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      // Set flag to prevent scroll events during tab change
      _isChangingTab = true;
      context.read<ProductManagementBloc>().add(ChangeProductTab(tabIndex: _tabController.index));
      // Reset flag after a short delay to allow the tab change to complete
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _isChangingTab = false;
        }
      });
    }
  }
  
  void _onScrollEnd(ScrollController controller, int tabIndex) {
    // Don't trigger scroll events if we're changing tabs
    if (_isChangingTab) {
      return;
    }
    
    // Only trigger if we're close to the bottom and have scrolled down
    if (controller.hasClients && 
        controller.position.pixels > 0 && // Make sure we've actually scrolled
        controller.position.pixels >= controller.position.maxScrollExtent - 200) {
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
          hasMore = state.hasMoreOffShelfProducts;
          break;
      }

      AppLogger.d('[ProductManagementPage] _onScrollEnd: tabIndex=$tabIndex, hasMore=$hasMore, isLoading=${state.isLoading}');
      
      if (hasMore && !state.isLoading) {
        ProductStatus status;
        switch (tabIndex) {
          case 0:
            status = ProductStatus.normal;
            break;
          case 1:
            status = ProductStatus.disabled;
            break;
          default:
            status = ProductStatus.normal;
        }
        
        AppLogger.d('[ProductManagementPage] Triggering load more for status: $status');
        context.read<ProductManagementBloc>().add(LoadProductList(
          status: status,
          loadMore: true,
        ));
      }
    }
  }
  
  @override
  void dispose() {
    // 移除生命周期观察者
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _onSaleScrollController.dispose();
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
          tabs: [
            Tab(text: AppLocalizations.of(context).product_management_tab_on_sale ?? 'On Sale'),
            // 轻咨询模式：移除草稿Tab
            // Tab(text: AppLocalizations.of(context)!?.product_management_tab_draft ?? 'Drafts'),
            Tab(text: AppLocalizations.of(context).product_management_tab_off_shelf ?? 'Off Shelf'),
          ],
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: AppColors.textTertiary,
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
            
            AppLogger.d('=== DEBUG NAVIGATION ===');
            AppLogger.d('[ProductManagementPage] Full navigation path: ${state.navigationPath}');
            AppLogger.d('[ProductManagementPage] Path without query: ${state.navigationPath!.split('?')[0]}');
            AppLogger.d('[ProductManagementPage] Query string: ${state.navigationPath!.contains('?') ? state.navigationPath!.split('?')[1] : 'none'}');
            AppLogger.d('[ProductManagementPage] Path parts: ${state.navigationPath!.split('?')[0].split('/')}');
            AppLogger.d('[ProductManagementPage] Edit index found: ${state.navigationPath!.split('?')[0].split('/').indexWhere((part) => part == 'edit')}');
            AppLogger.d('[ProductManagementPage] Extracted productId: $productId, isPreviewMode: $isPreviewMode');
            AppLogger.d('[ProductManagementPage] About to create ${isPreviewMode ? 'ProductPreviewPage' : 'ProductEditPage'} with productId: $productId');
            AppLogger.d('======================');
            
            // 如果是预览模式，使用新的ProductPreviewPage
            if (isPreviewMode) {
              // 先导入必要的页面
              // Navigate to product edit page in preview mode using GoRouter
              await context.push('/seller/products/$productId/edit?preview=true');
            } else {
              // Navigate to product edit page using GoRouter
              // 创建模式使用特殊路径
              final String routePath = isCreateMode 
                  ? '/seller/products/create' 
                  : '/seller/products/$productId/edit';
              AppLogger.d('[ProductManagementPage] Navigating to: $routePath');
              final needRefresh = await context.push<bool>(routePath);
              
              // 如果返回值为true，说明需要刷新列表
              if (needRefresh == true) {
                AppLogger.d('[ProductManagementPage] Product ${isCreateMode ? "created" : "edited"} successfully, refreshing lists');
                
                // 如果是创建商品，切换到在售Tab并刷新
                if (isCreateMode) {
                  _tabController.animateTo(0); // 切换到在售Tab
                  // 先刷新草稿列表（移除已发布的商品）
                  context.read<ProductManagementBloc>().add(const LoadProductList(
                    status: ProductStatus.draft,
                    forceRefresh: true,
                  ));
                  // 然后刷新在售列表（添加新发布的商品）
                  context.read<ProductManagementBloc>().add(const LoadProductList(
                    status: ProductStatus.normal,
                    forceRefresh: true,
                  ));
                } else {
                  // 如果是编辑商品（从草稿发布到在售）
                  // 刷新草稿列表（移除已发布的商品）
                  context.read<ProductManagementBloc>().add(const LoadProductList(
                    status: ProductStatus.draft,
                    forceRefresh: true,
                  ));
                  // 刷新在售列表（添加新发布的商品）
                  context.read<ProductManagementBloc>().add(const LoadProductList(
                    status: ProductStatus.normal,
                    forceRefresh: true,
                  ));
                  
                  // 如果当前在草稿Tab，切换到在售Tab查看发布的商品
                  if (_tabController.index == 1) {
                    _tabController.animateTo(0);
                  }
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
                  backgroundColor: AppColors.error,
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
              
              // 轻咨询模式：移除草稿商品列表
              // _buildProductList(
              //   context,
              //   1,
              //   ProductStatus.draft,
              //   _draftScrollController,
              // ),
              
              _buildProductList(
                context,
                1,  // index从2改为1
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
        tooltip: AppLocalizations.of(context).product_management_create_product ?? 'Create Product',
        child: const Icon(Icons.add),
      ),
    );
  }
  
  /// 根据Tab索引获取对应的商品状态
  ProductStatus _getStatusByTabIndex(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return ProductStatus.normal;
      case 1:
        // 轻咨询模式：index 1 现在是下架
        return ProductStatus.disabled;
      // 原草稿status（已移除）
      // case 1:
      //   return ProductStatus.draft;
      // case 2:
      //   return ProductStatus.disabled;
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
        AppLogger.d('[ProductManagementPage] Builder executing for Tab: $tabIndex ($status)');
        AppLogger.d('[ProductManagementPage] State: isLoading=${state.isLoading}, hasError=${state.hasError}');
        AppLogger.d('[ProductManagementPage] Products from state (via _getProductListByStatus): ${products?.length ?? 'null'}');
        if (products != null && products.isNotEmpty) {
          AppLogger.d('[ProductManagementPage] First product in list: ID=${products.first.id}, Name=${products.first.name}');
        }
        
        if (state.isLoading && _getProductListByStatus(state, status) == null) {
          return const SellerPageSkeleton(variant: SellerSkeletonVariant.list);
        }
        
        // Always wrap content in RefreshIndicator to enable pull-to-refresh
        return RefreshIndicator(
          onRefresh: () async {
            context.read<ProductManagementBloc>().add(LoadProductList(
              status: status,
              forceRefresh: true,
            ));
            return Future.delayed(const Duration(milliseconds: 300));
          },
          child: (products == null || products.isEmpty) 
            ? ListView(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(), // Ensure scrollability for empty state
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6, // Center the empty state vertically
                    child: EmptyState.noProducts(
                      text: _getEmptyStateText(status),
                      onAddPressed: () {
                        context.read<ProductManagementBloc>().add(const NavigateToProductCreate());
                      },
                    ),
                  ),
                ],
              )
            : ListView.builder(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(), // 确保列表始终可滚动
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
    AppLogger.d('[ProductManagementPage] _buildProductItem: Product ID=${product.id}, Status=${product.status}, TabIndex=${state.tabIndex}');

    final isProcessing = state.processingProductIds.contains(product.id);
    
    List<Widget> actions = [];
    
    switch (product.status) {
      case ProductStatus.normal:
        actions.add(
          _buildActionButton(
            context,
            AppLocalizations.of(context).product_management_action_off_shelf ?? 'Off Shelf',
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
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              border: Border.all(color: AppColors.warning.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hourglass_empty, size: 16, color: AppColors.warning),
                const SizedBox(width: AppDimensions.spacingXs),
                Text(
                  AppLocalizations.of(context).product_management_status_waiting_review ?? 'Waiting for Review',
                  style: const TextStyle(
                    color: AppColors.warning,
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
            AppLocalizations.of(context).product_management_action_resubmit ?? 'Resubmit',
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
            AppLocalizations.of(context).product_management_action_publish ?? 'Publish',
            Icons.publish,
            isProcessing,
            () {
              // 发布商品（提交审核）
              _updateProductStatus(product.id, ProductStatus.reviewing);
              // 发布后自动切换到在售Tab查看结果
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  _tabController.animateTo(0); // 切换到在售Tab
                }
              });
            },
          ),
        );
        actions.add(
          _buildActionButton(
            context,
            AppLocalizations.of(context).product_management_action_delete ?? 'Delete',
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
            AppLocalizations.of(context).product_management_action_on_shelf ?? 'On Shelf',
            Icons.arrow_upward,
            isProcessing,
            () => _updateProductStatus(product.id, ProductStatus.normal),
          ),
        );
        actions.add(
          _buildActionButton(
            context,
            AppLocalizations.of(context).product_management_action_delete ?? 'Delete',
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
    if (product.status != ProductStatus.reviewing && product.status != ProductStatus.disabled) {
      actions.add(
        _buildActionButton(
          context,
          AppLocalizations.of(context).product_management_action_edit ?? 'Edit',
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
    
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(12),
      tintOpacity: 0.62,
      child: InkWell(
        onTap: () {
          // 防抖检查：防止快速重复点击导致重复导航
          final now = DateTime.now();
          if (_lastNavigationTime != null &&
              now.difference(_lastNavigationTime!).inMilliseconds < _navigationDebounceMs) {
            AppLogger.d('[ProductManagementPage] 防止快速重复点击，忽略本次导航');
            return;
          }
          _lastNavigationTime = now;

          // 只有非草稿状态的商品才能预览
          if (product.status != ProductStatus.draft) {
            context.read<ProductManagementBloc>().add(
              NavigateToProductDetail(productId: product.id),
            );
          } else {
            // 草稿状态显示提示信息
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).product_management_draft_preview_hint ?? 'Draft products need to be published before preview'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    child: _buildProductImage(product),
                  ),

                  const SizedBox(width: AppDimensions.spacingMd),
                  
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
                            const SizedBox(width: AppDimensions.spacingSm),
                            _buildStatusTag(product.status),
                          ],
                        ),

                        const SizedBox(height: AppDimensions.spacingXs),

                        Text(
                          '${RegionConfig.currencySymbol}${_getBasicTierPrice(product).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spacingXs),

                        Row(
                          children: [
                            Text(
                              '${AppLocalizations.of(context).product_management_stock_label ?? 'Stock'}: --',
                              style: const TextStyle(
                                fontSize: 13.0,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.spacingMd),
                            Text(
                              '${AppLocalizations.of(context).product_management_sales_label ?? 'Sales'}: ${product.sales ?? 0}',
                              style: const TextStyle(
                                fontSize: 13.0,
                                color: AppColors.textSecondary,
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
                const Divider(height: 24.0, color: AppColors.borderPrimary),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (int i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppDimensions.spacingSm),
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
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator(bool hasMore, bool isLoading) {
    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingLg),
        child: Center(
          child: Text(AppLocalizations.of(context).product_management_no_more_products ?? 'No more products', style: const TextStyle(color: AppColors.textTertiary)),
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
        title: Text(AppLocalizations.of(context).product_management_confirm_off_shelf_title ?? 'Confirm Off Shelf'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).product_management_confirm_off_shelf_message(productName)
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).product_management_confirm_off_shelf_desc ?? 'After off shelf:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(AppLocalizations.of(context).product_management_confirm_off_shelf_point1 ?? '• Buyers will not be able to see or purchase this product'),
            Text(AppLocalizations.of(context).product_management_confirm_off_shelf_point2 ?? '• You can put it back on shelf at any time'),
            Text(AppLocalizations.of(context).product_management_confirm_off_shelf_point3 ?? '• Product data will be retained'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(context).product_management_cancel ?? 'Cancel'),
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
              foregroundColor: AppColors.warning,
            ),
            child: Text(AppLocalizations.of(context).product_management_confirm ?? 'Confirm Off Shelf'),
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
        title: Text(AppLocalizations.of(context).product_management_confirm_delete_title ?? 'Confirm Delete'),
        content: Text(AppLocalizations.of(context).product_management_confirm_delete_message ?? 'Are you sure you want to delete this product? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(context).product_management_cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // 使用之前获取的bloc引用，避免Provider作用域问题
              bloc.add(DeleteProduct(productId: productId));
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: Text(AppLocalizations.of(context).product_management_delete ?? 'Delete'),
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
          AppLogger.d('[_getProductListByStatus] onSaleProducts count: ${state.onSaleProducts!.length}');
          for (var product in state.onSaleProducts!) {
            AppLogger.d('[_getProductListByStatus] Product ${product.id}: status=${product.status}, statusValue=${product.status.value}');
          }
          result.addAll(state.onSaleProducts!.where((product) => 
            product.status == ProductStatus.normal ||
            product.status == ProductStatus.reviewing ||
            product.status == ProductStatus.rejected
          ));
          AppLogger.d('[_getProductListByStatus] Filtered result count: ${result.length}');
        } else {
          AppLogger.d('[_getProductListByStatus] onSaleProducts is null');
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
        return AppLocalizations.of(context).product_management_empty_on_sale ?? 'No products on sale';
      case ProductStatus.draft:
        return AppLocalizations.of(context).product_management_empty_draft ?? 'No draft products';
      case ProductStatus.disabled:
        return AppLocalizations.of(context).product_management_empty_off_shelf ?? 'No off-shelf products';
      default:
        return AppLocalizations.of(context).product_management_empty_default ?? 'No product data';
    }
  }
  

  /// 构建商品图片
  Widget _buildProductImage(SellerManagedProduct product) {
    // 调试日志
    AppLogger.d('[_buildProductImage] Product ${product.id} - images: "${product.images}"');
    AppLogger.d('[_buildProductImage] Product ${product.id} - status: ${product.status}');
    
    // 从逗号分隔的字符串中获取第一张图片
    String? firstImage;
    if (product.images.isNotEmpty) {
      final imageList = product.images.split(',');
      AppLogger.d('[_buildProductImage] Product ${product.id} - imageList: $imageList');
      if (imageList.isNotEmpty) {
        firstImage = imageList.first.trim();
        AppLogger.d('[_buildProductImage] Product ${product.id} - firstImage: "$firstImage"');
      }
    }
    
    if (firstImage != null && firstImage.isNotEmpty) {
      return AppNetworkImage(
        imageUrl: firstImage,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      );
    }

    return Container(
      width: 80,
      height: 80,
      color: AppColors.borderInput,
      child: const Icon(Icons.image, color: AppColors.textTertiary),
    );
  }

  /// 构建状态标签
  Widget _buildStatusTag(ProductStatus status) {
    Color bgColor;
    Color textColor;
    String text;
    
    switch (status) {
      case ProductStatus.reviewing:
        bgColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        text = AppLocalizations.of(context).product_management_status_reviewing ?? 'Under Review';
        break;
      case ProductStatus.rejected:
        bgColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        text = AppLocalizations.of(context).product_management_status_rejected ?? 'Review Failed';
        break;
      case ProductStatus.normal:
        bgColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        text = AppLocalizations.of(context).product_management_status_on_shelf ?? 'On Shelf';
        break;
      case ProductStatus.disabled:
        bgColor = AppColors.backgroundSecondary;
        textColor = AppColors.textSecondary;
        text = AppLocalizations.of(context).product_management_status_off_shelf ?? 'Off Shelf';
        break;
      case ProductStatus.draft:
        bgColor = AppColors.info.withOpacity(0.1);
        textColor = AppColors.info;
        text = AppLocalizations.of(context).product_management_status_draft ?? 'Draft';
        break;
      default:
        bgColor = AppColors.backgroundSecondary;
        textColor = AppColors.textSecondary;
        text = AppLocalizations.of(context).product_management_status_unknown ?? 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingSm, vertical: AppDimensions.spacingXs),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
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
