import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import '../bloc/ai_chat/ai_chat_bloc.dart';

/// 已分发服务历史弹窗内容 (#347)。
/// 按 allocatedAt 倒序展示当前 conversation 的全部分发记录。
class DispatchHistoryBottomSheetContent extends StatelessWidget {
  const DispatchHistoryBottomSheetContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiChatBloc, AiChatState>(
      buildWhen: (previous, current) =>
          previous.dispatchHistory != current.dispatchHistory ||
          previous.dispatchHistoryStatus != current.dispatchHistoryStatus,
      builder: (context, state) {
        final history = state.dispatchHistory ?? const [];
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: AppDimensions.spacingMd,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
                child: Row(
                  children: [
                    const Icon(Icons.history, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '已分发服务',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '${history.length} 条',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                    ),
                  ],
                ),
              ),
              if (state.dispatchHistoryStatus == DispatchHistoryStatus.loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (history.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      '暂无分发记录',
                      style: TextStyle(color: AppColors.textTertiary),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: history.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.borderInput,
                          child: Icon(Icons.shopping_bag_outlined, size: 18),
                        ),
                        title: Text('商品 #${item.itemId}'),
                        subtitle: Text(
                          item.merchantId != null
                              ? '商家 ${item.merchantId} · ${_formatTime(item.allocatedAt)}'
                              : _formatTime(item.allocatedAt),
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.textTertiary,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(int? allocatedAt) {
    if (allocatedAt == null) return '';
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final diff = now - allocatedAt;
    if (diff < 60) return '刚刚';
    if (diff < 3600) return '${diff ~/ 60} 分钟前';
    if (diff < 86400) return '${diff ~/ 3600} 小时前';
    if (diff < 86400 * 7) return '${diff ~/ 86400} 天前';
    final dt = DateTime.fromMillisecondsSinceEpoch(allocatedAt * 1000);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
