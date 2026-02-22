import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
// Import OrderItem
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_item.dart';
import 'dart:io'; // Import dart:io for File
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc
import '../bloc/after_sales_bloc.dart'; // Import Bloc/Event
import 'package:dskk_flutter_refactor/core/utils/image_upload_helper.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';

/// 售后申请表单页面
class AfterSalesApplyPage extends StatefulWidget {
  // Keep these as they identify the request
  final int orderItemId;
  final String afterSalesType; // e.g., 'REMAKE', 'SUPPLEMENT', 'REFUND'
  // Add OrderItem to display info
  final OrderItem orderItem;

  const AfterSalesApplyPage({
    super.key,
    required this.orderItemId,
    required this.afterSalesType,
    required this.orderItem, // Add to constructor
  });

  @override
  State<AfterSalesApplyPage> createState() => _AfterSalesApplyPageState();
}

class _AfterSalesApplyPageState extends State<AfterSalesApplyPage> {
  final _formKey = GlobalKey<FormState>(); // Form key
  String? _selectedReason; // State for selected reason
  final _descriptionController = TextEditingController(); // Controller for description
  final _amountController = TextEditingController(); // Controller for amount
  // Use ImageProcessResult for better image handling
  List<ImageProcessResult> _selectedImages = [];
  final int _maxImages = 9; // Define max images based on prototype hint
  bool _isProcessingImages = false;

  // TODO: Define these reasons based on actual requirements/backend enum
  final List<String> _afterSalesReasons = [
    '商品质量问题',
    '商品与描述不符',
    '卖家发错货',
    '不想要了',
    '其他',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose(); // Dispose amount controller
    super.dispose();
  }

