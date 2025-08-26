import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/order_materials.dart';
import '../../domain/entities/order_delivery.dart';
import '../bloc/order_detail_bloc.dart';
import 'delivery_file_viewer.dart';

/// 订单材料交付组件
class OrderMaterialsSection extends StatelessWidget {
  final Order order;

  const OrderMaterialsSection({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return BlocBuilder<OrderDetailBloc, OrderDetailState>(
      builder: (context, state) {
        // 获取材料和交付数据
        List<OrderMaterials>? materials;
        List<OrderDelivery>? deliveries;
        
        if (state is OrderDetailLoaded) {
          materials = state.materials;
          deliveries = state.deliveries;
        }
        
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
                      Icons.folder_outlined,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n?.materialsInfo ?? 'Materials Info',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // 内容部分
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 买家提交的材料
                    Text(
                      l10n?.buyerSubmittedMaterials ?? 'Buyer Submitted Materials',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildBuyerMaterialsContent(context, materials),
                    
                    // 如果是待收货、待评价或已完成状态，显示卖家交付内容
                    if (order.state == OrderStatus.awaitingConfirmation ||
                        order.state == OrderStatus.awaitingEvaluation ||
                        order.state == OrderStatus.orderCompleted) ...[
                      const SizedBox(height: 16),
                      Text(
                        l10n?.sellerDeliveryContent ?? 'Seller Delivery Content',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildSellerDeliveriesContent(context, deliveries),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建买家材料内容
  Widget _buildBuyerMaterialsContent(BuildContext context, List<OrderMaterials>? materials) {
    final l10n = AppLocalizations.of(context);
    
    if (materials == null || materials.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200] ?? Colors.grey),
        ),
        child: Text(
          l10n?.noBuyerMaterials ?? 'No buyer materials submitted',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }
    
    return Column(
      children: materials.map((material) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[200] ?? Colors.blue),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 显示特征问答
            if (material.features.isNotEmpty) ...[
              ...material.features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${feature.question}: ${feature.answer}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )),
              const SizedBox(height: 8),
            ],
            // 显示附件文件（可预览和下载）
            if (material.files.isNotEmpty) ...[
              Text(
                l10n?.attachments ?? 'Attachments',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              ...material.files.map((fileUrl) => DeliveryFileViewer(
                fileUrl: fileUrl,
                fileName: _extractFileName(fileUrl),
              )),
            ],
          ],
        ),
      )).toList(),
    );
  }

  /// 构建卖家交付内容
  Widget _buildSellerDeliveriesContent(BuildContext context, List<OrderDelivery>? deliveries) {
    final l10n = AppLocalizations.of(context);
    
    if (deliveries == null || deliveries.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200] ?? Colors.grey),
        ),
        child: Text(
          l10n?.noSellerDelivery ?? 'No seller delivery content',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }
    
    return Column(
      children: deliveries.map((delivery) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green[200] ?? Colors.green),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n?.deliveryDescription ?? 'Delivery Description'}: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Text(
                    delivery.content,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            if (delivery.files.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                l10n?.deliveryFiles ?? 'Delivery Files',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ...delivery.files.map((fileUrl) => DeliveryFileViewer(
                fileUrl: fileUrl,
                fileName: _extractFileName(fileUrl),
              )),
            ],
          ],
        ),
      )).toList(),
    );
  }

  
  /// 从URL中提取文件名
  String _extractFileName(String fileUrl) {
    if (fileUrl.contains('/')) {
      return fileUrl.split('/').last;
    }
    return fileUrl;
  }
}