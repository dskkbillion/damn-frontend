import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/repositories/i_file_upload_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

/// 添加订单交付参数
class AddOrderDeliveryParams extends Equatable {
  /// 订单ID
  final int orderId;
  
  /// 交付内容描述
  final String content;
  
  /// 待上传的本地文件路径列表
  final List<String> localFilePaths;

  /// 构造函数
  const AddOrderDeliveryParams({
    required this.orderId,
    required this.content,
    required this.localFilePaths,
  });

  @override
  List<Object> get props => [orderId, content, localFilePaths];
}

/// 添加订单交付UseCase
@injectable
class AddOrderDeliveryUseCase implements UseCase<bool, AddOrderDeliveryParams> {
  final ISellerRepository _sellerRepository;
  final IFileUploadRepository _fileUploadRepository;

  /// 构造函数
  AddOrderDeliveryUseCase(
    this._sellerRepository,
    this._fileUploadRepository,
  );

  @override
  Future<Either<Failure, bool>> call(AddOrderDeliveryParams params) async {
    // 如果有文件需要上传
    if (params.localFilePaths.isNotEmpty) {
      final uploadedUrls = <String>[];
      
      // 逐个上传文件
      for (final path in params.localFilePaths) {
        final file = File(path);
        final uploadResult = await _fileUploadRepository.uploadFile(file);
        
        // 如果有一个文件上传失败，则返回失败
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
      
      // 提交订单交付
      return _sellerRepository.addOrderDelivery(
        orderId: params.orderId,
        content: params.content,
        files: uploadedUrls,
      );
    } else {
      // 如果没有文件需要上传，直接提交订单交付
      return _sellerRepository.addOrderDelivery(
        orderId: params.orderId,
        content: params.content,
        files: const [],
      );
    }
  }
} 