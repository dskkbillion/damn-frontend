import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
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

    // 轻咨询形态下「买家提交的材料」流程已废弃（2025-08 后无新数据），
    // 本卡片只承载「卖家交付内容」，仅在卖家已交付的三个状态展示；
    // 其余状态整卡不渲染，避免出现只剩标题的空材料卡。
    final bool showSellerDelivery =
        order.state == OrderStatus.awaitingConfirmation ||
            order.state == OrderStatus.awaitingEvaluation ||
            order.state == OrderStatus.orderCompleted;
    if (!showSellerDelivery) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<OrderDetailBloc, OrderDetailState>(
      builder: (context, state) {
        // 获取交付数据
        List<OrderDelivery>? deliveries;

        if (state is OrderDetailLoaded) {
          deliveries = state.deliveries;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            boxShadow: const [
              BoxShadow(
                color: AppColors.borderSecondary,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题部分
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingLg),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.borderPrimary,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: AppDimensions.spacingSm),
                    Text(
                      l10n.sellerDeliveryContent,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // 内容部分：卖家交付内容
              Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingLg),
                child: _buildSellerDeliveriesContent(context, deliveries),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建卖家交付内容
  Widget _buildSellerDeliveriesContent(BuildContext context, List<OrderDelivery>? deliveries) {
    final l10n = AppLocalizations.of(context);

    if (deliveries == null || deliveries.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          border: Border.all(color: AppColors.borderPrimary),
        ),
        child: Text(
          l10n.noSellerDelivery,
          style: const TextStyle(color: AppColors.textTertiary),
        ),
      );
    }

    return Column(
      children: deliveries.map((delivery) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.deliveryDescription}: ',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
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
              const SizedBox(height: AppDimensions.spacingMd),
              Text(
                l10n.deliveryFiles,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
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
