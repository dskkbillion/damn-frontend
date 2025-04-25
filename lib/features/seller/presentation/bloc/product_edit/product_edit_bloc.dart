import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/create_product_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_product_detail_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/update_product_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_edit/product_edit_event.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_edit/product_edit_state.dart';
import 'package:injectable/injectable.dart';

/// 产品编辑BLoC
@injectable
class ProductEditBloc extends Bloc<ProductEditEvent, ProductEditState> {
  /// 获取产品详情UseCase
  final GetSellerProductDetailUseCase _getSellerProductDetailUseCase;
  
  /// 创建产品UseCase
  final CreateProductUseCase _createProductUseCase;
  
  /// 更新产品UseCase
  final UpdateProductUseCase _updateProductUseCase;

  /// 构造函数
  ProductEditBloc(
    this._getSellerProductDetailUseCase,
    this._createProductUseCase,
    this._updateProductUseCase,
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
    emit(state.copyWithSelectedImages(event.imagePaths));
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
    if (state.selectedImagePaths.isEmpty && (state.product?.images.isEmpty ?? true)) {
      emit(state.copyWithError('请至少上传一张商品图片'));
      return;
    }
    
    emit(state.copyWithSubmitting());
    
    if (state.isCreateMode) {
      // 创建商品
      final params = CreateProductParams(
        name: state.formData.name,
        description: state.formData.description,
        price: state.formData.price,
        imageFilePaths: state.selectedImagePaths,
        categoryId: state.formData.categoryId,
        variants: state.formData.variants.isNotEmpty ? state.formData.variants : null,
        productMaterials: state.formData.productMaterials.isNotEmpty ? state.formData.productMaterials : null,
      );
      
      final result = await _createProductUseCase(params);
      
      result.fold(
        (failure) => emit(state.copyWithError(failure.message)),
        (success) {
          if (success) {
            emit(state.copyWithSubmitSuccess());
          } else {
            emit(state.copyWithError('创建商品失败'));
          }
        },
      );
    } else {
      // 更新商品
      if (state.product == null) {
        emit(state.copyWithError('无法获取要更新的商品数据'));
        return;
      }
      
      final params = UpdateProductParams(
        id: state.product!.id,
        name: state.formData.name,
        description: state.formData.description,
        price: state.formData.price,
        imageFilePaths: state.selectedImagePaths.isNotEmpty ? state.selectedImagePaths : null,
        categoryId: state.formData.categoryId,
        variants: state.formData.variants.isNotEmpty ? state.formData.variants : null,
        productMaterials: state.formData.productMaterials.isNotEmpty ? state.formData.productMaterials : null,
      );
      
      final result = await _updateProductUseCase(params);
      
      result.fold(
        (failure) => emit(state.copyWithError(failure.message)),
        (success) {
          if (success) {
            emit(state.copyWithSubmitSuccess());
          } else {
            emit(state.copyWithError('更新商品失败'));
          }
        },
      );
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