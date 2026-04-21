import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/bloc/ai_chat/ai_chat_bloc.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart'; // 导入国际化资源

class AnimatedAllocationButton extends StatefulWidget {
  final VoidCallback? onTap;
  final VoidCallback? onEnterChat;
  final AllocationStatus status;

  const AnimatedAllocationButton({
    super.key,
    required this.status,
    this.onTap,
    this.onEnterChat,
  });

  @override
  State<AnimatedAllocationButton> createState() => _AnimatedAllocationButtonState();
}

class _AnimatedAllocationButtonState extends State<AnimatedAllocationButton> with TickerProviderStateMixin {
  // 打字机文字动画控制器
  late AnimationController _textController;

  // 主进度条动画控制器 (0-80%)
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  // 完成时的额外进度控制器 (80-100%)
  late AnimationController _completionController;
  late Animation<double> _completionAnimation;

  // 打字机文字状态 - 移除固定文本数组，改为从国际化资源获取
  int _currentTextStep = 0;
  final int _totalTextSteps = 4; // 总共4个状态

  // 当前总进度值 (0.0-1.0)
  double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();

    // 初始化文字动画控制器
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentTextStep = (_currentTextStep + 1) % _totalTextSteps;
        });
        _textController.forward(from: 0.0);
      }
    });

    // 初始化主进度条动画控制器 (20秒达到80%)
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 20000), // 20秒
    );

    // 创建进度动画，使用缓慢的曲线
    _progressAnimation = Tween<double>(begin: 0.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _progressController,
        // 使用自定义曲线，开始快一些，中间变慢，给用户耐心等待的感觉
        curve: Curves.easeOutQuad,
      ),
    )..addListener(() {
      setState(() {
        // 主进度条占总进度的80%
        _currentProgress = _progressAnimation.value;
      });
    });

    // 初始化完成动画控制器 (0.5秒内完成剩余20%)
    _completionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 创建完成动画，从当前进度快速到达100%
    _completionAnimation = Tween<double>(begin: 0.0, end: 0.2).animate(
      CurvedAnimation(
        parent: _completionController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
      setState(() {
        // 完成动画从当前进度开始，增加最后20%
        _currentProgress = 0.8 + _completionAnimation.value;
      });
    });

    // 根据当前状态开始动画
    if (widget.status == AllocationStatus.loading) {
      _startAnimations();
    }
  }

  // 获取当前打字机状态对应的文本
  String _getTextForCurrentStep(AppLocalizations appLocalizations) {
    // 根据国际化资源获取不同语言的文本
    switch (_currentTextStep) {
      case 0:
        return appLocalizations.allocating_step1; // 分发中
      case 1:
        return appLocalizations.allocating_step2; // 分发中.
      case 2:
        return appLocalizations.allocating_step3; // 分发中..
      case 3:
        return appLocalizations.allocating_step4; // 分发中...
      default:
        return appLocalizations.allocating_step1; // 默认分发中
    }
  }

  @override
  void didUpdateWidget(AnimatedAllocationButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 状态变化时，控制动画
    if (oldWidget.status != widget.status) {
      if (widget.status == AllocationStatus.loading) {
        _resetAndStartAnimations();
      } else if (widget.status == AllocationStatus.success) {
        // 分发成功，快速完成剩余进度
        _completeProgress();
      } else {
        _stopAnimations();
      }
    }
  }

  void _resetAndStartAnimations() {
    // 重置进度
    setState(() {
      _currentProgress = 0.0;
      _currentTextStep = 0;
    });

    // 重置并启动动画
    _progressController.reset();
    _completionController.reset();
    _startAnimations();
  }

  void _startAnimations() {
    _textController.forward();
    _progressController.forward();
  }

  void _completeProgress() {
    // 停止主进度动画
    _progressController.stop();
    // 停止文字动画
    _textController.stop();

    // 启动完成动画
    _completionController.forward(from: 0.0);
  }

  void _stopAnimations() {
    _textController.stop();
    _progressController.stop();
    _completionController.stop();
  }

  @override
  void dispose() {
    _textController.dispose();
    _progressController.dispose();
    _completionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 根据状态决定显示内容
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildButtonForStatus(),
    );
  }

  Widget _buildButtonForStatus() {
    switch (widget.status) {
      case AllocationStatus.loading:
        return _buildLoadingButton();
      case AllocationStatus.success:
        return _buildSuccessButton();
      case AllocationStatus.failure:
        return _buildFailureButton();
      case AllocationStatus.initial:
      default:
        return _buildInitialButton();
    }
  }

  // 初始状态按钮
  Widget _buildInitialButton() {
    final appLocalizations = AppLocalizations.of(context); // 获取国际化资源

    return Container(
      key: const ValueKey('initial'),
      width: double.infinity,
      height: 32,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: TextButton(
        onPressed: widget.onTap,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          appLocalizations.ai_docs_let_them_see, // 使用国际化文本
          style: const TextStyle(color: Colors.white, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // 加载中状态按钮 - 包含打字机效果和进度条
  Widget _buildLoadingButton() {
    final appLocalizations = AppLocalizations.of(context); // 获取国际化资源

    return Container(
      key: const ValueKey('loading'),
      width: double.infinity,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Stack(
        children: [
          // 底层背景
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            ),
          ),

          // 中层进度条
          FractionallySizedBox(
            widthFactor: _currentProgress.clamp(0.0, 1.0), // 确保不超过1.0
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              ),
            ),
          ),

          // 顶层文字
          Center(
            child: Text(
              _getTextForCurrentStep(appLocalizations), // 使用国际化文本
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.clip,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // 成功状态按钮
  Widget _buildSuccessButton() {
    final appLocalizations = AppLocalizations.of(context); // 获取国际化资源

    return Container(
      key: const ValueKey('success'),
      width: double.infinity,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: TextButton(
        onPressed: widget.onEnterChat, // 使用进入聊天回调
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          appLocalizations.ai_docs_enter_chat, // 使用国际化文本 "进入聊天"
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // 失败状态按钮
  Widget _buildFailureButton() {
    final appLocalizations = AppLocalizations.of(context); // 获取国际化资源

    return Container(
      key: const ValueKey('failure'),
      width: double.infinity,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: TextButton(
        onPressed: widget.onTap,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          appLocalizations.ai_docs_retry, // 使用国际化文本
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
