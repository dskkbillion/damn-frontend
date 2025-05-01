import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:flutter/material.dart';

/// Widget displaying the delivered content and actions for awaiting confirmation state.
class DeliveryConfirmationArea extends StatelessWidget {
  final Order order;

  const DeliveryConfirmationArea({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // TODO: Fetch actual delivery data based on order.id or info within order object
    // Placeholder data structure for delivery items
    final List<Map<String, dynamic>> deliveryItems = [
      {
        'title': '交付 #1',
        'timestamp': '2024/08/29', // Example timestamp
        'contentPreview': '感谢您的耐心等待，这是您需要的初步方案...', // Example text preview
        'files': [
           {'name': '方案文档.pdf', 'size': '1.2MB'},
           {'name': '参考图片.jpg', 'size': '800KB'},
        ] // Example file list
      },
      // Add more delivery items if applicable (e.g., multiple deliveries)
    ];


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display Delivery Items (using placeholder data for now)
        ListView.builder(
          shrinkWrap: true, // Important when inside a Column/SingleChildScrollView
          physics: const NeverScrollableScrollPhysics(), // Disable inner scrolling
          itemCount: deliveryItems.length,
          itemBuilder: (context, index) {
            final delivery = deliveryItems[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 1,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Delivery Header (Title and Timestamp)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(delivery['title'], style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        Text(delivery['timestamp'], style: textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Content Preview (Text)
                    if (delivery['contentPreview'] != null)
                       Text(delivery['contentPreview'], style: textTheme.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis,),
                    if (delivery['contentPreview'] != null && delivery['files'].isNotEmpty)
                       const SizedBox(height: 8),
                    // File List / Download Area
                    if (delivery['files'].isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                         padding: const EdgeInsets.all(12.0),
                         decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8)
                         ),
                         child: Builder( // Use Builder to access context if needed inside calculation
                           builder: (context) {
                              // Prepare the list of file row widgets safely
                              final List<Widget> fileWidgets = [];
                              final filesList = delivery['files'];
                              if (filesList is List) {
                                for (final fileData in filesList) {
                                  if (fileData is Map<String, dynamic>) {
                                    fileWidgets.add(_buildFileRow(context, fileData));
                                  }
                                }
                              }
                              // Return the Column with the prepared widgets
                              return Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: fileWidgets,
                               );
                           }
                         ),
                      ),
                    ],


                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // --- "Not Satisfied?" Actions ---
        Center( // Center the button or use a different layout
          child: OutlinedButton(
            onPressed: () {
              // TODO: Show bottom sheet with options: 我要补充, 我要重新制作, 我要退款
              print('Show delivery issue options');
               _showDeliveryIssueOptions(context);
            },
            child: const Text('对交付不满意？'),
          ),
        ),
         const SizedBox(height: 8),
        Center(
          child: Text(
            '当前交付次数不足时，请先与卖家沟通是否同意再次交付', // From prototype
             style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
             textAlign: TextAlign.center,
          ),
        ),

      ],
    );
  }

  // --- Helper method to build a file row --- 
  Widget _buildFileRow(BuildContext context, Map<String, dynamic> fileData) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final fileName = fileData['name'] as String? ?? '未知文件';
    final fileSize = fileData['size'] as String?;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0), // Add vertical padding between rows
      child: Row(
        children: [
          Icon(_getFileIcon(fileName), size: 20, color: colorScheme.primary), // File type icon
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fileName, style: textTheme.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (fileSize != null)
                  Text(fileSize, style: textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // TODO: Implement download/preview action
          InkWell(
            onTap: () => print('Download/Preview $fileName'),
            child: Icon(Icons.download_outlined, size: 20, color: colorScheme.primary),
          ),
        ],
      ),
    );
  }

  // --- Helper method to get file icon based on extension --- 
  IconData _getFileIcon(String fileName) {
    final extension = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'doc':
      case 'docx':
        return Icons.description_outlined; // Or specific Word icon if available
      case 'xls':
      case 'xlsx':
        return Icons.assessment_outlined; // Or specific Excel icon
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_outlined; // Or specific PPT icon
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
        return Icons.image_outlined;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.archive_outlined;
      default:
        return Icons.insert_drive_file_outlined; // Generic file icon
    }
  }

  // --- Helper to show bottom sheet (placeholder) ---
  void _showDeliveryIssueOptions(BuildContext context) {
     showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea( // Add SafeArea for bottom intrusions
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                 alignment: WrapAlignment.center,
                 spacing: 16,
                 runSpacing: 16,
                children: <Widget>[
                  ElevatedButton(
                    child: const Text('我要补充'),
                    onPressed: () {
                       // TODO: Navigate or trigger 'request revision' flow
                       Navigator.pop(context);
                       print('Request Revision');
                    }
                  ),
                   ElevatedButton(
                    child: const Text('我要重新制作'),
                     onPressed: () {
                       // TODO: Navigate or trigger 'request remake' flow
                        Navigator.pop(context);
                        print('Request Remake');
                    }
                  ),
                   ElevatedButton(
                    child: const Text('我要退款'),
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.errorContainer),
                     onPressed: () {
                        // TODO: Navigate to AfterSale application or trigger refund flow
                         Navigator.pop(context);
                         print('Request Refund');
                    }
                  ),
                ],
              ),
            ),
          );
        });
  }


} 