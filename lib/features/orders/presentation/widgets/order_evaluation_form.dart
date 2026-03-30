import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart'; // Import Bloc and Events
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/submit_evaluation_use_case.dart';
import 'package:dskk_flutter_refactor/core/utils/image_upload_helper.dart';
import 'dart:io'; // Import dart:io for File

/// Widget for submitting order evaluation (rating and comment).
class OrderEvaluationForm extends StatefulWidget {
  final Order order;

  const OrderEvaluationForm({super.key, required this.order});

  @override
  State<OrderEvaluationForm> createState() => _OrderEvaluationFormState();
}

class _OrderEvaluationFormState extends State<OrderEvaluationForm> {
  final _formKey = GlobalKey<FormState>();
  int _score = 5; // Default score as int
  final _contentController = TextEditingController();
  bool _isAnonymous = false;
  List<ImageProcessResult> _selectedImages = []; // Use ImageProcessResult
  bool _isProcessingImages = false;

  // --- Build Rating Stars ---
  Widget _buildRatingStars(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Center the stars
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        return IconButton(
          icon: Icon(
            starNumber <= _score ? Icons.star : Icons.star_border,
            color: starNumber <= _score ? Colors.amber : AppColors.textTertiary,
            size: 32, // Adjust size as needed
          ),
          onPressed: () {
            setState(() {
              _score = starNumber;
            });
          },
        );
      }),
    );
  }

  void _submitEvaluation() {
    if (_formKey.currentState!.validate()) {
      final orderId = widget.order.id;

      final params = SubmitEvaluationParams(
        orderId: orderId,
        score: _score.toDouble(),
        content: _contentController.text,
        isAnonymous: _isAnonymous,
        pictures: _selectedImages.map((result) => result.finalFile.path).toList(),
      );

      context.read<OrderDetailBloc>().add(SubmitEvaluationRequested(params: params));
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.borderSecondary,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题部分
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingLg),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.borderPrimary,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: AppDimensions.spacingSm),
                  Text(
                    '评价商品',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // 表单内容
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimensions.spacingSm),
                  // --- Replace Slider with Stars ---
                  Center(child: _buildRatingStars(context)),
                  const SizedBox(height: AppDimensions.spacingXxl), // Add more space after stars
                  TextFormField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      hintText: '分享您的使用体验吧～',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSm)),
                      filled: true,
                      fillColor: AppColors.backgroundSecondary,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingMd,
                        vertical: AppDimensions.spacingSm,
                      ),
                    ),
                    maxLines: 5,
                    maxLength: 200, // Optional limit
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),

                  // --- Picture Upload Section ---
                  Text('添加图片 (最多9张)', style: textTheme.bodyMedium),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Wrap(
                    spacing: AppDimensions.spacingSm,
                    runSpacing: AppDimensions.spacingSm,
                    children: [
                      // Display selected image thumbnails
                      ..._selectedImages.map((result) => _buildImageThumbnail(result)).toList(),
                      // Show "Add Picture" button if limit not reached
                      if (_selectedImages.length < 9 && !_isProcessingImages)
                        _buildAddPictureButton(context),
                      // Show processing indicator
                      if (_isProcessingImages)
                        _buildProcessingIndicator(),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  // --- Anonymous Checkbox ---
                  Row(
                    children: [
                      Checkbox(
                        value: _isAnonymous,
                        onChanged: (bool? value) {
                          setState(() {
                            _isAnonymous = value ?? false;
                          });
                        },
                      ),
                      Text('匿名评价', style: textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingXxl),
                  // --- Submit Button (already wrapped in BlocSelector) ---
                  BlocSelector<OrderDetailBloc, OrderDetailState, bool>(
                    selector: (state) {
                      return state is OrderDetailLoaded && state.isSubmittingEvaluation;
                    },
                    builder: (context, isSubmitting) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSubmitting || _score == 0 ? null : _submitEvaluation, // Disable if submitting or score is 0
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('提交评价'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper to build image thumbnail ---
  Widget _buildImageThumbnail(ImageProcessResult result) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.borderPrimary,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            image: DecorationImage(
              // Use the final processed file
              image: FileImage(result.finalFile),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Show compression info on success
        if (result.isSuccess && result.compressionRatio != null)
          Positioned(
            bottom: 2,
            left: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingXs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(AppDimensions.spacingXs),
              ),
              child: Text(
                '${result.compressionRatio!.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        // Show error indicator
        if (result.error != null)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(AppDimensions.spacingXs),
              ),
              child: const Icon(
                Icons.error,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        Positioned(
          top: -8,
          right: -8,
          child: IconButton(
            icon: Icon(Icons.remove_circle, color: AppColors.error, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() {
                _selectedImages.remove(result);
              });
            },
          ),
        ),
      ],
    );
  }

  // --- Helper to build "Add Picture" button ---
  Widget _buildAddPictureButton(BuildContext context) {
    return InkWell(
      onTap: _pickImage, // Call the image picking method
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          border: Border.all(color: AppColors.borderPrimary),
        ),
        child: Icon(Icons.add_a_photo, color: AppColors.textSecondary, size: 30),
      ),
    );
  }

  // --- Image Picking Logic using ImageUploadHelper ---
  Future<void> _pickImage() async {
    // Check limit before picking
    if (_selectedImages.length >= 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('最多只能上传9张图片')),
      );
      return;
    }

    setState(() {
      _isProcessingImages = true;
    });

    try {
      int remainingSlots = 9 - _selectedImages.length;

      // Use ImageUploadHelper for multiple image selection with review type compression
      final List<ImageProcessResult> results = await ImageUploadHelper.pickFromGallery(
        type: ImageUploadType.review,
        allowMultiple: true,
        maxImages: remainingSlots,
      );

      if (results.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(results);
        });

        // Show compression summary
        final successCount = results.where((r) => r.isSuccess).length;
        final errorCount = results.where((r) => r.error != null).length;

        if (successCount > 0) {
          final avgCompression = results
              .where((r) => r.compressionRatio != null)
              .map((r) => r.compressionRatio!)
              .fold(0.0, (a, b) => a + b) / successCount;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('成功处理 $successCount 张图片，平均压缩 ${avgCompression.toStringAsFixed(1)}%'),
              backgroundColor: AppColors.success,
            ),
          );
        }

        if (errorCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$errorCount 张图片处理失败'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      }
    } catch (e) {
       AppLogger.d('Error picking images: $e');
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('选择图片失败: ${e.toString()}')),
       );
    } finally {
      setState(() {
        _isProcessingImages = false;
      });
    }
  }

  // --- Helper to build processing indicator ---
  Widget _buildProcessingIndicator() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            '处理中...',
            style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
