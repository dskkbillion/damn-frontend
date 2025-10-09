import 'dart:io'; // Import File
import 'dart:async'; // Import async
import 'package:flutter/foundation.dart'; // Import for kIsWeb

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:record/record.dart'; // Import record
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler
import 'package:path_provider/path_provider.dart'; // Import path_provider
import 'package:dskk_flutter_refactor/generated/app_localizations.dart'; // 导入国际化资源
import 'package:dskk_flutter_refactor/core/utils/image_upload_helper.dart';

import '../bloc/chat_messages/chat_messages_bloc.dart';

// 文件上传状态定义
enum FileUploadStatus { uploading, success, failure }

class FileUploadState {
  final FileUploadStatus status;
  final String? url;
  final String? error;
  
  const FileUploadState.uploading() : status = FileUploadStatus.uploading, url = null, error = null;
  const FileUploadState.success(this.url) : status = FileUploadStatus.success, error = null;
  const FileUploadState.failure(this.error) : status = FileUploadStatus.failure, url = null;
}

class MessageInputBar extends StatefulWidget {
  final int chatId; // Needed to potentially associate input with the chat

  const MessageInputBar({super.key, required this.chatId});

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  final TextEditingController _controller = TextEditingController();
  bool _canSend = false;
  bool _isRecording = false;
  bool _isVoiceMode = false; // Added state for input mode
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _recordingPath;
  Timer? _recordingTimer;
  int _recordingDuration = 0;
  
  // 新增：文件上传状态管理
  List<File> _pendingFiles = [];
  Map<String, FileUploadState> _fileUploadStates = {};

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _canSend = _controller.text.trim().isNotEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioRecorder.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _sendMessage() {
    if (_canSend) {
      final text = _controller.text.trim();
      context.read<ChatMessagesBloc>().add(
            SendMessageRequested(type: 'text', text: text),
          );
      _controller.clear();
      // Ensure keyboard hides after sending
      FocusScope.of(context).unfocus(); 
    }
  }

  Future<void> _startRecording() async {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context)!;
    
