import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

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
              padding: EdgeInsets.all(AppDimensions.spacingXl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8), // TODO(reskin): review this color
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
                        padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacingLg,
                            vertical: AppDimensions.spacingSm),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.white, size: 16),
                            SizedBox(width: AppDimensions.spacingXs),
                            const Text('主图', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () => _setAsMainImage(),
                        icon: const Icon(Icons.star_border, size: 16),
                        label: const Text('设为主图'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                          ),
                        ),
                      ),
                    
                    // 页面指示器
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingMd,
                          vertical: AppDimensions.spacingXs),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5), // TODO(reskin): review this color
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
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
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.white, size: 64),
                SizedBox(height: AppDimensions.spacingLg),
                Text('图片加载失败', style: TextStyle(color: Colors.white)),
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
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.white, size: 64),
                SizedBox(height: AppDimensions.spacingLg),
                Text('图片加载失败', style: TextStyle(color: Colors.white)),
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
        title: const Text('删除图片'),
        content: Text('确定要删除第 ${_currentIndex + 1} 张图片吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 关闭对话框
              _deleteCurrentImage();
            },
            child: Text('删除', style: TextStyle(color: AppColors.error)),
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