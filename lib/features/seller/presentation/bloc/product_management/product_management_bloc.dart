import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/enums/product_status.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/delete_product_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_draft_list_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_product_list_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/update_product_status_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_management/product_management_event.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_management/product_management_state.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/routes/seller_routes.dart';
import 'package:injectable/injectable.dart';

/// 每页加载商品数量
const int _pageSize = 10;

/// 商品管理 BLoC
@injectable
class ProductManagementBloc extends Bloc<ProductManagementEvent, ProductManagementState> {
  /// 商品列表 UseCase
  final GetSellerProductListUseCase _getSellerProductListUseCase;
  
  /// 草稿列表 UseCase
  final GetSellerDraftListUseCase _getSellerDraftListUseCase;
  
  /// 更新商品状态 UseCase
  final UpdateProductStatusUseCase _updateProductStatusUseCase;
  
  /// 删除商品 UseCase
  final DeleteProductUseCase _deleteProductUseCase;
  
  /// 当前在售商品页码
  int _onSaleCurrentPage = 1;
  
  /// 当前草稿商品页码
  int _draftCurrentPage = 1;
  
  /// 当前已下架商品页码
  int _offShelfCurrentPage = 1;
  
  /// 构造函数
  ProductManagementBloc(
    this._getSellerProductListUseCase,
    this._getSellerDraftListUseCase,
    this._updateProductStatusUseCase,
    this._deleteProductUseCase,
  ) : super(ProductManagementState.initial()) {
    on<LoadProductList>(_onLoadProductList);
    on<ChangeProductTab>(_onChangeProductTab);
    on<UpdateProductStatus>(_onUpdateProductStatus);
    on<DeleteProduct>(_onDeleteProduct);
    on<NavigateToProductCreate>(_onNavigateToProductCreate);
    on<NavigateToProductEdit>(_onNavigateToProductEdit);
    on<NavigateToProductDetail>(_onNavigateToProductDetail);
  }
  