    // --- Add Web Check --- 
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appLocalizations.chat_web_recording_not_supported)),
      );
      return;
    }
    // --- End Web Check --- 

    // Check and Request permission AT RUNTIME
    var status = await Permission.microphone.status;
    print('[Permission Check] Microphone status BEFORE request: $status');

    if (status.isPermanentlyDenied) {
        // FIX: Handle permanently denied status
        print("[Permission Check] Permission permanently denied.");
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: Text(appLocalizations.chat_mic_permission_denied_title),
                content: Text(appLocalizations.chat_mic_permission_denied_message),
                actions: <Widget>[
                    TextButton(
                        child: Text(appLocalizations.chat_permission_denied_cancel),
                        onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                        child: Text(appLocalizations.chat_permission_denied_settings),
                        onPressed: () {
                            Navigator.of(context).pop();
                            openAppSettings(); // Open app settings
                        },
                    ),
                ],
            ),
        );
        return; // Stop execution
    }

    // Request if denied or restricted, but not permanently denied
    if (!status.isGranted) {
        status = await Permission.microphone.request();
        print('[Permission Check] Microphone status AFTER request: $status');
    }

    // Check final status after potential request
    if (!status.isGranted) {
      // FIX: Provide slightly more context if denied after request
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appLocalizations.chat_mic_permission_denied)),
      );
      return;
    }

    // --- Permission Granted - Proceed with recording --- 
    try {
      final Directory tempDir = await getTemporaryDirectory();
      // 修改为WAV格式，与AI docs保持一致
      _recordingPath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';

      // 使用与AI docs相同的录音配置
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav, // 使用WAV格式
          bitRate: 16000, // 设置码率为16kbps
          sampleRate: 16000, // 设置采样率为16kHz
        ),
        path: _recordingPath!,
      );

      final recording = await _audioRecorder.isRecording();
      if(mounted && recording) {
        setState(() {
          _isRecording = true;
          _recordingDuration = 0;
        });
        _startRecordingTimer();
        print('Recording started: $_recordingPath');
      }

    } catch (e) {
      print('Error starting recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appLocalizations.chat_recording_error('$e'))),
      );
      _resetRecordingState();
    }
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel(); // Cancel any existing timer
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) { 
      if(mounted) {
        setState(() {
          _recordingDuration++;
        });
      }
    });
  }

  Future<void> _stopRecordingAndSend() async {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context)!;
    
    _recordingTimer?.cancel();
    try {
      final path = await _audioRecorder.stop();
      if (path != null && mounted) {
        print('Recording stopped: $path, Duration: $_recordingDuration s');
        final recordingFile = File(path);
        if (await recordingFile.exists() && _recordingDuration > 0) {
          context.read<ChatMessagesBloc>().add(
            SendMessageRequested(type: 'audio', file: recordingFile),
          );
        } else {
          print('Recording file invalid or too short.');
        }
      } else {
        print('Stopping recording failed or component unmounted.');
      }
    } catch (e) {
      print('Error stopping recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appLocalizations.chat_stop_recording_error('$e'))),
      );
    } finally {
      if(mounted) {
        _resetRecordingState();
      }
    }
  }

  Future<void> _cancelRecording() async {
    _recordingTimer?.cancel();
    try {
      await _audioRecorder.stop(); // Stop recording
      // Optionally delete the file if needed
      if(_recordingPath != null) {
        final file = File(_recordingPath!);
        if(await file.exists()) {
          await file.delete();
          print("Recording cancelled and file deleted.");
        }
      }
    } catch (e) {
      print("Error cancelling recording: $e");
    } finally {
      if(mounted) {
        _resetRecordingState();
      }
    }
  }

  void _resetRecordingState() {
    setState(() {
      _isRecording = false;
      _recordingPath = null;
      _recordingDuration = 0;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context)!;
    
    try {
      // Use ImageUploadHelper for consistent image processing
      ImageProcessResult? result;
      
      if (source == ImageSource.camera) {
        result = await ImageUploadHelper.pickFromCamera(type: ImageUploadType.chat);
      } else {
        final results = await ImageUploadHelper.pickFromGallery(
          type: ImageUploadType.chat,
          allowMultiple: false,
        );
        result = results.isNotEmpty ? results.first : null;
      }

      if (result != null) {
        final processResult = result; // 创建局部变量避免空安全问题
        
        if (processResult.isSuccess) {
          // 1. 添加到待上传列表，显示上传状态
          setState(() {
            _pendingFiles.add(processResult.finalFile);
            _fileUploadStates[processResult.finalFile.path] = const FileUploadState.uploading();
          });

          print('Image processed: ${processResult.finalFile.path}, compression: ${processResult.compressionRatio?.toStringAsFixed(1)}%');
          
          // 2. 发送消息（会触发上传）
          context.read<ChatMessagesBloc>().add(
            SendMessageRequested(type: 'image', file: processResult.finalFile),
          );
          
          // 3. 监听上传结果
          _listenToUploadResult(processResult.finalFile);
          
          // 4. 显示压缩信息
          if (processResult.compressionRatio != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('图片已压缩 ${processResult.compressionRatio!.toStringAsFixed(1)}%'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          // 处理失败
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('图片处理失败: ${processResult.error ?? "未知错误"}')),
          );
        }
      } else {
        print('No image selected.');
      }
    } catch (e) {
       print('Error picking image: $e');
       ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appLocalizations.chat_image_picking_error('$e'))), 
      ); 
    }
  }
  
  // 支持多图片选择
  Future<void> _pickMultipleImages() async {
    try {
      // Use ImageUploadHelper for multiple image selection
      final List<ImageProcessResult> results = await ImageUploadHelper.pickFromGallery(
        type: ImageUploadType.chat,
        allowMultiple: true,
        maxImages: 9,
      );

      if (results.isNotEmpty) {
        int successCount = 0;
        int errorCount = 0;
        double totalCompression = 0;
        
        for (final result in results) {
          if (result.isSuccess) {
            setState(() {
              _pendingFiles.add(result.finalFile);
              _fileUploadStates[result.finalFile.path] = const FileUploadState.uploading();
            });
            
            // 逐个发送
            context.read<ChatMessagesBloc>().add(
              SendMessageRequested(type: 'image', file: result.finalFile),
            );
            
            _listenToUploadResult(result.finalFile);
            successCount++;
            
            if (result.compressionRatio != null) {
              totalCompression += result.compressionRatio!;
            }
          } else {
            errorCount++;
          }
        }
        
        // 显示处理结果摘要
        if (successCount > 0) {
          final avgCompression = totalCompression / successCount;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('成功处理 $successCount 张图片，平均压缩 ${avgCompression.toStringAsFixed(1)}%'),
              backgroundColor: Colors.green,
            ),
          );
        }
        
        if (errorCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$errorCount 张图片处理失败'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('Error picking multiple images: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择图片出错: $e')),
      );
    }
  }
  
  // 监听上传结果
  void _listenToUploadResult(File file) {
    // 模拟上传过程，实际应该监听Bloc状态变化
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _fileUploadStates[file.path] = const FileUploadState.success('uploaded_url');
          // 3秒后清除状态
          Timer(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _pendingFiles.remove(file);
                _fileUploadStates.remove(file.path);
              });
            }
          });
        });
      }
    });
  }
  
  // 构建文件预览区域
  Widget _buildFilePreviewArea() {
    if (_pendingFiles.isEmpty) return const SizedBox.shrink();
    
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _pendingFiles.length,
        itemBuilder: (context, index) {
          final file = _pendingFiles[index];
          final uploadState = _fileUploadStates[file.path];
          
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Stack(
              children: [
                // 文件预览
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: _buildFilePreview(file),
                ),
                
                // 上传状态覆盖层
                if (uploadState != null)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: uploadState.status == FileUploadStatus.uploading
                            ? Colors.black.withOpacity(0.5)
                            : uploadState.status == FileUploadStatus.failure
                                ? Colors.red.withOpacity(0.6)
                                : Colors.transparent,
                      ),
                      child: Center(
                        child: _buildUploadStatusIcon(uploadState),
                      ),
                    ),
                  ),
                
                // 删除按钮
                Positioned(
                  top: -4,
                  right: -4,
                  child: GestureDetector(
                    onTap: () => _removeFile(index),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
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
  
  Widget _buildFilePreview(File file) {
    final extension = file.path.toLowerCase();
    
    if (extension.endsWith('.jpg') || 
        extension.endsWith('.jpeg') || 
        extension.endsWith('.png') || 
        extension.endsWith('.gif')) {
      // 图片预览
      return Image.file(
        file,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
      );
    } else {
      // 其他文件类型显示图标
      return Container(
        width: 64,
        height: 64,
        color: Colors.grey[300],
        child: const Icon(Icons.insert_drive_file, size: 32),
      );
    }
  }
  
  Widget _buildUploadStatusIcon(FileUploadState uploadState) {
    switch (uploadState.status) {
      case FileUploadStatus.uploading:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        );
      case FileUploadStatus.success:
        return const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 24,
        );
      case FileUploadStatus.failure:
        return const Icon(
          Icons.error_outline,
          color: Colors.white,
          size: 24,
        );
    }
  }
  
  void _removeFile(int index) {
    final file = _pendingFiles[index];
    setState(() {
      _pendingFiles.removeAt(index);
      _fileUploadStates.remove(file.path);
    });
  }

  // 添加一个示例Markdown消息快捷发送方法
  void _sendMarkdownExample() {
    // 关闭底部菜单
    Navigator.of(context).pop();
    
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context)!;
    
    // 使用国际化字符串构建Markdown示例
    final String markdownExample = """
# ${appLocalizations.chat_markdown_example_title1}
## ${appLocalizations.chat_markdown_example_title2}

${appLocalizations.chat_markdown_example_bold_italic}

- ${appLocalizations.chat_markdown_example_list1}
- ${appLocalizations.chat_markdown_example_list2}
  - ${appLocalizations.chat_markdown_example_list3}

> ${appLocalizations.chat_markdown_example_quote}
> ${appLocalizations.chat_markdown_example_quote}

[This is a link](https://flutter.dev)

```dart
void main() {
  print('Hello, Markdown!');
}
```

${appLocalizations.chat_markdown_example_table_col1} | ${appLocalizations.chat_markdown_example_table_col2} |
|-----|-----|
| ${appLocalizations.chat_markdown_example_table_content1} | ${appLocalizations.chat_markdown_example_table_content2} |
| ${appLocalizations.chat_markdown_example_table_content3} | ${appLocalizations.chat_markdown_example_table_content4} |
""";

    // 发送Markdown消息
    context.read<ChatMessagesBloc>().add(
      SendMessageRequested(type: 'text', text: markdownExample),
    );
  }

  void _showAttachmentMenu(BuildContext context) {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context)!;

    showModalBottomSheet(
        context: context,
        isDismissible: true, // 允许点击外部区域关闭
        enableDrag: true, // 允许下滑关闭
        isScrollControlled: false, // 不控制滚动，保持默认行为
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: Text(appLocalizations.chat_pick_from_gallery),
                    onTap: () {
                      Navigator.of(context).pop(); // Close bottom sheet
                      _pickImage(ImageSource.gallery);
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: Text(appLocalizations.chat_take_photo),
                  onTap: () {
                     Navigator.of(context).pop(); // Close bottom sheet
                    _pickImage(ImageSource.camera);
                  },
                ),
                // 新增多图片选择
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('选择多张图片'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickMultipleImages();
                  },
                ),
                // 添加Markdown消息示例按钮
                ListTile(
                  leading: const Icon(Icons.text_format),
                  title: Text(appLocalizations.chat_send_markdown),
                  onTap: _sendMarkdownExample,
                ),
                 // TODO: Add options for file selection etc. later
              ],
            ),
          );
        });
  }

  // Helper widget builders
  Widget _buildVoiceKeyboardButton() {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context)!;
    
    return IconButton(
      icon: Icon(_isVoiceMode ? Icons.keyboard_alt_outlined : Icons.mic_none_outlined),
      onPressed: () {
        setState(() {
          _isVoiceMode = !_isVoiceMode;
        });
        // Hide keyboard if switching to voice mode
        if (_isVoiceMode) FocusScope.of(context).unfocus();
      },
      tooltip: _isVoiceMode ? appLocalizations.chat_switch_to_text : appLocalizations.chat_switch_to_voice,
      color: Colors.grey[700],
    );
  }

  Widget _buildTextField() {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context)!;
    
    return TextField(
      controller: _controller,
      maxLines: 5, // Allow multi-line input
      minLines: 1,
      textInputAction: TextInputAction.newline, // Or send on enter? Decide behavior
      decoration: InputDecoration(
        hintText: appLocalizations.chat_enter_message,
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide.none, // No visible border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide.none, // Or a subtle highlight
        ),
      ),
      onSubmitted: (_) => _sendMessage(), // Option: Send on keyboard submit action
    );
  }

  Widget _buildPressToTalkButton() {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context)!;
    
    Color buttonColor = _isRecording ? Colors.red : Theme.of(context).primaryColor;
    String buttonText = _isRecording ? appLocalizations.chat_release_to_send(_recordingDuration) : appLocalizations.chat_press_to_talk;

    return GestureDetector(
      // Use LongPressDraggable or simple LongPress handlers based on complexity needed
      onLongPressStart: (_) {
          if (!_isRecording) {
             _startRecording(); 
          }
      },
      onLongPressEnd: (_) { 
         if (_isRecording) {
            _stopRecordingAndSend();
         } 
      },
      onLongPressCancel: () { // This might not trigger easily, consider drag update
          if(_isRecording) {
              _cancelRecording();
              print('Recording cancelled via onLongPressCancel');
          }
      },
      // Consider adding onLongPressMoveUpdate for cancel-by-dragging logic

      child: Container(
          height: 48, // Match TextField height approx
          decoration: BoxDecoration(
              color: buttonColor.withOpacity(0.1), // Lighter background
              borderRadius: BorderRadius.circular(25.0),
              border: Border.all(color: buttonColor)
          ),
          child: Center(
              child: Text(
                  buttonText,
                  style: TextStyle(color: buttonColor, fontWeight: FontWeight.bold)
              )
          ),
      )
    );
  }

  Widget _buildAttachmentButton() {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context)!;
    
    return IconButton(
      icon: const Icon(Icons.add_circle_outline),
      onPressed: () => _showAttachmentMenu(context),
      tooltip: appLocalizations.chat_attach,
      color: Colors.grey[700],
    );
  }

  Widget _buildSendButton() {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context)!;
    
    return Visibility(
      visible: _canSend && !_isVoiceMode, // Show only if text entered and not in voice mode
      child: IconButton(
        icon: const Icon(Icons.send),
        onPressed: _sendMessage,
        tooltip: appLocalizations.chat_send,
        color: Theme.of(context).primaryColor, // Use theme color
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[50], // Lighter background for the bar
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 0.5)), // Top border
        // boxShadow removed for flatter design, adjust if needed
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 文件预览区域
            _buildFilePreviewArea(),
            
            // 输入区域
            Row(
              crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically
              children: [
                _buildVoiceKeyboardButton(),
                const SizedBox(width: 4), // Spacing
                Expanded(
                  // Switch between TextField and PressToTalk button
                  child: _isVoiceMode ? _buildPressToTalkButton() : _buildTextField(),
                ),
                const SizedBox(width: 4), // Spacing
                // Show attachment button only when not recording
                // Or always show? Decide based on UX preference
                if (!_isRecording)
                   _buildAttachmentButton(), 
                
                // Send button is conditionally visible inside its builder
                _buildSendButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}