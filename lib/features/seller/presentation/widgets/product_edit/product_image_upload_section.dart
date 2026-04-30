import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_edit/product_edit_state.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:dskk_flutter_refactor/core/widgets/app_network_image.dart';
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
      color: AppColors.backgroundCard,
      margin: const EdgeInsets.only(top: AppDimensions.spacingMd),
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '服务封面图',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              _UploadStatusIndicator(state: state),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: AppDimensions.spacingMd),
            child: Text(
              '支持jpg、png、jpeg格式，单张不超过5MB，最多可上传9张图片',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
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
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd, vertical: AppDimensions.spacingXs),
        decoration: BoxDecoration(
          color: AppColors.info.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: AppDimensions.spacingLg,
              height: AppDimensions.spacingLg,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingSm),
            Text(
              'Uploading ${state.uploadedCount}/${state.totalUploadCount}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.info,
                  ),
            ),
          ],
        ),
      );
    }

    if (state.uploadStatus == UploadStatus.success && state.uploadedImageUrls.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd, vertical: AppDimensions.spacingXs),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 16, color: AppColors.success),
            const SizedBox(width: AppDimensions.spacingSm),
            Text(
              '上传成功',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                  ),
            ),
          ],
        ),
      );
    }

    if (state.uploadStatus == UploadStatus.failure) {
      return Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd, vertical: AppDimensions.spacingXs),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, size: 16, color: AppColors.error),
            const SizedBox(width: AppDimensions.spacingSm),
            Text(
              '上传失败',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                  ),
            ),
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
              border: Border.all(color: AppColors.borderInput),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm - 1),
              child: _imageChild(),
            ),
          ),
          Positioned(
            top: AppDimensions.spacingXs,
            right: AppDimensions.spacingXs,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.spacingXs),
                decoration: BoxDecoration(
                  color: AppColors.overlayHeavy,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: AppColors.onPrimary, size: 16),
              ),
            ),
          ),
          if (index == 0)
            Positioned(
              bottom: AppDimensions.spacingXs,
              left: AppDimensions.spacingXs,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingXs + 2,
                    vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Text(
                  '主图',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onPrimary,
                        fontSize: 10,
                      ),
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
      return AppNetworkImage(
        imageUrl: networkUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorWidget: const Center(child: Icon(Icons.image_not_supported, color: AppColors.textTertiary)),
      );
    }
    return const Center(
      child: Icon(Icons.image_not_supported, size: 40, color: AppColors.textTertiary),
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
            color: canAdd ? AppColors.borderInput : AppColors.borderPrimary,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          color: canAdd ? AppColors.backgroundCard : AppColors.backgroundSecondary,
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
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Icon(Icons.cloud_upload,
                      color: Theme.of(context).colorScheme.primary, size: 12),
                ],
              )
            else
              Icon(
                Icons.add_photo_alternate_outlined,
                color: canAdd
                    ? Theme.of(context).colorScheme.primary
                    : AppColors.textTertiary,
                size: 28,
              ),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              isUploading ? 'Uploading...' : 'Add Image',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: canAdd ? AppColors.textPrimary : AppColors.textTertiary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
