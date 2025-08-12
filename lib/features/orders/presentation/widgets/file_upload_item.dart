import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/core/services/file_upload_service.dart';

/// 文件上传状态
enum FileUploadStatus {
  waiting,    // 等待上传
  uploading,  // 上传中
  success,    // 上传成功
  failed,     // 上传失败
}

/// 文件上传项数据
class FileUploadItem {
  final String id;
  final String localPath;
  final String fileName;
  final int fileSize;
  final FileUploadStatus status;
  final double progress;
  final String? uploadedUrl;
  final String? errorMessage;

  FileUploadItem({
    required this.id,
    required this.localPath,
    required this.fileName,
    required this.fileSize,
    this.status = FileUploadStatus.waiting,
    this.progress = 0.0,
    this.uploadedUrl,
    this.errorMessage,
  });

  FileUploadItem copyWith({
    FileUploadStatus? status,
    double? progress,
    String? uploadedUrl,
    String? errorMessage,
  }) {
    return FileUploadItem(
      id: id,
      localPath: localPath,
      fileName: fileName,
      fileSize: fileSize,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      uploadedUrl: uploadedUrl ?? this.uploadedUrl,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isImage {
    final ext = fileName.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext);
  }
}

/// 文件上传项组件
class FileUploadItemWidget extends StatefulWidget {
  final FileUploadItem item;
  final VoidCallback onRemove;
  final Function(String url) onUploadSuccess;
  final int maxFileSize; // 最大文件大小（字节）
  final VoidCallback? onRetry; // 重试回调

  const FileUploadItemWidget({
    Key? key,
    required this.item,
    required this.onRemove,
    required this.onUploadSuccess,
    this.maxFileSize = 10 * 1024 * 1024, // 默认10MB
    this.onRetry,
  }) : super(key: key);

  @override
  State<FileUploadItemWidget> createState() => _FileUploadItemWidgetState();
}

class _FileUploadItemWidgetState extends State<FileUploadItemWidget> {
  late FileUploadItem _item;
  final _fileUploadService = GetIt.instance<IFileUploadService>();
  int _retryCount = 0;
  static const int _maxRetryCount = 3;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    
    // 检查文件大小
    if (_item.fileSize > widget.maxFileSize) {
      setState(() {
        _item = _item.copyWith(
          status: FileUploadStatus.failed,
          errorMessage: '文件大小超过限制（最大${_formatFileSize(widget.maxFileSize)}）',
        );
      });
    } else if (_item.status == FileUploadStatus.waiting) {
      // 立即开始上传
      _startUpload();
    }
  }

  Future<void> _startUpload() async {
    setState(() {
      _item = _item.copyWith(status: FileUploadStatus.uploading, progress: 0.0);
    });

    try {
      // 如果是重试，添加指数退避延迟
      if (_retryCount > 0) {
        final delay = Duration(seconds: _retryCount * 2);
        await Future.delayed(delay);
      }
      
      final result = await _fileUploadService.uploadFileWithProgress(
        _item.localPath,
        (progress) {
          if (mounted && _item.status == FileUploadStatus.uploading) {
            setState(() {
              _item = _item.copyWith(progress: progress);
            });
          }
        },
      );
      
      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              _item = _item.copyWith(
                status: FileUploadStatus.failed,
                errorMessage: failure.message,
              );
            });
          }
        },
        (uploadResult) {
          if (mounted) {
            setState(() {
              _item = _item.copyWith(
                status: FileUploadStatus.success,
                progress: 1.0,
                uploadedUrl: uploadResult.url,
              );
            });
            widget.onUploadSuccess(uploadResult.url);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _item = _item.copyWith(
            status: FileUploadStatus.failed,
            errorMessage: '上传失败: $e',
          );
        });
      }
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget _buildPreview() {
    if (_item.isImage) {
      // 图片预览
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(_item.localPath),
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 80,
              height: 80,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 30),
            );
          },
        ),
      );
    } else {
      // 文件图标
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Icon(
          _getFileIcon(_item.fileName),
          size: 30,
          color: Colors.grey[600],
        ),
      );
    }
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
    switch (extension) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'doc': case 'docx': return Icons.description;
      case 'xls': case 'xlsx': return Icons.table_chart;
      case 'ppt': case 'pptx': return Icons.slideshow;
      case 'zip': case 'rar': case '7z': return Icons.archive;
      case 'mp4': case 'avi': case 'mov': return Icons.video_file;
      case 'mp3': case 'wav': case 'flac': return Icons.audio_file;
      default: return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _item.status == FileUploadStatus.failed 
            ? Colors.red[300]! 
            : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          // 预览
          _buildPreview(),
          const SizedBox(width: 12),
          
          // 文件信息和状态
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 文件名
                Text(
                  _item.fileName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                
                // 文件大小和状态
                Row(
                  children: [
                    Text(
                      _formatFileSize(_item.fileSize),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_item.status == FileUploadStatus.success)
                      const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    if (_item.status == FileUploadStatus.failed)
                      Icon(Icons.error, color: Colors.red[400], size: 16),
                  ],
                ),
                
                // 进度条或错误信息
                if (_item.status == FileUploadStatus.uploading) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _item.progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '上传中 ${(_item.progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
                
                if (_item.errorMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _item.errorMessage!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[400],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // 操作按钮
          if (_item.status == FileUploadStatus.failed && _retryCount < _maxRetryCount)
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: () {
                _retryCount++;
                if (widget.onRetry != null) {
                  widget.onRetry!();
                } else {
                  _startUpload();
                }
              },
              color: Theme.of(context).primaryColor,
              tooltip: '重试上传',
            )
          else if (_item.status != FileUploadStatus.uploading)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: widget.onRemove,
              color: Colors.grey[600],
            ),
        ],
      ),
    );
  }
}