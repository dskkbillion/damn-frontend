import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/create_product_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_product_detail_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/update_product_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_edit/product_edit_event.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_edit/product_edit_state.dart';
import 'package:injectable/injectable.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/repositories/i_file_upload_repository.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';

/// 产品编辑BLoC
@injectable
class ProductEditBloc extends Bloc<ProductEditEvent, ProductEditState> {
  /// 获取产品详情UseCase
  final GetSellerProductDetailUseCase _getSellerProductDetailUseCase;
  
  /// 创建产品UseCase
  final CreateProductUseCase _createProductUseCase;
  
  /// 更新产品UseCase
  final UpdateProductUseCase _updateProductUseCase;
  
  /// 文件上传仓库
  final IFileUploadRepository _fileUploadRepository;
  
  /// 卖家仓库
  final ISellerRepository _sellerRepository;

  /// 构造函数
  ProductEditBloc(
    this._getSellerProductDetailUseCase,
    this._createProductUseCase,
    this._updateProductUseCase,
    this._fileUploadRepository,
    this._sellerRepository,
  ) : super(ProductEditState.initial()) {
    on<InitializeProductEdit>(_onInitializeProductEdit);
    on<LoadProductData>(_onLoadProductData);
    on<LoadProductCategories>(_onLoadProductCategories);
    on<UpdateFormField>(_onUpdateFormField);
    on<UpdateFormData>(_onUpdateFormData);
    on<AddProductVariant>(_onAddProductVariant);
    on<RemoveProductVariant>(_onRemoveProductVariant);
    on<UpdateProductVariant>(_onUpdateProductVariant);
    on<AddProductMaterial>(_onAddProductMaterial);
    on<RemoveProductMaterial>(_onRemoveProductMaterial);
    on<UpdateProductMaterial>(_onUpdateProductMaterial);
    on<SelectProductImages>(_onSelectProductImages);
    on<SelectDetailProductImages>(_onSelectDetailProductImages);
    on<UploadProductImage>(_onUploadProductImage);
    on<ProductImageUploadSuccess>(_onProductImageUploadSuccess);
    on<ProductImageUploadFailure>(_onProductImageUploadFailure);
    on<SubmitProductForm>(_onSubmitProductForm);
    on<ResetProductForm>(_onResetProductForm);
  }

  /// 初始化编辑页面处理
  Future<void> _onInitializeProductEdit(
    InitializeProductEdit event,
    Emitter<ProductEditState> emit,
  ) async {
    // 根据是否有productId判断是创建还是编辑模式
    final bool isCreateMode = event.productId == null;
    
    emit(ProductEditState.initial(isCreateMode: isCreateMode));
    
    // 如果是编辑模式，加载商品数据
    if (!isCreateMode) {
      add(LoadProductData(productId: event.productId!));
    }
    
    // 加载商品类别数据
    add(const LoadProductCategories());
  }

  /// 加载商品数据处理
  Future<void> _onLoadProductData(
    LoadProductData event,
    Emitter<ProductEditState> emit,
  ) async {
    emit(state.copyWithLoading());
    
    final result = await _getSellerProductDetailUseCase(
      GetSellerProductDetailParams(productId: event.productId),
    );
    
    result.fold(
      (failure) => emit(state.copyWithError(failure.message)),
      (product) => emit(state.copyWithProductLoaded(product)),
    );
  }

  /// 加载商品类别数据处理
  Future<void> _onLoadProductCategories(
    LoadProductCategories event,
    Emitter<ProductEditState> emit,
  ) async {
    // 这里假设有一个加载商品类别的UseCase或Repository方法
    // 由于代码示例中没有找到相关UseCase，暂时使用静态数据
    
    // TODO: 实现从后端获取商品类别的逻辑
    final categories = [
      const ProductCategory(id: 1, name: '数字产品'),
      const ProductCategory(id: 2, name: '设计服务'),
      const ProductCategory(id: 3, name: '定制商品'),
    ];
    
    emit(state.copyWithCategoriesLoaded(categories));
  }

  /// 更新表单字段处理
  void _onUpdateFormField(
    UpdateFormField event,
    Emitter<ProductEditState> emit,
  ) {
    final currentFormData = state.formData;
    ProductFormData updatedFormData;
    
    switch (event.fieldName) {
      case 'name':
        updatedFormData = currentFormData.copyWith(name: event.value as String);
        break;
      case 'description':
        updatedFormData = currentFormData.copyWith(description: event.value as String);
        break;
      case 'price':
        updatedFormData = currentFormData.copyWith(price: event.value as double);
        break;
      case 'categoryId':
        updatedFormData = currentFormData.copyWith(categoryId: event.value as int);
        break;
      default:
        updatedFormData = currentFormData;
    }
    
    emit(state.copyWithFormUpdated(updatedFormData));
  }

