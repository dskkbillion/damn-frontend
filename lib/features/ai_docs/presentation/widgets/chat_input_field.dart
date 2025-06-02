import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart'; // Import the record package
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler
import 'package:image_picker/image_picker.dart';
import 'package:dskk_flutter_refactor/generated/l10n.dart'; // 导入国际化资源

import '../bloc/ai_chat/ai_chat_bloc.dart';
// Remove direct imports of part files
// import '../bloc/ai_chat/ai_chat_state.dart';
// import '../bloc/ai_chat/ai_chat_event.dart';

// Convert to StatefulWidget to manage local recording state for UI feedback
class ChatInputField extends StatefulWidget {
  final TextEditingController textController;
  final Function(String) onSendMessage;
  // TODO: Add a callback for when voice recording finishes
  // final Function(String filePath) onSendVoice; 

  const ChatInputField({
    super.key,
    required this.textController,
    required this.onSendMessage,
    // required this.onSendVoice,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  bool _isRecording = false; // Local state to track recording status
  final AudioRecorder _audioRecorder = AudioRecorder(); // Instance of the recorder
  String? _recordingPath; // To store the path of the recording

  @override
  void dispose() {
    _audioRecorder.dispose(); // Dispose the recorder when widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context); // 获取国际化资源
    
    // Use BlocBuilder to access the full state, including pendingImageFiles & imageUploadStates
    return BlocBuilder<AiChatBloc, AiChatState>(
      buildWhen: (previous, current) => 
          previous.status != current.status || 
          previous.pendingImageFiles != current.pendingImageFiles ||
          previous.imageUploadStates != current.imageUploadStates, // Also rebuild on upload state changes
      builder: (context, state) {
        final bool isStreaming = state.status == AiChatStatus.streamingResponse;
        final bool isCancelling = state.status == AiChatStatus.cancellingGeneration;
        final bool isBusy = state.status == AiChatStatus.sendingMessage ||
                           state.status == AiChatStatus.transcribingAudio ||
                           state.status == AiChatStatus.allocatingResource ||
                           isStreaming ||
                           isCancelling;
        final List<File> pendingImages = state.pendingImageFiles ?? [];
        // Get the upload states map
        final Map<String, ImageUploadState> uploadStates = state.imageUploadStates ?? {}; 
        
        // --- Check if any image is currently uploading --- 
        bool isAnyImageUploading = false;
        if (pendingImages.isNotEmpty) {
          isAnyImageUploading = pendingImages.any((file) {
            final status = uploadStates[file.path]?.status;
            return status == ImageUploadStatus.uploading;
          });
        }
        // --- End check --- 

        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: widget.textController,
          builder: (context, textValue, child) {
             // Base condition: Not busy/recording AND (text is not empty OR has images)
             final bool hasText = textValue.text.trim().isNotEmpty;
             final bool hasImages = pendingImages.isNotEmpty;
             final bool baseCanSendMessage = !isBusy && !(_isRecording ?? false) && (hasText || hasImages);

             return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                decoration: BoxDecoration(
                 color: Theme.of(context).cardColor,
                 boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, -1),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.05),
                    )
                 ]
               ),
              child: Column( // Use Column to stack preview above input row
                mainAxisSize: MainAxisSize.min, // Take minimum vertical space
                children: [
                  // --- Image Preview Row --- 
                  if (pendingImages.isNotEmpty)
                    // Pass uploadStates to the preview row builder
                    _buildImagePreviewRow(context, pendingImages, uploadStates),
                  
                  // --- Input Row --- 
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Attach Image Button
                      IconButton(
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        // Use internal method _pickAndDispatchImage
                        onPressed: isBusy || _isRecording ? null : _pickAndDispatchImage, 
                        tooltip: s.ai_docs_add_image, // 使用国际化文本
                      ),
                      // Attach Voice Button (Stateful)
                      IconButton(
                         icon: Icon(_isRecording ? Icons.stop_circle_outlined : Icons.mic_none_outlined, 
                                    color: _isRecording ? Colors.red : null),
                         onPressed: isBusy ? null : _handleVoiceButtonPress, 
                         tooltip: _isRecording ? s.ai_docs_stop_recording : s.ai_docs_start_recording, // 使用国际化文本
                       ),
                      // Text Input Field
                      Expanded(
                        child: TextField(
                          controller: widget.textController,
                          enabled: !isBusy && !_isRecording, 
                          decoration: InputDecoration(
                            hintText: _isRecording ? s.ai_docs_recording : s.ai_docs_enter_message, // 使用国际化文本
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                          ),
                          // Send button logic moved solely to IconButton
                          onSubmitted: baseCanSendMessage 
                                         ? (_) => widget.onSendMessage(widget.textController.text) 
                                         : null, 
                          textInputAction: TextInputAction.send, 
                        ),
                      ),
                      // Send / Stop Generation Button
                       if (isStreaming || isCancelling)
                          IconButton(
                            icon: isCancelling 
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2)
                                  )
                                : const Icon(Icons.stop_circle, color: Colors.red),
                            tooltip: isCancelling 
                                ? s.ai_docs_cancelling_generation
                                : s.ai_docs_stop_generation, // 使用国际化文本
                            onPressed: isCancelling 
                                ? null // 取消中时禁用按钮
                                : () {
                                    // 使用新的CancelChatGeneration事件，这会调用后端API
                                    context.read<AiChatBloc>().add(const CancelChatGeneration());
                                  },
                          )
                       else
                          IconButton(
                            icon: const Icon(Icons.send),
                            // Enable based on base conditions, logic inside onPressed
                            onPressed: baseCanSendMessage 
                                         ? () {
                                             // --- Check for uploading images before sending --- 
                                             if (isAnyImageUploading) {
                                                // Show feedback and DO NOT send
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                   SnackBar(content: Text(s.ai_docs_uploading_images)), // 使用国际化文本
                                                 );
                                             } else {
                                                // No uploads in progress, proceed to send
                                                widget.onSendMessage(widget.textController.text);
                                             }
                                           }
                                         : null,
                            // 添加长按操作显示Markdown示例菜单
                            onLongPress: isBusy ? null : _showMarkdownExampleMenu,
                            tooltip: s.ai_docs_send_message, // 使用国际化文本
                          ),
                    ],
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  // --- Helper Widget for Image Preview Row (Updated) ---
  Widget _buildImagePreviewRow(
    BuildContext context, 
    List<File> images, 
    Map<String, ImageUploadState> uploadStates // Receive upload states
  ) {
    return Container(
      height: 80, // Adjust height as needed
      padding: const EdgeInsets.only(bottom: 8.0), 
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          final file = images[index];
          final filePath = file.path;
          // Get the upload state for this specific file
          final uploadState = uploadStates[filePath]; 

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Stack(
              clipBehavior: Clip.none, 
              alignment: Alignment.center, // Center potential overlay icons
              children: [
                // Image Preview
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    file,
                    width: 70, // Adjust size
                    height: 70,
                    fit: BoxFit.cover,
                    // Add error builder for robustness
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, color: Colors.grey, size: 30),
                    ),
                  ),
                ),

