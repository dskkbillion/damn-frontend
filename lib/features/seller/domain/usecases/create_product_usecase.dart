import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/repositories/i_file_upload_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

/// 创建商品参数
class CreateProductParams extends Equatable {
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
  
  /// 待上传的商品图片本地路径列表
  final List<String> imageFilePaths;

  /// 构造函数
  const CreateProductParams({
    required this.name,
    required this.description,
    required this.price,
    required this.imageFilePaths,
    this.categoryId,
    this.variants,
    this.productMaterials,
  });

  @override
  List<Object?> get props => [
    name, 
    description, 
    price, 
    imageFilePaths, 
    categoryId, 
    variants, 
    productMaterials
  ];
}

/// 创建商品UseCase
@injectable
class CreateProductUseCase implements UseCase<bool, CreateProductParams> {
  final ISellerRepository _sellerRepository;
  final IFileUploadRepository _fileUploadRepository;

  /// 构造函数
  CreateProductUseCase(
    this._sellerRepository,
    this._fileUploadRepository,
  );

  @override
  Future<Either<Failure, bool>> call(CreateProductParams params) async {
    // 先上传商品图片
    if (params.imageFilePaths.isNotEmpty) {
      final uploadedUrls = <String>[];
      
      // 逐个上传图片
      for (final path in params.imageFilePaths) {
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
      
      // 构建商品创建数据，包含上传的图片URL
      final productData = ProductCreationData(
        name: params.name,
        description: params.description,
        price: params.price,
        images: uploadedUrls.join(','), // 将URL列表转换为逗号分隔的字符串
        categoryId: params.categoryId,
        variants: params.variants,
        productMaterials: params.productMaterials,
      );
      
      // 创建商品
      return _sellerRepository.createProduct(productData);
    } else {
      // 如果没有图片需要上传，返回错误（商品必须有至少一张图片）
      return Left(ValidationFailure(message: '商品必须至少包含一张图片'));
    }
  }
} 