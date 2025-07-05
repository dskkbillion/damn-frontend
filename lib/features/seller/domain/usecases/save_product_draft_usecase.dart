import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

/// 保存草稿参数
class SaveProductDraftParams extends Equatable {
  /// 商品名称
  final String name;
  
  /// 商品描述
  final String description;
  
  /// 基础价格
  final double price;
  
  /// 分类ID（可选）
  final int? categoryId;
  
  /// 规格选项（可选）
  final List<ProductOptionValue>? variants;
  
  /// 自定义材料问题（可选）
  final List<ProductMaterial>? productMaterials;
  
  /// 已上传的图片URL列表
  final List<String> imageUrls;
  
  /// 已上传的详情图URL列表
  final List<String> detailImageUrls;
  
  /// 商品ID（编辑草稿时使用）
  final int? productId;

  const SaveProductDraftParams({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrls,
    this.detailImageUrls = const [],
    this.categoryId,
    this.variants,
    this.productMaterials,
    this.productId,
  });

  @override
  List<Object?> get props => [
    name, description, price, imageUrls, detailImageUrls,
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
        images: params.imageUrls.join(','),
        categoryId: params.categoryId,
        variants: params.variants,
        productMaterials: params.productMaterials,
        detailImages: params.detailImageUrls.isNotEmpty 
            ? params.detailImageUrls.join(',') 
            : null,
      );
      
      return _sellerRepository.updateProduct(updateData);
    } else {
      // 创建新草稿
      final creationData = ProductCreationData(
        name: params.name,
        description: params.description,
        price: params.price,
        images: params.imageUrls.join(','),
        categoryId: params.categoryId,
        variants: params.variants,
        productMaterials: params.productMaterials,
        detailImages: params.detailImageUrls.isNotEmpty 
            ? params.detailImageUrls.join(',') 
            : null,
        productType: 'draft', // 标记为草稿
      );
      
      return _sellerRepository.createProduct(creationData);
    }
  }
} 