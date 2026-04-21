import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/repositories/i_file_upload_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

/// 图片上传进度回调
typedef UploadProgressCallback = void Function(int uploadedCount, int totalCount);

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
  
  /// 待上传的商品主图本地路径列表
  final List<String> imageFilePaths;
  
  /// 待上传的商品详情图本地路径列表
  final List<String> detailImageFilePaths;
  
  /// 详情图HTML内容（可选，优先使用图片）
  final String? detailContent;
  
  /// 上传进度回调
  final UploadProgressCallback? onUploadProgress;

  /// 构造函数
  const CreateProductParams({
    required this.name,
    required this.description,
    required this.price,
    required this.imageFilePaths,
    this.detailImageFilePaths = const [],
    this.categoryId,
    this.variants,
    this.productMaterials,
    this.detailContent,
    this.onUploadProgress,
  });

  @override
  List<Object?> get props => [
    name, 
    description, 
    price, 
    imageFilePaths, 
    detailImageFilePaths,
    categoryId, 
    variants, 
    productMaterials,
    detailContent,
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
      final uploadedDetailUrls = <String>[];
      
      // 创建合并的图片路径列表，并标记类型
      final allImagePaths = <Map<String, dynamic>>[];
      
      // 添加主图路径
      for (final path in params.imageFilePaths) {
        allImagePaths.add({
          'path': path,
          'type': 'main', // 主图
        });
      }
      
      // 添加详情图路径
      for (final path in params.detailImageFilePaths) {
        allImagePaths.add({
          'path': path,
          'type': 'detail', // 详情图
        });
      }
      
      // 总文件数，用于进度计算
      final totalFiles = allImagePaths.length;
      int uploadedCount = 0;
      
      // 逐个上传所有图片，而不是先上传所有主图再上传所有详情图
      for (final imageData in allImagePaths) {
        final path = imageData['path'] as String;
        final type = imageData['type'] as String;
        
        final file = File(path);
        
        // 短暂延迟，避免连续请求导致服务器压力过大
        if (allImagePaths.indexOf(imageData) > 0) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
        
        // 上传前通知进度
        params.onUploadProgress?.call(uploadedCount, totalFiles);
        
        final uploadResult = await _fileUploadRepository.uploadFile(file);
        
        // 如果有一个图片上传失败，则返回失败
        if (uploadResult.isLeft()) {
          return uploadResult.fold(
            (failure) => Left(failure),
            (_) => throw Exception("Unexpected state"),
          );
        }
        
        // 上传成功，更新计数器
        uploadedCount++;
        
        // 上传后通知进度
        params.onUploadProgress?.call(uploadedCount, totalFiles);
        
        // 根据图片类型，添加到相应的URL列表
        uploadResult.fold(
          (_) => throw Exception("Unexpected state"),
          (url) {
            if (type == 'main') {
              uploadedUrls.add(url);
            } else {
              uploadedDetailUrls.add(url);
            }
          },
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
        detailImages: uploadedDetailUrls.isNotEmpty ? uploadedDetailUrls.join(',') : null,
        detailContent: params.detailContent,
      );
      
      // 创建商品
      return _sellerRepository.createProduct(productData);
    } else {
      // 如果没有图片需要上传，返回错误（商品必须有至少一张图片）
      return const Left(ValidationFailure(message: '商品必须至少包含一张图片'));
    }
  }
} 