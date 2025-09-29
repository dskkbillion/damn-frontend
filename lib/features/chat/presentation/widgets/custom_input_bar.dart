import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/utils/image_upload_helper.dart';
import 'package:dskk_flutter_refactor/core/services/file_upload_service.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/cubit/message_queue/message_queue_cubit.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/cubit/message_list/message_list_cubit.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/bloc/chat_messages/chat_messages_bloc.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart';

/// 文件上传进度对话框
class _UploadProgressDialog extends StatelessWidget {
  final String fileName;
  final double? progress;

  const _UploadProgressDialog({
    required this.fileName,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('上传文件'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            fileName,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
          ),
          const SizedBox(height: 8),
          Text(
            progress != null 
              ? '${(progress! * 100).toStringAsFixed(1)}%'
              : '准备上传...',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// Custom input bar for chat interface
/// Provides text input, voice recording, image picking, and file attachment
class CustomInputBar extends StatefulWidget {
  final int chatId;
  final Function(String text) onSendPressed;
  final VoidCallback? onAttachmentPressed;

  const CustomInputBar({
    super.key,
    required this.chatId,
    required this.onSendPressed,
    this.onAttachmentPressed,
  });

  @override
  State<CustomInputBar> createState() => _CustomInputBarState();
}

class _CustomInputBarState extends State<CustomInputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _canSend = false;
  bool _isRecording = false;
  bool _isVoiceMode = false;
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
    _focusNode.dispose();
    _audioRecorder.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _sendMessage() {
    if (_canSend) {
      final text = _controller.text.trim();
      widget.onSendPressed(text);
      _controller.clear();
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _startRecording() async {
    final appLocalizations = AppLocalizations.of(context)!;
    
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appLocalizations.chat_web_recording_not_supported)),
      );
      return;
    }

    // Check and request microphone permission
    var status = await Permission.microphone.status;
    
    if (status.isPermanentlyDenied) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(appLocalizations.chat_mic_permission_denied_title),
          content: Text(appLocalizations.chat_mic_permission_denied_message),
          actions: [
            TextButton(
              child: Text(appLocalizations.chat_permission_denied_cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(appLocalizations.chat_permission_denied_settings),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        ),
      );
      return;
    }

    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appLocalizations.chat_mic_permission_denied)),
      );
      return;
    }

    try {
      final Directory tempDir = await getTemporaryDirectory();
      _recordingPath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 16000,
          sampleRate: 16000,
        ),
        path: _recordingPath!,
      );

      final recording = await _audioRecorder.isRecording();
      if (mounted && recording) {
        setState(() {
          _isRecording = true;
          _recordingDuration = 0;
        });
        _startRecordingTimer();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appLocalizations.chat_recording_error('$e'))),
      );
      _resetRecordingState();
    }
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) { 
      if (mounted) {
        setState(() {
          _recordingDuration++;
        });
      }
    });
  }

  Future<void> _stopRecordingAndSend() async {
    final appLocalizations = AppLocalizations.of(context)!;

    _recordingTimer?.cancel();
    try {
      final path = await _audioRecorder.stop();
      if (path != null && mounted) {
        final recordingFile = File(path);
        if (await recordingFile.exists() && _recordingDuration > 0) {
          print('[CustomInputBar] Sending audio file: $path');
          // Use MessageListCubit to handle audio with file upload
          context.read<MessageListCubit>().sendFileMessage(
            filePath: path,
            fileType: 'audio',
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appLocalizations.chat_stop_recording_error('$e'))),
      );
    } finally {
      if (mounted) {
        _resetRecordingState();
      }
    }
  }

  Future<void> _cancelRecording() async {
    _recordingTimer?.cancel();
    try {
      await _audioRecorder.stop();
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      // Error cancelling recording: $e
    } finally {
      if (mounted) {
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
    final appLocalizations = AppLocalizations.of(context)!;
    
    try {
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

      if (result != null && result.isSuccess) {
        // 显示上传进度对话框
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => PopScope(
            canPop: false,
            child: _UploadProgressDialog(
              fileName: '图片上传中...',
            ),
          ),
        );
        
        try {
          // 获取文件上传服务
          final fileUploadService = GetIt.instance<IFileUploadService>();
          
          // 上传图片文件
          final uploadResult = await fileUploadService.uploadFileWithProgress(
            result.finalFile.path,
            (progress) {
              // 进度回调
            },
          );
          
          // 关闭进度对话框
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          
          uploadResult.fold(
            (failure) {
              // 上传失败
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('图片上传失败: ${failure.message}')),
                );
              }
            },
            (success) {
              // 上传成功，发送图片消息
              if (mounted) {
                // 通过 MessageListCubit 发送图片消息
                context.read<MessageListCubit>().sendImageMessage(
                  url: success.url,
                  fileName: result!.finalFile.path.split('/').last,
                );

                // 发送图片后收起键盘
                FocusScope.of(context).unfocus();

                // 显示压缩信息（如果有）
                if (result!.compressionRatio != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('图片已压缩 ${result.compressionRatio!.toStringAsFixed(1)}% 并发送'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('图片发送成功'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
          );
        } catch (e) {
          // 确保关闭对话框
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('图片上传出错: $e')),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appLocalizations.chat_image_picking_error('$e'))),
      );
    }
  }

  Future<void> _pickFile() async {
    final appLocalizations = AppLocalizations.of(context)!;
    
    try {
      // 使用 FilePicker 选择文件
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'zip', 'rar'],
        withData: false, // 不直接加载到内存，使用路径
        withReadStream: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // 检查文件大小（限制10MB）
        if (file.size != null && file.size! > 10 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('文件大小不能超过10MB')),
          );
          return;
        }
        
        if (file.path != null) {
          // 显示上传进度对话框，保存返回的 Future 以便后续关闭
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => PopScope(
              canPop: false, // 防止意外关闭
              child: _UploadProgressDialog(
                fileName: file.name,
              ),
            ),
          );
          
          try {
            // 获取文件上传服务
            final fileUploadService = GetIt.instance<IFileUploadService>();
            
            // 上传文件
            final uploadResult = await fileUploadService.uploadFileWithProgress(
              file.path!,
              (progress) {
                // 更新进度（如果需要的话）
                // progress: ${(progress * 100).toStringAsFixed(1)}%
              },
            );
            
            // 关闭进度对话框 - 使用正确的方式关闭对话框
            if (mounted) {
              // 只pop一次，并且确保是对话框而不是整个页面
              Navigator.of(context, rootNavigator: true).pop();
            }
            
            uploadResult.fold(
              (failure) {
                // 上传失败
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('文件上传失败: ${failure.message}')),
                  );
                }
              },
              (success) {
                // 上传成功，发送文件消息

                if (mounted) {
                  // 通过 MessageListCubit 发送文件消息
                  context.read<MessageListCubit>().sendDocumentMessage(
                    url: success.url,
                    fileName: file.name,
                    fileSize: file.size ?? 0,
                    fileExtension: file.extension ?? '',
                  );

                  // 发送文件后收起键盘
                  FocusScope.of(context).unfocus();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('文件发送成功')),
                  );
                }
              },
            );
          } catch (e) {
            // 确保关闭对话框
            if (mounted) {
              // 使用rootNavigator确保关闭的是对话框
              Navigator.of(context, rootNavigator: true).pop();
            }
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('上传出错: $e')),
              );
            }
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择文件失败: $e')),
      );
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file, color: Colors.orange),
              title: const Text('文件'),
              onTap: () {
                Navigator.pop(context);
                _pickFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  Widget build(BuildContext context) {
    if (_isRecording) {
      // Recording UI
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Cancel button
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: _cancelRecording,
            ),
            
            // Recording indicator and duration
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '录音中 ${_formatDuration(_recordingDuration)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Send button
            IconButton(
              icon: const Icon(Icons.send, color: Colors.blue),
              onPressed: _stopRecordingAndSend,
            ),
          ],
        ),
      );
    }

    // Normal input UI
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Voice/Keyboard toggle
          IconButton(
            icon: Icon(
              _isVoiceMode ? Icons.keyboard : Icons.mic,
              color: Colors.grey[600],
            ),
            onPressed: () {
              setState(() {
                _isVoiceMode = !_isVoiceMode;
              });
              if (!_isVoiceMode) {
                _focusNode.requestFocus();
              } else {
                _focusNode.unfocus();
              }
            },
          ),
          
          // Input field or voice button
          Expanded(
            child: _isVoiceMode
                ? GestureDetector(
                    onLongPress: _startRecording,
                    onLongPressEnd: (_) => _stopRecordingAndSend(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          '按住说话',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: '输入消息...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
          ),
          
          // Attachment button
          if (!_isVoiceMode)
            IconButton(
              icon: Icon(
                Icons.add_circle_outline,
                color: Colors.grey[600],
              ),
              onPressed: _showAttachmentOptions,
            ),
          
          // Send button
          if (!_isVoiceMode)
            IconButton(
              icon: Icon(
                Icons.send,
                color: _canSend ? Theme.of(context).primaryColor : Colors.grey[400],
              ),
              onPressed: _canSend ? _sendMessage : null,
            ),
        ],
      ),
    );
  }
}