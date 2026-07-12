import 'package:flutter/material.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';

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
    // 这里需要根据实际的订单数据结构来实现
    // 可能的字段：buyerPlatformFlag, sellerPlatformFlag
    return false; // 暂时返回false，等待订单实体更新
  }

  /// 构建申请平台介入的UI
  Widget _buildApplySection(BuildContext context) {
    // 检查是否适合申请平台介入
    if (!_shouldShowApplyButton()) {
      return const SizedBox.shrink();
    }

    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.support_agent,
                  color: AppColors.info,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).order_platform_intervention_title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).order_platform_intervention_desc,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onApplyIntervention,
                icon: const Icon(Icons.report_problem, size: 18),
                label: Text(AppLocalizations.of(context).order_platform_intervention_apply),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.info,
                  side: BorderSide(color: AppColors.info),
                ),
              ),
            ),
          ],
      ),
    );
  }

  /// 构建平台介入状态显示UI
  Widget _buildStatusSection(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      tintColor: AppColors.warning,
      tintOpacity: 0.10,
      padding: const EdgeInsets.all(16.0),
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
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).order_platform_intervention_in_progress,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    AppLocalizations.of(context).order_platform_intervention_processing,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).order_platform_intervention_processing_msg,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 12),
            _buildTimelineStep(
              context,
              AppLocalizations.of(context).order_platform_intervention_step1,
              AppLocalizations.of(context).order_platform_intervention_step1_desc,
              true,
              AppColors.warning,
            ),
            _buildTimelineStep(
              context,
              AppLocalizations.of(context).order_platform_intervention_step2,
              AppLocalizations.of(context).order_platform_intervention_step2_desc,
              false,
              AppColors.textSecondary,
            ),
            _buildTimelineStep(
              context,
              AppLocalizations.of(context).order_platform_intervention_step3,
              AppLocalizations.of(context).order_platform_intervention_step3_desc,
              false,
              AppColors.textSecondary,
            ),
          ],
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? color : AppColors.backgroundSecondary,
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
          const SizedBox(width: 12),
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
    // 只有在特定状态下才显示申请平台介入按钮
    // 比如：进行中的订单、有争议的状态等
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