  /// 加载商品列表
  Future<void> _onLoadProductList(
    LoadProductList event,
    Emitter<ProductManagementState> emit,
  ) async {
    print('[ProductManagementBloc] _onLoadProductList called, event.status: ${event.status}, forceRefresh: ${event.forceRefresh}, loadMore: ${event.loadMore}');
    
    // 如果是强制刷新，重置页码
    if (event.forceRefresh) {
      _resetPages();
    }
    
    // 如果不是加载更多，显示加载状态
    if (!event.loadMore) {
      emit(state.copyWithLoading());
    }
    
    // 确定要加载的商品状态
    final ProductStatus status = event.status ?? _getStatusByTabIndex(state.tabIndex);
    print('[ProductManagementBloc] Determined status: $status');
    
    // 根据状态确定加载哪种类型的商品列表
    if (status == ProductStatus.draft) {
      print('[ProductManagementBloc] Loading draft list...');
      await _loadDraftList(emit, event.loadMore);
    } else {
      print('[ProductManagementBloc] Loading products by status: $status');
      await _loadProductsByStatus(status, emit, event.loadMore);
    }
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
  
  /// 重置所有页码
  void _resetPages() {
    _onSaleCurrentPage = 1;
    _draftCurrentPage = 1;
    _offShelfCurrentPage = 1;
  }
  
  /// 加载商品列表
  Future<void> _loadProductsByStatus(
    ProductStatus status,
    Emitter<ProductManagementState> emit,
    bool isLoadMore,
  ) async {
    // 确定当前页码
    final int currentPage = _getCurrentPageByStatus(status);
    
    // 根据状态决定API参数
    String? apiState;
    switch (status) {
      case ProductStatus.normal:
        // 获取所有正式商品（包括各种审核状态），不传state参数
        apiState = null;
        break;
      case ProductStatus.disabled:
        apiState = 'DISABLED';
        break;
      default:
        apiState = status.value;
    }
    
    final params = GetSellerProductListParams(
      pageNum: currentPage,
      pageSize: _pageSize,
      state: apiState,
    );
    
    final result = await _getSellerProductListUseCase(params);
    
    result.fold(
      (failure) => emit(state.copyWithError(failure.message)),
      (paginatedList) {
        final products = paginatedList.items;
        final hasMore = paginatedList.items.length >= _pageSize;
        
        // 更新当前页码
        _updateCurrentPageByStatus(status, currentPage + 1);

        print('[ProductManagementBloc] Success. Status: $status, Fetched Products: ${products.length}, HasMore: $hasMore, IsLoadMore: $isLoadMore');
        if (products.isNotEmpty) {
           print('[ProductManagementBloc] First product ID: ${products.first.id}, Name: ${products.first.name}, ProductStatus: ${products.first.status}');
        }

        switch (status) {
          case ProductStatus.normal:
            emit(state.copyWithProducts(
              onSaleProducts: products,
              hasMoreOnSaleProducts: hasMore,
              appendToExisting: isLoadMore,
            ));
            break;
          case ProductStatus.disabled:
            emit(state.copyWithProducts(
              offShelfProducts: products,
              hasMoreOffShelfProducts: hasMore,
              appendToExisting: isLoadMore,
            ));
            break;
          default:
            // 其他状态，例如未知状态，不处理
            emit(state.copyWith(isLoading: false));
        }
      },
    );
  }
  
  /// 加载草稿列表
  Future<void> _loadDraftList(Emitter<ProductManagementState> emit, bool isLoadMore) async {
    print('[ProductManagementBloc] _loadDraftList called, page: $_draftCurrentPage, isLoadMore: $isLoadMore');
    
    final params = GetSellerDraftListParams(
      pageNum: _draftCurrentPage,
      pageSize: _pageSize,
    );
    
    print('[ProductManagementBloc] Calling GetSellerDraftListUseCase with params: $params');
    final result = await _getSellerDraftListUseCase(params);
    
    result.fold(
      (failure) => emit(state.copyWithError(failure.message)),
      (paginatedList) {
        final products = paginatedList.items;
        final hasMore = products.length >= _pageSize;
        
        // 更新当前页码
        _draftCurrentPage++;
        
        emit(state.copyWithProducts(
          draftProducts: products,
          hasMoreDraftProducts: hasMore,
          appendToExisting: isLoadMore,
        ));
      },
    );
  }
  
  /// 根据商品状态获取当前页码
  int _getCurrentPageByStatus(ProductStatus status) {
    switch (status) {
      case ProductStatus.normal:
        return _onSaleCurrentPage;
      case ProductStatus.draft:
        return _draftCurrentPage;
      case ProductStatus.disabled:
        return _offShelfCurrentPage;
      default:
        return 1;
    }
  }
  
  /// 更新对应状态的当前页码
  void _updateCurrentPageByStatus(ProductStatus status, int newPage) {
    switch (status) {
      case ProductStatus.normal:
        _onSaleCurrentPage = newPage;
        break;
      case ProductStatus.draft:
        _draftCurrentPage = newPage;
        break;
      case ProductStatus.disabled:
        _offShelfCurrentPage = newPage;
        break;
      default:
        // 其他状态不处理
        break;
    }
  }
  
  /// 切换标签页
  Future<void> _onChangeProductTab(
    ChangeProductTab event,
    Emitter<ProductManagementState> emit,
  ) async {
    print('[ProductManagementBloc] _onChangeProductTab called, tabIndex: ${event.tabIndex}');
    
    // 更新标签页索引
    emit(state.copyWithTabIndex(event.tabIndex));

    // 判断是否需要加载数据
    bool needLoad = false;
    switch (event.tabIndex) {
      case 0: // 在售
        needLoad = state.onSaleProducts == null;
        print('[ProductManagementBloc] Tab 0 (在售): onSaleProducts null? ${state.onSaleProducts == null}, needLoad: $needLoad');
        break;
      case 1: // 草稿
        needLoad = state.draftProducts == null;
        print('[ProductManagementBloc] Tab 1 (草稿): draftProducts null? ${state.draftProducts == null}, length: ${state.draftProducts?.length}, needLoad: $needLoad');
        break;
      case 2: // 已下架
        needLoad = state.offShelfProducts == null;
        print('[ProductManagementBloc] Tab 2 (已下架): offShelfProducts null? ${state.offShelfProducts == null}, needLoad: $needLoad');
        break;
    }

    // 如果需要加载，触发加载事件
    if (needLoad) {
      final status = _getStatusByTabIndex(event.tabIndex);
      print('[ProductManagementBloc] Need to load, triggering LoadProductList with status: $status');
      add(LoadProductList(status: status));
    } else {
      print('[ProductManagementBloc] No need to load data for tab ${event.tabIndex}');
    }
  }
  
  /// 更新商品状态
  Future<void> _onUpdateProductStatus(
    UpdateProductStatus event,
    Emitter<ProductManagementState> emit,
  ) async {
    // 添加到处理中ID列表
    emit(state.addProcessingProductId(event.productId));
    
    final params = UpdateProductStatusParams(
      productId: event.productId,
      status: event.targetStatus,
    );
    
    final result = await _updateProductStatusUseCase(params);
    
    result.fold(
      (failure) {
        // 从处理中ID列表移除
        emit(state.removeProcessingProductId(event.productId));
        
        // 显示错误
        // 这里可以通过UI层的BlocListener处理错误提示
        emit(state.copyWith(
          errorMessage: failure.message,
        ));
      },
      (success) {
        // 从处理中ID列表移除
        emit(state.removeProcessingProductId(event.productId));
        
        if (success) {
          print('🎉 [ProductManagementBloc] 商品${event.productId}状态更新成功，目标状态: ${event.targetStatus}');
          // 更新成功，根据目标状态更新对应列表
          
          // 这里我们选择简单地刷新当前Tab的列表
          // 更复杂的实现可以只更新受影响的列表项
          _resetPages();
          print('🔄 [ProductManagementBloc] 触发列表刷新，当前tab: ${state.tabIndex}');
          add(LoadProductList(
            status: _getStatusByTabIndex(state.tabIndex),
            forceRefresh: true,
          ));
        }
      },
    );
  }
  
  /// 删除商品
  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ProductManagementState> emit,
  ) async {
    // 添加到处理中ID列表
    emit(state.addProcessingProductId(event.productId));
    
    // 找到要删除的商品信息 - 根据当前标签页从对应列表中查找
    SellerManagedProduct? productToDelete;
    
    // 根据当前标签页决定从哪个列表中查找
    switch (state.tabIndex) {
      case 0: // 在售商品
        productToDelete = state.onSaleProducts
            ?.where((p) => p.id == event.productId)
            .firstOrNull;
        break;
      case 1: // 草稿箱
        productToDelete = state.draftProducts
            ?.where((p) => p.id == event.productId)
            .firstOrNull;
        break;
      case 2: // 已下架
        productToDelete = state.offShelfProducts
            ?.where((p) => p.id == event.productId)
            .firstOrNull;
        break;
      default:
        // 如果标签页未知，尝试从所有列表中查找
        productToDelete = state.onSaleProducts
                ?.where((p) => p.id == event.productId)
                .firstOrNull ??
            state.draftProducts
                ?.where((p) => p.id == event.productId)
                .firstOrNull ??
            state.offShelfProducts
                ?.where((p) => p.id == event.productId)
                .firstOrNull;
    }
        
    if (productToDelete == null) {
      // 从处理中ID列表移除
      emit(state.removeProcessingProductId(event.productId));
      
      emit(state.copyWith(
        errorMessage: '找不到要删除的商品',
      ));
      return;
    }
    
    print('=== 开始删除商品 ===');
    print('商品ID: ${productToDelete.id}');
    print('商品名称: ${productToDelete.name}');
    print('商品状态: ${productToDelete.status}');
    print('状态值: ${productToDelete.status.value}');
    print('状态显示: ${productToDelete.status.displayName}');
    
    // 创建删除参数，包含商品信息
    final params = DeleteProductParams(
      productIds: [event.productId],
      products: [productToDelete],  // 传递商品信息用于状态判断
    );
    
    final result = await _deleteProductUseCase(params);
    
    result.fold(
      (failure) {
        // 从处理中ID列表移除
        emit(state.removeProcessingProductId(event.productId));
        
        // 显示错误
        emit(state.copyWith(
          errorMessage: failure.message,
        ));
      },
      (success) {
        // 从处理中ID列表移除
        emit(state.removeProcessingProductId(event.productId));
        
        if (success) {
          // 删除成功，更新列表
          // 这里为简单起见，我们选择刷新整个列表
          // 更复杂的实现可以只移除受影响的列表项
          _resetPages();
          add(LoadProductList(
            status: _getStatusByTabIndex(state.tabIndex), 
            forceRefresh: true,
          ));
        }
      },
    );
  }
  
