import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/message_bloc/message_bloc.dart';
import '../bloc/message_bloc/message_event.dart';

/// 聊天输入框组件
///
/// 提供文本输入和媒体选择功能，用于发送各类消息
class ChatInput extends StatefulWidget {
  /// 会话ID
  final String sessionId;
  
  /// 消息发送后回调
  final VoidCallback? onMessageSent;

  const ChatInput({
    Key? key,
    required this.sessionId,
    this.onMessageSent,
  }) : super(key: key);

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  /// 文本输入控制器
  final TextEditingController _textController = TextEditingController();
  
  /// 是否显示表情选择器
  bool _showEmojiPicker = false;
  
  /// 是否在录音模式
  bool _isVoiceMode = false;
  
  /// 是否显示更多功能面板
  bool _showMoreOptions = false;
  
  /// 消息发送按钮是否可点击
  bool _canSend = false;
  
  /// 焦点节点，用于管理输入框焦点
  final FocusNode _focusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    
    // 监听文本变化
    _textController.addListener(_updateSendButtonState);
    
    // 监听焦点变化
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _showEmojiPicker) {
        setState(() {
          _showEmojiPicker = false;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _textController.removeListener(_updateSendButtonState);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  /// 更新发送按钮状态
  void _updateSendButtonState() {
    final canSend = _textController.text.trim().isNotEmpty;
    if (canSend != _canSend) {
      setState(() {
        _canSend = canSend;
      });
    }
  }
  
  /// 发送文本消息
  void _sendTextMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    
    context.read<MessageBloc>().add(SendMessage(
      sessionId: widget.sessionId,
      content: text,
      receiverId: '', // 由Bloc根据sessionId获取
    ));
    
    // 清空输入框
    _textController.clear();
    
    // 调用发送回调
    widget.onMessageSent?.call();
  }
  
  /// 切换语音/文本输入模式
  void _toggleVoiceMode() {
    setState(() {
      _isVoiceMode = !_isVoiceMode;
      if (_isVoiceMode) {
        // 如果切换到语音模式，关闭键盘和其他面板
        _focusNode.unfocus();
        _showEmojiPicker = false;
        _showMoreOptions = false;
      }
    });
  }
  
  /// 切换表情选择器
  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
      if (_showEmojiPicker) {
        // 如果打开表情选择器，关闭键盘和更多选项
        _focusNode.unfocus();
        _showMoreOptions = false;
      }
    });
  }
  
  /// 切换更多选项
  void _toggleMoreOptions() {
    setState(() {
      _showMoreOptions = !_showMoreOptions;
      if (_showMoreOptions) {
        // 如果打开更多选项，关闭键盘和表情选择器
        _focusNode.unfocus();
        _showEmojiPicker = false;
      }
    });
  }
  
  /// 选择图片
  void _selectImage() {
    // 模拟选择图片并发送
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('此功能尚未实现')),
    );
  }
  
  /// 选择文件
  void _selectFile() {
    // 模拟选择文件并发送
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('此功能尚未实现')),
    );
  }
  
  /// 选择位置
  void _selectLocation() {
    // 模拟选择位置并发送
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('此功能尚未实现')),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 底部分割线
        Container(
          height: 1,
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
        
        // 输入栏
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              // 语音/键盘切换按钮
              IconButton(
                icon: Icon(_isVoiceMode ? Icons.keyboard : Icons.mic),
                onPressed: _toggleVoiceMode,
              ),
              
              // 语音模式下的按住说话按钮
              if (_isVoiceMode)
                Expanded(
                  child: GestureDetector(
                    onLongPress: () {
                      // TODO: 实现语音录制开始
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('开始录音')),
                      );
                    },
                    onLongPressEnd: (details) {
                      // TODO: 实现语音录制结束并发送
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('录音结束，发送语音消息')),
                      );
                    },
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      alignment: Alignment.center,
                      child: const Text('按住说话'),
                    ),
                  ),
                )
              else
                // 文本输入框
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            focusNode: _focusNode,
                            decoration: const InputDecoration(
                              hintText: '输入消息...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            maxLines: 5,
                            minLines: 1,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                        // 表情按钮
                        IconButton(
                          icon: const Icon(Icons.emoji_emotions_outlined),
                          onPressed: _toggleEmojiPicker,
                          color: _showEmojiPicker ? Theme.of(context).colorScheme.primary : null,
                        ),
                      ],
                    ),
                  ),
                ),
              
              // 更多功能按钮
              if (!_isVoiceMode && !_canSend)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _toggleMoreOptions,
                  color: _showMoreOptions ? Theme.of(context).colorScheme.primary : null,
                ),
                
              // 发送按钮
              if (!_isVoiceMode && _canSend)
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: _sendTextMessage,
                ),
            ],
          ),
        ),
        
        // 表情选择器
        if (_showEmojiPicker)
          Container(
            height: 250,
            color: Theme.of(context).colorScheme.surface,
            child: const Center(
              child: Text('表情选择器 - 此功能尚未实现'),
            ),
          ),
        
        // 更多功能面板
        if (_showMoreOptions)
          Container(
            height: 200,
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: GridView.count(
              crossAxisCount: 4,
              childAspectRatio: 1,
              children: [
                _buildMoreOptionItem(
                  icon: Icons.image,
                  label: '图片',
                  onTap: _selectImage,
                ),
                _buildMoreOptionItem(
                  icon: Icons.camera_alt,
                  label: '拍照',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('此功能尚未实现')),
                    );
                  },
                ),
                _buildMoreOptionItem(
                  icon: Icons.videocam,
                  label: '视频',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('此功能尚未实现')),
                    );
                  },
                ),
                _buildMoreOptionItem(
                  icon: Icons.insert_drive_file,
                  label: '文件',
                  onTap: _selectFile,
                ),
                _buildMoreOptionItem(
                  icon: Icons.location_on,
                  label: '位置',
                  onTap: _selectLocation,
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  /// 构建更多功能面板中的选项项
  Widget _buildMoreOptionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
} 