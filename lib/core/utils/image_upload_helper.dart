import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_it/get_it.dart';

import '../services/image_compress_service.dart';

/// 图片上传类型
enum ImageUploadType {
  /// 用户头像
  avatar,
  /// 商品图片
  product,
  /// 聊天图片
  chat,
  /// 评价图片
  review,
  /// 认证图片
  authentication,
  /// AI文档图片
  aiDocument,
  /// 售后图片
  afterSales,
}

/// 图片处理结果
class ImageProcessResult {
  final File originalFile;
  final File? compressedFile;
  final String? error;
  final int originalSize;
  final int? compressedSize;

  ImageProcessResult({
    required this.originalFile,
    this.compressedFile,
    this.error,
    required this.originalSize,
    this.compressedSize,
  });

  /// 是否压缩成功
  bool get isSuccess => compressedFile != null && error == null;
  
  /// 获取最终文件（压缩后的或原文件）
  File get finalFile => compressedFile ?? originalFile;
  
  /// 压缩比例
  double? get compressionRatio {
    if (compressedSize == null) return null;
    return ((originalSize - compressedSize!) / originalSize * 100);
  }
  
  /// 格式化大小信息
  Map<String, String> get sizeInfo => {
    'originalSize': _formatFileSize(originalSize),
    'compressedSize': compressedSize != null ? _formatFileSize(compressedSize!) : 'N/A',
    'compressionRatio': compressionRatio != null ? '${compressionRatio!.toStringAsFixed(1)}%' : 'N/A',
  };
  
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

/// 图片上传助手
/// 
/// 提供统一的图片选择、压缩和上传功能
class ImageUploadHelper {
  static final ImagePicker _picker = ImagePicker();
  static ImageCompressService? _compressService;

  /// 获取图片压缩服务
  static ImageCompressService get _compress {
    _compressService ??= GetIt.instance<ImageCompressService>();
    return _compressService!;
  }

  /// 从相册选择图片
  /// 
  /// [type] 图片类型，用于选择合适的压缩策略
  /// [allowMultiple] 是否允许多选
  /// [maxImages] 最大选择数量（仅在多选时有效）
  static Future<List<ImageProcessResult>> pickFromGallery({
    required ImageUploadType type,
    bool allowMultiple = false,
    int maxImages = 9,
  }) async {
    try {
      List<XFile> pickedFiles = [];
      
      if (allowMultiple) {
        final files = await _picker.pickMultiImage(
          imageQuality: 100, // 选择原始质量，后续由压缩服务处理
        );
        pickedFiles = files.take(maxImages).toList();
      } else {
        final file = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 100,
        );
        if (file != null) pickedFiles = [file];
      }

      // 处理选中的文件
      return await _processImages(pickedFiles, type);
    } catch (e) {
      if (kDebugMode) {
        print('[ImageUploadHelper] 选择图片出错: $e');
      }
      return [];
    }
  }