  // --- Image Picking Logic ---
  Future<void> _pickImages() async {
    // Calculate remaining slots
    final remainingSlots = _maxImages - _selectedImages.length;
    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('最多只能上传 $_maxImages 张图片')),
      );
      return;
    }

    setState(() {
      _isProcessingImages = true;
    });

    try {
      // Use ImageUploadHelper for after-sales images
      final List<ImageProcessResult> results = await ImageUploadHelper.pickFromGallery(
        type: ImageUploadType.afterSales,
        allowMultiple: true,
        maxImages: remainingSlots,
      );

      if (results.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(results);
        });
        
        // Show processing summary
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
              backgroundColor: Colors.green,
            ),
          );
        }
        
        if (errorCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$errorCount 张图片处理失败'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.d("Error picking images: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择图片失败: $e')),
      );
    } finally {
      setState(() {
        _isProcessingImages = false;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }
  // --------------------------

  @override
  Widget build(BuildContext context) {
    // Determine the AppBar title based on the type
    String title = '申请售后';
    if (widget.afterSalesType == 'REMAKE') {
      title = '申请重新制作';
    } else if (widget.afterSalesType == 'SUPPLEMENT') {
      title = '申请补充';
    } else if (widget.afterSalesType == 'REFUND') {
      title = '申请退款';
    }

    // Determine max refundable amount (example: item price)
    final maxRefundAmount = widget.orderItem.price;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        // Wrap content in a Form
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildOrderItemInfo(context, widget.orderItem),
              const SizedBox(height: 24.0),

              // --- Reason Selection Dropdown ---
              DropdownButtonFormField<String>(
                value: _selectedReason,
                hint: const Text('请选择售后原因'),
                isExpanded: true,
                items: _afterSalesReasons.map((String reason) {
                  return DropdownMenuItem<String>(
                    value: reason,
                    child: Text(reason),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedReason = newValue;
                  });
                },
                validator: (value) => value == null || value.isEmpty ? '请选择售后原因' : null,
                decoration: const InputDecoration(
                  labelText: '售后原因',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                ),
              ),
              const SizedBox(height: 16.0),

              // --- Description Text Field ---
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '问题描述',
                  hintText: '请详细描述您遇到的问题...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true, // Better alignment for multiline
                ),
                maxLines: 4, // Allow multiple lines
                textInputAction: TextInputAction.newline, // Suggest newline action
                validator: (value) {
                  // Optional validation: enforce description length?
                  return null; // No validation for now
                },
              ),
              const SizedBox(height: 16.0),

              // --- Amount Text Field (Conditional) ---
              if (widget.afterSalesType == 'REFUND')
                 Padding(
                   padding: const EdgeInsets.only(bottom: 16.0),
                   child: TextFormField(
                      controller: _amountController, // Use controller
                      decoration: InputDecoration(
                        labelText: '退款金额',
                        hintText: '最多可退 ${RegionConfig.currencySymbol}${maxRefundAmount.toStringAsFixed(2)}', // Show max amount
                        prefixText: '${RegionConfig.currencySymbol} ',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) { // Add validation
                        if (value == null || value.isEmpty) {
                          return '请输入退款金额';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null) {
                          return '请输入有效的金额数字';
                        }
                        if (amount <= 0) {
                          return '退款金额必须大于0';
                        }
                        if (amount > maxRefundAmount) {
                          return '退款金额不能超过 ¥${maxRefundAmount.toStringAsFixed(2)}';
                        }
                        return null;
                      },
                   ),
                 ),

              // --- Image Upload Section ---
              Text('上传凭证 (最多 $_maxImages 张)', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              _buildImagePickerSection(),
              const SizedBox(height: 16.0),
              // --------------------------

              const SizedBox(height: 24),
              ElevatedButton(
                 onPressed: () {
                   if (_formKey.currentState!.validate()) {
                     // Form is valid
                     AppLogger.d('Form is valid. Submitting...');

                     // Collect amount if applicable
                     double? refundAmount;
                     if (widget.afterSalesType == 'REFUND') {
                       refundAmount = double.tryParse(_amountController.text);
                     }

                     // Create and add the event
                     final submitEvent = ApplyForAfterSalesSubmitted(
                       orderItemId: widget.orderItemId,
                       refundType: widget.afterSalesType, // Use the type passed to the page
                       refundReason: _selectedReason!, // Not null due to validation
                       refundExplain: _descriptionController.text,
                       imagePaths: _selectedImages.map((result) => result.finalFile.path).toList(),
                       refundAmount: refundAmount,
                     );
                     AppLogger.d('Adding event: $submitEvent with amount $refundAmount');
                     context.read<AfterSalesBloc>().add(submitEvent);

                     // TODO: Optionally show loading indicator or navigate back after submission
                     // Consider listening to Bloc state for success/failure feedback
                   }
                 },
                child: const Text('提交申请'),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget for Image Picker and Thumbnails ---
  Widget _buildImagePickerSection() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        // Existing images with remove button
        ..._selectedImages.asMap().entries.map((entry) {
          int idx = entry.key;
          ImageProcessResult result = entry.value;
          return SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: Image.file(
                    result.finalFile,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 40), // Smaller error icon
                  ),
                ),
                Positioned(
                  top: -4, // Adjust position
                  right: -4, // Adjust position
                  child: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: '移除图片',
                    onPressed: () => _removeImage(idx),
                    splashRadius: 15,
                  ),
                ),
              ],
            ),
          );
        }),
        // Add image button (only if slots remaining)
        if (_selectedImages.length < _maxImages && !_isProcessingImages)
          InkWell(
            onTap: _pickImages,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(color: Colors.grey[400]!)
              ),
              child: Icon(Icons.add_a_photo_outlined, color: Colors.grey[600]),
            ),
          ),
      ],
    );
  }
  // ---------------------------------------------

  // Add method to display order item info (copied & adapted from SelectAfterSalesTypePage)
  Widget _buildOrderItemInfo(BuildContext context, OrderItem item) {
     return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60, height: 60,
              color: Colors.grey[300],
              child: item.imageUrl.isNotEmpty
                 ? ClipRRect(
                     borderRadius: BorderRadius.circular(4.0),
                     child: Image.network(item.imageUrl, fit: BoxFit.cover,
                       errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, color: Colors.grey[500]),
                       loadingBuilder: (context, child, progress) => progress == null ? child : Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                     ),
                   )
                 : Icon(Icons.image, color: Colors.grey[500]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(item.skuName ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('${RegionConfig.currencySymbol}${item.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

} 