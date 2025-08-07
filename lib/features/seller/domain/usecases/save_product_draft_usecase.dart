import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

/// 保存草稿参数
class SaveProductDraftParams extends Equatable {
  /// 商品名称（草稿允许为空）
  final String name;
  
  /// 商品描述（草稿允许为空）
  final String description;
  
  /// 基础价格（草稿允许为0）
  final double price;
  
  /// 分类ID（可选）
  final int? categoryId;
  
  /// 规格选项（可选）
  final List<ProductOptionValue>? variants;
  
  /// 自定义材料问题（可选）
  final List<ProductMaterial>? productMaterials;
  
  /// 已上传的图片URL列表（草稿允许为空）
  final List<String> imageUrls;
  
  /// 已上传的详情图URL列表
  final List<String> detailImageUrls;
  
  /// 成功案例图片URL列表
  final List<String> winImageUrls;
  
  /// 商品ID（编辑草稿时使用）
  final int? productId;

  const SaveProductDraftParams({
    this.name = '',
    this.description = '',
    this.price = 0,
    this.imageUrls = const [],
    this.detailImageUrls = const [],
    this.winImageUrls = const [],
    this.categoryId,
    this.variants,
    this.productMaterials,
    this.productId,
  });

  @override
  List<Object?> get props => [
    name, description, price, imageUrls, detailImageUrls, winImageUrls,
    categoryId, variants, productMaterials, productId,
  ];
}

/// 保存商品草稿UseCase
@injectable
class SaveProductDraftUseCase implements UseCase<bool, SaveProductDraftParams> {
  final ISellerRepository _sellerRepository;

  SaveProductDraftUseCase(this._sellerRepository);

  @override
  Future<Either<Failure, bool>> call(SaveProductDraftParams params) async {
    if (params.productId != null) {
      // 更新现有草稿
      final updateData = ProductUpdateData(
        id: params.productId!,
        name: params.name,
        description: params.description,
        price: params.price,
        images: params.imageUrls.isNotEmpty ? params.imageUrls.join(',') : null,
        categoryId: params.categoryId,
        variants: params.variants,
        productMaterials: params.productMaterials,
        detailImages: params.detailImageUrls.isNotEmpty 
            ? params.detailImageUrls.join(',') 
            : null,
        winImages: params.winImageUrls.isNotEmpty 
            ? params.winImageUrls.join(',') 
            : null,
      );
      
      return _sellerRepository.updateProduct(updateData);
    } else {
      // 创建新草稿 - 允许图片为空
      final creationData = ProductCreationData(
        name: params.name,
        description: params.description,
        price: params.price,
        images: params.imageUrls.isNotEmpty ? params.imageUrls.join(',') : '', // 草稿允许空图片
        categoryId: params.categoryId,
        variants: params.variants,
        productMaterials: params.productMaterials,
        detailImages: params.detailImageUrls.isNotEmpty 
            ? params.detailImageUrls.join(',') 
            : null,
        winImages: params.winImageUrls.isNotEmpty 
            ? params.winImageUrls.join(',') 
            : null,
        productType: 'draft', // 标记为草稿
      );
      
      return _sellerRepository.createProduct(creationData);
    }
  }
} 