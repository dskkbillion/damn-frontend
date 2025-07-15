import 'package:flutter/material.dart';

/// 微交互动画组件库
/// 提供按钮点击反馈、悬停效果等小交互动画
class MicroInteractions {
  /// 包装widget添加点击动画效果
  /// 
  /// [child] - 子widget
  /// [onTap] - 点击回调
  /// [scaleValue] - 缩放值，默认0.95
  /// [duration] - 动画持续时间，默认100ms
  static Widget wrapWithTapAnimation(
    Widget child, 
    VoidCallback onTap, {
    double scaleValue = 0.95,
    Duration duration = const Duration(milliseconds: 100),
  }) {
    return _TapAnimationWidget(
      child: child,
      onTap: onTap,
      scaleValue: scaleValue,
      duration: duration,
    );
  }
  
  /// 包装widget添加悬停效果
  /// 
  /// [child] - 子widget
  /// [hoverColor] - 悬停背景色
  /// [duration] - 动画持续时间，默认200ms
  static Widget wrapWithHoverEffect(
    Widget child, {
    Color? hoverColor,
    Duration duration = const Duration(milliseconds: 200),
  }) {
    return _HoverEffectWidget(
      child: child,
      hoverColor: hoverColor,
      duration: duration,
    );
  }
  
  /// 包装widget添加长按动画效果
  /// 
  /// [child] - 子widget
  /// [onLongPress] - 长按回调
  /// [scaleValue] - 缩放值，默认0.90
  /// [duration] - 动画持续时间，默认150ms
  static Widget wrapWithLongPressAnimation(
    Widget child,
    VoidCallback onLongPress, {
    double scaleValue = 0.90,
    Duration duration = const Duration(milliseconds: 150),
  }) {
    return _LongPressAnimationWidget(
      child: child,
      onLongPress: onLongPress,
      scaleValue: scaleValue,
      duration: duration,
    );
  }
  
  /// 包装widget添加弹跳动画效果
  /// 
  /// [child] - 子widget
  /// [onTap] - 点击回调
  /// [bounceIntensity] - 弹跳强度，默认1.1
  /// [duration] - 动画持续时间，默认200ms
  static Widget wrapWithBounceAnimation(
    Widget child,
    VoidCallback onTap, {
    double bounceIntensity = 1.1,
    Duration duration = const Duration(milliseconds: 200),
  }) {
    return _BounceAnimationWidget(
      child: child,
      onTap: onTap,
      bounceIntensity: bounceIntensity,
      duration: duration,
    );
  }
}

/// 点击动画widget
class _TapAnimationWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scaleValue;
  final Duration duration;
  
  const _TapAnimationWidget({
    required this.child,
    required this.onTap,
    required this.scaleValue,
    required this.duration,
  });
  
  @override
  State<_TapAnimationWidget> createState() => _TapAnimationWidgetState();
}

class _TapAnimationWidgetState extends State<_TapAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleValue,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        ),
      ),
    );
  }
}

/// 悬停效果widget
class _HoverEffectWidget extends StatefulWidget {
  final Widget child;
  final Color? hoverColor;
  final Duration duration;
  
  const _HoverEffectWidget({
    required this.child,
    this.hoverColor,
    required this.duration,
  });
  
  @override
  State<_HoverEffectWidget> createState() => _HoverEffectWidgetState();
}

class _HoverEffectWidgetState extends State<_HoverEffectWidget> {
  bool _isHovering = false;
  
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: widget.duration,
        decoration: BoxDecoration(
          color: _isHovering 
              ? widget.hoverColor ?? Colors.grey.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: widget.child,
      ),
    );
  }
}

/// 长按动画widget
class _LongPressAnimationWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onLongPress;
  final double scaleValue;
  final Duration duration;
  
  const _LongPressAnimationWidget({
    required this.child,
    required this.onLongPress,
    required this.scaleValue,
    required this.duration,
  });
  
  @override
  State<_LongPressAnimationWidget> createState() => _LongPressAnimationWidgetState();
}

class _LongPressAnimationWidgetState extends State<_LongPressAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleValue,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _controller.forward(),
      onLongPressEnd: (_) => _controller.reverse(),
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        ),
      ),
    );
  }
}

/// 弹跳动画widget
class _BounceAnimationWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double bounceIntensity;
  final Duration duration;
  
  const _BounceAnimationWidget({
    required this.child,
    required this.onTap,
    required this.bounceIntensity,
    required this.duration,
  });
  
  @override
  State<_BounceAnimationWidget> createState() => _BounceAnimationWidgetState();
}

class _BounceAnimationWidgetState extends State<_BounceAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.bounceIntensity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onTap() {
    _controller.forward().then((_) {
      _controller.reverse();
      widget.onTap();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        ),
      ),
    );
  }
} 