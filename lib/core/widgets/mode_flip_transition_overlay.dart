import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_mode.dart';
import '../services/mode_transition_service.dart';

/// 全屏翻转动画覆盖层
class ModeFlipTransitionOverlay extends ConsumerStatefulWidget {
  final Widget child;
  
  const ModeFlipTransitionOverlay({
    Key? key,
    required this.child,
  }) : super(key: key);
  
  @override
  ConsumerState<ModeFlipTransitionOverlay> createState() => _ModeFlipTransitionOverlayState();
}

class _ModeFlipTransitionOverlayState extends ConsumerState<ModeFlipTransitionOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  ModeTransitionEvent? _currentEvent;
  bool _isAnimating = false;
  bool _callbackExecuted = false;
  StreamSubscription? _subscription;
  AppMode? _animationStartMode; // 记录动画开始时的模式
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    // 监听动画进度，在翻转到一半时执行切换
    _animation.addListener(() {
      if (_animation.value >= 0.5 && _currentEvent != null && !_callbackExecuted) {
        _callbackExecuted = true;
        // 在动画进行到50%时执行模式切换
        _currentEvent?.onComplete();
      }
    });
    
    // 监听动画状态
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        // 动画完成后立即结束过渡
        print('[ModeFlip] Animation completed');
        _completeTransition();
      }
    });
    
    // 在initState中监听转换事件
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final modeTransitionService = ref.read(modeTransitionServiceProvider);
        _subscription = modeTransitionService.transitionStream.listen((event) {
          if (!_isAnimating && _currentEvent == null && mounted) {
            _currentEvent = event;
            // 记录动画开始时的模式
            _animationStartMode = ref.read(appModeProvider);
            
            setState(() {
              _isAnimating = true;
              _callbackExecuted = false;
            });
            
            // 开始动画，模式切换会在动画50%时自动触发
            _controller.forward();
          }
        });
      }
    });
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
    super.dispose();
  }
  
  
  /// 完成过渡动画
  void _completeTransition() {
    if (!mounted) return;
    
    print('[ModeFlip] Completing transition...');
    
    // 重置状态
    setState(() {
      _isAnimating = false;
      _callbackExecuted = false;
      _currentEvent = null;
      _animationStartMode = null;
    });
    
    // 重置动画控制器
    _controller.reset();
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isAnimating) {
      // 全屏翻转动画
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final rotation = _animation.value * pi;
          final isShowingFront = rotation < pi / 2;
          
          return ClipRect(
            child: OverflowBox(
              alignment: Alignment.center,
              maxWidth: MediaQuery.of(context).size.width,
              maxHeight: MediaQuery.of(context).size.height,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0) // 移除透视效果，避免位移
                  ..rotateY(rotation),
                child: SizedBox.expand(
                  child: isShowingFront 
                    ? widget.child
                    : _buildTransitionPage(),
                ),
              ),
            ),
          );
        },
      );
    }
    
    return widget.child;
  }
  
  Widget _buildTransitionPage() {
    final targetMode = _currentEvent?.targetMode ?? AppMode.buyer;
    // 使用动画开始时的模式，而不是当前模式，因为模式已经切换了
    final displayMode = _animationStartMode ?? ref.watch(appModeProvider);
    
    // 使用当前主题背景色，并提供Directionality
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 当前模式图标：从一开始就完全显示，到70%时淡出
              AnimatedOpacity(
                opacity: _animation.value < 0.5 
                  ? 1.0
                  : _animation.value < 0.7 
                    ? 1.0 - ((_animation.value - 0.5) / 0.2)
                    : 0.0,
                duration: const Duration(milliseconds: 100),
                child: Icon(
                  displayMode == AppMode.buyer 
                    ? Icons.shopping_bag_outlined 
                    : Icons.storefront_outlined,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              
              // 目标模式图标：70%-100%时淡入
              AnimatedOpacity(
                opacity: _animation.value > 0.7 
                  ? ((_animation.value - 0.7) / 0.3).clamp(0.0, 1.0)
                  : 0.0,
                duration: const Duration(milliseconds: 100),
                child: Icon(
                  targetMode == AppMode.buyer 
                    ? Icons.shopping_bag_outlined 
                    : Icons.storefront_outlined,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}