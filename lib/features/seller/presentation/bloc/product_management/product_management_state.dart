import 'package:equatable/equatable.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';

/// 商品管理页面状态
class ProductManagementState extends Equatable {
  /// 是否加载中
  final bool isLoading;
  
  /// 是否有错误
  final bool hasError;
  
  /// 错误信息
  final String? errorMessage;
  
  /// 当前标签页索引
  final int tabIndex;
  
  /// 在售商品列表 (在售/已上架)
  final List<SellerManagedProduct>? onSaleProducts;
  
  /// 草稿箱商品列表
  final List<SellerManagedProduct>? draftProducts;
  
  /// 已下架商品列表
  final List<SellerManagedProduct>? offShelfProducts;
  
  /// 在售商品分页是否有更多数据
  final bool hasMoreOnSaleProducts;
  
  /// 草稿箱分页是否有更多数据
  final bool hasMoreDraftProducts;
  
  /// 已下架分页是否有更多数据
  final bool hasMoreOffShelfProducts;
  
  /// 当前操作中的商品ID，用于状态变更操作 (上架/下架等)
  final List<int> processingProductIds;
  
  /// 构造函数
  const ProductManagementState({
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.tabIndex = 0,
    this.onSaleProducts,
    this.draftProducts,
    this.offShelfProducts,
    this.hasMoreOnSaleProducts = true,
    this.hasMoreDraftProducts = true,
    this.hasMoreOffShelfProducts = true,
    this.processingProductIds = const [],
  });
  
  @override
  List<Object?> get props => [
    isLoading,
    hasError,
    errorMessage,
    tabIndex,
    onSaleProducts,
    draftProducts,
    offShelfProducts,
    hasMoreOnSaleProducts,
    hasMoreDraftProducts,
    hasMoreOffShelfProducts,
    processingProductIds,
  ];
  
  /// 初始状态
  factory ProductManagementState.initial() {
    return const ProductManagementState(
      isLoading: true,
    );
  }
  
  /// 加载中状态
  ProductManagementState copyWithLoading() {
    return ProductManagementState(
      isLoading: true,
      hasError: false,
      errorMessage: null,
      tabIndex: tabIndex,
      onSaleProducts: onSaleProducts,
      draftProducts: draftProducts,
      offShelfProducts: offShelfProducts,
      hasMoreOnSaleProducts: hasMoreOnSaleProducts,
      hasMoreDraftProducts: hasMoreDraftProducts,
      hasMoreOffShelfProducts: hasMoreOffShelfProducts,
      processingProductIds: processingProductIds,
    );
  }
  
  /// 加载失败状态
  ProductManagementState copyWithError(String errorMessage) {
    return ProductManagementState(
      isLoading: false,
      hasError: true,
      errorMessage: errorMessage,
      tabIndex: tabIndex,
      onSaleProducts: onSaleProducts,
      draftProducts: draftProducts,
      offShelfProducts: offShelfProducts,
      hasMoreOnSaleProducts: hasMoreOnSaleProducts,
      hasMoreDraftProducts: hasMoreDraftProducts,
      hasMoreOffShelfProducts: hasMoreOffShelfProducts,
      processingProductIds: processingProductIds,
    );
  }
  
  /// 更新列表数据
  ProductManagementState copyWithProducts({
    List<SellerManagedProduct>? onSaleProducts,
    List<SellerManagedProduct>? draftProducts,
    List<SellerManagedProduct>? offShelfProducts,
    bool? hasMoreOnSaleProducts,
    bool? hasMoreDraftProducts,
    bool? hasMoreOffShelfProducts,
    bool appendToExisting = false,
  }) {
    return ProductManagementState(
      isLoading: false,
      hasError: false,
      errorMessage: null,
      tabIndex: tabIndex,
      onSaleProducts: onSaleProducts != null
          ? (appendToExisting && this.onSaleProducts != null)
              ? [...this.onSaleProducts!, ...onSaleProducts]
              : onSaleProducts
          : this.onSaleProducts,
      draftProducts: draftProducts != null
          ? (appendToExisting && this.draftProducts != null)
              ? [...this.draftProducts!, ...draftProducts]
              : draftProducts
          : this.draftProducts,
      offShelfProducts: offShelfProducts != null
          ? (appendToExisting && this.offShelfProducts != null)
              ? [...this.offShelfProducts!, ...offShelfProducts]
              : offShelfProducts
          : this.offShelfProducts,
      hasMoreOnSaleProducts: hasMoreOnSaleProducts ?? this.hasMoreOnSaleProducts,
      hasMoreDraftProducts: hasMoreDraftProducts ?? this.hasMoreDraftProducts,
      hasMoreOffShelfProducts: hasMoreOffShelfProducts ?? this.hasMoreOffShelfProducts,
      processingProductIds: processingProductIds,
    );
  }
  
