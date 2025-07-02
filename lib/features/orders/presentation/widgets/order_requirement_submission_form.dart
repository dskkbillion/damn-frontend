import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_detail_item_tile.dart'; // Can reuse or adapt
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:file_picker/file_picker.dart'; // Import file_picker
import 'dart:io'; // Import dart:io for File (potentially needed for display later, though path is String)
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'dart:convert'; // Import dart:convert for json handling

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
  bool _isLoadingDraft = true; // Flag to indicate draft loading

  // Helper to generate SharedPreferences key for the draft
  String _getDraftKey(String orderId) => 'order_draft_$orderId';

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _requirementController1 = TextEditingController();
    _requirementController2 = TextEditingController();
    // Asynchronously load the draft
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    setState(() {
      _isLoadingDraft = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftKey = _getDraftKey(widget.order.id.toString());
      final String? draftJson = prefs.getString(draftKey);

      if (draftJson != null) {
        final draftData = jsonDecode(draftJson) as Map<String, dynamic>;
        // Safely extract data
        final req1 = draftData['requirement1'] as String? ?? '';
        final req2 = draftData['requirement2'] as String? ?? '';
        final attachments = (draftData['attachments'] as List<dynamic>? ?? []).cast<String>();

        // Update controllers and attachment list
        _requirementController1.text = req1;
        _requirementController2.text = req2;
        // Need setState here to update the UI with loaded attachments
        setState(() {
          _selectedAttachmentPaths = attachments;
        });
         print('Draft loaded successfully for order ${widget.order.id}');
      } else {
         print('No draft found for order ${widget.order.id}');
      }
    } catch (e) {
      print('Error loading draft: $e');
      // Optionally show an error message to the user
      if (mounted) { // Check if widget is still in the tree
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('加载草稿失败')), // Localize this
        );
      }
    } finally {
      // Ensure loading indicator is turned off even if errors occur
      if (mounted) {
         setState(() {
           _isLoadingDraft = false;
         });
      }
    }
  }

  // --- Draft Saving Logic ---
  Future<void> _saveDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftKey = _getDraftKey(widget.order.id.toString());

      final draftData = {
        'requirement1': _requirementController1.text,
        'requirement2': _requirementController2.text,
        'attachments': _selectedAttachmentPaths,
      };

      final String draftJson = jsonEncode(draftData);
      await prefs.setString(draftKey, draftJson);
      print('Draft saved for order ${widget.order.id}');
    } catch (e) {
      print('Error saving draft: $e');
      // Optionally show an error message to the user
      if (mounted) { // Check if widget is still in the tree
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('保存草稿失败')), // Localize this
         );
      }
    }
  }

  // --- Draft Clearing Logic (called externally, e.g., after successful submission) ---
  Future<void> _clearDraft() async {
     try {
       final prefs = await SharedPreferences.getInstance();
       final draftKey = _getDraftKey(widget.order.id.toString());
       await prefs.remove(draftKey);
       print('Draft cleared for order ${widget.order.id}');
     } catch (e) {
        print('Error clearing draft: $e');
        // Optionally inform the user
     }
  }

  @override
  void dispose() {
    // Save draft one last time before disposing
    _saveDraft();
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

    // Show loading indicator while draft is loading
    if (_isLoadingDraft) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      // 使用统一Card主题
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
                 // REMOVED: Save Draft Button and associated BlocSelector
                 // const SizedBox(width: 16), // Keep spacing if needed
                 // --- Submit Requirements Button ---
                 BlocSelector<OrderDetailBloc, OrderDetailState, bool>(
                    selector: (state) => state is OrderDetailLoaded && state.isSubmittingRequirements,
                    builder: (context, isSubmitting) {
                       return ElevatedButton(
                          onPressed: isSubmitting ? null : () {
                            // Dispatch SubmitRequirementsSubmitted event with correct parameters
                            // --- Construct feature data --- 
                            // TODO: This assumes a fixed structure based on current UI.
                            // Replace with logic to get actual questions/answers if dynamic.
                            final featureData = [
                              {
                                'question': '1. 您订购的是基本服务 (30¥/150字)...', // Placeholder, get actual question
                                'answer': _requirementController1.text
                              },
                              {
                                'question': '2. 对于额外需求...', // Placeholder, get actual question
                                'answer': _requirementController2.text
                              },
                              // Add more question/answer pairs if needed
                            ];
                            // --- Get productId --- 
                            final productId = item?.productId ?? -1;
                            if (productId == -1) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('错误：无法获取商品 ID')),
                              );
                              return;
                            }

                            // --- Dispatch Event --- 
                            context.read<OrderDetailBloc>().add(
                                SubmitRequirementsSubmitted(
                                  orderId: widget.order.id.toString(),
                                  productId: productId, // Pass productId
                                  feature: featureData, // Pass structured feature data
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
                   style: Theme.of(context).textTheme.labelSmall,
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