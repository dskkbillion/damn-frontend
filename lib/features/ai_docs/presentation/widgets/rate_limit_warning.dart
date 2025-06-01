import 'package:flutter/material.dart';

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
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: remaining <= 2 ? Colors.red.shade50 : Colors.orange.shade50,
        border: Border.all(
          color: remaining <= 2 ? Colors.red.shade300 : Colors.orange.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            remaining <= 2 ? Icons.warning : Icons.info,
            color: remaining <= 2 ? Colors.red.shade700 : Colors.orange.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              remaining <= 2 
                ? '推荐次数即将用完，剩余${remaining}次，${_formatResetTime(resetInSeconds)}后重置'
                : '推荐次数较少，剩余${remaining}次',
              style: TextStyle(
                color: remaining <= 2 ? Colors.red.shade700 : Colors.orange.shade700,
                fontSize: 13,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: onDismiss,
              color: remaining <= 2 ? Colors.red.shade700 : Colors.orange.shade700,
            ),
        ],
      ),
    );
  }

  String _formatResetTime(int seconds) {
    final minutes = (seconds / 60).ceil();
    if (minutes > 60) {
      return '${(minutes / 60).ceil()}小时';
    }
    return '${minutes}分钟';
  }
}