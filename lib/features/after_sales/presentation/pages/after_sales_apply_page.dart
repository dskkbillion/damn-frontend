import 'package:flutter/material.dart';
// Import OrderItem
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_item.dart';
// Import dart:io for File
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc
import '../bloc/after_sales_bloc.dart'; // Import Bloc/Event
import 'package:dskk_flutter_refactor/core/utils/image_upload_helper.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';
import 'package:dskk_flutter_refactor/core/widgets/app_network_image.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

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
  final List<ImageProcessResult> _selectedImages = [];
  final int _maxImages = 9; // Define max images based on prototype hint
  bool _isProcessingImages = false;

  // Reasons will be built in build() using l10n
  List<String> _getAfterSalesReasons(BuildContext context) {
    final s = AppLocalizations.of(context);
    return [
      s.after_sales_reason_quality,
      s.after_sales_reason_mismatch,
      s.after_sales_reason_wrong_item,
      s.after_sales_reason_unwanted,
      s.after_sales_reason_other,
    ];
  }

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
        SnackBar(content: Text(AppLocalizations.of(context).after_sales_max_images(_maxImages))),
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
              content: Text(AppLocalizations.of(context).after_sales_image_process_success(successCount, avgCompression.toStringAsFixed(1))),
            ),
          );
        }
        
        if (errorCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).after_sales_image_process_failed(errorCount)),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      print("Error picking images: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).after_sales_image_pick_failed(e.toString()))),
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
    final s = AppLocalizations.of(context);
    String title = s.after_sales_apply_title;
    if (widget.afterSalesType == 'REMAKE') {
      title = s.after_sales_apply_remake;
    } else if (widget.afterSalesType == 'SUPPLEMENT') {
      title = s.after_sales_apply_supplement;
    } else if (widget.afterSalesType == 'REFUND') {
      title = s.after_sales_apply_refund;
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
                initialValue: _selectedReason,
                hint: Text(s.after_sales_select_reason_hint),
                isExpanded: true,
                items: _getAfterSalesReasons(context).map((String reason) {
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
                validator: (value) => value == null || value.isEmpty ? s.after_sales_select_reason_validator : null,
                decoration: InputDecoration(
                  labelText: s.after_sales_reason_label,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                ),
              ),
              const SizedBox(height: 16.0),

              // --- Description Text Field ---
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: s.after_sales_description_label,
                  hintText: s.after_sales_description_hint,
                  border: const OutlineInputBorder(),
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
                        labelText: s.after_sales_refund_amount_label,
                        hintText: s.after_sales_refund_amount_hint(RegionConfig.currencySymbol, maxRefundAmount.toStringAsFixed(2)), // Show max amount
                        prefixText: '${RegionConfig.currencySymbol} ',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) { // Add validation
                        if (value == null || value.isEmpty) {
                          return s.after_sales_refund_amount_required;
                        }
                        final amount = double.tryParse(value);
                        if (amount == null) {
                          return s.after_sales_refund_amount_invalid;
                        }
                        if (amount <= 0) {
                          return s.after_sales_refund_amount_positive;
                        }
                        if (amount > maxRefundAmount) {
                          return s.after_sales_refund_amount_exceed(RegionConfig.currencySymbol, maxRefundAmount.toStringAsFixed(2));
                        }
                        return null;
                      },
                   ),
                 ),

              // --- Image Upload Section ---
              Text(s.after_sales_upload_evidence(_maxImages), style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              _buildImagePickerSection(),
              const SizedBox(height: 16.0),
              // --------------------------

              const SizedBox(height: 24),
              ElevatedButton(
                 onPressed: () {
                   if (_formKey.currentState!.validate()) {
                     // Form is valid
                     print('Form is valid. Submitting...');

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
                     print('Adding event: $submitEvent with amount $refundAmount');
                     context.read<AfterSalesBloc>().add(submitEvent);

                     // TODO: Optionally show loading indicator or navigate back after submission
                     // Consider listening to Bloc state for success/failure feedback
                   }
                 },
                child: Text(s.after_sales_submit),
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
                    icon: Icon(Icons.remove_circle, color: Theme.of(context).colorScheme.error, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: AppLocalizations.of(context).after_sales_remove_image,
                    onPressed: () => _removeImage(idx),
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
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
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.4)),
              ),
              child: Icon(Icons.add_a_photo_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
      ],
    );
  }
  // ---------------------------------------------

  // Add method to display order item info (copied & adapted from SelectAfterSalesTypePage)
  Widget _buildOrderItemInfo(BuildContext context, OrderItem item) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return GlassCard(
      padding: const EdgeInsets.all(16.0),
      borderRadius: BorderRadius.circular(12),
      tintColor: colorScheme.surfaceContainerHighest,
      tintOpacity: 0.3,
      child: Row(
        children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: item.imageUrl.isNotEmpty
                ? AppNetworkImage(
                    imageUrl: item.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(4.0),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.image, color: colorScheme.onSurfaceVariant),
                  ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productName, style: textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    item.skuName ?? '',
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${RegionConfig.currencySymbol}${item.price.toStringAsFixed(2)}',
                    style: textTheme.titleSmall?.copyWith(color: colorScheme.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }

}
