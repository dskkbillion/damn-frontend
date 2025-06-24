import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          padding: const EdgeInsets.only(right: 8.0),
          child: InkWell(
            onTap: () => _showRateLimitDialog(context, state),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getBackgroundColor(remaining),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getBorderColor(remaining),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getIcon(remaining),
                    size: 16,
                    color: _getTextColor(remaining),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$remaining',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getTextColor(remaining),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getBackgroundColor(int remaining) {
    if (remaining <= 2) return Colors.red.shade50;
    if (remaining <= 5) return Colors.orange.shade50;
    return Colors.green.shade50;
  }

  Color _getBorderColor(int remaining) {
    if (remaining <= 2) return Colors.red.shade300;
    if (remaining <= 5) return Colors.orange.shade300;
    return Colors.green.shade300;
  }

  Color _getTextColor(int remaining) {
    if (remaining <= 2) return Colors.red.shade700;
    if (remaining <= 5) return Colors.orange.shade700;
    return Colors.green.shade700;
  }

  IconData _getIcon(int remaining) {
    if (remaining <= 2) return Icons.warning;
    if (remaining <= 5) return Icons.info;
    return Icons.check_circle;
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
    
    return AlertDialog(
      title: const Text('分发次数限制'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('剩余次数: ${rateLimit?.remaining ?? 0}'),
          const SizedBox(height: 8),
          Text('重置时间: ${_formatResetTime(rateLimit?.resetInSeconds ?? 0)}'),
          const SizedBox(height: 16),
          const Text('规则详情:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...(rateLimit?.rulesStatus ?? []).map((rule) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${rule.name}: ${rule.remaining}/${rule.limit} (${rule.windowMinutes}分钟)',
              style: const TextStyle(fontSize: 12),
            ),
          )),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('确定'),
        ),
      ],
    );
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