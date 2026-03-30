import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// 文件预览页面
class FilePreviewPage extends StatefulWidget {
  final String fileUrl;
  final String fileName;
  final String fileExtension;

  const FilePreviewPage({
    super.key,
    required this.fileUrl,
    required this.fileName,
    required this.fileExtension,
  });

  @override
  State<FilePreviewPage> createState() => _FilePreviewPageState();
}

class _FilePreviewPageState extends State<FilePreviewPage> {
  bool _isLoading = true;
  String? _localPath;
  double _downloadProgress = 0.0;
  String? _errorMessage;
  final Dio _dio = Dio();

  // PDF相关
  int _totalPages = 0;
  int _currentPage = 0;
  // PDFViewController? _pdfController; // 暂时未使用

  @override
  void initState() {
    super.initState();
    _downloadAndPreview();
  }

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }

  Future<void> _downloadAndPreview() async {
    try {
      // 获取临时目录
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${widget.fileName}';
      
      // 检查文件是否已存在
      final file = File(filePath);
      if (await file.exists()) {
        setState(() {
          _localPath = filePath;
          _isLoading = false;
        });
        return;
      }
      
      // 下载文件
      await _dio.download(
        widget.fileUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );
      
      setState(() {
        _localPath = filePath;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '文件下载失败: $e';
        _isLoading = false;
      });
    }
  }
  
  /// 使用系统应用打开文件
  Future<void> _openWithSystemApp() async {
    if (_localPath == null) return;
    
    try {
      final result = await OpenFile.open(_localPath!);
      if (result.type != ResultType.done) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('无法打开文件: ${result.message}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('打开文件失败: $e')),
        );
      }
    }
  }
  
  /// 下载文件到设备存储
  Future<void> _downloadFile() async {
    if (_localPath == null) return;
    
    try {
      // Android需要检查存储权限
      if (Platform.isAndroid) {
        final status = await Permission.storage.status;
        if (!status.isGranted) {
          final result = await Permission.storage.request();
          if (!result.isGranted) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('需要存储权限才能保存文件'),
                  duration: Duration(seconds: 3),
                ),
              );
            }
            return;
          }
        }
      }
      
      Directory? targetDir;
      String saveLocation = '';
      String fullPath = '';
      
      if (Platform.isAndroid) {
        // Android: 获取公共下载目录
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (await downloadsDir.exists()) {
          targetDir = downloadsDir;
          saveLocation = '下载文件夹';
        } else {
          // 备用方案：使用外部存储目录
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            final downloadPath = '${externalDir.path}/Download';
            targetDir = Directory(downloadPath);
            if (!await targetDir.exists()) {
              await targetDir.create(recursive: true);
            }
            saveLocation = '应用下载目录';
          }
        }
      } else if (Platform.isIOS) {
        // iOS: 使用应用文档目录
        targetDir = await getApplicationDocumentsDirectory();
        saveLocation = '文件应用';
      } else {
        // 其他平台：使用下载目录
        targetDir = await getDownloadsDirectory();
        saveLocation = '下载文件夹';
      }
      
      if (targetDir != null) {
        // 处理文件名冲突
        String fileName = widget.fileName;
        final nameWithoutExt = fileName.substring(0, fileName.lastIndexOf('.'));
        final extension = fileName.substring(fileName.lastIndexOf('.'));
        
        String savePath = '${targetDir.path}/$fileName';
        int counter = 1;
        
        // 如果文件已存在，添加数字后缀
        while (await File(savePath).exists()) {
          fileName = '$nameWithoutExt($counter)$extension';
          savePath = '${targetDir.path}/$fileName';
          counter++;
        }
        
        await File(_localPath!).copy(savePath);
        fullPath = savePath;
        
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('下载成功'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('文件已保存到$saveLocation'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                    child: SelectableText(
                      fullPath,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Platform.isAndroid 
                      ? '您可以在手机的"文件管理器"应用中找到此文件'
                      : Platform.isIOS
                        ? '您可以在"文件"应用中找到此文件'
                        : '文件已保存到系统下载目录',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('确定'),
                ),
                if (Platform.isAndroid || Platform.isIOS)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      OpenFile.open(savePath);
                    },
                    child: const Text('打开文件'),
                  ),
              ],
            ),
          );
        }
      } else {
        throw '无法获取下载目录';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.fileName,
              style: const TextStyle(fontSize: 16, color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (_totalPages > 0 && widget.fileExtension.toLowerCase() == 'pdf')
              Text(
                '${_currentPage + 1} / $_totalPages',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
          ],
        ),
        actions: [
          if (_localPath != null)
            IconButton(
              icon: const Icon(Icons.open_in_new, color: Colors.white),
              onPressed: _openWithSystemApp,
              tooltip: '使用其他应用打开',
            ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () => _downloadFile(),
            tooltip: '保存文件',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              value: _downloadProgress > 0 ? _downloadProgress : null,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              _downloadProgress > 0 
                  ? '下载中: ${(_downloadProgress * 100).toStringAsFixed(1)}%'
                  : '加载中...',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 60),
            const SizedBox(height: 20),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                  _downloadProgress = 0.0;
                });
                _downloadAndPreview();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }
    
    if (_localPath == null) {
      return const Center(
        child: Text(
          '无法加载文件',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    
    // 根据文件类型显示不同的预览
    switch (widget.fileExtension.toLowerCase()) {
      case 'pdf':
        return _buildPDFViewer();
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return _buildImageViewer();
      case 'txt':
      case 'log':
      case 'json':
      case 'xml':
      case 'html':
      case 'css':
      case 'js':
      case 'dart':
      case 'java':
      case 'py':
      case 'cpp':
      case 'c':
      case 'h':
        return _buildTextViewer();
      default:
        return _buildUnsupportedViewer();
    }
  }
  
  /// 构建PDF查看器
  Widget _buildPDFViewer() {
    return PDFView(
      filePath: _localPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: false,
      pageFling: true,
      pageSnap: true,
      fitPolicy: FitPolicy.BOTH,
      onRender: (pages) {
        setState(() {
          _totalPages = pages ?? 0;
        });
      },
      onError: (error) {
        setState(() {
          _errorMessage = '无法加载PDF: $error';
        });
      },
      onPageError: (page, error) {
        // 页面错误日志
        debugPrint('Page $page: $error');
      },
      onViewCreated: (PDFViewController controller) {
        // _pdfController = controller; // 保留以备后续使用
      },
      onPageChanged: (page, total) {
        setState(() {
          _currentPage = page ?? 0;
          _totalPages = total ?? 0;
        });
      },
    );
  }
  
  /// 构建图片查看器
  Widget _buildImageViewer() {
    return Center(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.file(
          File(_localPath!),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, color: Colors.white, size: 60),
                SizedBox(height: 20),
                Text(
                  '无法加载图片',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  
  /// 构建文本查看器
  Widget _buildTextViewer() {
    return FutureBuilder<String>(
      future: File(_localPath!).readAsString(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              '无法读取文件内容: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }
        
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        
        return Container(
          color: AppColors.textPrimary,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              snapshot.data!,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// 构建不支持预览的文件视图
  Widget _buildUnsupportedViewer() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getFileIcon(widget.fileExtension),
            color: Colors.white,
            size: 80,
          ),
          const SizedBox(height: 20),
          Text(
            widget.fileName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            '文件类型: ${widget.fileExtension.toUpperCase()}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 30),
          const Text(
            '该文件类型不支持预览',
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _openWithSystemApp,
            icon: const Icon(Icons.open_in_new),
            label: const Text('使用其他应用打开'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 获取文件图标
  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip;
      case 'mp3':
      case 'wav':
      case 'flac':
        return Icons.audio_file;
      case 'mp4':
      case 'avi':
      case 'mkv':
        return Icons.video_file;
      default:
        return Icons.insert_drive_file;
    }
  }
}