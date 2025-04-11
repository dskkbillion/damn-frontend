import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart'; // Import Bloc and Events
import 'package:image_picker/image_picker.dart'; // Import image_picker
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
  List<String> _selectedImagePaths = []; // Renamed from _selectedImages
  final ImagePicker _picker = ImagePicker(); // Create an instance of ImagePicker

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
          const SnackBar(content: Text('错误：无法找到要评价的商品项')),
        );
        return;
      }

      context.read<OrderDetailBloc>().add(
            SubmitEvaluationRequested(
              orderId: widget.order.id.toString(), // Use ID as it's likely int
              orderItemId: orderItemId,
              score: _score.toDouble(),
              content: _contentController.text,
              isAnonymous: _isAnonymous,
              pictures: _selectedImagePaths, // Pass the list of paths
            ),
          );
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

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('评价订单', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              // --- Replace Slider with Stars ---
              Center(child: _buildRatingStars(context)),
              const SizedBox(height: 24), // Add more space after stars
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: '分享您的使用体验吧～',
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
              Text('添加图片 (最多9张)', style: textTheme.bodyMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  // Display selected image thumbnails
                  ..._selectedImagePaths.map((path) => _buildImageThumbnail(path)).toList(),
                  // Show "Add Picture" button if limit not reached
                  if (_selectedImagePaths.length < 9)
                    _buildAddPictureButton(context),
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
                  Text('匿名评价', style: textTheme.bodyMedium),
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
                          : const Text('提交评价'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper to build image thumbnail --- 
  Widget _buildImageThumbnail(String imagePath) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              // Use Image.file to display the selected image
              image: FileImage(File(imagePath)),
              fit: BoxFit.cover,
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
                _selectedImagePaths.remove(imagePath);
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

  // --- Image Picking Logic --- 
  Future<void> _pickImage() async {
    // Check limit before picking
    if (_selectedImagePaths.length >= 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('最多只能上传9张图片')),
      );
      return;
    }

    try {
      // Pick multiple images from the gallery
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: 80, // Optional: Adjust image quality
        maxWidth: 1024,    // Optional: Limit image width
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
           // Add newly selected images, respecting the limit
          int remainingSlots = 9 - _selectedImagePaths.length;
          _selectedImagePaths.addAll(
              pickedFiles.take(remainingSlots).map((file) => file.path));
        });
      }
    } catch (e) {
       // Handle potential errors (e.g., permission denied)
       print('Error picking images: $e');
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('选择图片失败: ${e.toString()}')),
       );
    }
  }
} 