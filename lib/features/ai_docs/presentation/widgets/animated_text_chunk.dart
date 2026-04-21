import 'package:flutter/material.dart';

/// 带淡入动画效果的文本块组件
/// 用于实现ChatGPT风格的文本块逐步显示效果
class AnimatedTextChunk extends StatefulWidget {
  final String text;
  final bool isStreaming;
  final TextStyle? textStyle;
  final Duration animationDuration;
  final Curve animationCurve;

  const AnimatedTextChunk({
    super.key,
    required this.text,
    this.isStreaming = false,
    this.textStyle,
    this.animationDuration = const Duration(milliseconds: 400),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  State<AnimatedTextChunk> createState() => _AnimatedTextChunkState();
}

class _AnimatedTextChunkState extends State<AnimatedTextChunk>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));

    // 启动动画
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              widget.text,
              style: widget.textStyle?.copyWith(
                color: widget.isStreaming
                    ? widget.textStyle?.color?.withOpacity(0.8)
                    : widget.textStyle?.color,
              ) ?? TextStyle(
                color: widget.isStreaming
                    ? Colors.grey[600]
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 流式文本显示组件
/// 将文本块列表渲染为带动画效果的文本
class StreamingTextDisplay extends StatelessWidget {
  final List<String> textChunks;
  final String? fullText;
  final bool isStreaming;
  final TextStyle? textStyle;
  final Duration animationDuration;
  final Curve animationCurve;

  const StreamingTextDisplay({
    super.key,
    required this.textChunks,
    this.fullText,
    this.isStreaming = false,
    this.textStyle,
    this.animationDuration = const Duration(milliseconds: 400),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    // 如果有文本块，使用动画显示
    if (textChunks.isNotEmpty) {
      return Wrap(
        children: textChunks.asMap().entries.map((entry) {
          final index = entry.key;
          final chunk = entry.value;
          
          return AnimatedTextChunk(
            key: ValueKey('chunk_$index'),
            text: chunk,
            isStreaming: isStreaming && index == textChunks.length - 1,
            textStyle: textStyle,
            animationDuration: animationDuration,
            animationCurve: animationCurve,
          );
        }).toList(),
      );
    }
    
    // 如果没有文本块但有完整文本，直接显示
    if (fullText != null && fullText!.isNotEmpty) {
      return Text(
        fullText!,
        style: textStyle,
      );
    }
    
    // 如果什么都没有，返回空容器
    return const SizedBox.shrink();
  }
} 