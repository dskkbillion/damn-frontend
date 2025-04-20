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
  final AudioRecorder _audioRecorder = AudioRecorder(); // Recorder instance
  String? _recordingPath;
  Timer? _recordingTimer;
  int _recordingDuration = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if(mounted) {
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
    // Log current status BEFORE requesting
    var status = await Permission.microphone.status;
    print('[Permission Check] Microphone status BEFORE request: $status');

    if (!status.isGranted) { // Only request if not already granted
        status = await Permission.microphone.request(); // Request permission
        print('[Permission Check] Microphone status AFTER request: $status');
    }

    // Check final status
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('需要麦克风权限才能录音')), // Keep message generic
      );
      return;
    }

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
          children: [
            // --- Voice/Keyboard Toggle Button ---
            IconButton(
              icon: Icon(_isRecording ? Icons.keyboard : Icons.mic_none_outlined),
              onPressed: () {
                 if (_isRecording) {
                   // TODO: Switch back to keyboard, maybe cancel recording?
                   _cancelRecording(); // For now, cancel if mic is pressed again while recording
                 } else {
                   // TODO: Show voice recording UI or start recording
                   _startRecording();
                 }
              },
            ),
            // --- Text Input Field ---
            Expanded(
              child: _isRecording
                  ? GestureDetector(
                      onLongPressEnd:(details) {
                         print("Long press end");
                         _stopRecordingAndSend();
                      },
                      onTapUp: (details) {
                         print("Tap up - stopping recording");
                         _stopRecordingAndSend(); // Treat tap up as sending for now
                      },
                      onHorizontalDragEnd: (details) {
                         print("Drag end - cancelling");
                         _cancelRecording(); // Cancel on swipe
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                          _recordingDuration > 0
                           ? '正在录音... ${_recordingDuration}s (松开结束，滑动取消)'
                           : '按住说话',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    )
                  : TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: '输入消息...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      minLines: 1,
                      maxLines: 5, // Allow multiple lines
                    ),
            ),
            // --- Attachment Button ---
            if (!_isRecording) // Only show if not recording
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  _showAttachmentMenu(context); // Call the method to show the bottom sheet
                },
              ),
            // --- Send Button ---
             if (!_isRecording && _canSend) // Only show send button if not recording and text entered
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage, // Call the send message method
                color: Theme.of(context).primaryColor,
              ),
          ],
        ),
      ),
    );
  }
} 