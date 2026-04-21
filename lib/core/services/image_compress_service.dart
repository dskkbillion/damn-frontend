import 'dart:io';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:injectable/injectable.dart';

/// 图片压缩服务
@singleton
class ImageCompressService {
  /// 压缩头像图片
  /// 
  /// 头像压缩参数：
  /// - 尺寸：512x512 (适合头像显示)
  /// - 质量：85 (平衡文件大小和质量)
  /// - 格式：JPEG (兼容性好，文件小)
  Future<File?> compressAvatar(File imageFile) async {
    return await _compressImage(
      imageFile,
      maxWidth: 512,
      maxHeight: 512,
      quality: 85,
      format: CompressFormat.jpeg,
    );
  }

  /// 压缩商品图片
  /// 
  /// 商品图片压缩参数：
  /// - 尺寸：1024x1024 (适合商品展示)
  /// - 质量：90 (保证商品图片质量)
  /// - 格式：JPEG
  Future<File?> compressProductImage(File imageFile) async {
    return await _compressImage(
      imageFile,
      maxWidth: 1024,
      maxHeight: 1024,
      quality: 90,
      format: CompressFormat.jpeg,
    );
  }

  /// 压缩缩略图
  /// 
  /// 缩略图压缩参数：
  /// - 尺寸：256x256 (用于列表显示)
  /// - 质量：80 (文件小，加载快)
  /// - 格式：JPEG
  Future<File?> compressThumbnail(File imageFile) async {
    return await _compressImage(
      imageFile,
      maxWidth: 256,
      maxHeight: 256,
      quality: 80,
      format: CompressFormat.jpeg,
    );
  }

  /// 通用图片压缩方法
  Future<File?> _compressImage(
    File imageFile, {
    required int maxWidth,
    required int maxHeight,
    required int quality,
    required CompressFormat format,
  }) async {
    try {
      // 检查文件是否存在
      if (!await imageFile.exists()) {
        AppLogger.d('[ImageCompressService] 图片文件不存在: ${imageFile.path}');
        return null;
      }

      // 获取文件信息
      final fileSize = await imageFile.length();
      AppLogger.d('[ImageCompressService] 原图片大小: ${_formatFileSize(fileSize)}');

      // 如果文件很小且是JPEG格式，可能不需要压缩
      if (fileSize < 500 * 1024 && _isJpeg(imageFile)) {
        AppLogger.d('[ImageCompressService] 图片已经很小，跳过压缩');
        return imageFile;
      }

      // 获取临时目录
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = format == CompressFormat.jpeg ? '.jpg' : '.png';
      final compressedPath = path.join(tempDir.path, 'compressed_$timestamp$extension');

      // 执行压缩
      final compressedXFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        compressedPath,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
        format: format,
        keepExif: false, // 移除EXIF信息减小文件大小
      );

      if (compressedXFile == null) {
        AppLogger.d('[ImageCompressService] 图片压缩失败');
        return null;
      }

      // 将XFile转换为File
      final compressedFile = File(compressedXFile.path);

      // 检查压缩结果
      final compressedSize = await compressedFile.length();
      final compressionRatio = ((fileSize - compressedSize) / fileSize * 100).toStringAsFixed(1);
      
      AppLogger.d('[ImageCompressService] 压缩完成:');
      AppLogger.d('  - 压缩后大小: ${_formatFileSize(compressedSize)}');
      AppLogger.d('  - 压缩比例: $compressionRatio%');
      AppLogger.d('  - 输出路径: ${compressedFile.path}');

      return compressedFile;
    } catch (e) {
      AppLogger.d('[ImageCompressService] 图片压缩出错: $e');
      return null;
    }
  }

  /// 检查是否为JPEG格式
  bool _isJpeg(File file) {
    final extension = path.extension(file.path).toLowerCase();
    return extension == '.jpg' || extension == '.jpeg';
  }

  /// 格式化文件大小显示
  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  /// 压缩图片到指定字节数以下
  /// 
  /// 用于确保图片不超过服务器限制
  Future<File?> compressToMaxSize(
    File imageFile, {
    required int maxSizeBytes,
    int maxWidth = 1024,
    int maxHeight = 1024,
  }) async {
    try {
      File? result = imageFile;
      int currentQuality = 95;
      
      // 循环压缩直到满足大小要求
      while (currentQuality > 30) {
        result = await _compressImage(
          imageFile,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          quality: currentQuality,
          format: CompressFormat.jpeg,
        );
        
        if (result == null) break;
        
        final size = await result.length();
        if (size <= maxSizeBytes) {
          AppLogger.d('[ImageCompressService] 压缩到目标大小: ${_formatFileSize(size)}');
          return result;
        }
        
        currentQuality -= 10;
        AppLogger.d('[ImageCompressService] 继续压缩，质量: $currentQuality');
      }
      
      AppLogger.d('[ImageCompressService] 无法压缩到目标大小');
      return result;
    } catch (e) {
      AppLogger.d('[ImageCompressService] 压缩到指定大小失败: $e');
      return null;
    }
  }
} 