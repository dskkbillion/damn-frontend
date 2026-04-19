import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart'; // Import Bloc and Events
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/submit_evaluation_use_case.dart';
import 'package:dskk_flutter_refactor/core/utils/image_upload_helper.dart';
import 'dart:io'; // Import dart:io for File
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

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
            color: starNumber <= _score ? Colors.amber : Colors.grey,
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
      final orderItemId = widget.order.items.isNotEmpty ? widget.order.items.first.id : -1;
      if (orderItemId == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.order_evaluation_error_no_item), backgroundColor: Colors.red),
        );
        return;
      }

      final params = SubmitEvaluationParams(
        orderItemId: orderItemId,
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.order_evaluation_title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // 表单内容
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // --- Replace Slider with Stars ---
                  Center(child: _buildRatingStars(context)),
                  const SizedBox(height: 24), // Add more space after stars
                  TextFormField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.order_evaluation_hint,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    maxLines: 5,
                    maxLength: 200, // Optional limit
                  ),
                  const SizedBox(height: 16),

                  // --- Picture Upload Section ---
                  Text(AppLocalizations.of(context)!.order_evaluation_add_images, style: textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
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
                  const SizedBox(height: 16),
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
                      Text(AppLocalizations.of(context)!.order_evaluation_anonymous, style: textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 24),
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
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text(AppLocalizations.of(context)!.order_evaluation_submit),
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
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
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
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
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
                color: Colors.red.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
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
            icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
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
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[400]!)
        ),
        child: Icon(Icons.add_a_photo, color: Colors.grey[600], size: 30),
      ),
    );
  }

  // --- Image Picking Logic using ImageUploadHelper --- 
  Future<void> _pickImage() async {
    // Check limit before picking
    if (_selectedImages.length >= 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.order_evaluation_max_images)),
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
              content: Text(AppLocalizations.of(context)!.order_evaluation_success_count(successCount, avgCompression.toStringAsFixed(1))),
              backgroundColor: Colors.green,
            ),
          );
        }
        
        if (errorCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.order_evaluation_failed_count(errorCount)),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
       print('Error picking images: $e');
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(AppLocalizations.of(context)!.order_evaluation_pick_failed(e.toString()))),
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
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.order_evaluation_processing,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
} 