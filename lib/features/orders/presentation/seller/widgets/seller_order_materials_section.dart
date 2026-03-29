import 'package:flutter/material.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/entities/order_status.dart';
import '../../../domain/entities/order_materials.dart';
import '../../../domain/entities/order_delivery.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

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
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg, vertical: AppDimensions.spacingSm),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Text(
                  '买家提供的材料',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLg),
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
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 显示特征问答
            if (material.features.isNotEmpty) ...[
              ...material.features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.question,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
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
              const SizedBox(height: AppDimensions.spacingSm),
              const Divider(height: 16),
              Text(
                '附件:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Wrap(
                spacing: AppDimensions.spacingSm,
                runSpacing: AppDimensions.spacingSm,
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
          SnackBar(content: Text('查看附件功能待实现: $fileName')),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd, vertical: AppDimensions.spacingXs + 2),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          border: Border.all(color: AppColors.borderPrimary),
          boxShadow: [
            BoxShadow(
              color: AppColors.borderSecondary,
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
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              fileName,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.download_outlined,
              size: 14,
              color: AppColors.textSecondary,
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