  /// 更新整个表单数据处理
  void _onUpdateFormData(
    UpdateFormData event,
    Emitter<ProductEditState> emit,
  ) {
    emit(state.copyWithFormUpdated(event.formData));
  }

  /// 添加规格选项处理
  void _onAddProductVariant(
    AddProductVariant event,
    Emitter<ProductEditState> emit,
  ) {
    final currentVariants = List<ProductOptionValue>.from(state.formData.variants);
    
    // 添加新的空规格选项
    currentVariants.add(
      const ProductOptionValue(
        id: 0, // 0表示新增的规格，后端会分配真实ID
        optionName: '',
        optionValue: '',
        price: 0,
        stock: 0,
      ),
    );
    
    final updatedFormData = state.formData.copyWith(variants: currentVariants);
    emit(state.copyWithFormUpdated(updatedFormData));
  }

  /// 移除规格选项处理
  void _onRemoveProductVariant(
    RemoveProductVariant event,
    Emitter<ProductEditState> emit,
  ) {
    final currentVariants = List<ProductOptionValue>.from(state.formData.variants);
    
    if (event.index >= 0 && event.index < currentVariants.length) {
      currentVariants.removeAt(event.index);
      
      final updatedFormData = state.formData.copyWith(variants: currentVariants);
      emit(state.copyWithFormUpdated(updatedFormData));
    }
  }

  /// 更新规格选项处理
  void _onUpdateProductVariant(
    UpdateProductVariant event,
    Emitter<ProductEditState> emit,
  ) {
    final currentVariants = List<ProductOptionValue>.from(state.formData.variants);
    
    if (event.index >= 0 && event.index < currentVariants.length) {
      final currentVariant = currentVariants[event.index];
      
      // 更新当前规格选项的字段
      currentVariants[event.index] = ProductOptionValue(
        id: currentVariant.id,
        optionName: event.variantData['optionName'] ?? currentVariant.optionName,
        optionValue: event.variantData['optionValue'] ?? currentVariant.optionValue,
        price: event.variantData['price'] ?? currentVariant.price,
        stock: event.variantData['stock'] ?? currentVariant.stock,
      );
      
      final updatedFormData = state.formData.copyWith(variants: currentVariants);
      emit(state.copyWithFormUpdated(updatedFormData));
    }
  }

  /// 添加自定义材料问题处理
  void _onAddProductMaterial(
    AddProductMaterial event,
    Emitter<ProductEditState> emit,
  ) {
    final currentMaterials = List<ProductMaterial>.from(state.formData.productMaterials);
    
    // 添加新的空材料问题
    currentMaterials.add(
      const ProductMaterial(
        id: 0, // 0表示新增的问题，后端会分配真实ID
        question: '',
        type: 'TEXT', // 默认为文本类型
      ),
    );
    
    final updatedFormData = state.formData.copyWith(productMaterials: currentMaterials);
    emit(state.copyWithFormUpdated(updatedFormData));
  }

  /// 移除自定义材料问题处理
  void _onRemoveProductMaterial(
    RemoveProductMaterial event,
    Emitter<ProductEditState> emit,
  ) {
    final currentMaterials = List<ProductMaterial>.from(state.formData.productMaterials);
    
    if (event.index >= 0 && event.index < currentMaterials.length) {
      currentMaterials.removeAt(event.index);
      
      final updatedFormData = state.formData.copyWith(productMaterials: currentMaterials);
      emit(state.copyWithFormUpdated(updatedFormData));
    }
  }

  /// 更新自定义材料问题处理
  void _onUpdateProductMaterial(
    UpdateProductMaterial event,
    Emitter<ProductEditState> emit,
  ) {
    final currentMaterials = List<ProductMaterial>.from(state.formData.productMaterials);
    
    if (event.index >= 0 && event.index < currentMaterials.length) {
      final currentMaterial = currentMaterials[event.index];
      
      // 更新当前材料问题的字段
      currentMaterials[event.index] = ProductMaterial(
        id: currentMaterial.id,
        question: event.materialData['question'] ?? currentMaterial.question,
        type: event.materialData['type'] ?? currentMaterial.type,
      );
      
      final updatedFormData = state.formData.copyWith(productMaterials: currentMaterials);
      emit(state.copyWithFormUpdated(updatedFormData));
    }
  }

