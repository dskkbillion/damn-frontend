import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/widgets/skeleton/shimmer_effect.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
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
    super.key,
    required this.imagePaths,
    required this.initialIndex,
    required this.mainImageIndex,
    required this.onSetMainImage,
    required this.onDeleteImage,
  });

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
          icon: const Icon(Icons.close, color: AppColors.onPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.imagePaths.length}',
          style: const TextStyle(color: AppColors.onPrimary),
        ),
        centerTitle: true,
        actions: [
          // 删除按钮
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.onPrimary),
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
                    AppColors.overlay.withValues(alpha: 0.8),
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
                            const Icon(Icons.star, color: AppColors.onPrimary, size: 16),
                            const SizedBox(width: 4),
                            Text(AppLocalizations.of(context).seller_image_preview_main_image ?? 'Main', style: const TextStyle(color: AppColors.onPrimary)),
                          ],
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () => _setAsMainImage(),
                        icon: const Icon(Icons.star_border, size: 16),
                        label: Text(AppLocalizations.of(context).seller_image_preview_set_main ?? 'Set as Main'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.onPrimary.withValues(alpha: 0.2),
                          foregroundColor: AppColors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    
                    // 页面指示器
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.overlay,
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
                                  ? AppColors.onPrimary
                                  : AppColors.onPrimary.withValues(alpha: 0.3),
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
      return CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.contain,
        placeholder: (ctx, url) => const Center(
          child: SizedBox(
            width: 48,
            height: 48,
            child: ShimmerEffect(child: CircleAvatar()),
          ),
        ),
        errorWidget: (context, url, error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: AppColors.onPrimary, size: 64),
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context).seller_image_preview_load_failed ?? 'Image load failed', style: const TextStyle(color: AppColors.onPrimary)),
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
                const Icon(Icons.error, color: AppColors.onPrimary, size: 64),
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context).seller_image_preview_load_failed ?? 'Image load failed', style: const TextStyle(color: AppColors.onPrimary)),
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
        title: Text(AppLocalizations.of(context).seller_image_preview_delete_title ?? 'Delete Image'),
        content: Text(AppLocalizations.of(context).seller_image_preview_delete_confirm(_currentIndex + 1) ?? 'Delete image ${_currentIndex + 1}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).seller_common_cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 关闭对话框
              _deleteCurrentImage();
            },
            child: Text(AppLocalizations.of(context).seller_image_preview_delete ?? 'Delete', style: const TextStyle(color: AppColors.error)),
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