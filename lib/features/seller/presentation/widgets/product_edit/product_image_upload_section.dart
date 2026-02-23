import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_edit/product_edit_state.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/enums/product_status.dart';
import '../image_preview_page.dart';

/// 商品封面图上传 section，完全由 BLoC state 驱动，无本地状态。
///
/// 通过回调将操作传回父级：
/// - [onPickImages]：选择图片（replaceExisting 控制是否替换）
/// - [onRemoveImage]：删除指定 index 图片
/// - [onSetMainImage]：设置主图
class ProductImageUploadSection extends StatelessWidget {
  const ProductImageUploadSection({
    super.key,
    required this.state,
    required this.onPickImages,
    required this.onRemoveImage,
    required this.onSetMainImage,
  });

  final ProductEditState state;
  final void Function({bool replaceExisting}) onPickImages;
  final void Function(int index) onRemoveImage;
  final void Function(int index) onSetMainImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '服务封面图',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              _UploadStatusIndicator(state: state),
            ],
          ),
          const SizedBox(height: 12),
          _ImageGrid(
            state: state,
            onPickImages: onPickImages,
            onRemoveImage: onRemoveImage,
            onSetMainImage: onSetMainImage,
          ),
          if (state.uploadStatus == UploadStatus.failure && state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '上传错误: ${state.errorMessage}',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              '支持jpg、png、jpeg格式，单张不超过5MB，最多可上传9张图片',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 上传状态指示器
// ---------------------------------------------------------------------------

class _UploadStatusIndicator extends StatelessWidget {
  const _UploadStatusIndicator({required this.state});
  final ProductEditState state;

  @override
  Widget build(BuildContext context) {
    if (state.uploadStatus == UploadStatus.uploading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Uploading ${state.uploadedCount}/${state.totalUploadCount}',
              style: TextStyle(fontSize: 12, color: Colors.blue[700]),
            ),
          ],
        ),
      );
    }

    if (state.uploadStatus == UploadStatus.success && state.uploadedImageUrls.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
            const SizedBox(width: 8),
            Text('上传成功', style: TextStyle(fontSize: 12, color: Colors.green[700])),
          ],
        ),
      );
    }

    if (state.uploadStatus == UploadStatus.failure) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, size: 16, color: Colors.red),
            SizedBox(width: 8),
            Text('上传失败', style: TextStyle(fontSize: 12, color: Colors.red)),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// ---------------------------------------------------------------------------
// 图片网格
// ---------------------------------------------------------------------------

class _ImageGrid extends StatelessWidget {
  const _ImageGrid({
    required this.state,
    required this.onPickImages,
    required this.onRemoveImage,
    required this.onSetMainImage,
  });

  final ProductEditState state;
  final void Function({bool replaceExisting}) onPickImages;
  final void Function(int index) onRemoveImage;
  final void Function(int index) onSetMainImage;

  @override
  Widget build(BuildContext context) {
    final allImages = [
      ...state.uploadedImageUrls,
      ...state.selectedImagePaths,
    ];

    final hasImages = allImages.isNotEmpty;
    int totalItemCount = hasImages ? allImages.length + 1 : 1;
    if (totalItemCount > 10) totalItemCount = 10;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: totalItemCount,
      itemBuilder: (context, index) {
        if (hasImages && index == totalItemCount - 1) {
          return _AddImageButton(
            state: state,
            onPickImages: onPickImages,
          );
        }
        if (index < allImages.length) {
          final imagePath = allImages[index];
          final isNetwork = imagePath.startsWith('http');
          return _ImageItem(
            state: state,
            index: index,
            localPath: isNetwork ? null : imagePath,
            networkUrl: isNetwork ? imagePath : null,
            onRemove: () => onRemoveImage(index),
            onTap: () => _openPreview(context, allImages, index),
          );
        }
        return _AddImageButton(state: state, onPickImages: onPickImages);
      },
    );
  }

  void _openPreview(BuildContext context, List<String> allImages, int index) {
    if (allImages.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ImagePreviewPage(
            imagePaths: allImages,
            initialIndex: index,
            mainImageIndex: 0,
            onSetMainImage: onSetMainImage,
            onDeleteImage: onRemoveImage,
          ),
        ),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// 单张图片项
// ---------------------------------------------------------------------------

class _ImageItem extends StatelessWidget {
  const _ImageItem({
    required this.state,
    required this.index,
    required this.localPath,
    required this.networkUrl,
    required this.onRemove,
    required this.onTap,
  });

  final ProductEditState state;
  final int index;
  final String? localPath;
  final String? networkUrl;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: _imageChild(),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
          if (index == 0)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '主图',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _imageChild() {
    if (localPath != null) {
      return Image.file(
        File(localPath!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (networkUrl != null) {
      return Image.network(
        networkUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
      );
    }
    return const Center(
      child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
    );
  }
}

// ---------------------------------------------------------------------------
// 添加图片按钮
// ---------------------------------------------------------------------------

class _AddImageButton extends StatelessWidget {
  const _AddImageButton({required this.state, required this.onPickImages});

  final ProductEditState state;
  final void Function({bool replaceExisting}) onPickImages;

  @override
  Widget build(BuildContext context) {
    final canAdd = state.selectedImagePaths.length < 9;
    final isUploading = state.uploadStatus == UploadStatus.uploading;

    return InkWell(
      onTap: canAdd ? () => onPickImages(replaceExisting: false) : null,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: canAdd ? Colors.grey[300]! : Colors.grey[200]!,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: canAdd ? Colors.white : Colors.grey[100],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isUploading)
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Icon(Icons.cloud_upload, color: Theme.of(context).primaryColor, size: 12),
                ],
              )
            else
              Icon(
                Icons.add_photo_alternate_outlined,
                color: canAdd ? Theme.of(context).primaryColor : Colors.grey,
                size: 28,
              ),
            const SizedBox(height: 4),
            Text(
              isUploading ? 'Uploading...' : 'Add Image',
              style: TextStyle(
                fontSize: 12,
                color: canAdd ? Colors.grey[700] : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