                // --- Upload Status Overlay --- 
                if (uploadState != null)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(8.0),
                         // Semi-transparent overlay based on status
                         color: uploadState.status == ImageUploadStatus.uploading 
                                ? Colors.black.withOpacity(0.5) 
                                : uploadState.status == ImageUploadStatus.failure
                                  ? Colors.red.withOpacity(0.6)
                                  : Colors.transparent, // No overlay for success
                      ),
                      child: Center(
                        child: switch (uploadState.status) {
                           ImageUploadStatus.uploading => const SizedBox(
                               width: 24, 
                               height: 24, 
                               child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                           ImageUploadStatus.failure => const Icon(
                               Icons.error_outline,
                               color: Colors.white,
                               size: 30,
                            ),
                           ImageUploadStatus.success => null, // No icon needed for success
                        },
                      ),
                    ),
                  ),

                // Delete Button (Always visible if image exists)
                Positioned(
                  top: -5,
                  right: -5,
                  child: Material(
                    color: Colors.black54,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        // Dispatch event using file path
                        context.read<AiChatBloc>().add(RemovePendingImage(imagePathToRemove: filePath));
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Method to handle picking image and dispatching event ---
  Future<void> _pickAndDispatchImage() async {
     // Use ImagePicker (you might need to import 'package:image_picker/image_picker.dart')
     final ImagePicker picker = ImagePicker(); 
    try {
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
        if (image != null && mounted) {
          // Dispatch PickImage event
          context.read<AiChatBloc>().add(PickImage(imageFile: File(image.path)));
        } 
    } catch (e) {
        print("Error picking image: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('选择图片出错: $e')),
          );
        }
    }
  }

  // Handle voice button logic with actual recording
  void _handleVoiceButtonPress() async {
    final s = S.of(context); // 获取国际化资源
    
    if (!_isRecording) {
      // --- Start Recording ---
      // 1. Check for microphone permission
      if (!await _audioRecorder.hasPermission()) {
         // Request permission (consider using permission_handler for better flow)
         // For simplicity, show a snackbar if permission denied.
         // You might want a more robust permission handling flow.
         final status = await Permission.microphone.request();
         if (!status.isGranted) {
            if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text(s.ai_docs_mic_permission_denied)), // 使用国际化文本
               );
            }
            return; // Stop if permission is not granted
         }
      }

       // 2. Start recording to a temporary path
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav'; // 使用WAV格式
      
      // 修改录音配置，使用WAV格式，16kbps码率
       const recordConfig = RecordConfig(
         encoder: AudioEncoder.wav, // 使用WAV格式
         bitRate: 16000, // 设置码率为16kbps
         sampleRate: 16000, // 设置采样率为16kHz
       );

      try {
          await _audioRecorder.start(recordConfig, path: filePath);
          print("Recording started: $filePath");
          setState(() {
             _isRecording = true;
             _recordingPath = filePath; // Store the path
             widget.textController.clear(); // Clear text field
           });
      } catch (e) {
         print("Error starting recording: $e");
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(s.ai_docs_recording_error(e.toString()))), // 使用国际化文本
            );
         }
      }

    } else {
      // --- Stop Recording ---
      try {
         final String? path = await _audioRecorder.stop();
         print("Recording stopped: $path");

         setState(() {
           _isRecording = false;
         });

         if (path != null) {
            final recordedFile = File(path);
            if (await recordedFile.exists()) {
                // TODO: Add encoding/compression step here if needed to meet 16kbps
                print("Recorded file size: ${await recordedFile.length()} bytes");

               // Dispatch the event with the **actual recorded file**
                if (mounted) {
                   // 获取当前AI聊天Bloc状态
                   final aiChatBloc = context.read<AiChatBloc>();
                   final currentState = aiChatBloc.state;
                   
                   // 检查是否已选择对话，如果没有选择，先创建新对话
                   if (currentState.selectedConversationId == null) {
                     // 先创建新对话，再发送语音消息
                     print("[ChatInputField] ${s.ai_docs_auto_create_voice}");
                     aiChatBloc.add(CreateNewConversationAndSendVoiceMessage(audioFile: recordedFile));
                   } else {
                     // 已有对话，直接发送语音消息
                     aiChatBloc.add(SendVoiceMessage(audioFile: recordedFile));
                   }
                } 
             } else {
               print("Error: Recorded file not found at path: $path");
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(s.ai_docs_recording_file_not_found)), // 使用国际化文本
                  );
               }
             }
         } else {
            print("Error: Stopping recording failed, path is null.");
            if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text(s.ai_docs_stop_recording_error)), // 使用国际化文本
               );
            }
         }
      } catch (e) {
         print("Error stopping recording: $e");
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(s.ai_docs_stop_recording_error_with_reason(e.toString()))), // 使用国际化文本
            );
         }
          // Ensure recording state is reset even if stopping fails
         if (mounted && _isRecording) {
           setState(() => _isRecording = false);
         }
      }
    }
  }

  // 添加长按操作显示Markdown示例菜单
  void _showMarkdownExampleMenu() {
    final s = S.of(context);
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.title),
                title: const Text('Markdown 标题示例'),
                onTap: () {
                  _sendMarkdownExample("""
# 一级标题
## 二级标题
### 三级标题
                  """);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.format_list_bulleted),
                title: const Text('Markdown 列表示例'),
                onTap: () {
                  _sendMarkdownExample("""
- 列表项 1
- 列表项 2
  - 子列表项 2.1
  - 子列表项 2.2
- 列表项 3

1. 有序列表 1
2. 有序列表 2
   1. 子列表 2.1
   2. 子列表 2.2
3. 有序列表 3
                  """);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.format_quote),
                title: const Text('Markdown 引用和代码示例'),
                onTap: () {
                  _sendMarkdownExample("""
> 这是一段引用文本
> 这是引用的第二行

代码块示例:
```dart
void main() {
  print('Hello, Markdown!');
}
```
                  """);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('Markdown 表格示例'),
                onTap: () {
                  _sendMarkdownExample("""
| 列1 | 列2 | 列3 |
|-----|-----|-----|
| 单元格1 | 单元格2 | 单元格3 |
| 单元格4 | 单元格5 | 单元格6 |
                  """);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.format_bold),
                title: const Text('Markdown 格式化和链接示例'),
                onTap: () {
                  _sendMarkdownExample("""
**粗体文本** 和 *斜体文本*

~~删除线文本~~

[Flutter官网链接](https://flutter.dev)

![图片描述](https://picsum.photos/200/100)
                  """);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.view_agenda),
                title: const Text('Markdown 完整示例'),
                onTap: () {
                  _sendMarkdownExample("""
# Markdown 完整示例

## 标题与格式

这是正文内容。**这是粗体** 和 *这是斜体*。

## 列表

- 无序列表项 1
- 无序列表项 2
  - 子项 2.1
  - 子项 2.2

1. 有序列表项 1
2. 有序列表项 2

## 引用与代码

> 这是一段引用文本
> 第二行引用

代码示例:
```dart
void main() {
  print('Hello, Markdown!');
}
```

## 表格

| 商品 | 价格 | 库存 |
|-----|-----|-----|
| 商品A | ¥100 | 20 |
| 商品B | ¥200 | 10 |

[更多Markdown语法](https://www.markdownguide.org/)
                  """);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  // 发送Markdown示例
  void _sendMarkdownExample(String markdownText) {
    // 清理不必要的前导和尾随空白，但保留内部格式
    final cleanedText = markdownText.trim();
    // 设置到输入框
    widget.textController.text = cleanedText;
    // 发送消息
    widget.onSendMessage(cleanedText);
  }
} 