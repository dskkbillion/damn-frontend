import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/order_materials.dart';
import '../../domain/entities/order_delivery.dart';
import '../bloc/order_detail_bloc.dart';

/// 订单材料交付组件
class OrderMaterialsSection extends StatelessWidget {
  final Order order;

  const OrderMaterialsSection({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
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
                      '材料信息',
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
                      '买家提交的材料',
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
                        '卖家交付内容',
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
    if (materials == null || materials.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: const Text(
          '暂无买家提交的材料',
          style: TextStyle(color: Colors.grey),
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
          border: Border.all(color: Colors.blue[200]!),
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
            // 显示附件
            if (material.files.isNotEmpty) ...[
              const Text(
                '附件:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: material.files.map((fileUrl) => _buildFileChip(_extractFileName(fileUrl))).toList(),
              ),
            ],
          ],
        ),
      )).toList(),
    );
  }

  /// 构建卖家交付内容
  Widget _buildSellerDeliveriesContent(BuildContext context, List<OrderDelivery>? deliveries) {
    if (deliveries == null || deliveries.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: const Text(
          '卖家暂未交付内容',
          style: TextStyle(color: Colors.grey),
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
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '交付说明: ${delivery.content}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (delivery.files.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                '交付文件:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: delivery.files.map((fileUrl) => _buildFileChip(_extractFileName(fileUrl))).toList(),
              ),
            ],
          ],
        ),
      )).toList(),
    );
  }

  /// 构建文件标签
  Widget _buildFileChip(String fileName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getFileIcon(fileName),
            size: 14,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            fileName,
            style: const TextStyle(fontSize: 12),
          ),
        ],
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
      default: return Icons.insert_drive_file;
    }
  }
  
  /// 从URL中提取文件名
  String _extractFileName(String fileUrl) {
    if (fileUrl.contains('/')) {
      return fileUrl.split('/').last;
    }
    return fileUrl;
  }
}