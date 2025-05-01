import 'package:equatable/equatable.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/enums/product_status.dart';

/// 商品管理页面事件基类
abstract class ProductManagementEvent extends Equatable {
  const ProductManagementEvent();

  @override
  List<Object> get props => [];
}

/// 加载商品列表事件
class LoadProductList extends ProductManagementEvent {
  /// 是否强制刷新
  final bool forceRefresh;
  
  /// 是否加载更多 (分页)
  final bool loadMore;
  
  /// 要加载的商品状态类型 (null表示根据当前标签页自动确定)
  final ProductStatus? status;
  
  const LoadProductList({
    this.forceRefresh = false,
    this.loadMore = false,
    this.status,
  });
  
  @override
  List<Object> get props => [forceRefresh, loadMore, status ?? 'auto'];
}

/// 切换标签页事件
class ChangeProductTab extends ProductManagementEvent {
  /// 目标标签页索引
  final int tabIndex;
  
  const ChangeProductTab({required this.tabIndex});
  
  @override
  List<Object> get props => [tabIndex];
}

/// 更新商品状态事件 (上架/下架)
class UpdateProductStatus extends ProductManagementEvent {
  /// 商品ID
  final int productId;
  
  /// 目标状态
  final ProductStatus targetStatus;
  
  const UpdateProductStatus({
    required this.productId,
    required this.targetStatus,
  });
  
  @override
  List<Object> get props => [productId, targetStatus];
}

/// 删除商品事件
class DeleteProduct extends ProductManagementEvent {
  /// 商品ID
  final int productId;
  
  const DeleteProduct({required this.productId});
  
  @override
  List<Object> get props => [productId];
}

/// 导航到商品创建页面事件
class NavigateToProductCreate extends ProductManagementEvent {
  const NavigateToProductCreate();
}

/// 导航到商品编辑页面事件
class NavigateToProductEdit extends ProductManagementEvent {
  /// 商品ID
  final int productId;
  
  const NavigateToProductEdit({required this.productId});
  
  @override
  List<Object> get props => [productId];
}

/// 导航到商品详情页面事件
class NavigateToProductDetail extends ProductManagementEvent {
  /// 商品ID
  final int productId;
  
  const NavigateToProductDetail({required this.productId});
  
  @override
  List<Object> get props => [productId];
} 