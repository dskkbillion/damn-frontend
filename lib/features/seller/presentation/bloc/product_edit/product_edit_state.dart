import 'package:equatable/equatable.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';

/// 上传状态枚举
enum UploadStatus {
  /// 未上传
  idle,
  
  /// 上传中
  uploading,
  
  /// 上传成功
  success,
  
  /// 上传失败
  failure,
}

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
  
  /// 图片上传状态
  final UploadStatus uploadStatus;
  
  /// 已上传图片数量
  final int uploadedCount;
  
  /// 总共需要上传的图片数量
  final int totalUploadCount;
  
  /// 已上传的主图URL列表
  final List<String> uploadedImageUrls;
  
  /// 已上传的详情图URL列表
  final List<String> uploadedDetailImageUrls;
  
  /// 上传进度百分比 (0-100)
  double get uploadProgress {
    if (totalUploadCount == 0) return 0;
    return (uploadedCount / totalUploadCount) * 100;
  }
  
  /// 商品表单数据
  final ProductFormData formData;
  
  /// 是否为创建模式（true为创建，false为编辑）
  final bool isCreateMode;
  
  /// 商品类别列表
  final List<ProductCategory>? categories;
  
  /// 初始表单数据（用于检测变更）
  final ProductFormData? initialFormData;
  
  /// 是否有未保存的变更
  final bool hasUnsavedChanges;
  
  /// 是否正在保存草稿
  final bool isSavingDraft;
  
  /// 草稿保存成功
  final bool isDraftSaveSuccess;

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
    this.uploadStatus = UploadStatus.idle,
    this.uploadedCount = 0,
    this.totalUploadCount = 0,
    this.uploadedImageUrls = const [],
    this.uploadedDetailImageUrls = const [],
    this.formData = const ProductFormData(),
    this.isCreateMode = true,
    this.categories,
    this.initialFormData,
    this.hasUnsavedChanges = false,
    this.isSavingDraft = false,
    this.isDraftSaveSuccess = false,
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
    uploadStatus,
    uploadedCount,
    totalUploadCount,
    uploadedImageUrls,
    uploadedDetailImageUrls,
    formData,
    isCreateMode,
    categories,
    initialFormData,
    hasUnsavedChanges,
    isSavingDraft,
    isDraftSaveSuccess,
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

  /// 设置初始数据状态
  ProductEditState copyWithInitialData(ProductFormData initialData) {
    return copyWith(
      initialFormData: initialData,
      hasUnsavedChanges: false,
    );
  }

  /// 保存草稿中状态
  ProductEditState copyWithSavingDraft() {
    return copyWith(
      isSavingDraft: true,
      hasError: false,
      errorMessage: null,
    );
  }

  /// 草稿保存成功状态
  ProductEditState copyWithDraftSaveSuccess() {
    return copyWith(
      isSavingDraft: false,
      isDraftSaveSuccess: true,
      hasUnsavedChanges: false,
    );
  }

  /// 检查表单是否有变更
  bool _hasFormChanges() {
    if (initialFormData == null) return false;
    
    return formData.name != initialFormData!.name ||
           formData.description != initialFormData!.description ||
           formData.price != initialFormData!.price ||
           formData.variants.length != initialFormData!.variants.length ||
           selectedImagePaths.isNotEmpty ||
           selectedDetailImagePaths.isNotEmpty;
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
    UploadStatus? uploadStatus,
    int? uploadedCount,
    int? totalUploadCount,
    List<String>? uploadedImageUrls,
    List<String>? uploadedDetailImageUrls,
    ProductFormData? formData,
    bool? isCreateMode,
    List<ProductCategory>? categories,
    ProductFormData? initialFormData,
    bool? hasUnsavedChanges,
    bool? isSavingDraft,
    bool? isDraftSaveSuccess,
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
      uploadStatus: uploadStatus ?? this.uploadStatus,
      uploadedCount: uploadedCount ?? this.uploadedCount,
      totalUploadCount: totalUploadCount ?? this.totalUploadCount,
      uploadedImageUrls: uploadedImageUrls ?? this.uploadedImageUrls,
      uploadedDetailImageUrls: uploadedDetailImageUrls ?? this.uploadedDetailImageUrls,
      formData: formData ?? this.formData,
      isCreateMode: isCreateMode ?? this.isCreateMode,
      categories: categories ?? this.categories,
      initialFormData: initialFormData ?? this.initialFormData,
      isSavingDraft: isSavingDraft ?? this.isSavingDraft,
      isDraftSaveSuccess: isDraftSaveSuccess ?? this.isDraftSaveSuccess,
      hasUnsavedChanges: hasUnsavedChanges ?? _computeHasUnsavedChanges(
        formData ?? this.formData,
        selectedImagePaths ?? this.selectedImagePaths,
        selectedDetailImagePaths ?? this.selectedDetailImagePaths,
        initialFormData ?? this.initialFormData,
      ),
    );
  }

  /// 计算是否有未保存的变更
  bool _computeHasUnsavedChanges(
    ProductFormData currentFormData,
    List<String> currentImagePaths,
    List<String> currentDetailImagePaths,
    ProductFormData? initialData,
  ) {
    // 对于新建商品（没有初始数据），只要用户输入了任何内容就算有变更
    if (initialData == null) {
      return currentFormData.name.trim().isNotEmpty ||
             currentFormData.description.trim().isNotEmpty ||
             currentFormData.price > 0 ||
             currentImagePaths.isNotEmpty ||
             currentDetailImagePaths.isNotEmpty ||
             (currentFormData.variants.isNotEmpty && 
              currentFormData.variants.any((v) => v.price > 0));
    }
    
    // 对于编辑商品，比较与初始状态的差异
    return currentFormData.name != initialData.name ||
           currentFormData.description != initialData.description ||
           currentFormData.price != initialData.price ||
           currentFormData.variants.length != initialData.variants.length ||
           currentImagePaths.isNotEmpty ||
           currentDetailImagePaths.isNotEmpty;
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