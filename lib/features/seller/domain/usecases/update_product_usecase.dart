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
  
  /// 待上传的商品主图本地路径列表（可选）
  final List<String>? imageFilePaths;
  
  /// 待上传的商品详情图本地路径列表（可选）
  final List<String>? detailImageFilePaths;
  
  /// 详情内容HTML（可选）
  final String? detailContent;

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
    this.detailImageFilePaths,
    this.detailContent,
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
    imageFilePaths,
    detailImageFilePaths,
    detailContent,
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
      detailContent: params.detailContent,
    );
    
    // 收集需要上传的所有图片
    final allImagePaths = <Map<String, dynamic>>[];
    
    // 添加主图路径
    if (params.imageFilePaths != null && params.imageFilePaths!.isNotEmpty) {
      for (final path in params.imageFilePaths!) {
        allImagePaths.add({
          'path': path,
          'type': 'main', // 主图
        });
      }
    }
    
    // 添加详情图路径
    if (params.detailImageFilePaths != null && params.detailImageFilePaths!.isNotEmpty) {
      for (final path in params.detailImageFilePaths!) {
        allImagePaths.add({
          'path': path,
          'type': 'detail', // 详情图
        });
      }
    }
    
    // 如果有图片需要上传
    if (allImagePaths.isNotEmpty) {
      final uploadedMainUrls = <String>[];
      final uploadedDetailUrls = <String>[];
      
      // 逐个上传所有图片
      for (final imageData in allImagePaths) {
        final path = imageData['path'] as String;
        final type = imageData['type'] as String;
        
        final file = File(path);
        
        // 短暂延迟，避免连续请求导致服务器压力过大
        if (allImagePaths.indexOf(imageData) > 0) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
        
        final uploadResult = await _fileUploadRepository.uploadFile(file);
        
        // 如果有一个图片上传失败，则返回失败
        if (uploadResult.isLeft()) {
          return uploadResult.fold(
            (failure) => Left(failure),
            (_) => throw Exception("Unexpected state"),
          );
        }
        
        // 根据图片类型，添加到相应的URL列表
        uploadResult.fold(
          (_) => throw Exception("Unexpected state"),
          (url) {
            if (type == 'main') {
              uploadedMainUrls.add(url);
            } else {
              uploadedDetailUrls.add(url);
            }
          },
        );
      }
      
      // 根据上传结果更新产品数据
      if (uploadedMainUrls.isNotEmpty) {
        final imagesString = uploadedMainUrls.join(',');
        productData = productData.copyWith(images: imagesString);
      }
      
      if (uploadedDetailUrls.isNotEmpty) {
        final detailImagesString = uploadedDetailUrls.join(',');
        productData = productData.copyWith(detailImages: detailImagesString);
      }
    }
    
    // 更新商品
    return _sellerRepository.updateProduct(productData);
  }
} 