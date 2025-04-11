import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_detail_item_tile.dart'; // Can reuse or adapt
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:file_picker/file_picker.dart'; // Import file_picker
import 'dart:io'; // Import dart:io for File (potentially needed for display later, though path is String)

/// Widget for submitting order requirements (text and attachments).
class OrderRequirementSubmissionForm extends StatefulWidget {
  final Order order;

  const OrderRequirementSubmissionForm({super.key, required this.order});

  @override
  State<OrderRequirementSubmissionForm> createState() =>
      _OrderRequirementSubmissionFormState();
}

class _OrderRequirementSubmissionFormState
    extends State<OrderRequirementSubmissionForm> {
  // Add TextEditingControllers for text inputs
  late TextEditingController _requirementController1;
  late TextEditingController _requirementController2;
  // Add state for attached files
  List<String> _selectedAttachmentPaths = []; // List to hold selected attachment paths

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _requirementController1 = TextEditingController();
    _requirementController2 = TextEditingController();
    // TODO: Initialize with existing draft data if available from order object
  }

  @override
  void dispose() {
    // Dispose controllers
    _requirementController1.dispose();
    _requirementController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    // Assuming only one item per order for requirement submission view, adjust if needed
    final item = widget.order.items.isNotEmpty ? widget.order.items.first : null;

    return Card(
      elevation: 0, // Use elevation from outer card or none
      margin: EdgeInsets.zero,
      color: Colors.white, // Or theme surface color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Product Info ---
            // Use a simpler display than the full OrderDetailItemTile if needed
            if (item != null)
              ListTile(
                 leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      item.imageUrl,
                      width: 50, height: 50, fit: BoxFit.cover,
                      errorBuilder: (_,__,___) => const Icon(Icons.broken_image, size: 50),
                    ),
                  ),
                  title: Text(item.productName, style: textTheme.titleSmall),
                  subtitle: Text(item.skuName ?? '', style: textTheme.bodySmall),
                   trailing: Text('¥${item.price.toStringAsFixed(2)}', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                   contentPadding: EdgeInsets.zero,
              ),
            if (item != null) const Divider(height: 24),

            // --- Requirements Section ---
            Text('要求提交', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            // TODO: Display seller's questions/required fields here
            _buildSellerQuestion(context, '1. 您订购的是基本服务 (30¥/150字)...'),
            TextField(
              controller: _requirementController1, // Assign controller
              decoration: InputDecoration(
                hintText: '在此输入您的回答',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              maxLines: 3,
            ),
             const SizedBox(height: 16),
            _buildSellerQuestion(context, '2. 您的稿件具体字数是多少？'),
             TextField(
               controller: _requirementController2, // Assign controller
              decoration: InputDecoration(
                hintText: '在此输入您的回答',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                 filled: true,
                fillColor: Colors.grey[100],
                 contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 24),

            // --- Attachments Section ---
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text('附件上传', style: textTheme.titleMedium),
                 TextButton(onPressed: () {/* TODO */}, child: const Text('文本/附件 切换?'))
               ],
             ),
            const SizedBox(height: 8),
            // Implement file picker and display logic using Wrap
             Wrap(
               spacing: 8.0,
               runSpacing: 8.0,
               children: [
                 ..._selectedAttachmentPaths.map((path) => _buildAttachmentThumbnail(path)).toList(),
                 if (_selectedAttachmentPaths.length < 9)
                   _buildAddAttachmentButton(context),
               ],
             ),
            const SizedBox(height: 24),

            // --- Action Buttons for this Form ---
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                 // --- Save Draft Button ---
                 BlocSelector<OrderDetailBloc, OrderDetailState, bool>(
                   selector: (state) => state is OrderDetailLoaded && state.isSavingDraft,
                   builder: (context, isSaving) {
                     return OutlinedButton(
                        onPressed: isSaving ? null : () {
                          // Dispatch SaveRequirementDraftRequested event with correct parameters
                          context.read<OrderDetailBloc>().add(
                                SaveRequirementDraftRequested(
                                  orderId: widget.order.id.toString(),
                                  requirementText1: _requirementController1.text, // Correct parameter
                                  requirementText2: _requirementController2.text, // Correct parameter
                                  attachmentPaths: _selectedAttachmentPaths, // Pass the correct list
                                ),
                              );
                          print('Save Draft Tapped');
                        },
                        child: isSaving
                           ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                           : const Text('保存'),
                     );
                   },
                 ),
                 const SizedBox(width: 16),
                 // --- Submit Requirements Button ---
                 BlocSelector<OrderDetailBloc, OrderDetailState, bool>(
                    selector: (state) => state is OrderDetailLoaded && state.isSubmittingRequirements,
                    builder: (context, isSubmitting) {
                       return ElevatedButton(
                          onPressed: isSubmitting ? null : () {
                            // Dispatch SubmitRequirementsSubmitted event with correct parameters
                             context.read<OrderDetailBloc>().add(
                                SubmitRequirementsSubmitted(
                                  orderId: widget.order.id.toString(),
                                  requirementText1: _requirementController1.text, // Correct parameter
                                  requirementText2: _requirementController2.text, // Correct parameter
                                  attachmentPaths: _selectedAttachmentPaths, // Pass the correct list
                                ),
                              );
                            print('Confirm Submission Tapped');
                          },
                          child: isSubmitting
                             ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                             : const Text('确认提交'),
                       );
                    },
                 ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper for seller question text style
  Widget _buildSellerQuestion(BuildContext context, String text) {
     return Padding(
       padding: const EdgeInsets.only(bottom: 8.0),
       child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
     );
  }

  // --- Helper to build attachment thumbnail --- 
  Widget _buildAttachmentThumbnail(String attachmentPath) {
    // Similar to image thumbnail, but might show different icons/previews
    final fileName = attachmentPath.split('_').last; // Simple name for simulation
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Icon(_getFileIcon(fileName), size: 30, color: Colors.grey[700]), // Use file icon helper
               const SizedBox(height: 4),
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 4.0),
                 child: Text(
                   fileName, // Show simulated file name
                   style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                   maxLines: 1,
                   overflow: TextOverflow.ellipsis,
                  ),
               ),
            ],
          )
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
                _selectedAttachmentPaths.remove(attachmentPath);
              });
            },
          ),
        ),
      ],
    );
  }

  // --- Helper to build "Add Attachment" button --- 
  Widget _buildAddAttachmentButton(BuildContext context) {
    return InkWell(
      onTap: _pickFiles, // Call the file picking method
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid)
        ),
        child: Icon(Icons.add_circle_outline, color: Colors.grey[600], size: 30),
      ),
    );
  }

  // --- File Picking Logic --- 
  Future<void> _pickFiles() async {
     if (_selectedAttachmentPaths.length >= 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('最多只能上传9个附件')),
      );
      return;
    }

    try {
      // Use FilePicker to pick multiple files
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        // Optional: Specify allowed file types
        // type: FileType.custom,
        // allowedExtensions: ['jpg', 'pdf', 'doc'],
      );

      if (result != null) {
         setState(() {
           int remainingSlots = 9 - _selectedAttachmentPaths.length;
           // Add paths of newly selected files, ensuring they are not null
           _selectedAttachmentPaths.addAll(
             result.files.take(remainingSlots).map((file) => file.path!).where((path) => path != null) // Get non-null paths
           );
         });
      }
    } catch (e) {
       // Handle potential errors (e.g., platform exceptions)
       print('Error picking files: $e');
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('选择文件失败: ${e.toString()}')),
       );
    }
  }

  // --- Helper method to get file icon based on extension (reuse/copy from DeliveryConfirmationArea or common utils) ---
  IconData _getFileIcon(String fileName) {
    final extension = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
    // ... (Switch case logic remains the same as in DeliveryConfirmationArea)
    switch (extension) {
      case 'pdf': return Icons.picture_as_pdf_outlined;
      case 'doc': case 'docx': return Icons.description_outlined;
      case 'xls': case 'xlsx': return Icons.assessment_outlined;
      case 'ppt': case 'pptx': return Icons.slideshow_outlined;
      case 'jpg': case 'jpeg': case 'png': case 'gif': case 'bmp': return Icons.image_outlined;
      case 'zip': case 'rar': case '7z': return Icons.archive_outlined;
      default: return Icons.insert_drive_file_outlined;
    }
  }
} 