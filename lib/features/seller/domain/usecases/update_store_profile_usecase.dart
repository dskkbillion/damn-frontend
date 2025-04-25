import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_store_profile.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/repositories/i_file_upload_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

/// 更新店铺资料参数
class UpdateStoreProfileParams extends Equatable {
  /// 店铺名称（可选）
  final String? storeName;
  
  /// 店铺描述（可选）
  final String? description;
  
  /// 联系方式（可选）
  final ContactInfo? contactInfo;
  
  /// 店铺政策（可选）
  final StorePolicies? policies;
  
  /// 待上传的店铺Logo本地文件路径（可选）
  final String? logoFilePath;

  /// 构造函数
  const UpdateStoreProfileParams({
    this.storeName,
    this.description,
    this.contactInfo,
    this.policies,
    this.logoFilePath,
  });

  @override
  List<Object?> get props => [
    storeName,
    description,
    contactInfo,
    policies,
    logoFilePath,
  ];
}

/// 更新店铺资料UseCase
@injectable
class UpdateStoreProfileUseCase implements UseCase<bool, UpdateStoreProfileParams> {
  final ISellerRepository _sellerRepository;
  final IFileUploadRepository _fileUploadRepository;

  /// 构造函数
  UpdateStoreProfileUseCase(
    this._sellerRepository,
    this._fileUploadRepository,
  );

  @override
  Future<Either<Failure, bool>> call(UpdateStoreProfileParams params) async {
    // 定义店铺资料更新数据
    StoreProfileUpdateData profileData = StoreProfileUpdateData(
      storeName: params.storeName,
      description: params.description,
      contactInfo: params.contactInfo,
      policies: params.policies,
    );
    
    // 如果需要更新店铺Logo
    if (params.logoFilePath != null) {
      final file = File(params.logoFilePath!);
      final uploadResult = await _fileUploadRepository.uploadFile(file);
      
      // 处理上传结果
      return uploadResult.fold(
        (failure) => Left(failure),
        (logoUrl) {
          // 设置Logo URL
          profileData = StoreProfileUpdateData(
            storeName: profileData.storeName,
            description: profileData.description,
            contactInfo: profileData.contactInfo,
            policies: profileData.policies,
            logoUrl: logoUrl,
          );
          
          // 更新店铺资料
          return _sellerRepository.updateStoreProfile(profileData);
        },
      );
    } else {
      // 直接更新店铺资料
      return _sellerRepository.updateStoreProfile(profileData);
    }
  }
} 