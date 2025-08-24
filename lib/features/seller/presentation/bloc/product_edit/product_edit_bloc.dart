import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/product_edit_models.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/create_product_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_product_detail_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/update_product_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/save_product_draft_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_edit/product_edit_event.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_edit/product_edit_state.dart';
import 'package:injectable/injectable.dart';
import 'dart:io';
import 'dart:math' as math;
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/repositories/i_file_upload_repository.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:dskk_flutter_refactor/core/utils/image_upload_helper.dart';
import 'package:dskk_flutter_refactor/core/services/image_compress_service.dart';

/// 产品编辑BLoC
@injectable
class ProductEditBloc extends Bloc<ProductEditEvent, ProductEditState> {
  /// 获取产品详情UseCase
  final GetSellerProductDetailUseCase _getSellerProductDetailUseCase;
  
  /// 创建产品UseCase
  final CreateProductUseCase _createProductUseCase;
  
  /// 更新产品UseCase
  final UpdateProductUseCase _updateProductUseCase;
  
  /// 保存草稿UseCase
  final SaveProductDraftUseCase _saveProductDraftUseCase;
  
  /// 文件上传仓库
  final IFileUploadRepository _fileUploadRepository;
  
  /// 卖家仓库
  final ISellerRepository _sellerRepository;

  /// 构造函数
  ProductEditBloc(
    this._getSellerProductDetailUseCase,
    this._createProductUseCase,
    this._updateProductUseCase,
    this._saveProductDraftUseCase,
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
    on<RemoveProductImage>(_onRemoveProductImage);
    on<SetMainProductImage>(_onSetMainProductImage);
    on<UploadProductImage>(_onUploadProductImage);
    on<ProductImageUploadSuccess>(_onProductImageUploadSuccess);
    on<ProductImageUploadFailure>(_onProductImageUploadFailure);
    on<SubmitProductForm>(_onSubmitProductForm);
    on<ResetProductForm>(_onResetProductForm);
    on<SaveProductDraft>(_onSaveProductDraft);
    on<CheckForUnsavedChanges>(_onCheckForUnsavedChanges);
    on<SetInitialFormData>(_onSetInitialFormData);
    on<AddSuccessCaseImage>(_onAddSuccessCaseImage);
    on<UpdateSuccessCase>(_onUpdateSuccessCase);
    on<RetrySuccessCaseUpload>(_onRetrySuccessCaseUpload);
    on<RemoveSuccessCase>(_onRemoveSuccessCase);
    on<SuccessCaseUploadSuccess>(_onSuccessCaseUploadSuccess);
    on<SuccessCaseUploadFailure>(_onSuccessCaseUploadFailure);
    on<SuccessCaseUploadProgress>(_onSuccessCaseUploadProgress);
  }