  /// 切换标签页
  ProductManagementState copyWithTabIndex(int tabIndex) {
    return ProductManagementState(
      isLoading: isLoading,
      hasError: hasError,
      errorMessage: errorMessage,
      tabIndex: tabIndex,
      onSaleProducts: onSaleProducts,
      draftProducts: draftProducts,
      offShelfProducts: offShelfProducts,
      hasMoreOnSaleProducts: hasMoreOnSaleProducts,
      hasMoreDraftProducts: hasMoreDraftProducts,
      hasMoreOffShelfProducts: hasMoreOffShelfProducts,
      processingProductIds: processingProductIds,
    );
  }
  
  /// 添加处理中的商品ID
  ProductManagementState addProcessingProductId(int productId) {
    if (processingProductIds.contains(productId)) {
      return this;
    }
    
    return ProductManagementState(
      isLoading: isLoading,
      hasError: hasError,
      errorMessage: errorMessage,
      tabIndex: tabIndex,
      onSaleProducts: onSaleProducts,
      draftProducts: draftProducts,
      offShelfProducts: offShelfProducts,
      hasMoreOnSaleProducts: hasMoreOnSaleProducts,
      hasMoreDraftProducts: hasMoreDraftProducts,
      hasMoreOffShelfProducts: hasMoreOffShelfProducts,
      processingProductIds: [...processingProductIds, productId],
    );
  }
  
  /// 移除处理中的商品ID
  ProductManagementState removeProcessingProductId(int productId) {
    if (!processingProductIds.contains(productId)) {
      return this;
    }
    
    return ProductManagementState(
      isLoading: isLoading,
      hasError: hasError,
      errorMessage: errorMessage,
      tabIndex: tabIndex,
      onSaleProducts: onSaleProducts,
      draftProducts: draftProducts,
      offShelfProducts: offShelfProducts,
      hasMoreOnSaleProducts: hasMoreOnSaleProducts,
      hasMoreDraftProducts: hasMoreDraftProducts,
      hasMoreOffShelfProducts: hasMoreOffShelfProducts,
      processingProductIds: processingProductIds.where((id) => id != productId).toList(),
    );
  }
  
  /// 复制一个新状态
  ProductManagementState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    int? tabIndex,
    List<SellerManagedProduct>? onSaleProducts,
    List<SellerManagedProduct>? draftProducts,
    List<SellerManagedProduct>? offShelfProducts,
    bool? hasMoreOnSaleProducts,
    bool? hasMoreDraftProducts,
    bool? hasMoreOffShelfProducts,
    List<int>? processingProductIds,
  }) {
    return ProductManagementState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      tabIndex: tabIndex ?? this.tabIndex,
      onSaleProducts: onSaleProducts ?? this.onSaleProducts,
      draftProducts: draftProducts ?? this.draftProducts,
      offShelfProducts: offShelfProducts ?? this.offShelfProducts,
      hasMoreOnSaleProducts: hasMoreOnSaleProducts ?? this.hasMoreOnSaleProducts,
      hasMoreDraftProducts: hasMoreDraftProducts ?? this.hasMoreDraftProducts,
      hasMoreOffShelfProducts: hasMoreOffShelfProducts ?? this.hasMoreOffShelfProducts,
      processingProductIds: processingProductIds ?? this.processingProductIds,
    );
  }
} 