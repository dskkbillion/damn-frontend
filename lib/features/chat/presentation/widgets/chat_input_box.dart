import 'package:flutter/material.dart';

/// 聊天输入框组件
class ChatInputBox extends StatefulWidget {
  /// 文本编辑控制器
  final TextEditingController controller;
  
  /// 发送按钮回调
  final VoidCallback onSendPressed;
  
  /// 图片按钮回调
  final VoidCallback onImagePressed;
  
  /// 语音按钮回调
  final VoidCallback onVoicePressed;

  const ChatInputBox({
    Key? key,
    required this.controller,
    required this.onSendPressed,
    required this.onImagePressed,
    required this.onVoicePressed,
  }) : super(key: key);

  @override
  State<ChatInputBox> createState() => _ChatInputBoxState();
}

class _ChatInputBoxState extends State<ChatInputBox> {
  bool _isVoiceMode = false; // 是否处于语音输入模式
  bool _isRecording = false; // 是否正在录音
  bool _hasText = false; // 文本框是否有内容

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _toggleVoiceMode() {
    setState(() {
      _isVoiceMode = !_isVoiceMode;
      if (_isVoiceMode) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
    });
    // 开始录音
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
    });
    // 停止录音并发送
    widget.onVoicePressed();
  }

  void _cancelRecording() {
    setState(() {
      _isRecording = false;
    });
    // 取消录音
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // 正在录音时的提示条
          if (_isRecording)
            Container(
              color: Colors.red.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.mic, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text('正在录音...'),
                  const Spacer(),
                  const Text('上滑取消'),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _cancelRecording,
                  ),
                ],
              ),
            ),
            
          // 输入框区域
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                // 语音/键盘切换按钮
                IconButton(
                  icon: Icon(_isVoiceMode ? Icons.keyboard : Icons.mic),
                  onPressed: _toggleVoiceMode,
                ),
                
                // 文本输入框或语音按钮
                Expanded(
                  child: _isVoiceMode
                      ? GestureDetector(
                          onTapDown: (_) => _startRecording(),
                          onTapUp: (_) => _stopRecording(),
                          onTapCancel: _cancelRecording,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: _isRecording ? Colors.red.withOpacity(0.1) : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                _isRecording ? '松开发送' : '按住说话',
                                style: TextStyle(
                                  color: _isRecording ? Colors.red : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                        )
                      : TextField(
                          controller: widget.controller,
                          decoration: InputDecoration(
                            hintText: '输入消息...',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade200,
                          ),
                          maxLines: 4,
                          minLines: 1,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                ),
                
                // 图片按钮
                IconButton(
                  icon: const Icon(Icons.photo),
                  onPressed: widget.onImagePressed,
                ),
                
                // 发送按钮 (仅在文本模式且有内容时显示)
                if (!_isVoiceMode && _hasText)
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Theme.of(context).primaryColor,
                    onPressed: widget.onSendPressed,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 