import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';
import 'package:path/path.dart' as path;

/// 文件选择组件
class FileSelectionWidget extends StatelessWidget {
  /// 已选择的文件路径列表
  final List<String> selectedFiles;
  
  /// 文件选择回调
  final void Function(String filePath) onFileSelected;
  
  /// 文件移除回调
  final void Function(int index) onFileRemoved;
  
  /// 是否禁用（不可选择新文件）
  final bool disabled;

  /// 构造函数
  const FileSelectionWidget({
    super.key,
    required this.selectedFiles,
    required this.onFileSelected,
    required this.onFileRemoved,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 文件选择按钮
        if (!disabled)
          ElevatedButton.icon(
            onPressed: () async {
              // 打开文件选择器
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                allowMultiple: true,
                type: FileType.any,
              );
              
              if (result != null) {
                // 获取所选文件的路径
                for (var file in result.paths) {
                  if (file != null) {
                    onFileSelected(file);
                  }
                }
              }
            },
            icon: const Icon(Icons.attach_file),
            label: Text(AppLocalizations.of(context).seller_file_select ?? 'Select File'),
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.onPrimary,
              backgroundColor: AppColors.primary,
            ),
          ),
        
        const SizedBox(height: 16),
        
        // 已选择文件列表
        if (selectedFiles.isNotEmpty) ...[
          Text(
            AppLocalizations.of(context).seller_file_selected ?? 'Selected files:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: selectedFiles.length,
            itemBuilder: (context, index) {
              final filePath = selectedFiles[index];
              final fileName = path.basename(filePath);
              final fileExtension = path.extension(filePath).toLowerCase();
              
              return GlassCard(
                margin: const EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: _buildFileIcon(fileExtension),
                  title: Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    AppLocalizations.of(context).seller_file_size(_getFileSize(filePath)) ?? 'Size: ${_getFileSize(filePath)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: !disabled
                      ? IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error),
                          onPressed: () => onFileRemoved(index),
                        )
                      : null,
                  onTap: () {
                    // 预览文件
                    _previewFile(context, filePath);
                  },
                ),
              );
            },
          ),
        ],
      ],
    );
  }
  
  /// 根据文件扩展名构建文件图标
  Widget _buildFileIcon(String extension) {
    IconData iconData;
    Color iconColor;
    
    // 根据文件类型选择图标
    switch (extension) {
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
      case '.bmp':
        iconData = Icons.image;
        iconColor = AppColors.primary;
        break;
      case '.pdf':
        iconData = Icons.picture_as_pdf;
        iconColor = AppColors.error;
        break;
      case '.doc':
      case '.docx':
        iconData = Icons.description;
        iconColor = Colors.indigo;
        break;
      case '.xls':
      case '.xlsx':
        iconData = Icons.table_chart;
        iconColor = AppColors.success;
        break;
      case '.ppt':
      case '.pptx':
        iconData = Icons.slideshow;
        iconColor = AppColors.warning;
        break;
      case '.txt':
        iconData = Icons.text_snippet;
        iconColor = AppColors.textTertiary;
        break;
      case '.zip':
      case '.rar':
      case '.7z':
        iconData = Icons.archive;
        iconColor = Colors.brown;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = AppColors.textTertiary;
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(iconData, color: iconColor),
    );
  }
  
  /// 获取文件大小
  String _getFileSize(String filePath) {
    try {
      final file = File(filePath);
      final bytes = file.lengthSync();
      
      if (bytes < 1024) {
        return '$bytes B';
      } else if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      } else if (bytes < 1024 * 1024 * 1024) {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      } else {
        return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
      }
    } catch (e) {
      return 'N/A';
    }
  }
  
  /// 预览文件
  void _previewFile(BuildContext context, String filePath) {
    final fileName = path.basename(filePath);
    final fileExtension = path.extension(filePath).toLowerCase();
    
    // 如果是图片，则显示图片预览
    if (['.jpg', '.jpeg', '.png', '.gif', '.bmp'].contains(fileExtension)) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text(fileName),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Flexible(
                child: Image.file(File(filePath)),
              ),
            ],
          ),
        ),
      );
    } else {
      // 非图片文件，显示信息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).seller_file_preview_unsupported(fileName) ?? 'Cannot preview this file type: $fileName'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
} 
