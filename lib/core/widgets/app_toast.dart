import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/app/navigation/app_router.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

enum _ToastType { success, error, info }

/// 统一轻量级 Toast 提示组件
class AppToast {
  AppToast._();

  static OverlayEntry? _currentOverlayEntry;

  static void _dismissCurrent() {
    if (_currentOverlayEntry != null) {
      try {
        _currentOverlayEntry!.remove();
      } catch (_) {
        // 防止 auto-dismiss timer 竞态
      }
      _currentOverlayEntry = null;
    }
  }

  static void _show(BuildContext context, String message, _ToastType type) {
    final overlay = rootNavigatorKey.currentState?.overlay;
    if (overlay == null) return;

    _dismissCurrent();

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _ToastWidget(
        message: message,
        type: type,
        onDismissed: () {
          try {
            entry.remove();
          } catch (_) {}
          if (_currentOverlayEntry == entry) {
            _currentOverlayEntry = null;
          }
        },
      ),
    );

    _currentOverlayEntry = entry;
    overlay.insert(entry);
  }

  static void success(BuildContext context, String message) {
    _show(context, message, _ToastType.success);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, _ToastType.error);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, _ToastType.info);
  }
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({
    required this.message,
    required this.type,
    required this.onDismissed,
  });

  final String message;
  final _ToastType type;
  final VoidCallback onDismissed;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    final duration = widget.type == _ToastType.error
        ? const Duration(seconds: 3)
        : const Duration(seconds: 2);

    _timer = Timer(duration, _dismiss);
  }

  void _dismiss() {
    if (!mounted) return;
    _controller.reverseDuration = const Duration(milliseconds: 150);
    _controller.reverse().then((_) {
      widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final IconData icon;
    final Color iconColor;

    switch (widget.type) {
      case _ToastType.success:
        icon = Icons.check_circle;
        iconColor = isDark ? AppColorsDark.success : AppColors.success;
      case _ToastType.error:
        icon = Icons.error;
        iconColor = isDark ? AppColorsDark.error : AppColors.error;
      case _ToastType.info:
        icon = Icons.info;
        iconColor = isDark ? AppColorsDark.info : AppColors.info;
    }

    final bgColor =
        isDark ? AppColorsDark.backgroundElevated : Colors.white;
    final textColor =
        isDark ? AppColorsDark.textPrimary : AppColors.textPrimary;

    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 80,
      left: 24,
      right: 24,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _opacity,
          child: Material(
            elevation: 4,
            borderRadius:
                BorderRadius.circular(AppDimensions.radiusMd),
            color: bgColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Icon(icon, color: iconColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
