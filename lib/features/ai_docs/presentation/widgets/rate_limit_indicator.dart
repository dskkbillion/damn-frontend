import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import '../bloc/ai_chat/ai_chat_bloc.dart';

/// AppBar右上角的频率限制指示器
class RateLimitIndicator extends StatelessWidget {
  const RateLimitIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiChatBloc, AiChatState>(
      buildWhen: (previous, current) =>
          previous.conversationRateLimit != current.conversationRateLimit ||
          previous.rateLimitStatus != current.rateLimitStatus,
      builder: (context, state) {
        final rateLimit = state.conversationRateLimit;

        if (rateLimit == null) {
          return const SizedBox.shrink();
        }

        final remaining = rateLimit.remaining;

        return Padding(
          padding: const EdgeInsets.only(right: AppDimensions.spacingSm),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showRateLimitDialog(context, state),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getGradientColors(remaining),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                  boxShadow: [
                    BoxShadow(
                      color: _getShadowColor(remaining).withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIcon(remaining),
                        size: 14,
                        color: _getIconColor(remaining),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$remaining',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Color> _getGradientColors(int remaining) {
    if (remaining <= 2) {
      return [Colors.amber.shade400, Colors.amber.shade600];
    }
    if (remaining <= 5) {
      return [AppColors.info, AppColors.info];
    }
    return [AppColors.success, AppColors.success];
  }

  Color _getShadowColor(int remaining) {
    if (remaining <= 2) return Colors.amber.shade700;
    if (remaining <= 5) return AppColors.info;
    return AppColors.success;
  }

  Color _getIconColor(int remaining) {
    if (remaining <= 2) return Colors.amber.shade700;
    if (remaining <= 5) return AppColors.info;
    return AppColors.success;
  }

  IconData _getIcon(int remaining) {
    if (remaining <= 2) return Icons.access_time;
    if (remaining <= 5) return Icons.info_outline;
    return Icons.check_circle_outline;
  }

  void _showRateLimitDialog(BuildContext context, AiChatState state) {
    showDialog(
      context: context,
      builder: (context) => RateLimitDetailDialog(state: state),
    );
  }
}

/// 频率限制详情对话框
class RateLimitDetailDialog extends StatelessWidget {
  final AiChatState state;

  const RateLimitDetailDialog({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final rateLimit = state.conversationRateLimit;
    final remaining = rateLimit?.remaining ?? 0;
    final resetInSeconds = rateLimit?.resetInSeconds ?? 0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingXxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '使用次数详情',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingXl),
            _buildStatusCard(context, remaining, resetInSeconds),
            const SizedBox(height: AppDimensions.spacingLg),
            _buildRulesCard(context, rateLimit?.rulesStatus ?? []),
            const SizedBox(height: AppDimensions.spacingXl),
            _buildUpgradeSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, int remaining, int resetInSeconds) {
    final isLow = remaining <= 5;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingXl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLow
            ? [Colors.amber.shade50, Colors.amber.shade100]
            : [AppColors.backgroundSecondary, AppColors.borderPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Column(
        children: [
          Icon(
            isLow ? Icons.access_time : Icons.check_circle_outline,
            size: 48,
            color: isLow ? Colors.amber.shade700 : AppColors.success,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            '剩余 $remaining 次',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isLow ? Colors.amber.shade800 : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            '${_formatResetTime(resetInSeconds)}后重置',
            style: TextStyle(
              fontSize: 14,
              color: isLow ? Colors.amber.shade700 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesCard(BuildContext context, List<dynamic> rulesStatus) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rule, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: AppDimensions.spacingSm),
              Text(
                '使用规则',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          ...rulesStatus.map((rule) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatRuleName(rule.name),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${rule.remaining}/${rule.limit}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: rule.remaining <= 2 ? Colors.amber.shade700 : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      ' (${rule.windowMinutes}分钟)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildUpgradeSection(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: 实现升级引导
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
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingLg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.rocket_launch, size: 20),
            const SizedBox(width: AppDimensions.spacingSm),
            const Text(
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

  String _formatRuleName(String name) {
    switch (name) {
      case 'burst':
        return '突发限制';
      case 'hourly':
        return '小时限制';
      default:
        return name;
    }
  }

  String _formatResetTime(int seconds) {
    if (seconds <= 0) return '已重置';

    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}小时${minutes}分钟';
    } else if (minutes > 0) {
      return '${minutes}分钟${secs}秒';
    } else {
      return '${secs}秒';
    }
  }
}