  /// 导航到商品创建页面
  Future<void> _onNavigateToProductCreate(
    NavigateToProductCreate event,
    Emitter<ProductManagementState> emit,
  ) async {
    // Emit state with navigation path
    emit(state.copyWith(navigationPath: SellerRoutes.productCreate));
    // Emit state immediately after to clear the navigation path 
    // to prevent re-navigation on unrelated state changes.
    emit(state.copyWith(clearNavigationPath: true));
  }
  
  /// 导航到商品编辑页面
  Future<void> _onNavigateToProductEdit(
    NavigateToProductEdit event,
    Emitter<ProductManagementState> emit,
  ) async {
    // Build the path with parameters
    final String path = SellerRoutes.buildPath(
      SellerRoutes.productEdit, // Use the base route for editing
      params: {'id': event.productId.toString()},
    );
    // Emit state with navigation path
    emit(state.copyWith(navigationPath: path));
    // Emit state immediately after to clear the navigation path
    emit(state.copyWith(clearNavigationPath: true)); 
  }
  
  /// 导航到商品详情页面
  Future<void> _onNavigateToProductDetail(
    NavigateToProductDetail event,
    Emitter<ProductManagementState> emit,
  ) async {
    // 导航到商品详情页面 - 使用Home模块的商品详情路由
    final String path = '/home/product/${event.productId}';
    
    print('[ProductManagementBloc] Navigating to product detail: $path');
    
    // 发出带有导航路径的状态
    emit(state.copyWith(navigationPath: path));
    // 立即清除导航路径，防止在无关状态变化时重复导航
    emit(state.copyWith(clearNavigationPath: true));
  }
} 