import 'dart:async';
import 'package:flutter/material.dart';

/// 验证码按钮的状态
enum CodeButtonState {
  idle,      // 空闲，可点击
  counting,  // 正在倒计时
}

/// 发送验证码按钮 Widget (带倒计时功能)
class VerificationCodeButton extends StatefulWidget {
  final TextEditingController phoneController; // 用于获取手机号
  final Future<void> Function(String phone) onSendCode; // 点击发送验证码的回调
  final CodeButtonState codeSentState; // 由外部状态管理控制按钮状态
  final bool isSending; // 是否正在发送验证码（显示加载状态）
  final int countdownSeconds; // 倒计时总秒数

  const VerificationCodeButton({
    super.key,
    required this.phoneController,
    required this.onSendCode,
    required this.codeSentState,
    required this.isSending,
    this.countdownSeconds = 60,
  });

  @override
  State<VerificationCodeButton> createState() => _VerificationCodeButtonState();
}

class _VerificationCodeButtonState extends State<VerificationCodeButton> {
  Timer? _timer;
  int _currentCountdown = 0;

  @override
  void initState() {
    super.initState();
    _currentCountdown = widget.countdownSeconds;
    // 如果初始状态就是 counting，则开始倒计时
    if (widget.codeSentState == CodeButtonState.counting) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(covariant VerificationCodeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 监听外部状态变化来启动或停止计时器
    if (widget.codeSentState == CodeButtonState.counting && _timer == null) {
      _startTimer();
    } else if (widget.codeSentState == CodeButtonState.idle && _timer != null) {
      _stopTimer();
    }
    // 如果倒计时总时长发生变化，更新当前值
    if (widget.countdownSeconds != oldWidget.countdownSeconds) {
       _currentCountdown = widget.countdownSeconds;
    }
  }

  void _startTimer() {
    _timer?.cancel(); // Ensure any existing timer is cancelled
    _currentCountdown = widget.countdownSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { // Widget 可能已 unmount
         timer.cancel();
         return;
      }
      setState(() {
        if (_currentCountdown > 0) {
          _currentCountdown--;
        } else {
          _stopTimer();
          // TODO: 通知外部状态管理器倒计时结束？(可选)
          // 或者依赖外部状态管理自动切换回 idle
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
     if (mounted) {
        setState(() {
          _currentCountdown = widget.countdownSeconds; // 重置倒计时
        });
     }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool canSend = !widget.isSending && widget.codeSentState == CodeButtonState.idle;

    return ElevatedButton(
      onPressed: canSend
          ? () {
              final account = widget.phoneController.text;
              print('尝试发送验证码到: $account');
              
              // 不在这里验证，让调用方处理验证逻辑
              if (account.isNotEmpty) {
                widget.onSendCode(account);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请输入手机号或邮箱')),
                );
              }
            }
          : null,
      child: widget.isSending
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) // 加载状态
          : Text(
              widget.codeSentState == CodeButtonState.counting
                  ? '$_currentCountdown s' // 显示倒计时
                  : '获取验证码', // 空闲状态
            ),
    );
  }
}
