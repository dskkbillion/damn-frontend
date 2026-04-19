import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/entities/order_status.dart';
import '../../../domain/entities/order_materials.dart';
import '../../../domain/entities/order_delivery.dart';

/// 卖家订单材料交付组件
class SellerOrderMaterialsSection extends StatelessWidget {
  final Order order;
  final List<OrderMaterials>? materials;
  final List<OrderDelivery>? deliveries;

  const SellerOrderMaterialsSection({
    super.key,
    required this.order,
    this.materials,
    this.deliveries,
  });

  @override
  Widget build(BuildContext context) {
    // 判断是否需要显示此组件
    bool shouldShowMaterials = false;
    
    // 待接单及之后的状态都需要显示买家提供的材料
    if (order.state == OrderStatus.awaitingStart ||
        order.state == OrderStatus.awaitingDelivery ||
        order.state == OrderStatus.awaitingConfirmation ||
        order.state == OrderStatus.awaitingEvaluation ||
        order.state == OrderStatus.orderCompleted ||
        order.state == OrderStatus.afterSale ||
        order.state == OrderStatus.applyForRefuse) {
      shouldShowMaterials = true;
    }
    
    if (!shouldShowMaterials || (materials == null || materials!.isEmpty)) {
      return const SizedBox.shrink();
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3))
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.order_seller_buyer_materials,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 材料内容
            _buildBuyerMaterialsContent(context),
          ],
        ),
      ),
    );
  }

  /// 构建买家材料内容
  Widget _buildBuyerMaterialsContent(BuildContext context) {
    return Column(
      children: materials!.map((material) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 显示特征问答
            if (material.features.isNotEmpty) ...[
              ...material.features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.question,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature.answer,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              )),
            ],
            // 显示附件
            if (material.files.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(height: 16),
              Text(
                AppLocalizations.of(context)!.order_seller_attachment_label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: material.files.map((fileUrl) => _buildFileChip(context, _extractFileName(fileUrl))).toList(),
              ),
            ],
          ],
        ),
      )).toList(),
    );
  }

  /// 构建文件标签
  Widget _buildFileChip(BuildContext context, String fileName) {
    return InkWell(
      onTap: () {
        // TODO: 实现文件下载/预览功能
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.order_seller_view_attachment(fileName))),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getFileIcon(fileName),
              size: 16,
              color: Colors.blue[600],
            ),
            const SizedBox(width: 6),
            Text(
              fileName,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.download_outlined,
              size: 14,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  /// 根据文件扩展名获取图标
  IconData _getFileIcon(String fileName) {
    final extension = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
    switch (extension) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'doc': case 'docx': return Icons.description;
      case 'jpg': case 'jpeg': case 'png': case 'gif': return Icons.image;
      case 'ai': case 'psd': return Icons.design_services;
      case 'zip': case 'rar': return Icons.folder_zip;
      case 'xls': case 'xlsx': return Icons.table_chart;
      default: return Icons.insert_drive_file;
    }
  }
  
  /// 从URL中提取文件名
  String _extractFileName(String fileUrl) {
    if (fileUrl.contains('/')) {
      final name = fileUrl.split('/').last;
      // 处理URL参数
      if (name.contains('?')) {
        return name.split('?').first;
      }
      return name;
    }
    return fileUrl;
  }
}