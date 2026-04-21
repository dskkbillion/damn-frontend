import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

/// 频率限制警告横幅
class RateLimitWarningBanner extends StatelessWidget {
  final int remaining;
  final int resetInSeconds;
  final VoidCallback? onDismiss;

  const RateLimitWarningBanner({
    super.key,
    required this.remaining,
    required this.resetInSeconds,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (remaining > 5) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: remaining <= 2
            ? [Colors.amber.shade50, Colors.amber.shade100]
            : [AppColors.backgroundSecondary, AppColors.borderPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          onTap: () => _showDetailedInfo(context),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingSm),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(AppDimensions.spacingSm),
                  ),
                  child: Icon(
                    remaining <= 2 ? Icons.access_time : Icons.info_outline,
                    color: remaining <= 2 ? Colors.amber.shade700 : AppColors.info,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        remaining <= 2 ? '使用次数即将耗尽' : '今日剩余次数',
                        style: TextStyle(
                          color: remaining <= 2 ? Colors.amber.shade800 : AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '还可使用 $remaining 次，${_formatResetTime(resetInSeconds)}后重置',
                        style: TextStyle(
                          color: remaining <= 2 ? Colors.amber.shade700 : AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: remaining <= 2 ? Colors.amber.shade600 : AppColors.info,
                  size: 20,
                ),
                if (onDismiss != null)
                  Padding(
                    padding: const EdgeInsets.only(left: AppDimensions.spacingSm),
                    child: InkWell(
                      onTap: onDismiss,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.spacingXs),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatResetTime(int seconds) {
    final minutes = (seconds / 60).ceil();
    if (minutes > 60) {
      return '${(minutes / 60).ceil()}小时';
    }
    return '$minutes分钟';
  }

  void _showDetailedInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      builder: (context) => _DetailedRateLimitSheet(
        remaining: remaining,
        resetInSeconds: resetInSeconds,
      ),
    );
  }
}

/// 详细的频率限制信息底部弹窗
class _DetailedRateLimitSheet extends StatelessWidget {
  final int remaining;
  final int resetInSeconds;

  const _DetailedRateLimitSheet({
    required this.remaining,
    required this.resetInSeconds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingXxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderInput,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXxl),
            Text(
              '使用次数详情',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXl),
            _buildProgressCard(context),
            const SizedBox(height: AppDimensions.spacingLg),
            _buildRuleCard(context),
            const SizedBox(height: AppDimensions.spacingXl),
            _buildUpgradeButton(context),
            const SizedBox(height: AppDimensions.spacingLg),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    const totalLimit = 30; // 假设总限制为30次
    final usedPercentage = ((totalLimit - remaining) / totalLimit).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.backgroundSecondary, AppColors.borderPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '今日使用情况',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${totalLimit - remaining}/$totalLimit',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.spacingSm),
            child: LinearProgressIndicator(
              value: usedPercentage,
              backgroundColor: AppColors.borderPrimary,
              valueColor: AlwaysStoppedAnimation<Color>(
                remaining <= 2 ? Colors.amber.shade600 : AppColors.info,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            '${_formatResetTime(resetInSeconds)}后重置',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '使用规则',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          _buildRuleItem('突发限制', '5分钟内最多3次'),
          const SizedBox(height: AppDimensions.spacingSm),
          _buildRuleItem('小时限制', '60分钟内最多30次'),
          const SizedBox(height: AppDimensions.spacingSm),
          _buildRuleItem('重置时间', '每小时0分钟重置'),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildUpgradeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: 实现升级引导逻辑
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('升级功能即将推出'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.info,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, size: 20),
            SizedBox(width: AppDimensions.spacingSm),
            Text(
              '升级获取更多次数',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatResetTime(int seconds) {
    final minutes = (seconds / 60).ceil();
    if (minutes > 60) {
      return '${(minutes / 60).ceil()}小时';
    }
    return '$minutes分钟';
  }
}
