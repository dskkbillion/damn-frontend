import 'dart:io'; // Import File
import 'dart:async'; // Import async
import 'package:flutter/foundation.dart'; // Import for kIsWeb

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:record/record.dart'; // Import record
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler
import 'package:path_provider/path_provider.dart'; // Import path_provider

import '../bloc/chat_messages/chat_messages_bloc.dart';

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
    // --- Add Web Check --- 
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Web 平台暂不支持录音功能')),
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
                title: const Text('麦克风权限已被禁用'),
                content: const Text('请在系统设置中手动开启麦克风权限才能使用录音功能。'),
                actions: <Widget>[
                    TextButton(
                        child: const Text('取消'),
                        onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                        child: const Text('去设置'),
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
        const SnackBar(content: Text('未获得麦克风权限，无法录音')),
      );
      return;
    }

    // --- Permission Granted - Proceed with recording --- 
    try {
      final Directory tempDir = await getTemporaryDirectory();
      _recordingPath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a'; // Use m4a for broader compatibility

      // Start recording
      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc), // Specify encoder
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
        SnackBar(content: Text('无法开始录音: $e')),
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
        SnackBar(content: Text('停止录音失败: $e')),
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
    // --- Camera Permission Check --- 
    if (source == ImageSource.camera) {
      var status = await Permission.camera.status;
      print('[Permission Check] Camera status BEFORE request: $status');

      if (status.isPermanentlyDenied) {
        print("[Permission Check] Camera permission permanently denied.");
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: const Text('相机权限已被禁用'),
                content: const Text('请在系统设置中手动开启相机权限才能使用拍照功能。'),
                actions: <Widget>[
                    TextButton(
                        child: const Text('取消'),
                        onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                        child: const Text('去设置'),
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

      // Request if not granted
      if (!status.isGranted) {
          status = await Permission.camera.request();
          print('[Permission Check] Camera status AFTER request: $status');
      }

      // Check final status
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('未获得相机权限，无法拍照')),
        );
        return;
      }
    }
    // --- End Camera Permission Check --- 

    // --- Permission Granted (or Gallery source) - Proceed with picking --- 
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        print('Image picked: ${pickedFile.path}');
        context.read<ChatMessagesBloc>().add(
          SendMessageRequested(type: 'image', file: File(pickedFile.path)),
        );
      } else {
        print('No image selected.');
      }
    } catch (e) {
       print('Error picking image: $e');
       ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片出错: $e')),
      ); 
    }
  }

  void _showAttachmentMenu(BuildContext context) {
     showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('从相册选择'),
                    onTap: () {
                      Navigator.of(context).pop(); // Close bottom sheet
                      _pickImage(ImageSource.gallery);
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('拍照'),
                  onTap: () {
                     Navigator.of(context).pop(); // Close bottom sheet
                    _pickImage(ImageSource.camera);
                  },
                ),
                 // TODO: Add options for file selection etc. later
              ],
            ),
          );
        });
  }

  // Helper widget builders
  Widget _buildVoiceKeyboardButton() {
    return IconButton(
      icon: Icon(_isVoiceMode ? Icons.keyboard_alt_outlined : Icons.mic_none_outlined),
      onPressed: () {
        setState(() {
          _isVoiceMode = !_isVoiceMode;
        });
        // Hide keyboard if switching to voice mode
        if (_isVoiceMode) FocusScope.of(context).unfocus();
      },
      tooltip: _isVoiceMode ? '切换到文本输入' : '切换到语音输入',
      color: Colors.grey[700],
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: _controller,
      maxLines: 5, // Allow multi-line input
      minLines: 1,
      textInputAction: TextInputAction.newline, // Or send on enter? Decide behavior
      decoration: InputDecoration(
        hintText: '输入消息...',
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
    Color buttonColor = _isRecording ? Colors.red : Theme.of(context).primaryColor;
    String buttonText = _isRecording ? '松开 发送 (${_recordingDuration}s)' : '按住 说话';

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
    return IconButton(
      icon: const Icon(Icons.add_circle_outline),
      onPressed: () => _showAttachmentMenu(context),
      tooltip: '发送图片/文件',
      color: Colors.grey[700],
    );
  }

  Widget _buildSendButton() {
    return Visibility(
      visible: _canSend && !_isVoiceMode, // Show only if text entered and not in voice mode
      child: IconButton(
        icon: const Icon(Icons.send),
        onPressed: _sendMessage,
        tooltip: '发送',
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
        child: Row(
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
      ),
    );
  }
}