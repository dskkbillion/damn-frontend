import 'package:equatable/equatable.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';

/// 商品编辑状态
class ProductEditState extends Equatable {
  /// 是否处于加载状态
  final bool isLoading;
  
  /// 是否存在错误
  final bool hasError;
  
  /// 错误信息
  final String? errorMessage;
  
  /// 是否处于提交中状态
  final bool isSubmitting;
  
  /// 是否提交成功
  final bool isSubmitSuccess;
  
  /// 编辑的商品数据
  final SellerManagedProduct? product;
  
  /// 本地选择的主图路径列表
  final List<String> selectedImagePaths;
  
  /// 本地选择的详情图路径列表
  final List<String> selectedDetailImagePaths;
  
  /// 商品表单数据
  final ProductFormData formData;
  
  /// 是否为创建模式（true为创建，false为编辑）
  final bool isCreateMode;
  
  /// 商品类别列表
  final List<ProductCategory>? categories;

  /// 构造函数
  const ProductEditState({
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.isSubmitting = false,
    this.isSubmitSuccess = false,
    this.product,
    this.selectedImagePaths = const [],
    this.selectedDetailImagePaths = const [],
    this.formData = const ProductFormData(),
    this.isCreateMode = true,
    this.categories,
  });

  @override
  List<Object?> get props => [
    isLoading,
    hasError,
    errorMessage,
    isSubmitting,
    isSubmitSuccess,
    product,
    selectedImagePaths,
    selectedDetailImagePaths,
    formData,
    isCreateMode,
    categories,
  ];

  /// 初始状态
  factory ProductEditState.initial({bool isCreateMode = true}) {
    return ProductEditState(
      isLoading: true,
      isCreateMode: isCreateMode,
      formData: ProductFormData(),
    );
  }

  /// 加载中状态
  ProductEditState copyWithLoading() {
    return copyWith(
      isLoading: true,
      hasError: false,
      errorMessage: null,
    );
  }

  /// 错误状态
  ProductEditState copyWithError(String message) {
    return copyWith(
      isLoading: false,
      isSubmitting: false,
      hasError: true,
      errorMessage: message,
    );
  }

  /// 提交中状态
  ProductEditState copyWithSubmitting() {
    return copyWith(
      isSubmitting: true,
      hasError: false,
      errorMessage: null,
    );
  }

  /// 提交成功状态
  ProductEditState copyWithSubmitSuccess() {
    return copyWith(
      isLoading: false,
      isSubmitting: false,
      isSubmitSuccess: true,
    );
  }

  /// 加载产品数据完成状态
  ProductEditState copyWithProductLoaded(SellerManagedProduct product) {
    return copyWith(
      isLoading: false,
      product: product,
      formData: ProductFormData.fromProduct(product),
    );
  }

  /// 加载类别数据完成状态
  ProductEditState copyWithCategoriesLoaded(List<ProductCategory> categories) {
    return copyWith(
      categories: categories,
      isLoading: false,
    );
  }

  /// 更新表单数据状态
  ProductEditState copyWithFormUpdated(ProductFormData formData) {
    return copyWith(
      formData: formData,
    );
  }

  /// 更新选中的主图
  ProductEditState copyWithSelectedImages(List<String> imagePaths) {
    return copyWith(
      selectedImagePaths: imagePaths,
    );
  }

  /// 更新选中的详情图
  ProductEditState copyWithSelectedDetailImages(List<String> imagePaths) {
    return copyWith(
      selectedDetailImagePaths: imagePaths,
    );
  }

  /// 复制状态
  ProductEditState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    bool? isSubmitting,
    bool? isSubmitSuccess,
    SellerManagedProduct? product,
    List<String>? selectedImagePaths,
    List<String>? selectedDetailImagePaths,
    ProductFormData? formData,
    bool? isCreateMode,
    List<ProductCategory>? categories,
  }) {
    return ProductEditState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitSuccess: isSubmitSuccess ?? this.isSubmitSuccess,
      product: product ?? this.product,
      selectedImagePaths: selectedImagePaths ?? this.selectedImagePaths,
      selectedDetailImagePaths: selectedDetailImagePaths ?? this.selectedDetailImagePaths,
      formData: formData ?? this.formData,
      isCreateMode: isCreateMode ?? this.isCreateMode,
      categories: categories ?? this.categories,
    );
  }
}

/// 商品表单数据
class ProductFormData extends Equatable {
  /// 商品名称
  final String name;
  
  /// 商品描述
  final String description;
  
  /// 商品价格
  final double price;
  
  /// 分类ID
  final int? categoryId;
  
  /// 商品规格选项
  final List<ProductOptionValue> variants;
  
  /// 自定义材料问题
  final List<ProductMaterial> productMaterials;
  
  /// 详情图HTML内容（富文本格式）
  final String detailContent;

  /// 构造函数
  const ProductFormData({
    this.name = '',
    this.description = '',
    this.price = 0,
    this.categoryId,
    this.variants = const [],
    this.productMaterials = const [],
    this.detailContent = '',
  });

  @override
  List<Object?> get props => [
    name,
    description,
    price,
    categoryId,
    variants,
    productMaterials,
    detailContent,
  ];

  /// 从产品实体创建表单数据
  factory ProductFormData.fromProduct(SellerManagedProduct product) {
    return ProductFormData(
      name: product.name,
      description: product.description,
      price: product.price,
      categoryId: product.category?.id,
      variants: product.variants ?? [],
      productMaterials: product.productMaterials ?? [],
      detailContent: '',  // 详情内容可能需要从其他字段获取
    );
  }

  /// 更新表单数据
  ProductFormData copyWith({
    String? name,
    String? description,
    double? price,
    int? categoryId,
    List<ProductOptionValue>? variants,
    List<ProductMaterial>? productMaterials,
    String? detailContent,
  }) {
    return ProductFormData(
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      variants: variants ?? this.variants,
      productMaterials: productMaterials ?? this.productMaterials,
      detailContent: detailContent ?? this.detailContent,
    );
  }

  /// 检查表单数据是否有效
  bool get isValid {
    return name.isNotEmpty && 
           description.isNotEmpty && 
           price > 0;
  }
} 