  /// 选择商品图片处理
  void _onSelectProductImages(
    SelectProductImages event,
    Emitter<ProductEditState> emit,
  ) {
    // 先保存选择的图片路径
    emit(state.copyWithSelectedImages(event.imagePaths));
    
    // 验证图片数量限制
    if (event.imagePaths.length > 9) {
      emit(state.copyWithError('最多只能上传9张图片'));
      return;
    }
    
    // 更新上传状态
    emit(state.copyWith(
      uploadStatus: UploadStatus.uploading,
      totalUploadCount: event.imagePaths.length,
      uploadedCount: 0,
    ));
    
    // 改为顺序上传，只先上传第一张图片
    if (event.imagePaths.isNotEmpty) {
      // 获取第一个图片和剩余图片列表
      final firstImagePath = event.imagePaths.first;
      final remainingPaths = event.imagePaths.length > 1 
          ? event.imagePaths.sublist(1) 
          : <String>[];
      
      add(UploadProductImage(
        imagePath: firstImagePath,
        isDetailImage: false,
        remainingPaths: remainingPaths,
      ));
    }
  }

  /// 选择商品详情图片处理
  void _onSelectDetailProductImages(
    SelectDetailProductImages event,
    Emitter<ProductEditState> emit,
  ) {
    // 先保存选择的详情图片路径
    emit(state.copyWithSelectedDetailImages(event.imagePaths));
    
    // 验证图片数量限制
    if (event.imagePaths.length > 9) {
      emit(state.copyWithError('最多只能上传9张详情图片'));
      return;
    }
    
    // 更新上传状态
    emit(state.copyWith(
      uploadStatus: UploadStatus.uploading,
      totalUploadCount: event.imagePaths.length,
      uploadedCount: 0,
    ));
    
    // 改为顺序上传，只先上传第一张图片
    if (event.imagePaths.isNotEmpty) {
      // 获取第一个图片和剩余图片列表
      final firstImagePath = event.imagePaths.first;
      final remainingPaths = event.imagePaths.length > 1 
          ? event.imagePaths.sublist(1) 
          : <String>[];
      
      add(UploadProductImage(
        imagePath: firstImagePath,
        isDetailImage: true,
        remainingPaths: remainingPaths,
      ));
    }
  }
  