  /// 拍照选择图片
  static Future<ImageProcessResult?> pickFromCamera({
    required ImageUploadType type,
  }) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );

      if (pickedFile == null) return null;

      final results = await _processImages([pickedFile], type);
      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      if (kDebugMode) {
        print('[ImageUploadHelper] 拍照出错: $e');
      }
      return null;
    }
  }

  /// 选择图片来源（相册或拍照）
  static Future<ImageProcessResult?> pickImage({
    required ImageUploadType type,
    ImageSource? preferredSource,
  }) async {
    if (preferredSource != null) {
      return preferredSource == ImageSource.camera
          ? await pickFromCamera(type: type)
          : (await pickFromGallery(type: type, allowMultiple: false)).firstOrNull;
    }

    // 如果没有指定来源，可以在这里添加选择对话框
    // 现在默认使用相册
    final results = await pickFromGallery(type: type, allowMultiple: false);
    return results.isNotEmpty ? results.first : null;
  }

  /// 处理图片列表
  static Future<List<ImageProcessResult>> _processImages(
    List<XFile> xFiles, 
    ImageUploadType type,
  ) async {
    final results = <ImageProcessResult>[];

    for (final xFile in xFiles) {
      final file = File(xFile.path);
      final originalSize = await file.length();

      try {
        // 根据类型选择压缩方法
        File? compressedFile;
        switch (type) {
          case ImageUploadType.avatar:
            compressedFile = await _compress.compressAvatar(file);
            break;
          case ImageUploadType.product:
            compressedFile = await _compress.compressProductImage(file);
            break;
          case ImageUploadType.chat:
          case ImageUploadType.review:
          case ImageUploadType.afterSales:
            // 为聊天、评价、售后图片使用中等压缩
            compressedFile = await _compressChatImage(file);
            break;
          case ImageUploadType.authentication:
          case ImageUploadType.aiDocument:
            // 为认证和AI文档使用较高质量压缩
            compressedFile = await _compressDocumentImage(file);
            break;
        }

        final compressedSize = compressedFile != null ? await compressedFile.length() : null;

        results.add(ImageProcessResult(
          originalFile: file,
          compressedFile: compressedFile,
          originalSize: originalSize,
          compressedSize: compressedSize,
        ));
      } catch (e) {
        if (kDebugMode) {
          print('[ImageUploadHelper] 压缩图片失败: $e');
        }
        
        results.add(ImageProcessResult(
          originalFile: file,
          error: e.toString(),
          originalSize: originalSize,
        ));
      }
    }

    return results;
  }

  /// 压缩聊天图片（800x800，质量85%）
  static Future<File?> _compressChatImage(File imageFile) async {
    // 临时实现，后续可以在ImageCompressService中添加专门方法
    return await _compress.compressToMaxSize(
      imageFile,
      maxSizeBytes: 1024 * 1024, // 1MB
      maxWidth: 800,
      maxHeight: 800,
    );
  }

  /// 压缩文档图片（1200x1200，质量90%）
  static Future<File?> _compressDocumentImage(File imageFile) async {
    // 临时实现，后续可以在ImageCompressService中添加专门方法
    return await _compress.compressToMaxSize(
      imageFile,
      maxSizeBytes: 2 * 1024 * 1024, // 2MB
      maxWidth: 1200,
      maxHeight: 1200,
    );
  }

  /// 验证图片文件
  static bool isValidImageFile(File file) {
    final extension = file.path.toLowerCase();
    return extension.endsWith('.jpg') ||
           extension.endsWith('.jpeg') ||
           extension.endsWith('.png') ||
           extension.endsWith('.gif') ||
           extension.endsWith('.webp');
  }

  /// 获取图片上传配置
  static Map<String, dynamic> getUploadConfig(ImageUploadType type) {
    switch (type) {
      case ImageUploadType.avatar:
        return {
          'maxSize': '1MB',
          'dimensions': '512x512',
          'quality': '85%',
          'format': 'JPEG',
          'description': '用户头像',
        };
      case ImageUploadType.product:
        return {
          'maxSize': '2MB',
          'dimensions': '1024x1024',
          'quality': '90%',
          'format': 'JPEG',
          'description': '商品图片',
        };
      case ImageUploadType.chat:
        return {
          'maxSize': '1MB',
          'dimensions': '800x800',
          'quality': '85%',
          'format': 'JPEG',
          'description': '聊天图片',
        };
      case ImageUploadType.review:
        return {
          'maxSize': '1MB',
          'dimensions': '800x800',
          'quality': '85%',
          'format': 'JPEG',
          'description': '评价图片',
        };
      case ImageUploadType.authentication:
        return {
          'maxSize': '2MB',
          'dimensions': '1200x1200',
          'quality': '90%',
          'format': 'JPEG',
          'description': '认证图片',
        };
      case ImageUploadType.aiDocument:
        return {
          'maxSize': '2MB',
          'dimensions': '1200x1200',
          'quality': '90%',
          'format': 'JPEG',
          'description': 'AI文档图片',
        };
      case ImageUploadType.afterSales:
        return {
          'maxSize': '1MB',
          'dimensions': '800x800',
          'quality': '85%',
          'format': 'JPEG',
          'description': '售后图片',
        };
    }
  }
}