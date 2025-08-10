import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// 交付文件查看器组件
class DeliveryFileViewer extends StatefulWidget {
  final String fileUrl;
  final String fileName;
  final VoidCallback? onDownloadComplete;

  const DeliveryFileViewer({
    super.key,
    required this.fileUrl,
    required this.fileName,
    this.onDownloadComplete,
  });

  @override
  State<DeliveryFileViewer> createState() => _DeliveryFileViewerState();
}

class _DeliveryFileViewerState extends State<DeliveryFileViewer> {
  // String? _taskId;  // TODO: Use for actual download tracking
  int _downloadProgress = 0;
  bool _isDownloading = false;
  String? _localPath;

  @override
  void initState() {
    super.initState();
    _checkLocalFile();
    
    // 监听下载进度
    FlutterDownloader.registerCallback(_downloadCallback);
  }

  // 检查文件是否已经下载
  Future<void> _checkLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/downloads/${widget.fileName}';
    final file = File(filePath);
    
    if (await file.exists()) {
      setState(() {
        _localPath = filePath;
      });
    }
  }

  // 下载回调
  static void _downloadCallback(String id, int status, int progress) {
    // 这是一个静态方法，无法直接更新UI
    // 需要通过其他方式通知UI更新
  }

  // 获取文件类型
  String _getFileType() {
    final extension = widget.fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return 'image';
      case 'pdf':
        return 'pdf';
      case 'doc':
      case 'docx':
        return 'document';
      case 'xls':
      case 'xlsx':
        return 'spreadsheet';
      case 'ppt':
      case 'pptx':
        return 'presentation';
      case 'txt':
        return 'text';
      case 'zip':
      case 'rar':
      case '7z':
        return 'archive';
      default:
        return 'other';
    }
  }

  // 获取文件图标
  IconData _getFileIcon() {
    switch (_getFileType()) {
      case 'image':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'document':
        return Icons.description;
      case 'spreadsheet':
        return Icons.table_chart;
      case 'presentation':
        return Icons.slideshow;
      case 'text':
        return Icons.text_snippet;
      case 'archive':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }

  // 获取文件颜色
  Color _getFileColor() {
    switch (_getFileType()) {
      case 'image':
        return Colors.blue;
      case 'pdf':
        return Colors.red;
      case 'document':
        return Colors.blue[700]!;
      case 'spreadsheet':
        return Colors.green;
      case 'presentation':
        return Colors.orange;
      case 'text':
        return Colors.grey;
      case 'archive':
        return Colors.purple;
      default:
        return Colors.grey[600]!;
    }
  }

  // 下载文件
  Future<void> _downloadFile() async {
    final l10n = AppLocalizations.of(context)!;
    
    // 请求存储权限
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      Fluttertoast.showToast(
        msg: l10n.storagePermissionRequired,
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      // 获取下载目录
      final dir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${dir.path}/downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      // 开始下载
      // _taskId = 
      await FlutterDownloader.enqueue(
        url: widget.fileUrl,
        savedDir: downloadDir.path,
        fileName: widget.fileName,
        showNotification: true,
        openFileFromNotification: true,
        saveInPublicStorage: true,
      );

      // 模拟下载进度（实际应该通过FlutterDownloader回调获取）
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) {
          setState(() {
            _downloadProgress = i;
          });
        }
      }

      setState(() {
        _isDownloading = false;
        _localPath = '${downloadDir.path}/${widget.fileName}';
      });

      Fluttertoast.showToast(
        msg: l10n.downloadCompleted,
        toastLength: Toast.LENGTH_SHORT,
      );

      widget.onDownloadComplete?.call();
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      
      Fluttertoast.showToast(
        msg: '${l10n.downloadFailed}: $e',
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  // 打开文件
  Future<void> _openFile() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (_localPath != null) {
      final result = await OpenFile.open(_localPath!);
      if (result.type != ResultType.done) {
        Fluttertoast.showToast(
          msg: '${l10n.openFileFailed}: ${result.message}',
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } else {
      // 如果文件未下载，先下载
      await _downloadFile();
      if (_localPath != null) {
        await OpenFile.open(_localPath!);
      }
    }
  }

  // 预览文件
  void _previewFile() {
    final fileType = _getFileType();
    
    if (fileType == 'image') {
      // 图片预览
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ImagePreviewPage(
            imageUrl: widget.fileUrl,
            fileName: widget.fileName,
          ),
        ),
      );
    } else if (fileType == 'pdf') {
      // PDF预览
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PdfPreviewPage(
            pdfUrl: widget.fileUrl,
            fileName: widget.fileName,
            localPath: _localPath,
          ),
        ),
      );
    } else {
      // 其他文件类型，直接打开
      _openFile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fileType = _getFileType();
    final canPreview = fileType == 'image' || fileType == 'pdf';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: canPreview ? _previewFile : _openFile,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 文件图标
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getFileColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getFileIcon(),
                  color: _getFileColor(),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              
              // 文件信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.fileName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (canPreview) ...[
                          Icon(
                            Icons.visibility,
                            size: 14,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.tapToPreview,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ] else ...[
                          Icon(
                            Icons.touch_app,
                            size: 14,
                            color: Theme.of(context).hintColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.tapToOpen,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                        if (_localPath != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              l10n.downloaded,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // 下载按钮
              if (_isDownloading)
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _downloadProgress / 100,
                        strokeWidth: 2,
                      ),
                      Text(
                        '$_downloadProgress%',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                )
              else if (_localPath == null)
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: _downloadFile,
                  tooltip: l10n.downloadFile,
                )
              else
                IconButton(
                  icon: const Icon(Icons.folder_open),
                  onPressed: _openFile,
                  tooltip: l10n.openFile,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 图片预览页面
class ImagePreviewPage extends StatelessWidget {
  final String imageUrl;
  final String fileName;

  const ImagePreviewPage({
    super.key,
    required this.imageUrl,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          fileName,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PhotoView(
        imageProvider: CachedNetworkImageProvider(imageUrl),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(
            value: event == null 
              ? null 
              : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
          ),
        ),
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 48,
          ),
        ),
      ),
    );
  }
}