  /// 处理图片，包括格式转换和压缩
  /// 返回处理后的图片路径
  Future<String> _preprocessImage(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      
      // 判断文件是否存在
      if (!await imageFile.exists()) {
        print('图片文件不存在: $imagePath');
        return imagePath; // 如果文件不存在，返回原路径
      }
      
      // 获取文件扩展名并转为小写
      final String extension = path.extension(imagePath).toLowerCase();
      
      // 检查文件大小
      final int fileSize = await imageFile.length();
      final int maxSize = 5 * 1024 * 1024; // 5MB最大限制
      final int targetSize = 1 * 1024 * 1024; // 目标1MB
      
      // 只处理HEIC格式或大于目标大小的图片
      bool needProcess = extension == '.heic' || extension == '.heif' || fileSize > targetSize;
      
      if (!needProcess) {
        return imagePath; // 如果不需要处理，返回原路径
      }
      
      // 获取临时目录保存处理后的图片
      final tempDir = await getTemporaryDirectory();
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';
      final String targetPath = path.join(tempDir.path, fileName);
      
      // 计算压缩质量
      int quality = 85; // 默认质量
      if (fileSize > maxSize) {
        quality = 60; // 对大图片使用更高压缩率
      } else if (fileSize > targetSize * 2) {
        quality = 70;
      }
      
      // 设置最大宽度和高度限制，保持宽高比
      const int maxWidth = 1920;
      const int maxHeight = 1920;
      
      print('开始处理图片: $imagePath (${(fileSize / 1024).toStringAsFixed(2)}KB, 格式:$extension)');
      print('目标路径: $targetPath, 压缩质量: $quality%');
      
      // 使用flutter_image_compress压缩并转换格式
      final result = await FlutterImageCompress.compressAndGetFile(
        imagePath,
        targetPath,
        quality: quality,
        minWidth: 1080,
        minHeight: 1080,
        format: CompressFormat.jpeg, // 统一转为JPEG格式
      );
      
      if (result != null) {
        final int newSize = await File(result.path).length();
        print('图片处理完成: ${(fileSize / 1024).toStringAsFixed(2)}KB -> ${(newSize / 1024).toStringAsFixed(2)}KB');
        print('压缩率: ${(newSize * 100 / fileSize).toStringAsFixed(1)}%');
        return result.path;
      } else {
        print('图片压缩失败，使用原图');
        return imagePath;
      }
    } catch (e) {
      print('图片预处理过程中发生错误: $e');
      return imagePath; // 处理失败时返回原路径
    }
  }

  /// 上传单个图片处理
  Future<void> _onUploadProductImage(
    UploadProductImage event,
    Emitter<ProductEditState> emit,
  ) async {
    try {
      // 原始文件路径
      final String originalPath = event.imagePath;
      
      // 图片预处理：转换格式和压缩
      final String processedPath = await _preprocessImage(originalPath);
      final File file = File(processedPath);
      
      // 检查文件大小是否超过限制 (5MB)
      final fileSize = await file.length();
      final maxSize = 5 * 1024 * 1024; // 5MB
      
      if (fileSize > maxSize) {
        add(ProductImageUploadFailure(
          imagePath: originalPath, // 保持用原始路径，保证UI显示的一致性
          errorMessage: '图片大小超过5MB限制，即使压缩后仍然过大',
          isDetailImage: event.isDetailImage,
          remainingPaths: event.remainingPaths,
        ));
        return;
      }
      
      // 上传预处理后的文件
      final result = await _fileUploadRepository.uploadFile(file);
      
      result.fold(
        (failure) {
          // 上传失败
          add(ProductImageUploadFailure(
            imagePath: originalPath,
            errorMessage: failure.message,
            isDetailImage: event.isDetailImage,
            remainingPaths: event.remainingPaths,
          ));
        },
        (url) {
          // 上传成功
          add(ProductImageUploadSuccess(
            imagePath: originalPath,
            imageUrl: url,
            isDetailImage: event.isDetailImage,
            remainingPaths: event.remainingPaths,
          ));
        },
      );
    } catch (e) {
      // 处理异常
      add(ProductImageUploadFailure(
        imagePath: event.imagePath,
        errorMessage: e.toString(),
        isDetailImage: event.isDetailImage,
        remainingPaths: event.remainingPaths,
      ));
    }
  }
  
  /// 图片上传成功处理
  void _onProductImageUploadSuccess(
    ProductImageUploadSuccess event,
    Emitter<ProductEditState> emit,
  ) {
    // 更新已上传数量
    final int newCount = state.uploadedCount + 1;
    
    // 更新已上传的URL列表
    List<String> updatedMainUrls = List.from(state.uploadedImageUrls);
    List<String> updatedDetailUrls = List.from(state.uploadedDetailImageUrls);
    
    if (event.isDetailImage) {
      updatedDetailUrls.add(event.imageUrl);
    } else {
      updatedMainUrls.add(event.imageUrl);
    }
    
    // 检查是否全部上传完成
    final bool allDone = newCount >= state.totalUploadCount;
    
    // 更新状态
    emit(state.copyWith(
      uploadedCount: newCount,
      uploadStatus: allDone ? UploadStatus.success : UploadStatus.uploading,
      uploadedImageUrls: updatedMainUrls,
      uploadedDetailImageUrls: updatedDetailUrls,
      errorMessage: null, // 清除之前的错误信息
      hasError: false,    // 清除错误状态
    ));
    
    // 检查是否有剩余图片需要上传
    if (event.remainingPaths != null && event.remainingPaths!.isNotEmpty) {
      // 获取下一个图片和更新后的剩余图片列表
      final nextImagePath = event.remainingPaths!.first;
      final updatedRemainingPaths = event.remainingPaths!.length > 1 
          ? event.remainingPaths!.sublist(1) 
          : <String>[];
      
      // 继续上传下一张图片
      add(UploadProductImage(
        imagePath: nextImagePath,
        isDetailImage: event.isDetailImage,
        remainingPaths: updatedRemainingPaths,
      ));
    }
  }
  
  /// 图片上传失败处理
  void _onProductImageUploadFailure(
    ProductImageUploadFailure event,
    Emitter<ProductEditState> emit,
  ) {
    // 仍然增加已处理的图片计数，以便UI可以显示进度
    final int newCount = state.uploadedCount + 1;
    final bool allDone = newCount >= state.totalUploadCount;
    
    // 标记上传失败
    emit(state.copyWith(
      uploadStatus: UploadStatus.failure,
      uploadedCount: newCount,
      errorMessage: '图片上传失败: ${event.errorMessage}',
      hasError: true,
      // 如果所有图片都已处理完（成功或失败），更新状态
      isLoading: allDone ? false : state.isLoading,
    ));
    
    // 对于上传失败的图片，我们不会继续处理remainingPaths中的图片
    // 可以添加重试逻辑或让用户手动重试
  }

  /// 提交表单处理
  Future<void> _onSubmitProductForm(
    SubmitProductForm event,
    Emitter<ProductEditState> emit,
  ) async {
    // 表单验证
    if (!state.formData.isValid) {
      emit(state.copyWithError('表单数据不完整，请检查所有必填字段'));
      return;
    }
    
    // 检查是否有选择图片
    if (state.selectedImagePaths.isEmpty && state.uploadedImageUrls.isEmpty && (state.product?.images.isEmpty ?? true)) {
      emit(state.copyWithError('请至少上传一张商品图片'));
      return;
    }
    
    // 检查是否所有图片都已上传完成
    if (state.uploadStatus == UploadStatus.uploading) {
      emit(state.copyWithError('图片正在上传中，请等待上传完成后再提交'));
      return;
    }
    
    // 检查是否有图片上传失败
    if (state.uploadStatus == UploadStatus.failure && state.uploadedImageUrls.isEmpty) {
      emit(state.copyWithError('图片上传失败，请重新选择图片'));
      return;
    }
    
    emit(state.copyWithSubmitting());
    
    if (state.isCreateMode) {
      // 创建商品
      try {
        // 准备创建参数
        final productData = ProductCreationData(
          name: state.formData.name,
          description: state.formData.description,
          price: state.formData.price,
          images: state.uploadedImageUrls.join(','), // 使用已上传的URL
          categoryId: state.formData.categoryId,
          variants: state.formData.variants,
          productMaterials: state.formData.productMaterials,
          detailImages: state.uploadedDetailImageUrls.isNotEmpty ? state.uploadedDetailImageUrls.join(',') : null,
          detailContent: state.formData.detailContent.isNotEmpty ? state.formData.detailContent : null,
        );
        
        // 创建商品
        final result = await _sellerRepository.createProduct(productData);
        
        result.fold(
          (failure) => emit(state.copyWithError(failure.message)),
          (success) {
            if (success) {
              emit(state.copyWith(isSubmitSuccess: true));
            } else {
              emit(state.copyWithError('创建商品失败'));
            }
          },
        );
      } catch (e) {
        emit(state.copyWithError('创建商品过程中发生错误: ${e.toString()}'));
      }
    } else {
      // 更新商品
      if (state.product == null) {
        emit(state.copyWithError('无法获取要更新的商品数据'));
        return;
      }
      
      try {
        // 准备更新参数
        final productData = ProductUpdateData(
          id: state.product!.id,
          name: state.formData.name,
          description: state.formData.description,
          price: state.formData.price,
          images: state.uploadedImageUrls.isNotEmpty ? state.uploadedImageUrls.join(',') : null,
          categoryId: state.formData.categoryId,
          variants: state.formData.variants,
          productMaterials: state.formData.productMaterials,
          detailImages: state.uploadedDetailImageUrls.isNotEmpty ? state.uploadedDetailImageUrls.join(',') : null,
          detailContent: state.formData.detailContent.isNotEmpty ? state.formData.detailContent : null,
        );
        
        // 更新商品
        final result = await _sellerRepository.updateProduct(productData);
        
        result.fold(
          (failure) => emit(state.copyWithError(failure.message)),
          (success) {
            if (success) {
              emit(state.copyWith(isSubmitSuccess: true));
            } else {
              emit(state.copyWithError('更新商品失败'));
            }
          },
        );
      } catch (e) {
        emit(state.copyWithError('更新商品过程中发生错误: ${e.toString()}'));
      }
    }
  }

  /// 重置表单处理
  void _onResetProductForm(
    ResetProductForm event,
    Emitter<ProductEditState> emit,
  ) {
    if (state.isCreateMode) {
      // 如果是创建模式，重置为初始状态
      emit(ProductEditState.initial(isCreateMode: true));
    } else if (state.product != null) {
      // 如果是编辑模式，重置为加载的商品数据
      emit(state.copyWithProductLoaded(state.product!));
    }
  }
} 