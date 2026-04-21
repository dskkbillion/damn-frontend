import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/order_status.dart';
import 'order_status_widget.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

/// 增强版订单状态标签，支持倒计时显示
class EnhancedOrderStatusWidget extends StatefulWidget {
  final OrderStatus status;
  final DateTime? countdownEndTime;
  final VoidCallback? onCountdownEnd;
  
  const EnhancedOrderStatusWidget({
    super.key,
    required this.status,
    this.countdownEndTime,
    this.onCountdownEnd,
  });
  
  @override
  State<EnhancedOrderStatusWidget> createState() => _EnhancedOrderStatusWidgetState();
}

class _EnhancedOrderStatusWidgetState extends State<EnhancedOrderStatusWidget> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  
  @override
  void initState() {
    super.initState();
    _startCountdown();
  }
  
  @override
  void didUpdateWidget(EnhancedOrderStatusWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.countdownEndTime != widget.countdownEndTime) {
      _timer?.cancel();
      _startCountdown();
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  void _startCountdown() {
    if (widget.countdownEndTime == null || !_shouldShowCountdown(widget.status)) {
      return;
    }
    
    _updateRemaining();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemaining();
      
      if (_remaining.isNegative || _remaining == Duration.zero) {
        timer.cancel();
        widget.onCountdownEnd?.call();
      }
    });
  }
  
  void _updateRemaining() {
    if (mounted && widget.countdownEndTime != null) {
      setState(() {
        _remaining = widget.countdownEndTime!.difference(DateTime.now());
      });
    }
  }
  
  /// 判断是否需要显示倒计时
  bool _shouldShowCountdown(OrderStatus status) {
    switch (status) {
      case OrderStatus.awaitingPayment:
      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
      case OrderStatus.awaitingStart:
      case OrderStatus.awaitingConfirmation:
        return true;
      default:
        return false;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 保持现有状态标签样式
        OrderStatusWidget(status: widget.status),
        
        // 新增：倒计时显示（仅特定状态）
        if (widget.countdownEndTime != null && 
            _shouldShowCountdown(widget.status) && 
            !_remaining.isNegative)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _buildCountdownChip(colorScheme, textTheme),
          ),
      ],
    );
  }
  
  Widget _buildCountdownChip(ColorScheme colorScheme, TextTheme textTheme) {
    // 根据剩余时间确定紧急程度
    final isUrgent = _remaining.inMinutes < 30;
    final backgroundColor = isUrgent 
      ? colorScheme.errorContainer 
      : colorScheme.secondaryContainer;
    final textColor = isUrgent
      ? colorScheme.onErrorContainer
      : colorScheme.onSecondaryContainer;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time,
            size: 12,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            _formatDuration(_remaining),
            style: textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 格式化时间间隔
  String _formatDuration(Duration duration) {
    final l10n = AppLocalizations.of(context);
    if (duration.isNegative) return l10n.order_countdown_expired;

    if (duration.inDays > 0) {
      return l10n.order_countdown_days_hours(duration.inDays, duration.inHours % 24);
    } else if (duration.inHours > 0) {
      return l10n.order_countdown_hours_minutes(duration.inHours, duration.inMinutes % 60);
    } else if (duration.inMinutes > 0) {
      return l10n.order_countdown_minutes(duration.inMinutes);
    } else {
      return l10n.order_countdown_seconds(duration.inSeconds);
    }
  }
}

/// 独立的倒计时芯片组件，可单独使用
class CountdownChip extends StatefulWidget {
  final DateTime endTime;
  final ChipStyle style;
  final VoidCallback? onTimeout;
  
  const CountdownChip({
    super.key,
    required this.endTime,
    this.style = ChipStyle.medium,
    this.onTimeout,
  });
  
  @override
  State<CountdownChip> createState() => _CountdownChipState();
}

enum ChipStyle {
  small,
  medium,
  large,
}

class _CountdownChipState extends State<CountdownChip> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  
  @override
  void initState() {
    super.initState();
    _startTimer();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  void _startTimer() {
    _updateRemaining();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemaining();
      
      if (_remaining.isNegative || _remaining == Duration.zero) {
        timer.cancel();
        widget.onTimeout?.call();
      }
    });
  }
  
  void _updateRemaining() {
    if (mounted) {
      setState(() {
        _remaining = widget.endTime.difference(DateTime.now());
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    // 根据样式大小确定字体和边距
    final fontSize = switch (widget.style) {
      ChipStyle.small => 10.0,
      ChipStyle.medium => 12.0,
      ChipStyle.large => 14.0,
    };
    
    final padding = switch (widget.style) {
      ChipStyle.small => const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      ChipStyle.medium => const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ChipStyle.large => const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    };
    
    final isUrgent = _remaining.inMinutes < 30;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: padding,
      decoration: BoxDecoration(
        color: isUrgent 
          ? colorScheme.errorContainer.withOpacity(0.8)
          : colorScheme.primaryContainer.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: fontSize + 2,
            color: isUrgent 
              ? colorScheme.onErrorContainer
              : colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            _formatDuration(_remaining),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: isUrgent 
                ? colorScheme.onErrorContainer
                : colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDuration(Duration duration) {
    final l10n = AppLocalizations.of(context);
    if (duration.isNegative) return l10n.order_countdown_expired;

    if (duration.inDays > 0) {
      return l10n.order_countdown_days(duration.inDays);
    } else if (duration.inHours > 0) {
      return l10n.order_countdown_hours_minutes(duration.inHours, duration.inMinutes % 60);
    } else if (duration.inMinutes > 5) {
      return l10n.order_countdown_minutes(duration.inMinutes);
    } else if (duration.inMinutes > 0) {
      return l10n.order_countdown_minutes_seconds(duration.inMinutes, duration.inSeconds % 60);
    } else {
      return l10n.order_countdown_seconds(duration.inSeconds);
    }
  }
}