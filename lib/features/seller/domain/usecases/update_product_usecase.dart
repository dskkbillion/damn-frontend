import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/repositories/i_file_upload_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

/// 更新商品参数
class UpdateProductParams extends Equatable {
  /// 商品ID
  final int id;
  
  /// 商品名称（可选）
  final String? name;
  
  /// 商品描述（可选）
  final String? description;
  
  /// 基础价格（可选）
  final double? price;
  
  /// 商品状态（可选）
  final String? state;
  
  /// 分类ID（可选）
  final int? categoryId;
  
  /// 规格选项（可选）
  final List<ProductOptionValue>? variants;
  
  /// 自定义材料问题（可选）
  final List<ProductMaterial>? productMaterials;
  
  /// 待上传的商品图片本地路径列表（可选）
  final List<String>? imageFilePaths;

  /// 构造函数
  const UpdateProductParams({
    required this.id,
    this.name,
    this.description,
    this.price,
    this.state,
    this.categoryId,
    this.variants,
    this.productMaterials,
    this.imageFilePaths,
  });

  @override
  List<Object?> get props => [
    id,
    name, 
    description, 
    price,
    state,
    categoryId, 
    variants, 
    productMaterials,
    imageFilePaths
  ];
}

/// 更新商品UseCase
@injectable
class UpdateProductUseCase implements UseCase<bool, UpdateProductParams> {
  final ISellerRepository _sellerRepository;
  final IFileUploadRepository _fileUploadRepository;

  /// 构造函数
  UpdateProductUseCase(
    this._sellerRepository,
    this._fileUploadRepository,
  );

  @override
  Future<Either<Failure, bool>> call(UpdateProductParams params) async {
    // 定义产品更新数据
    ProductUpdateData productData = ProductUpdateData(
      id: params.id,
      name: params.name,
      description: params.description,
      price: params.price,
      state: params.state,
      categoryId: params.categoryId,
      variants: params.variants,
      productMaterials: params.productMaterials,
    );
    
    // 如果需要更新商品图片
    if (params.imageFilePaths != null && params.imageFilePaths!.isNotEmpty) {
      final uploadedUrls = <String>[];
      
      // 逐个上传图片
      for (final path in params.imageFilePaths!) {
        final file = File(path);
        final uploadResult = await _fileUploadRepository.uploadFile(file);
        
        // 如果有一个图片上传失败，则返回失败
        if (uploadResult.isLeft()) {
          return uploadResult.fold(
            (failure) => Left(failure),
            (_) => throw Exception("Unexpected state"), // 这行永远不会执行，但需要满足类型要求
          );
        }
        
        // 添加上传成功的URL
        uploadResult.fold(
          (_) => throw Exception("Unexpected state"), // 这行永远不会执行，但需要满足类型要求
          (url) => uploadedUrls.add(url),
        );
      }
      
      // 设置商品图片URL
      final imagesString = uploadedUrls.join(',');
      productData = ProductUpdateData(
        id: productData.id,
        name: productData.name,
        description: productData.description,
        price: productData.price,
        state: productData.state,
        categoryId: productData.categoryId,
        variants: productData.variants,
        productMaterials: productData.productMaterials,
        images: imagesString,
      );
    }
    
    // 更新商品
    return _sellerRepository.updateProduct(productData);
  }
} 