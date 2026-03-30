import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart';
import '../pages/file_preview_page.dart';

/// 文件消息显示组件
class FileMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final VoidCallback? onTap;

  const FileMessageWidget({
    super.key,
    required this.message,
    required this.isMe,
    this.onTap,
  });

  /// 解析文件信息
  Map<String, dynamic> _parseFileInfo() {
    try {
      String contextStr = message.context.trim();
      
      
      // 如果是 URL 编码的内容，先解码
      if (contextStr.contains('%7B') || contextStr.contains('%7b') || contextStr.contains('%22')) {
        contextStr = Uri.decodeFull(contextStr);
      }
      
      // 处理可能的格式：{url: xxx, name: xxx, ...} （没有引号的格式）
      if (contextStr.startsWith('{') && !contextStr.contains('"url"')) {
        
        // 使用更精确的正则表达式来处理键值对
        // 1. 给键加引号：url: -> "url":
        contextStr = contextStr.replaceAllMapped(
          RegExp(r'(\w+)\s*:'),
          (match) => '"${match.group(1)}":',
        );
        
        // 2. 给非数字值加引号：: value -> : "value"
        // 但要避免已经有引号的值和数字值
        contextStr = contextStr.replaceAllMapped(
          RegExp(r':\s*([^",{}\d][^,}]*[^",}])'),
          (match) => ': "${match.group(1)}"',
        );
        
        // 3. 处理纯数字值，确保它们不被加引号
        contextStr = contextStr.replaceAllMapped(
          RegExp(r':\s*(\d+)'),
          (match) => ': ${match.group(1)}',
        );
        
      }
      
      // 如果是标准 JSON 字符串，解析它
      if (contextStr.startsWith('{')) {
        return jsonDecode(contextStr) as Map<String, dynamic>;
      }
      
      // 否则假设它只是一个 URL
      return {
        'url': contextStr,
        'name': 'file',
        'size': 0,
        'extension': '',
      };
    } catch (e) {
      return {
        'url': message.context,
        'name': 'file',
        'size': 0,
        'extension': '',
      };
    }
  }

  /// 获取文件图标
  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// 获取文件图标颜色
  Color _getFileIconColor(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return AppColors.error;
      case 'doc':
      case 'docx':
        return AppColors.info;
      case 'xls':
      case 'xlsx':
        return AppColors.success;
      case 'ppt':
      case 'pptx':
        return AppColors.warning;
      case 'txt':
        return AppColors.textTertiary;
      case 'zip':
      case 'rar':
        return AppColors.nodeHuman;
      default:
        return AppColors.textSecondary;
    }
  }

  /// 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  Widget build(BuildContext context) {
    final fileInfo = _parseFileInfo();
    final fileName = fileInfo['name'] ?? 'file';
    final fileSize = fileInfo['size'] ?? 0;
    final fileExtension = fileInfo['extension'] ?? '';
    
    return GestureDetector(
      onTap: onTap ?? () {
        // 如果没有提供自定义的 onTap，则默认打开文件预览
        final fileUrl = fileInfo['url'];
        if (fileUrl != null && fileUrl.isNotEmpty) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FilePreviewPage(
                fileUrl: fileUrl,
                fileName: fileName,
                fileExtension: fileExtension,
              ),
            ),
          );
        }
      },
      child: Container(
        constraints: const BoxConstraints(maxWidth: 250),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: isMe ? Theme.of(context).primaryColor.withValues(alpha: 0.3) : AppColors.borderInput,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 文件图标
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getFileIconColor(fileExtension).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getFileIcon(fileExtension),
                color: _getFileIconColor(fileExtension),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            // 文件信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    fileName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isMe ? Theme.of(context).primaryColor : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatFileSize(fileSize),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // 下载图标
            Icon(
              Icons.download,
              color: isMe ? Theme.of(context).primaryColor : Colors.grey[600],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// 图片消息显示组件
class ImageMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final VoidCallback? onTap;
  final GestureLongPressStartCallback? onLongPressStart;

  const ImageMessageWidget({
    super.key,
    required this.message,
    required this.isMe,
    this.onTap,
    this.onLongPressStart,
  });

  /// 解析图片信息
  Map<String, dynamic> _parseImageInfo() {
    try {
      String contextStr = message.context.trim();
      
      // 如果是 URL 编码的内容，先解码
      if (contextStr.contains('%7B') || contextStr.contains('%7b') || contextStr.contains('%22')) {
        contextStr = Uri.decodeFull(contextStr);
      }
      
      // 处理可能的格式：{url: xxx, name: xxx, ...} （没有引号的格式）
      if (contextStr.startsWith('{') && !contextStr.contains('"url"')) {
        // 转换为标准 JSON 格式
        contextStr = contextStr
            .replaceAll(RegExp(r'(\w+):'), '"\\1":')  // 给键加引号
            .replaceAll(RegExp(r':\s*([^,}]+)'), ': "\\1"');  // 给值加引号
      }
      
      // 如果是标准 JSON 字符串，解析它
      if (contextStr.startsWith('{')) {
        return jsonDecode(contextStr) as Map<String, dynamic>;
      }
      
      // 否则假设它只是一个 URL
      return {
        'url': contextStr,
        'name': 'image',
      };
    } catch (e) {
      return {
        'url': message.context,
        'name': 'image',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageInfo = _parseImageInfo();
    final imageUrl = imageInfo['url'] ?? message.context;
    
    return GestureDetector(
      onTap: onTap,
      onLongPressStart: onLongPressStart,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 250,
          maxHeight: 300,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // 图片 - 使用CachedNetworkImage并限制内存缓存大小
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                // 限制内存中图片的尺寸，减少内存占用
                memCacheWidth: 500,
                memCacheHeight: 600,
                maxHeightDiskCache: 600,
                placeholder: (context, url) => Container(
                  width: 250,
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 250,
                  height: 200,
                  color: Colors.grey[200],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, color: Colors.grey[400], size: 48),
                      const SizedBox(height: 8),
                      Text(
                        '图片加载失败',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              // 发送状态指示器（如果消息正在发送）
              if (message.status == MessageStatus.sending)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
