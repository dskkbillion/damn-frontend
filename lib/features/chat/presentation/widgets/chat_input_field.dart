import 'package:flutter/material.dart';

/// 聊天输入框组件
class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSendPressed; // Text send callback
  final VoidCallback onAttachmentPressed; // Callback for attachment selection (e.g., open picker)
  final Function(bool isVoice)? onVoiceModeChanged; // Optional: Callback when switching to/from voice

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSendPressed,
    required this.onAttachmentPressed,
    this.onVoiceModeChanged,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  bool _isVoiceMode = false; // Track if voice input is active
  bool _showSendButton = false;
  // final FocusNode _textFieldFocusNode = FocusNode(); // Optional: for requesting focus

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    // _textFieldFocusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final showSend = widget.controller.text.trim().isNotEmpty;
    if (showSend != _showSendButton) {
      setState(() {
        _showSendButton = showSend;
      });
    }
  }

  void _toggleVoiceMode() {
    setState(() {
      _isVoiceMode = !_isVoiceMode;
      if (_isVoiceMode) {
        FocusScope.of(context).unfocus(); // Hide keyboard when switching to voice
        widget.controller.clear(); // Clear text when switching to voice
      }
      widget.onVoiceModeChanged?.call(_isVoiceMode);
    });
     if (_isVoiceMode) {
       print("切换到语音模式");
     } else {
       print("切换到文本模式");
       // Optionally request focus for text field?
       // FocusScope.of(context).requestFocus(_textFieldFocusNode);
     }
  }

  void _handleSend() {
    if (widget.controller.text.trim().isNotEmpty) {
      widget.onSendPressed(); // Call the original text send callback
    }
  }

  void _showEmojiPicker() {
    // TODO: Implement emoji picker logic (e.g., using a package like 'emoji_picker_flutter')
    print("Emoji Picker pressed");
    FocusScope.of(context).unfocus(); // Hide keyboard if open
    // Example: Show a simple dialog for now
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emoji Picker'),
        content: const Text('Emoji selection not yet implemented.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  void _showAttachmentMenu() {
    print("Attachment Menu pressed");
    FocusScope.of(context).unfocus(); // Hide keyboard if open
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildAttachmentMenu(context),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 1. Voice/Keyboard toggle button
            IconButton(
              icon: Icon(_isVoiceMode ? Icons.keyboard : Icons.mic_none),
              onPressed: _toggleVoiceMode,
              tooltip: _isVoiceMode ? '切换到文本输入' : '切换到语音输入',
              color: Colors.grey[700],
            ),
            // const SizedBox(width: 8), // Reduced space or remove

            // 2. Input field / Voice input button / Emoji button
            Expanded(
              child: _isVoiceMode
                  ? _buildVoiceInputButton() // Voice recording button
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0), // Padding for inner elements
                      decoration: BoxDecoration(
                         color: Colors.grey[200],
                         borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: widget.controller,
                              // focusNode: _textFieldFocusNode,
                              maxLines: 5,
                              minLines: 1,
                              textInputAction: TextInputAction.newline,
                              keyboardType: TextInputType.multiline,
                              decoration: const InputDecoration(
                                hintText: '输入消息...',
                                border: InputBorder.none,
                                filled: false, // Background color handled by container
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 10.0),
                                isDense: true,
                              ),
                            ),
                          ),
                          // 3. Emoji button
                          IconButton(
                            icon: Icon(Icons.sentiment_satisfied_alt_outlined, color: Colors.grey[700]),
                            onPressed: _showEmojiPicker,
                            tooltip: '表情',
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(width: 8),

            // 4. Send or More (+) button
            _showSendButton && !_isVoiceMode // Only show Send button if text entered AND not in voice mode
                ? IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                       shape: const CircleBorder(), // Make it circular
                    ),
                    icon: const Icon(Icons.send),
                    onPressed: _handleSend,
                    tooltip: '发送',
                  )
                : IconButton(
                     // color: Colors.grey[700],
                     iconSize: 28, // Slightly larger icon
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _showAttachmentMenu,
                    tooltip: '更多',
                  ),
          ],
        ),
      ),
    );
  }

  // Placeholder for voice recording UI
  Widget _buildVoiceInputButton() {
    // Use GestureDetector for press-and-hold simulation
    return GestureDetector(
        onLongPressStart: (_) {
            print("开始录音");
            // TODO: Start actual recording logic (visual feedback needed)
        },
        onLongPressEnd: (_) {
             print("结束录音");
             // TODO: Stop recording and potentially send
        },
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
             decoration: BoxDecoration(
                color: Colors.grey[300], // Different color for voice button
                borderRadius: BorderRadius.circular(20.0),
             ),
            alignment: Alignment.center,
            child: const Text('按住 说话', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
        ),
    );
  }

 // Builds the attachment menu shown in the bottom sheet
 Widget _buildAttachmentMenu(BuildContext context) {
    return SafeArea(
        child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Wrap( // Use Wrap for grid-like layout
                spacing: 24.0, // Horizontal space
                runSpacing: 16.0, // Vertical space
                alignment: WrapAlignment.spaceAround,
                children: [
                    _buildAttachmentMenuItem(context, Icons.photo_library_outlined, '相册', () {
                       Navigator.pop(context); // Close sheet
                       print("Select Image");
                       // TODO: Call image picker logic via widget.onAttachmentPressed or specific callback
                       widget.onAttachmentPressed(); // For now, triggers the general callback
                    }),
                     _buildAttachmentMenuItem(context, Icons.camera_alt_outlined, '拍摄', () {
                       Navigator.pop(context);
                       print("Take Photo");
                       // TODO: Call camera logic
                    }),
                     _buildAttachmentMenuItem(context, Icons.insert_drive_file_outlined, '文件', () {
                       Navigator.pop(context);
                       print("Select File");
                       // TODO: Call file picker logic
                    }),
                   // Add more items like Location (Icons.location_on_outlined) if needed
                ],
            ),
        ),
    );
}

// Builds a single item for the attachment menu grid
Widget _buildAttachmentMenuItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
     return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                  Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                         color: Colors.grey[100], // Lighter background for items
                         borderRadius: BorderRadius.circular(16.0),
                      ),
                     child: Icon(icon, size: 32, color: Colors.grey[800]),
                  ),
                 const SizedBox(height: 8),
                 Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700])),
              ],
            ),
        ),
     );
  }
} 