import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_authentication_info.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/repositories/i_file_upload_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

/// 提交认证申请参数
class SubmitAuthenticationApplicationParams extends Equatable {
  /// 认证申请数据
  final AuthenticationApplicationData applicationData;
  
  /// 待上传的本地文件路径
  final List<String> localFilePaths;

  /// 构造函数
  const SubmitAuthenticationApplicationParams({
    required this.applicationData,
    required this.localFilePaths,
  });

  @override
  List<Object> get props => [applicationData, localFilePaths];
}

/// 提交认证申请UseCase
@injectable
class SubmitAuthenticationApplicationUseCase
    implements UseCase<bool, SubmitAuthenticationApplicationParams> {
  final ISellerRepository _sellerRepository;
  final IFileUploadRepository _fileUploadRepository;

  /// 构造函数
  SubmitAuthenticationApplicationUseCase(
    this._sellerRepository,
    this._fileUploadRepository,
  );

  @override
  Future<Either<Failure, bool>> call(SubmitAuthenticationApplicationParams params) async {
    // 先上传文件
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
      
      // 构建新的认证数据，包含上传的文件URL
      final updatedApplicationData = AuthenticationApplicationData(
        authenticationId: params.applicationData.authenticationId,
        authenticationType: params.applicationData.authenticationType,
        name: params.applicationData.name,
        images: uploadedUrls.join(','), // 将URL列表转换为逗号分隔的字符串
        remark: params.applicationData.remark,
        feature: params.applicationData.feature,
      );
      
      // 提交认证申请
      return _sellerRepository.submitAuthenticationApplication(updatedApplicationData);
    } else {
      // 如果没有文件需要上传，直接提交认证申请
      return _sellerRepository.submitAuthenticationApplication(params.applicationData);
    }
  }
} 