import 'package:flutter/material.dart';

/// 简化的麦克风按钮组件
/// 用于语音输入，只有简单的图标切换效果
class PulsatingMicButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onPressed;
  final bool isEnabled;
  final Color? primaryColor;
  final Color? recordingColor;
  final double size;

  const PulsatingMicButton({
    super.key,
    required this.isRecording,
    required this.onPressed,
    this.isEnabled = true,
    this.primaryColor,
    this.recordingColor,
    this.size = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = this.primaryColor ?? Theme.of(context).primaryColor;
    final recordingColor = this.recordingColor ?? Colors.red;

    return Stack(
      alignment: Alignment.center,
      children: [
        // 录音时的脉动圆圈（变小）
        if (isRecording)
          Container(
            width: size * 1.2, // 缩小外圈
            height: size * 1.2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: recordingColor.withOpacity(0.2),
            ),
          ),
        
        // 主按钮
        if (isRecording)
          // 录音时显示圆形背景
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: recordingColor,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(size / 2),
                onTap: isEnabled ? onPressed : null,
                child: Center(
                  child: Icon(
                    Icons.stop,
                    color: Colors.white,
                    size: size * 0.5,
                  ),
                ),
              ),
            ),
          )
        else
          // 平时只显示图标，没有圆形背景，和左边图片icon保持一致
          IconButton(
            onPressed: isEnabled ? onPressed : null,
            icon: const Icon(Icons.mic),
            tooltip: '语音输入',
          ),
      ],
    );
  }
}

/// 语音录音指示器组件
/// 显示录音状态和持续时间
class VoiceRecordingIndicator extends StatefulWidget {
  final bool isRecording;
  final Duration recordingDuration;

  const VoiceRecordingIndicator({
    super.key,
    required this.isRecording,
    required this.recordingDuration,
  });

  @override
  State<VoiceRecordingIndicator> createState() => _VoiceRecordingIndicatorState();
}

class _VoiceRecordingIndicatorState extends State<VoiceRecordingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    
    // 波形动画控制器
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _waveAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.isRecording) {
      _waveController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(VoiceRecordingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRecording != widget.isRecording) {
      if (widget.isRecording) {
        _waveController.repeat(reverse: true);
      } else {
        _waveController.stop();
      }
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRecording) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 录音波形指示器
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) {
              return Row(
                children: List.generate(3, (index) {
                  final delay = index * 0.2;
                  final animationValue = (_waveAnimation.value + delay) % 1.0;
                  return Container(
                    margin: const EdgeInsets.only(right: 2),
                    width: 3,
                    height: 12 + (8 * animationValue),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  );
                }),
              );
            },
          ),
          
          const SizedBox(width: 8),
          
          // 录音时间
          Text(
            _formatDuration(widget.recordingDuration),
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
} 