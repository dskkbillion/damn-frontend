import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

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
  double _downloadProgress = 0;
  bool _isDownloading = false;
  String? _localPath;
  CancelToken? _cancelToken;

  @override
  void initState() {
    super.initState();
    _checkLocalFile();
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
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
        return 'word';
      case 'xls':
      case 'xlsx':
        return 'excel';
      case 'ppt':
      case 'pptx':
        return 'powerpoint';
      case 'zip':
      case 'rar':
      case '7z':
        return 'archive';
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
        return 'video';
      case 'mp3':
      case 'wav':
      case 'flac':
        return 'audio';
      default:
        return 'document';
    }
  }

  // 获取文件图标
  IconData _getFileIcon() {
    switch (_getFileType()) {
      case 'image':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'word':
        return Icons.description;
      case 'excel':
        return Icons.table_chart;
      case 'powerpoint':
        return Icons.slideshow;
      case 'archive':
        return Icons.folder_zip;
      case 'video':
        return Icons.video_file;
      case 'audio':
        return Icons.audio_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  // 获取文件图标颜色
  Color _getFileColor() {
    switch (_getFileType()) {
      case 'image':
        return Colors.green;
      case 'pdf':
        return Colors.red;
      case 'word':
        return Colors.blue;
      case 'excel':
        return Colors.green.shade700;
      case 'powerpoint':
        return Colors.orange;
      case 'archive':
        return Colors.purple;
      case 'video':
        return Colors.indigo;
      case 'audio':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  // 下载文件
  Future<void> _downloadFile() async {
    final l10n = AppLocalizations.of(context);
    
    // 请求存储权限
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        Fluttertoast.showToast(
          msg: l10n?.storagePermissionDenied ?? 'Storage permission denied',
        );
        return;
      }
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${dir.path}/downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      
      final filePath = '${downloadDir.path}/${widget.fileName}';
      
      _cancelToken = CancelToken();
      
      await Dio().download(
        widget.fileUrl,
        filePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = (received / total);
            });
          }
        },
      );

      setState(() {
        _localPath = filePath;
        _isDownloading = false;
      });

      widget.onDownloadComplete?.call();
      
      Fluttertoast.showToast(
        msg: l10n?.downloadCompleted ?? 'Download completed',
      );
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _downloadProgress = 0;
      });
      
      if (e is DioException && e.type == DioExceptionType.cancel) {
        // Download was cancelled
        return;
      }
      
      Fluttertoast.showToast(
        msg: l10n?.downloadFailed ?? 'Download failed',
      );
    }
  }

  // 打开文件
  Future<void> _openFile() async {
    final l10n = AppLocalizations.of(context);
    
    if (_localPath != null) {
      final result = await OpenFile.open(_localPath!);
      if (result.type != ResultType.done) {
        Fluttertoast.showToast(
          msg: l10n?.openFileFailed ?? 'Failed to open file',
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

  // 预览图片
  void _previewImage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImagePreviewPage(
          imageUrl: widget.fileUrl,
          fileName: widget.fileName,
        ),
      ),
    );
  }

  // 预览PDF
  void _previewPdf() {
    if (_localPath != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PdfPreviewPage(
            pdfPath: _localPath!,
            fileName: widget.fileName,
          ),
        ),
      );
    } else {
      // 先下载再预览
      _downloadFile().then((_) {
        if (_localPath != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PdfPreviewPage(
                pdfPath: _localPath!,
                fileName: widget.fileName,
              ),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fileType = _getFileType();
    
    return Card(
      child: InkWell(
        onTap: () {
          if (fileType == 'image') {
            _previewImage();
          } else if (fileType == 'pdf') {
            _previewPdf();
          } else {
            _openFile();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // 文件图标
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getFileColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getFileIcon(),
                  color: _getFileColor(),
                  size: 32,
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
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fileType == 'image' 
                        ? (l10n?.tapToPreview ?? 'Tap to preview')
                        : fileType == 'pdf'
                          ? (l10n?.tapToPreview ?? 'Tap to preview')
                          : (l10n?.tapToOpen ?? 'Tap to open'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (_isDownloading) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _downloadProgress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // 下载按钮或已下载标记
              if (_localPath != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    l10n?.downloaded ?? 'Downloaded',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                    ),
                  ),
                )
              else if (!_isDownloading)
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: _downloadFile,
                  tooltip: l10n?.downloadFile ?? 'Download file',
                )
              else
                IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () {
                    _cancelToken?.cancel();
                    setState(() {
                      _isDownloading = false;
                      _downloadProgress = 0;
                    });
                  },
                  tooltip: l10n?.cancelDownload ?? 'Cancel download',
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
        title: Text(fileName),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(imageUrl),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          loadingBuilder: (context, event) => Center(
            child: CircularProgressIndicator(
              value: event == null
                  ? null
                  : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
            ),
          ),
        ),
      ),
    );
  }
}

/// PDF预览页面
class PdfPreviewPage extends StatefulWidget {
  final String pdfPath;
  final String fileName;

  const PdfPreviewPage({
    super.key,
    required this.pdfPath,
    required this.fileName,
  });

  @override
  State<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  PDFViewController? _controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        actions: [
          if (_isReady)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      body: PDFView(
        filePath: widget.pdfPath,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        onRender: (pages) {
          setState(() {
            _totalPages = pages!;
            _isReady = true;
          });
        },
        onError: (error) {
          Fluttertoast.showToast(
            msg: l10n?.pdfLoadFailed ?? 'Failed to load PDF',
          );
        },
        onPageError: (page, error) {
          Fluttertoast.showToast(
            msg: '${l10n?.pageLoadFailed ?? "Failed to load page"} ${page! + 1}',
          );
        },
        onViewCreated: (PDFViewController controller) {
          _controller = controller;
        },
        onPageChanged: (int? page, int? total) {
          setState(() {
            _currentPage = page ?? 0;
          });
        },
      ),
    );
  }
}