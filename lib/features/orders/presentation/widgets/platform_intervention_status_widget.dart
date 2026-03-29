import 'package:flutter/material.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

/// 平台介入状态显示组件
class PlatformInterventionStatusWidget extends StatelessWidget {
  final Order order;
  final VoidCallback? onApplyIntervention;

  const PlatformInterventionStatusWidget({
    super.key,
    required this.order,
    this.onApplyIntervention,
  });

  @override
  Widget build(BuildContext context) {
    // 判断是否已申请平台介入
    final bool hasPlatformFlag = _hasPlatformIntervention();

    if (!hasPlatformFlag) {
      // 没有平台介入，显示申请按钮（如果适用）
      return _buildApplySection(context);
    } else {
      // 已有平台介入，显示状态
      return _buildStatusSection(context);
    }
  }

  /// 判断是否已申请平台介入
  bool _hasPlatformIntervention() {
    // TODO: 根据订单数据判断是否有平台介入标记
    return false; // 暂时返回false，等待订单实体更新
  }

  /// 构建申请平台介入的UI
  Widget _buildApplySection(BuildContext context) {
    // 检查是否适合申请平台介入
    if (!_shouldShowApplyButton()) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg, vertical: AppDimensions.spacingSm),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.support_agent,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Text(
                  '平台介入',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              '如遇到争议无法协商解决，可申请平台客服介入处理',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onApplyIntervention,
                icon: const Icon(Icons.report_problem, size: 18),
                label: const Text('申请平台介入'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建平台介入状态显示UI
  Widget _buildStatusSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg, vertical: AppDimensions.spacingSm),
      color: AppColors.warning.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.support_agent,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Text(
                  '平台介入中',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingSm, vertical: AppDimensions.spacingXs),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Text(
                    '处理中',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              '您的申请已提交，平台客服会在24小时内联系您处理',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            _buildTimelineStep(
              context,
              '申请已提交',
              '等待平台客服处理',
              true,
              AppColors.warning,
            ),
            _buildTimelineStep(
              context,
              '客服介入',
              '24小时内联系双方',
              false,
              AppColors.textTertiary,
            ),
            _buildTimelineStep(
              context,
              '问题解决',
              '根据平台判定处理',
              false,
              AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建时间线步骤
  Widget _buildTimelineStep(
    BuildContext context,
    String title,
    String subtitle,
    bool isCompleted,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXs),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? color : AppColors.borderPrimary,
              border: Border.all(
                color: isCompleted ? color : AppColors.textTertiary,
                width: 2,
              ),
            ),
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    size: 8,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                    color: isCompleted ? color : AppColors.textSecondary,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 判断是否应该显示申请按钮
  bool _shouldShowApplyButton() {
    switch (order.state) {
      case OrderStatus.awaitingDelivery:
      case OrderStatus.awaitingConfirmation:
      case OrderStatus.sellerSupplementaryMaterials:
      case OrderStatus.awaitingEvaluation:
        return true;
      default:
        return false;
    }
  }
}