  /// 初始化编辑页面处理
  Future<void> _onInitializeProductEdit(
    InitializeProductEdit event,
    Emitter<ProductEditState> emit,
  ) async {
    print('[ProductEditBloc] InitializeProductEdit called with productId: ${event.productId}');
    
    // 根据是否有productId判断是创建还是编辑模式
    final bool isCreateMode = event.productId == null;
    
    print('[ProductEditBloc] isCreateMode: $isCreateMode');
    
    emit(ProductEditState.initial(isCreateMode: isCreateMode));
    
    // 如果是编辑模式，加载商品数据
    if (!isCreateMode) {
      print('[ProductEditBloc] Loading product data for productId: ${event.productId}');
      add(LoadProductData(productId: event.productId!));
    } else {
      print('[ProductEditBloc] Create mode - not loading existing product data');
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
      (product) {
        final formData = ProductFormData.fromProduct(product);
        
        // 从winImages恢复成功案例
        List<SuccessCase> successCases = [];
        if (product.winImages != null && product.winImages!.isNotEmpty) {
          final winImageList = product.winImages!.split(',').where((img) => img.trim().isNotEmpty).toList();
          for (int i = 0; i < winImageList.length; i++) {
            successCases.add(SuccessCase(
              imagePath: '',
              imageUrl: winImageList[i].trim(),
              title: '',
              description: '',
              uploadStatus: SuccessCaseUploadStatus.completed,
            ));
          }
        }
        
        emit(state.copyWithProductLoaded(product).copyWith(
          successCases: successCases,
        ));
        // 设置初始表单数据用于变更检测
        add(SetInitialFormData(initialData: formData));
      },
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
      case 'qaList':
        updatedFormData = currentFormData.copyWith(qaList: event.value as List<Map<String, String>>);
        break;
      case 'buyerInfoItems':
        updatedFormData = currentFormData.copyWith(buyerInfoItems: event.value as List<Map<String, dynamic>>);
        break;
      case 'successCases':
        updatedFormData = currentFormData.copyWith(successCases: event.value as List<Map<String, dynamic>>);
        break;
      case 'variants':
        updatedFormData = currentFormData.copyWith(variants: event.value as List<ProductOptionValue>);
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
    // 验证图片数量限制
    if (event.imagePaths.length > 9) {
      emit(state.copyWithError('最多只能上传9张图片'));
      return;
    }
    
    // 找出需要上传的新图片（不在已上传列表中的图片）
    final currentSelectedPaths = state.selectedImagePaths;
    final newImagePaths = event.imagePaths.where((path) => !currentSelectedPaths.contains(path)).toList();
    
    // 更新选择的图片路径列表
    emit(state.copyWithSelectedImages(event.imagePaths));
    
    // 如果有新图片需要上传
    if (newImagePaths.isNotEmpty) {
      // 检查当前是否已经在上传中
      final bool isCurrentlyUploading = state.uploadStatus == UploadStatus.uploading;
      
      // 更新上传状态 - 累加新增图片的数量到总计数
      emit(state.copyWith(
        uploadStatus: UploadStatus.uploading,
        totalUploadCount: state.totalUploadCount + newImagePaths.length, // 累加新图片数量
      ));
      
      // 开始上传第一张新图片
      final firstImagePath = newImagePaths.first;
      final remainingPaths = newImagePaths.length > 1 
          ? newImagePaths.sublist(1) 
          : <String>[];
      
      add(UploadProductImage(
        imagePath: firstImagePath,
        isDetailImage: false,
        remainingPaths: remainingPaths,
      ));
    } else {
      // 没有新图片需要上传
      // 如果当前没有在上传，标记为成功状态
      if (state.uploadStatus != UploadStatus.uploading) {
        emit(state.copyWith(
          uploadStatus: UploadStatus.success,
        ));
      }
      // 如果正在上传，保持当前状态不变
    }
  }

  /// 选择商品详情图片处理
  void _onSelectDetailProductImages(
    SelectDetailProductImages event,
    Emitter<ProductEditState> emit,
  ) {
    // 验证图片数量限制
    if (event.imagePaths.length > 9) {
      emit(state.copyWithError('最多只能上传9张详情图片'));
      return;
    }
    
    // 找出需要上传的新详情图片
    final currentSelectedDetailPaths = state.selectedDetailImagePaths;
    final newDetailImagePaths = event.imagePaths.where((path) => !currentSelectedDetailPaths.contains(path)).toList();
    
    // 更新选择的详情图片路径列表
    emit(state.copyWithSelectedDetailImages(event.imagePaths));
    
    // 如果有新详情图片需要上传
    if (newDetailImagePaths.isNotEmpty) {
      // 检查当前是否已经在上传中
      final bool isCurrentlyUploading = state.uploadStatus == UploadStatus.uploading;
      
      // 更新上传状态 - 累加新增图片的数量到总计数
      emit(state.copyWith(
        uploadStatus: UploadStatus.uploading,
        totalUploadCount: state.totalUploadCount + newDetailImagePaths.length, // 累加新图片数量
      ));
      
      // 开始上传第一张新详情图片
      final firstImagePath = newDetailImagePaths.first;
      final remainingPaths = newDetailImagePaths.length > 1 
          ? newDetailImagePaths.sublist(1) 
          : <String>[];
      
      add(UploadProductImage(
        imagePath: firstImagePath,
        isDetailImage: true,
        remainingPaths: remainingPaths,
      ));
    } else {
      // 没有新详情图片需要上传
      // 如果当前没有在上传，标记为成功状态
      if (state.uploadStatus != UploadStatus.uploading) {
        emit(state.copyWith(
          uploadStatus: UploadStatus.success,
        ));
      }
      // 如果正在上传，保持当前状态不变
    }
  }

  /// 删除图片处理（不触发重新上传）
  void _onRemoveProductImage(
    RemoveProductImage event,
    Emitter<ProductEditState> emit,
  ) {
    if (event.isDetailImage) {
      // 删除详情图片
      final currentPaths = List<String>.from(state.selectedDetailImagePaths);
      if (event.index < currentPaths.length) {
        currentPaths.removeAt(event.index);
        
        // 同时需要删除对应的已上传URL
        final currentUrls = List<String>.from(state.uploadedDetailImageUrls);
        if (event.index < currentUrls.length) {
          currentUrls.removeAt(event.index);
        }
        
        emit(state.copyWith(
          selectedDetailImagePaths: currentPaths,
          uploadedDetailImageUrls: currentUrls,
          uploadedCount: math.max(0, state.uploadedCount - 1), // 减少已上传计数
          totalUploadCount: math.max(0, state.totalUploadCount - 1), // 减少总计数
        ));
      }
    } else {
      // 删除主图片
      final currentPaths = List<String>.from(state.selectedImagePaths);
      if (event.index < currentPaths.length) {
        currentPaths.removeAt(event.index);
        
        // 同时需要删除对应的已上传URL
        final currentUrls = List<String>.from(state.uploadedImageUrls);
        if (event.index < currentUrls.length) {
          currentUrls.removeAt(event.index);
        }
        
        emit(state.copyWith(
          selectedImagePaths: currentPaths,
          uploadedImageUrls: currentUrls,
          uploadedCount: math.max(0, state.uploadedCount - 1), // 减少已上传计数
          totalUploadCount: math.max(0, state.totalUploadCount - 1), // 减少总计数
        ));
      }
    }
  }

  /// 设置主图处理
  void _onSetMainProductImage(
    SetMainProductImage event,
    Emitter<ProductEditState> emit,
  ) {
    if (event.isDetailImage) {
      // 设置详情图片的主图（重新排序）
      final currentPaths = List<String>.from(state.selectedDetailImagePaths);
      final currentUrls = List<String>.from(state.uploadedDetailImageUrls);
      
      if (event.index < currentPaths.length && event.index > 0) {
        // 将选中的图片移动到第一位
        final selectedPath = currentPaths.removeAt(event.index);
        currentPaths.insert(0, selectedPath);
        
        // 同步URL列表
        if (event.index < currentUrls.length) {
          final selectedUrl = currentUrls.removeAt(event.index);
          currentUrls.insert(0, selectedUrl);
        }
        
        emit(state.copyWith(
          selectedDetailImagePaths: currentPaths,
          uploadedDetailImageUrls: currentUrls,
        ));
      }
    } else {
      // 设置主图片的主图（重新排序）
      final currentPaths = List<String>.from(state.selectedImagePaths);
      final currentUrls = List<String>.from(state.uploadedImageUrls);
      
      if (event.index < currentPaths.length && event.index > 0) {
        // 将选中的图片移动到第一位
        final selectedPath = currentPaths.removeAt(event.index);
        currentPaths.insert(0, selectedPath);
        
        // 同步URL列表
        if (event.index < currentUrls.length) {
          final selectedUrl = currentUrls.removeAt(event.index);
          currentUrls.insert(0, selectedUrl);
        }
        
        emit(state.copyWith(
          selectedImagePaths: currentPaths,
          uploadedImageUrls: currentUrls,
        ));
      }
    }
  }
  
  /// 处理图片，包括格式转换和压缩
  /// 返回处理后的图片路径
  /// 公开此方法以供外部调用（如成功案例图片上传）
  Future<String> preprocessImage(String imagePath) async {
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
      
      // 处理HEIC、HEIF、WebP格式或大于目标大小的图片
      // 注意：WebP格式需要转换，因为后端不支持
      bool needProcess = extension == '.heic' || 
                        extension == '.heif' || 
                        extension == '.webp' ||  // 添加webp格式处理
                        fileSize > targetSize;
      
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
      final String processedPath = await preprocessImage(originalPath);
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
    
    // 从选择的路径列表中移除已上传的图片路径
    List<String> updatedSelectedPaths = List.from(state.selectedImagePaths);
    List<String> updatedSelectedDetailPaths = List.from(state.selectedDetailImagePaths);
    
    if (event.isDetailImage) {
      updatedDetailUrls.add(event.imageUrl);
      // 移除已上传的本地路径
      updatedSelectedDetailPaths.remove(event.imagePath);
    } else {
      updatedMainUrls.add(event.imageUrl);
      // 移除已上传的本地路径
      updatedSelectedPaths.remove(event.imagePath);
    }
    
    // 检查是否全部上传完成
    final bool allDone = newCount >= state.totalUploadCount;
    
    // 如果全部上传完成，清空所有本地路径
    if (allDone) {
      updatedSelectedPaths.clear();
      updatedSelectedDetailPaths.clear();
    }
    
    // 更新状态
    emit(state.copyWith(
      uploadedCount: newCount,
      uploadStatus: allDone ? UploadStatus.success : UploadStatus.uploading,
      uploadedImageUrls: updatedMainUrls,
      uploadedDetailImageUrls: updatedDetailUrls,
      selectedImagePaths: updatedSelectedPaths,
      selectedDetailImagePaths: updatedSelectedDetailPaths,
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
    bool hasImages = state.selectedImagePaths.isNotEmpty || 
                     state.uploadedImageUrls.isNotEmpty || 
                     (state.product?.images.isNotEmpty ?? false);
    
    if (!hasImages) {
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
    
    // 转换qaList和buyerInfoItems为productMaterials
    final List<ProductMaterial> materials = [];
    
    // 转换qaList为PROBLEM类型的materials
    if (state.formData.qaList.isNotEmpty) {
      int materialId = 1;
      for (final qa in state.formData.qaList) {
        materials.add(ProductMaterial(
          id: materialId++,
          question: qa['question'] ?? '',
          answer: qa['answer'] ?? '',
          type: 'PROBLEM',
        ));
      }
    }
    
    // 转换buyerInfoItems为ATTACHMENT或TEXT类型的materials
    if (state.formData.buyerInfoItems.isNotEmpty) {
      int materialId = 1000; // 从1000开始，避免与QA的ID冲突
      for (final item in state.formData.buyerInfoItems) {
        final type = item['type'] ?? 'text';
        String materialType = 'TEXT';
        if (type == 'file' || type == 'image') {
          materialType = 'ATTACHMENT';
        }
        
        materials.add(ProductMaterial(
          id: materialId++,
          question: item['label'] ?? '',
          answer: item['description'],
          type: materialType,
        ));
      }
    }
    
    // 处理成功案例图片 - 使用新的successCases状态
    List<String> winImageUrls = [];
    if (state.successCases.isNotEmpty) {
      for (final successCase in state.successCases) {
        // 只使用已上传完成的imageUrl
        if (successCase.isCompleted && successCase.imageUrl.isNotEmpty) {
          // 避免重复添加
          if (!winImageUrls.contains(successCase.imageUrl)) {
            winImageUrls.add(successCase.imageUrl);
          }
        } else if (successCase.uploadStatus == SuccessCaseUploadStatus.uploading) {
          print('警告：提交表单时发现成功案例正在上传中');
        } else if (successCase.uploadStatus == SuccessCaseUploadStatus.failed) {
          print('警告：提交表单时发现成功案例上传失败');
        }
      }
    }
    
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
          productMaterials: materials, // 使用转换后的materials
          winImages: winImageUrls.isNotEmpty ? winImageUrls.join(',') : null, // 添加成功案例图片
          detailImages: state.uploadedDetailImageUrls.isNotEmpty ? state.uploadedDetailImageUrls.join(',') : null,
          detailContent: state.formData.detailContent.isNotEmpty ? state.formData.detailContent : null,
          productType: 'product', // 明确设置为正式商品，不是草稿
          state: 'normal', // 设置为上架状态
          statusAudit: 'SUCCESS', // 设置为审核通过，直接发布
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
          productMaterials: materials, // 使用转换后的materials
          winImages: winImageUrls.isNotEmpty ? winImageUrls.join(',') : null, // 添加成功案例图片
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

  /// 设置初始表单数据
  void _onSetInitialFormData(
    SetInitialFormData event,
    Emitter<ProductEditState> emit,
  ) {
    emit(state.copyWithInitialData(event.initialData));
  }

  /// 检查未保存变更
  void _onCheckForUnsavedChanges(
    CheckForUnsavedChanges event,
    Emitter<ProductEditState> emit,
  ) {
    // hasUnsavedChanges会在copyWith中自动计算
    emit(state.copyWith());
  }

  /// 保存草稿处理
  Future<void> _onSaveProductDraft(
    SaveProductDraft event,
    Emitter<ProductEditState> emit,
  ) async {
    emit(state.copyWithSavingDraft());
    
    try {
      // 获取已上传的图片URL，使用Set去重
      Set<String> finalImageUrlsSet = Set.from(state.uploadedImageUrls);
      Set<String> finalDetailUrlsSet = Set.from(state.uploadedDetailImageUrls);
      
      // 只处理尚未上传的本地图片
      // 如果selectedImagePaths不为空，说明有未上传的本地图片
      if (state.selectedImagePaths.isNotEmpty) {
        print('警告：保存草稿时发现未上传的本地图片，数量：${state.selectedImagePaths.length}');
        
        // 可以选择：1. 触发上传流程 2. 忽略未上传的图片
        // 这里选择忽略，因为正常流程中图片应该已经上传完成
        // 如果需要上传，应该在保存草稿前完成
      }
      
      // 同样处理详情图
      if (state.selectedDetailImagePaths.isNotEmpty) {
        print('警告：保存草稿时发现未上传的详情图片，数量：${state.selectedDetailImagePaths.length}');
      }
      
      // 转换qaList和buyerInfoItems为productMaterials
      final List<ProductMaterial> materials = [];
      
      // 转换qaList为PROBLEM类型的materials
      if (state.formData.qaList.isNotEmpty) {
        int materialId = 1;
        for (final qa in state.formData.qaList) {
          materials.add(ProductMaterial(
            id: materialId++,
            question: qa['question'] ?? '',
            answer: qa['answer'] ?? '',
            type: 'PROBLEM',
          ));
        }
      }
      
      // 转换buyerInfoItems为ATTACHMENT或TEXT类型的materials
      if (state.formData.buyerInfoItems.isNotEmpty) {
        int materialId = 1000; // 从1000开始，避免与QA的ID冲突
        for (final item in state.formData.buyerInfoItems) {
          final type = item['type'] ?? 'text';
          String materialType = 'TEXT';
          if (type == 'file' || type == 'image') {
            materialType = 'ATTACHMENT';
          }
          
          materials.add(ProductMaterial(
            id: materialId++,
            question: item['label'] ?? '',
            answer: item['description'] ?? '',
            type: materialType,
          ));
        }
      }
      
      // 处理成功案例图片 - 使用新的successCases状态
      List<String> winImageUrls = [];
      List<Map<String, dynamic>> updatedSuccessCases = [];
      
      print('[DEBUG] 保存草稿 - 处理成功案例，数量: ${state.successCases.length}');
      
      if (state.successCases.isNotEmpty) {
        for (final successCase in state.successCases) {
          print('[DEBUG] 成功案例 ${successCase.id}: status=${successCase.uploadStatus.name}, imageUrl=${successCase.imageUrl}');
          
          // 转换为Map用于保存
          final caseMap = successCase.toJson();
          updatedSuccessCases.add(caseMap);
          
          // 只收集已上传完成的imageUrl
          if (successCase.isCompleted && successCase.imageUrl.isNotEmpty) {
            print('[DEBUG] 找到有效的imageUrl: ${successCase.imageUrl}');
            // 避免重复添加相同的URL
            if (!winImageUrls.contains(successCase.imageUrl)) {
              winImageUrls.add(successCase.imageUrl);
            }
          } else if (successCase.uploadStatus == SuccessCaseUploadStatus.uploading) {
            print('[DEBUG] 成功案例 ${successCase.id} 正在上传中');
          } else if (successCase.uploadStatus == SuccessCaseUploadStatus.failed) {
            print('[DEBUG] 成功案例 ${successCase.id} 上传失败: ${successCase.errorMessage}');
          }
        }
        
        // 更新formData中的successCases以保持同步
        if (updatedSuccessCases.isNotEmpty) {
          emit(state.copyWith(
            formData: state.formData.copyWith(
              successCases: updatedSuccessCases,
            ),
          ));
        }
      }
      
      // 创建草稿参数 - 使用新的可选参数构造方式
      print('[DEBUG] 创建SaveProductDraftParams，winImageUrls数量: ${winImageUrls.length}');
      print('[DEBUG] winImageUrls内容: $winImageUrls');
      
      final params = SaveProductDraftParams(
        name: state.formData.name,
        description: state.formData.description,
        price: state.formData.price,
        imageUrls: finalImageUrlsSet.toList(),
        detailImageUrls: finalDetailUrlsSet.toList(),
        winImageUrls: winImageUrls,
        categoryId: state.formData.categoryId,
        variants: state.formData.variants,
        productMaterials: materials, // 使用转换后的materials
        productId: state.product?.id,
      );
      
      print('[DEBUG] 调用保存草稿UseCase...');
      final result = await _saveProductDraftUseCase(params);
      
      result.fold(
        (failure) => emit(state.copyWithError(failure.message)),
        (success) {
          // 只有手动保存才设置isDraftSaveSuccess，避免自动保存触发页面退出
          if (!event.isAutoSave) {
            // 手动保存：设置成功标志，触发页面返回
            emit(state.copyWithDraftSaveSuccess().copyWith(
              selectedImagePaths: [],
              selectedDetailImagePaths: [],
            ));
          } else {
            // 自动保存：只更新状态，不设置成功标志
            emit(state.copyWith(
              isSavingDraft: false,
              hasUnsavedChanges: false,
              selectedImagePaths: [],
              selectedDetailImagePaths: [],
            ));
          }
          // 更新初始数据为当前数据，这样再次编辑时不会误判为有变更
          add(SetInitialFormData(initialData: state.formData));
        },
      );
      
    } catch (e) {
      emit(state.copyWithError('保存草稿失败: ${e.toString()}'));
    }
  }

  /// 添加成功案例图片处理
  Future<void> _onAddSuccessCaseImage(
    AddSuccessCaseImage event,
    Emitter<ProductEditState> emit,
  ) async {
    try {
      // 创建新的成功案例
      final newCase = SuccessCase(
        imagePath: event.imagePath,
        title: event.title,
        description: event.description,
        uploadStatus: SuccessCaseUploadStatus.pending,
      );

      // 更新状态，添加新案例
      final updatedCases = List<SuccessCase>.from(state.successCases)..add(newCase);
      emit(state.copyWith(successCases: updatedCases));

      // 立即开始上传图片
      await _uploadSuccessCaseImage(newCase, emit);

      // 触发自动保存（防抖处理）
      _scheduleAutoSave();
    } catch (e) {
      print('[ProductEditBloc] Error adding success case: $e');
      emit(state.copyWithError('添加成功案例失败: ${e.toString()}'));
    }
  }

  /// 更新成功案例处理
  Future<void> _onUpdateSuccessCase(
    UpdateSuccessCase event,
    Emitter<ProductEditState> emit,
  ) async {
    try {
      final updatedCases = state.successCases.map((case_) {
        if (case_.id == event.caseId) {
          var updatedCase = case_;
          
          // 更新标题和描述
          if (event.title != null) {
            updatedCase = updatedCase.copyWith(title: event.title);
          }
          if (event.description != null) {
            updatedCase = updatedCase.copyWith(description: event.description);
          }
          
          // 如果更换了图片，需要重新上传
          if (event.imagePath != null && event.imagePath != case_.imagePath) {
            updatedCase = updatedCase.copyWith(
              imagePath: event.imagePath!,
              imageUrl: '', // 清空旧的URL
              uploadStatus: SuccessCaseUploadStatus.pending,
              errorMessage: null,
            );
            
            // 异步上传新图片
            _uploadSuccessCaseImage(updatedCase, emit);
          }
          
          return updatedCase;
        }
        return case_;
      }).toList();

      emit(state.copyWith(successCases: updatedCases));
      
      // 触发自动保存
      _scheduleAutoSave();
    } catch (e) {
      print('[ProductEditBloc] Error updating success case: $e');
      emit(state.copyWithError('更新成功案例失败: ${e.toString()}'));
    }
  }

  /// 重试成功案例上传处理
  Future<void> _onRetrySuccessCaseUpload(
    RetrySuccessCaseUpload event,
    Emitter<ProductEditState> emit,
  ) async {
    try {
      final caseToRetry = state.successCases.firstWhere(
        (case_) => case_.id == event.caseId,
      );

      if (caseToRetry.canRetry) {
        // 更新状态为待上传
        final updatedCases = state.successCases.map((case_) {
          if (case_.id == event.caseId) {
            return case_.copyWith(
              uploadStatus: SuccessCaseUploadStatus.pending,
              errorMessage: null,
            );
          }
          return case_;
        }).toList();

        emit(state.copyWith(successCases: updatedCases));

        // 重新尝试上传
        await _uploadSuccessCaseImage(caseToRetry, emit);
      }
    } catch (e) {
      print('[ProductEditBloc] Error retrying success case upload: $e');
      emit(state.copyWithError('重试上传失败: ${e.toString()}'));
    }
  }

  /// 移除成功案例处理
  Future<void> _onRemoveSuccessCase(
    RemoveSuccessCase event,
    Emitter<ProductEditState> emit,
  ) async {
    try {
      final updatedCases = state.successCases
          .where((case_) => case_.id != event.caseId)
          .toList();
      
      emit(state.copyWith(successCases: updatedCases));
      
      // 触发自动保存
      _scheduleAutoSave();
    } catch (e) {
      print('[ProductEditBloc] Error removing success case: $e');
      emit(state.copyWithError('移除成功案例失败: ${e.toString()}'));
    }
  }

  /// 成功案例上传成功处理
  Future<void> _onSuccessCaseUploadSuccess(
    SuccessCaseUploadSuccess event,
    Emitter<ProductEditState> emit,
  ) async {
    final updatedCases = state.successCases.map((case_) {
      if (case_.id == event.caseId) {
        return case_.copyWith(
          imageUrl: event.imageUrl,
          uploadStatus: SuccessCaseUploadStatus.completed,
          uploadProgress: 100,
          errorMessage: null,
        );
      }
      return case_;
    }).toList();

    emit(state.copyWith(successCases: updatedCases));
    
    // 触发自动保存
    _scheduleAutoSave();
  }

  /// 成功案例上传失败处理
  Future<void> _onSuccessCaseUploadFailure(
    SuccessCaseUploadFailure event,
    Emitter<ProductEditState> emit,
  ) async {
    final updatedCases = state.successCases.map((case_) {
      if (case_.id == event.caseId) {
        return case_.copyWith(
          uploadStatus: SuccessCaseUploadStatus.failed,
          errorMessage: event.errorMessage,
          uploadProgress: 0,
        );
      }
      return case_;
    }).toList();

    emit(state.copyWith(successCases: updatedCases));
  }

  /// 成功案例上传进度更新处理
  Future<void> _onSuccessCaseUploadProgress(
    SuccessCaseUploadProgress event,
    Emitter<ProductEditState> emit,
  ) async {
    final updatedCases = state.successCases.map((case_) {
      if (case_.id == event.caseId) {
        return case_.copyWith(
          uploadStatus: SuccessCaseUploadStatus.uploading,
          uploadProgress: event.progress,
        );
      }
      return case_;
    }).toList();

    emit(state.copyWith(successCases: updatedCases));
  }

  /// 上传成功案例图片
  Future<void> _uploadSuccessCaseImage(
    SuccessCase successCase,
    Emitter<ProductEditState> emit,
  ) async {
    try {
      // 更新状态为上传中
      add(SuccessCaseUploadProgress(
        caseId: successCase.id,
        progress: 0,
      ));

      // 预处理图片
      final processedPath = await preprocessImage(successCase.imagePath);
      
      // 模拟进度更新
      add(SuccessCaseUploadProgress(
        caseId: successCase.id,
        progress: 30,
      ));

      // 上传图片
      final uploadResult = await _fileUploadRepository.uploadFile(
        File(processedPath)
      );

      // 更新进度
      add(SuccessCaseUploadProgress(
        caseId: successCase.id,
        progress: 80,
      ));

      uploadResult.fold(
        (failure) {
          // 上传失败
          add(SuccessCaseUploadFailure(
            caseId: successCase.id,
            errorMessage: failure.message,
          ));
        },
        (imageUrl) {
          // 上传成功
          add(SuccessCaseUploadSuccess(
            caseId: successCase.id,
            imageUrl: imageUrl,
          ));
        },
      );
    } catch (e) {
      print('[ProductEditBloc] Error uploading success case image: $e');
      add(SuccessCaseUploadFailure(
        caseId: successCase.id,
        errorMessage: e.toString(),
      ));
    }
  }

  // 自动保存定时器
  Timer? _autoSaveTimer;

  /// 调度自动保存（防抖处理）
  void _scheduleAutoSave() {
    // 取消之前的定时器
    _autoSaveTimer?.cancel();
    
    // 设置新的定时器，2秒后触发保存
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      // 检查是否有需要保存的变更
      if (state.hasUnsavedChanges && !state.isSavingDraft) {
        add(const SaveProductDraft(isAutoSave: true));
      }
    });
  }

  @override
  Future<void> close() {
    _autoSaveTimer?.cancel();
    return super.close();
  }
} 