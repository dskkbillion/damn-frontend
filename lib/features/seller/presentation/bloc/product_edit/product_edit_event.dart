import 'package:equatable/equatable.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_edit/product_edit_state.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';

/// 商品编辑事件基类
abstract class ProductEditEvent extends Equatable {
  const ProductEditEvent();

  @override
  List<Object?> get props => [];
}

/// 初始化编辑页面
class InitializeProductEdit extends ProductEditEvent {
  /// 商品ID，如果是创建模式则为null
  final int? productId;

  const InitializeProductEdit({
    this.productId,
  });

  @override
  List<Object?> get props => [productId];
}

/// 加载商品数据
class LoadProductData extends ProductEditEvent {
  /// 商品ID
  final int productId;

  const LoadProductData({
    required this.productId,
  });

  @override
  List<Object?> get props => [productId];
}

/// 加载商品类别数据
class LoadProductCategories extends ProductEditEvent {
  const LoadProductCategories();
}

/// 更新表单字段
class UpdateFormField extends ProductEditEvent {
  /// 表单字段名称
  final String fieldName;
  
  /// 表单字段值
  final dynamic value;

  const UpdateFormField({
    required this.fieldName,
    required this.value,
  });

  @override
  List<Object?> get props => [fieldName, value];
}

/// 更新表单数据
class UpdateFormData extends ProductEditEvent {
  /// 新的表单数据
  final ProductFormData formData;

  const UpdateFormData({
    required this.formData,
  });

  @override
  List<Object?> get props => [formData];
}

/// 添加规格选项
class AddProductVariant extends ProductEditEvent {
  const AddProductVariant();
}

/// 移除规格选项
class RemoveProductVariant extends ProductEditEvent {
  /// 规格选项索引
  final int index;

  const RemoveProductVariant({
    required this.index,
  });

  @override
  List<Object?> get props => [index];
}

/// 更新规格选项
class UpdateProductVariant extends ProductEditEvent {
  /// 规格选项索引
  final int index;
  
  /// 更新后的规格选项
  final Map<String, dynamic> variantData;

  const UpdateProductVariant({
    required this.index,
    required this.variantData,
  });

  @override
  List<Object?> get props => [index, variantData];
}

/// 添加自定义材料问题
class AddProductMaterial extends ProductEditEvent {
  const AddProductMaterial();
}

/// 移除自定义材料问题
class RemoveProductMaterial extends ProductEditEvent {
  /// 问题索引
  final int index;

  const RemoveProductMaterial({
    required this.index,
  });

  @override
  List<Object?> get props => [index];
}

/// 更新自定义材料问题
class UpdateProductMaterial extends ProductEditEvent {
  /// 问题索引
  final int index;
  
  /// 更新后的问题数据
  final Map<String, dynamic> materialData;

  const UpdateProductMaterial({
    required this.index,
    required this.materialData,
  });

  @override
  List<Object?> get props => [index, materialData];
}

/// 选择商品图片
class SelectProductImages extends ProductEditEvent {
  /// 选择的图片路径列表
  final List<String> imagePaths;

  const SelectProductImages({
    required this.imagePaths,
  });

  @override
  List<Object?> get props => [imagePaths];
}

/// 选择商品详情图片
class SelectDetailProductImages extends ProductEditEvent {
  /// 选择的详情图片路径列表
  final List<String> imagePaths;

  const SelectDetailProductImages({
    required this.imagePaths,
  });

  @override
  List<Object?> get props => [imagePaths];
}

/// 上传单个图片
class UploadProductImage extends ProductEditEvent {
  final String imagePath;
  final bool isDetailImage;
  final List<String>? remainingPaths;
  
  const UploadProductImage({
    required this.imagePath,
    this.isDetailImage = false,
    this.remainingPaths,
  });
  
  @override
  List<Object?> get props => [imagePath, isDetailImage, remainingPaths];
}

/// 图片上传成功
class ProductImageUploadSuccess extends ProductEditEvent {
  final String imagePath;
  final String imageUrl;
  final bool isDetailImage;
  final List<String>? remainingPaths;
  
  const ProductImageUploadSuccess({
    required this.imagePath,
    required this.imageUrl,
    this.isDetailImage = false,
    this.remainingPaths,
  });
  
  @override
  List<Object?> get props => [imagePath, imageUrl, isDetailImage, remainingPaths];
}

/// 图片上传失败
class ProductImageUploadFailure extends ProductEditEvent {
  final String imagePath;
  final String errorMessage;
  final bool isDetailImage;
  final List<String>? remainingPaths;
  
  const ProductImageUploadFailure({
    required this.imagePath,
    required this.errorMessage,
    this.isDetailImage = false,
    this.remainingPaths,
  });
  
  @override
  List<Object?> get props => [imagePath, errorMessage, isDetailImage, remainingPaths];
}

/// 提交表单
class SubmitProductForm extends ProductEditEvent {
  const SubmitProductForm();
}

/// 重置表单
class ResetProductForm extends ProductEditEvent {
  const ResetProductForm();
}

/// 保存草稿
class SaveProductDraft extends ProductEditEvent {
  const SaveProductDraft();
}

/// 检查是否有未保存的变更
class CheckForUnsavedChanges extends ProductEditEvent {
  const CheckForUnsavedChanges();
}

/// 初始化表单原始数据（用于变更检测）
class SetInitialFormData extends ProductEditEvent {
  final ProductFormData initialData;
  
  const SetInitialFormData({required this.initialData});
  
  @override
  List<Object?> get props => [initialData];
} 