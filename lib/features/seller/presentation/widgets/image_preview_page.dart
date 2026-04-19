import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';

/// 图片预览页面
class ImagePreviewPage extends StatefulWidget {
  /// 图片路径列表
  final List<String> imagePaths;
  
  /// 初始显示的图片索引
  final int initialIndex;
  
  /// 主图索引（第一张是主图）
  final int mainImageIndex;
  
  /// 设置主图回调
  final Function(int index) onSetMainImage;
  
  /// 删除图片回调
  final Function(int index) onDeleteImage;

  const ImagePreviewPage({
    Key? key,
    required this.imagePaths,
    required this.initialIndex,
    required this.mainImageIndex,
    required this.onSetMainImage,
    required this.onDeleteImage,
  }) : super(key: key);

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.imagePaths.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          // 删除按钮
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () => _showDeleteConfirmDialog(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 图片查看器
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imagePaths.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 3.0,
                child: Center(
                  child: _buildImageWidget(widget.imagePaths[index]),
                ),
              );
            },
          ),
          
          // 底部操作栏
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 主图标识/设置按钮
                    if (_currentIndex == widget.mainImageIndex)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(AppLocalizations.of(context)?.seller_image_preview_main_image ?? 'Main', style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () => _setAsMainImage(),
                        icon: const Icon(Icons.star_border, size: 16),
                        label: Text(AppLocalizations.of(context)?.seller_image_preview_set_main ?? 'Set as Main'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    
                    // 页面指示器
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          widget.imagePaths.length,
                          (index) => Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == _currentIndex
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建图片组件
  Widget _buildImageWidget(String imagePath) {
    // 检查是否是网络图片
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              color: Colors.white,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.white, size: 64),
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context)?.seller_image_preview_load_failed ?? 'Image load failed', style: const TextStyle(color: Colors.white)),
              ],
            ),
          );
        },
      );
    } else {
      // 本地图片
      return Image.file(
        File(imagePath),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.white, size: 64),
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context)?.seller_image_preview_load_failed ?? 'Image load failed', style: const TextStyle(color: Colors.white)),
              ],
            ),
          );
        },
      );
    }
  }

  /// 设置为主图
  void _setAsMainImage() {
    widget.onSetMainImage(_currentIndex);
    Navigator.of(context).pop();
  }

  /// 显示删除确认对话框
  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.seller_image_preview_delete_title ?? 'Delete Image'),
        content: Text(AppLocalizations.of(context)?.seller_image_preview_delete_confirm(_currentIndex + 1) ?? 'Delete image ${_currentIndex + 1}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)?.seller_common_cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 关闭对话框
              _deleteCurrentImage();
            },
            child: Text(AppLocalizations.of(context)?.seller_image_preview_delete ?? 'Delete', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 删除当前图片
  void _deleteCurrentImage() {
    widget.onDeleteImage(_currentIndex);
    
    // 如果删除后没有图片了，关闭预览页面
    if (widget.imagePaths.length <= 1) {
      Navigator.of(context).pop();
      return;
    }
    
    // 调整当前索引
    if (_currentIndex >= widget.imagePaths.length - 1) {
      _currentIndex = widget.imagePaths.length - 2;
    }
    
    Navigator.of(context).pop(); // 关闭预览页面，让父页面刷新
  }
} 