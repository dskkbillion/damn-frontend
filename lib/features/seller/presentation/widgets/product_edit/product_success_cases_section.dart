import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_edit/product_edit_state.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/product_edit_models.dart';
import 'package:dskk_flutter_refactor/core/utils/image_upload_helper.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:dskk_flutter_refactor/core/widgets/app_network_image.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';

/// 成功案例 section，完全由 BLoC state 驱动，无本地状态。
///
/// 通过回调将用户操作传回父级：
/// - [onAdd]：添加案例（图片路径、标题、描述）
/// - [onEdit]：更新案例
/// - [onRemove]：删除案例
/// - [onRetryUpload]：重试上传
class ProductSuccessCasesSection extends StatelessWidget {
  const ProductSuccessCasesSection({
    super.key,
    required this.state,
    required this.onAdd,
    required this.onEdit,
    required this.onRemove,
    required this.onRetryUpload,
  });

  final ProductEditState state;
  final void Function(String imagePath, String title, String description) onAdd;
  final void Function(
    String caseId, {
    String? imagePath,
    String? title,
    String? description,
  }) onEdit;
  final void Function(String caseId) onRemove;
  final void Function(String caseId) onRetryUpload;

  InputDecoration get _lightBorderDecoration => InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.borderInput, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.borderInput, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd, vertical: AppDimensions.spacingMd),
        filled: true,
        fillColor: AppColors.backgroundCard,
      );

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(top: AppDimensions.spacingMd),
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).product_edit_success_cases ?? 'Success Cases',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (state.successCases.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingSm,
                      vertical: AppDimensions.spacingXs),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Text(
                    '${state.successCases.length}个案例',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                        ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: state.successCases.length + 1,
            itemBuilder: (context, index) {
              if (index == state.successCases.length) {
                return _AddSuccessCaseButton(
                  onTap: () => _showAddDialog(context),
                );
              }
              return _SuccessCaseItem(
                successCase: state.successCases[index],
                onEdit: () => _showEditDialog(context, state, state.successCases[index].id),
                onRemove: () => onRemove(state.successCases[index].id),
                onRetryUpload: () => onRetryUpload(state.successCases[index].id),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedImagePath;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            AppLocalizations.of(context).product_edit_add_success_case ?? 'Add Success Case',
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
              maxWidth: double.maxFinite,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () async {
                      final results = await ImageUploadHelper.pickFromGallery(
                        type: ImageUploadType.product,
                        allowMultiple: false,
                      );
                      if (results.isNotEmpty) {
                        setState(() {
                          selectedImagePath = results.first.finalFile.path;
                        });
                      }
                    },
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderInput),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      ),
                      child: selectedImagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                              child: Image.file(
                                File(selectedImagePath!),
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_photo_alternate,
                                    size: 32, color: AppColors.textTertiary),
                                const SizedBox(height: AppDimensions.spacingXs),
                                Text(
                                  '点击选择图片',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textTertiary,
                                      ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  TextField(
                    controller: titleController,
                    decoration: _lightBorderDecoration.copyWith(
                      labelText: '案例标题',
                      hintText: '简短描述这个案例',
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: _lightBorderDecoration.copyWith(
                      labelText: '案例描述',
                      hintText: '详细描述案例的背景、执行过程或效果',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedImagePath != null && titleController.text.isNotEmpty) {
                  onAdd(selectedImagePath!, titleController.text, descriptionController.text);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请选择图片并输入标题')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, ProductEditState state, String caseId) {
    final successCase = state.successCases.firstWhere((c) => c.id == caseId);
    final titleController = TextEditingController(text: successCase.title);
    final descriptionController = TextEditingController(text: successCase.description);
    String? selectedImagePath = successCase.imagePath;
    final String currentImageUrl = successCase.imageUrl;
    bool imageChanged = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            AppLocalizations.of(context).product_edit_edit_success_case ?? 'Edit Success Case',
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
              maxWidth: double.maxFinite,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () async {
                      final results = await ImageUploadHelper.pickFromGallery(
                        type: ImageUploadType.product,
                        allowMultiple: false,
                      );
                      if (results.isNotEmpty) {
                        setState(() {
                          selectedImagePath = results.first.finalFile.path;
                          imageChanged = true;
                        });
                      }
                    },
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderInput),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                        child: _EditDialogImage(
                          localPath: selectedImagePath,
                          imageUrl: currentImageUrl,
                          imageChanged: imageChanged,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  TextField(
                    controller: titleController,
                    decoration: _lightBorderDecoration.copyWith(
                      labelText: '案例标题',
                      hintText: '简短描述这个案例',
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: _lightBorderDecoration.copyWith(
                      labelText: '案例描述',
                      hintText: '详细描述案例的背景、执行过程或效果',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedImagePath != null &&
                    selectedImagePath!.isNotEmpty &&
                    titleController.text.isNotEmpty) {
                  Navigator.pop(context);
                  onEdit(
                    caseId,
                    imagePath: imageChanged ? selectedImagePath : null,
                    title: titleController.text,
                    description: descriptionController.text,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请选择图片并输入标题')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 私有子 Widget
// ---------------------------------------------------------------------------

class _AddSuccessCaseButton extends StatelessWidget {
  const _AddSuccessCaseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderPrimary, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          color: AppColors.backgroundSecondary,
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 32, color: AppColors.textTertiary),
            SizedBox(height: AppDimensions.spacingSm),
            Text('添加案例',
                style: TextStyle(color: AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }
}

class _SuccessCaseItem extends StatelessWidget {
  const _SuccessCaseItem({
    required this.successCase,
    required this.onEdit,
    required this.onRemove,
    required this.onRetryUpload,
  });

  final SuccessCase successCase;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback onRetryUpload;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderInput),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppDimensions.radiusSm)),
                  child: _SuccessCaseImage(
                    successCase: successCase,
                    onRetryUpload: onRetryUpload,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _OverlayIconButton(
                        icon: Icons.edit,
                        onTap: onEdit,
                      ),
                      const SizedBox(width: AppDimensions.spacingXs),
                      _OverlayIconButton(
                        icon: Icons.close,
                        onTap: onRemove,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    successCase.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  Expanded(
                    child: Text(
                      successCase.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayIconButton extends StatelessWidget {
  const _OverlayIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingXs),
        decoration: BoxDecoration(
          color: AppColors.overlayHeavy,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.onPrimary, size: 16),
      ),
    );
  }
}

class _SuccessCaseImage extends StatelessWidget {
  const _SuccessCaseImage({required this.successCase, required this.onRetryUpload});
  final SuccessCase successCase;
  final VoidCallback onRetryUpload;

  @override
  Widget build(BuildContext context) {
    if (successCase.uploadStatus == SuccessCaseUploadStatus.uploading) {
      return Stack(
        children: [
          if (successCase.imagePath.isNotEmpty)
            Image.file(
              File(successCase.imagePath),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          Container(color: AppColors.overlayLight),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  value: successCase.uploadProgress / 100,
                  backgroundColor: AppColors.onPrimary.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Text(
                  '${successCase.uploadProgress.toInt()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onPrimary,
                      ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (successCase.uploadStatus == SuccessCaseUploadStatus.failed) {
      return Stack(
        children: [
          if (successCase.imagePath.isNotEmpty)
            Image.file(
              File(successCase.imagePath),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              color: AppColors.textTertiary, // blend mode desaturation overlay
              colorBlendMode: BlendMode.saturation,
            ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 40),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  '上传失败',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                ),
                if (successCase.canRetry)
                  TextButton(
                    onPressed: onRetryUpload,
                    child: Text(
                      '重试',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    if (successCase.imageUrl.isNotEmpty) {
      return AppNetworkImage(
        imageUrl: successCase.imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorWidget: successCase.imagePath.isNotEmpty
            ? Image.file(
                File(successCase.imagePath),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _brokenImage(),
              )
            : _brokenImage(),
      );
    }

    if (successCase.imagePath.isNotEmpty) {
      return Image.file(
        File(successCase.imagePath),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _brokenImage(),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.borderPrimary,
      child: const Icon(Icons.image, size: 40, color: AppColors.textTertiary),
    );
  }

  Widget _brokenImage() => Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.borderPrimary,
        child: const Icon(Icons.broken_image, size: 40, color: AppColors.textTertiary),
      );
}

class _EditDialogImage extends StatelessWidget {
  const _EditDialogImage({
    required this.localPath,
    required this.imageUrl,
    required this.imageChanged,
  });

  final String? localPath;
  final String? imageUrl;
  final bool imageChanged;

  @override
  Widget build(BuildContext context) {
    if (imageChanged && localPath != null && localPath!.isNotEmpty) {
      return Image.file(File(localPath!), fit: BoxFit.cover, errorBuilder: _errorFallback);
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return AppNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        errorWidget: (localPath != null && localPath!.isNotEmpty)
            ? Image.file(
                File(localPath!),
                fit: BoxFit.cover,
                errorBuilder: _errorFallback,
              )
            : null,
      );
    }

    if (localPath != null && localPath!.isNotEmpty) {
      return Image.file(File(localPath!), fit: BoxFit.cover, errorBuilder: _errorFallback);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add_photo_alternate, size: 32, color: AppColors.textTertiary),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(
          '点击选择图片',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
        ),
      ],
    );
  }

  Widget _errorFallback(BuildContext context, Object error, StackTrace? stackTrace) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.broken_image, size: 32, color: AppColors.textTertiary),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(
          '图片加载失败',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
        ),
      ],
    );
  }
}