/// PDF预览页面
class PdfPreviewPage extends StatefulWidget {
  final String pdfUrl;
  final String fileName;
  final String? localPath;

  const PdfPreviewPage({
    super.key,
    required this.pdfUrl,
    required this.fileName,
    this.localPath,
  });

  @override
  State<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  String? _localPath;
  bool _isLoading = true;
  int _totalPages = 0;
  int _currentPage = 1;
  // PDFViewController? _pdfViewController;  // TODO: Use for PDF navigation

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    if (widget.localPath != null) {
      setState(() {
        _localPath = widget.localPath;
        _isLoading = false;
      });
    } else {
      // 下载PDF文件
      await _downloadPdf();
    }
  }

  Future<void> _downloadPdf() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${dir.path}/downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      final filePath = '${downloadDir.path}/${widget.fileName}';
      
      // 这里应该使用Dio或其他方式下载文件
      // 暂时使用FlutterDownloader
      await FlutterDownloader.enqueue(
        url: widget.pdfUrl,
        savedDir: downloadDir.path,
        fileName: widget.fileName,
        showNotification: false,
        openFileFromNotification: false,
      );

      // 等待下载完成（简化处理）
      await Future.delayed(const Duration(seconds: 3));

      setState(() {
        _localPath = filePath;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF加载失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        actions: [
          if (_totalPages > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _localPath == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(l10n.pdfLoadFailed),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPdf,
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : PDFView(
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('PDF显示错误: $error'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  onPageError: (page, error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('第$page页加载错误: $error'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  onViewCreated: (PDFViewController pdfViewController) {
                    // _pdfViewController = pdfViewController;  // TODO: Use for PDF navigation
                  },
                  onPageChanged: (int? page, int? total) {
                    setState(() {
                      _currentPage = (page ?? 0) + 1;
                      _totalPages = total ?? 0;
                    });
                  },
                ),
    );
  }
}