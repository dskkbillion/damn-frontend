import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // Import audioplayers
import 'package:flutter_markdown/flutter_markdown.dart'; // 导入Markdown渲染包
import 'package:url_launcher/url_launcher.dart'; // 导入URL处理包
import '../../../../features/chat/presentation/utils/markdown_style_helper.dart'; // 复用已有的样式助手
import '../../domain/entities/ai_chat_message_entity.dart';
import '../../domain/entities/related_service_entity.dart'; // Import RelatedServiceEntity
import 'blinking_cursor.dart'; // Import the blinking cursor widget

/// {@template chat_message_bubble}
/// A StatefulWidget that displays a single chat message bubble.
///
/// Handles alignment based on the sender, background color,
/// displays the message content (text, image placeholder, or audio player), 
/// and shows a blinking cursor if the message is currently streaming.
/// It manages audio playback state for audio messages.
/// {@endtemplate}
class ChatMessageBubble extends StatefulWidget { // Changed to StatefulWidget
  /// The chat message entity to display.
  final AiChatMessageEntity message;

  /// Whether this message is currently being streamed (applies to text).
  final bool isStreaming;

   /// Callback when a related service chip is tapped. (Optional)
  final Function(RelatedServiceEntity)? onRelatedServiceTap;

  /// {@macro chat_message_bubble}
  const ChatMessageBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
    this.onRelatedServiceTap,
  });

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState(); // Create state
}

class _ChatMessageBubbleState extends State<ChatMessageBubble> { // State class
  AudioPlayer? _audioPlayer;
  PlayerState? _playerState;
  Duration? _duration;
  Duration? _position;

  bool get _isAudioMessage => widget.message.messageType == MessageType.audio;
  bool get _isPlaying => _playerState == PlayerState.playing;
  bool get _isPaused => _playerState == PlayerState.paused;
  String? get _audioUrl => widget.message.fileUrls?.isNotEmpty == true ? widget.message.fileUrls!.first : null;

  @override
  void initState() {
    super.initState();
    _checkAndInitAudioPlayer();
  }

  @override
  void didUpdateWidget(ChatMessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 检查fileUrls或转录状态是否有变化
    if (widget.message.fileUrls != oldWidget.message.fileUrls ||
        widget.message.isTranscribing != oldWidget.message.isTranscribing) {
      _checkAndInitAudioPlayer();
    }
  }

  void _checkAndInitAudioPlayer() {
    // 只有在以下条件都满足时才初始化AudioPlayer：
    // 1. 是音频消息
    // 2. 有音频URL
    // 3. 不是转录中状态（避免在转录阶段初始化）
    // 4. AudioPlayer还未初始化
    if (_isAudioMessage && 
        _audioUrl != null && 
        !widget.message.isTranscribing && 
        _audioPlayer == null) {
      print('[AudioPlayer] Initializing for URL: $_audioUrl');
      // 延迟初始化，给UI一些时间渲染
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _initAudioPlayer();
        }
      });
    }
  }

  void _initAudioPlayer() {
    if (_audioPlayer != null) {
      _audioPlayer!.dispose(); // 清理旧的播放器
    }
    
    try {
      _audioPlayer = AudioPlayer();
      // Set release mode to keep resources low. Typically you might use loop=false instead.
      _audioPlayer!.setReleaseMode(ReleaseMode.stop); 

      // Listen to state changes
      _audioPlayer!.onPlayerStateChanged.listen((state) {
         if (mounted) {
           setState(() => _playerState = state);
         }
      });

      // Listen to duration changes
      _audioPlayer!.onDurationChanged.listen((duration) {
        if (mounted) {
          setState(() => _duration = duration);
        }
      });

      // Listen to position changes
      _audioPlayer!.onPositionChanged.listen((position) {
         if (mounted) {
           setState(() => _position = position);
         }
      });

      // Prepare the player (optional but good practice)
      // 使用异步方式设置音频源，避免阻塞UI
      _audioPlayer!.setSourceUrl(_audioUrl!).then((_) {
        print('[AudioPlayer] Audio source set successfully for: $_audioUrl');
        if (mounted) {
          setState(() {}); // 触发重新渲染以更新UI状态
        }
      }).catchError((e) {
        print('[AudioPlayer] Failed to set audio source: $e');
        // 不立即显示错误，而是标记为初始化失败
        if (mounted) {
          setState(() {
            _audioPlayer?.dispose();
            _audioPlayer = null;
          });
        }
      });
    } catch (e) {
      print('[AudioPlayer] Exception during initialization: $e');
      _audioPlayer?.dispose();
      _audioPlayer = null;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    // Release the audio player resources when the widget is disposed
    _audioPlayer?.release();
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    if (_audioUrl == null) return;
    
    try {
      // If player is not initialized or disposed, re-initialize
      if (_audioPlayer == null || _playerState == PlayerState.stopped || _playerState == PlayerState.completed) {
        _initAudioPlayer(); // Re-initialize if needed (e.g., after completion)
        // 等待初始化完成
        await Future.delayed(const Duration(milliseconds: 200));
        if (_audioPlayer == null) {
          print('[AudioPlayer] Failed to initialize player for playback');
          return;
        }
        await _audioPlayer!.play(UrlSource(_audioUrl!));
      } else if (_playerState == PlayerState.paused) {
        await _audioPlayer!.resume();
      } else { // If already playing or preparing, stop and play from start
        await _audioPlayer!.stop();
        await _audioPlayer!.play(UrlSource(_audioUrl!));
      }
      if (mounted) {
        setState(() => _playerState = PlayerState.playing);
      }
    } catch (e) {
      print('[AudioPlayer] Error during playback: $e');
      // 播放失败时重置播放器状态
      if (mounted) {
        setState(() {
          _playerState = PlayerState.stopped;
          _audioPlayer?.dispose();
          _audioPlayer = null;
        });
      }
    }
  }

  Future<void> _pause() async {
    await _audioPlayer?.pause();
     if (mounted) {
       setState(() => _playerState = PlayerState.paused);
     }
  }

  Future<void> _stop() async {
    await _audioPlayer?.stop();
     if (mounted) {
       setState(() => _playerState = PlayerState.stopped);
     }
  }

  // --- Build method now uses widget.message ---
  @override
  Widget build(BuildContext context) {
    bool isUser = widget.message.sender == MessageSender.user;

    // 🎨 修改颜色方案 - AI消息使用固定的浅灰色
    Color bubbleColor = isUser
        ? Theme.of(context).colorScheme.primaryContainer
        : Colors.grey[100]!; // AI消息使用固定的浅灰色

    // 流式输出时也使用相同的浅灰色，保持一致性
    if (!isUser && widget.isStreaming && widget.message.messageType == MessageType.text) {
       bubbleColor = Colors.grey[100]!; // 与非流式状态保持一致
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // 消息气泡
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(16.0),
            ),
            constraints: BoxConstraints(
               maxWidth: MediaQuery.of(context).size.width * 0.75
            ),
            child: Column(
               crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
               mainAxisSize: MainAxisSize.min,
               children: [
                  // --- Display content based on messageType ---
                  if (widget.message.messageType == MessageType.text)
                     _buildTextContent(context, isUser)
                  else if (widget.message.messageType == MessageType.image)
                     _buildImageContent(context) // 改为实际图片渲染
                  else if (widget.message.messageType == MessageType.audio)
                     _buildAudioContent(context, isUser) // Use the new stateful player
                  else // Default or unknown type
                     const Text("不支持的消息类型"),

                  // --- Display Timestamp (Optional) ---
                  // 🕐 移除时间戳显示 - 现在使用时间分隔符来显示时间
                  // Don't show timestamp for streaming text message
                  // if (widget.message.timestamp != null && !(widget.isStreaming && widget.message.messageType == MessageType.text))
                  //  Padding(
                  //    padding: const EdgeInsets.only(top: 4.0),
                  //    child: Text(
                  //       "${widget.message.timestamp!.hour.toString().padLeft(2, '0')}:${widget.message.timestamp!.minute.toString().padLeft(2, '0')}",
                  //       style: TextStyle(
                  //           fontSize: 10.0, 
                  //           // 🎨 修改时间戳颜色 - AI消息使用固定的灰色
                  //           color: isUser 
                  //              ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7) 
                  //              : Colors.grey[600], // AI消息使用固定的灰色时间戳
                  //       ),
                  //    ),
                  //  )
               ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Text content builder (uses widget.message and widget.isStreaming) ---
  Widget _buildTextContent(BuildContext context, bool isUser) {
     // 🎨 修改文本颜色 - AI消息使用固定的深色文本，匹配固定的浅灰色背景
     final textColor = isUser 
          ? Theme.of(context).colorScheme.onPrimaryContainer 
          : Colors.black87; // AI消息使用固定的深色文本，匹配浅灰色背景
         
     // 处理流式响应或空消息的特殊情况
     if (widget.isStreaming && widget.message.content.isEmpty) {
       return Row(
         mainAxisSize: MainAxisSize.min,
         crossAxisAlignment: CrossAxisAlignment.end,
         children: [
           Text(
             "...",
             style: TextStyle(
               fontSize: 15.0,
               color: textColor,
             ),
           ),
           BlinkingCursor(cursorColor: textColor),
         ],
       );
     }
     
     // 使用Markdown渲染组件替代普通Text
     return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: SelectionArea(
              child: MarkdownBody(
                data: widget.message.content,
                selectable: true, // 允许用户选择文本
                styleSheet: MarkdownStyleHelper.buildChatBubbleStyle(context, textColor),
                onTapLink: (text, href, title) {
                  // 处理链接点击
                  if (href != null) {
                    launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
                  }
                },
                shrinkWrap: true, // 确保内容自适应并限制在消息气泡内
              ),
            ),
          ),
          if (widget.isStreaming)
              BlinkingCursor(cursorColor: textColor),
        ],
      );
  }

  // --- Image content builder (uses widget.message) ---
  Widget _buildImageContent(BuildContext context) {
     if (widget.message.fileUrls?.isNotEmpty ?? false) {
       final imageUrl = widget.message.fileUrls!.first;
       // 实现图片展示，添加错误处理和加载状态
       return Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         mainAxisSize: MainAxisSize.min,
         children: [
           ClipRRect(
             borderRadius: BorderRadius.circular(8.0),
             child: Image.network(
               imageUrl,
               errorBuilder: (context, error, stackTrace) {
                 // 图片加载失败时显示错误提示
                 return Container(
                   width: 200,
                   height: 150,
                   color: Colors.grey[200],
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Icon(Icons.error_outline, color: Colors.grey[500]),
                       const SizedBox(height: 8),
                       Text('图片加载失败', style: TextStyle(color: Colors.grey[600])),
                     ],
                   ),
                 );
               },
               loadingBuilder: (context, child, loadingProgress) {
                 if (loadingProgress == null) return child;
                 // 图片加载中显示进度
                 return Container(
                   width: 200,
                   height: 150,
                   color: Colors.grey[100],
                   child: Center(
                     child: CircularProgressIndicator(
                       value: loadingProgress.expectedTotalBytes != null
                           ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                           : null,
                     ),
                   ),
                 );
               },
               fit: BoxFit.cover,
               // 限制图片大小以避免过大
               width: 200,
               // 高度可以自适应，也可以设置固定值
               // height: 150,
             ),
           ),
           
           if (widget.message.content.isNotEmpty)
             Padding(
               padding: const EdgeInsets.only(top: 8.0),
               child: Text(
                 widget.message.content,
                 style: TextStyle(
                   fontSize: 15.0,
                   color: Theme.of(context).colorScheme.onSecondaryContainer,
                 ),
               ),
             ),
         ],
       );
     } else {
       return Text("图片链接缺失");
     }
  }

  // --- Audio player builder (uses state variables and widget.message) ---
  Widget _buildAudioContent(BuildContext context, bool isUser) {
     // 🎨 修改音频播放器图标颜色 - AI消息使用固定的深色图标
     final iconColor = isUser 
                      ? Theme.of(context).colorScheme.onPrimaryContainer 
                      : Colors.black87; // AI消息使用固定的深色图标
    
     final url = _audioUrl;
     print('[AudioPlayer] Building audio content - URL: $url, Player: ${_audioPlayer != null}, Message Type: ${widget.message.messageType}');
     
     // 如果没有URL，只显示转录状态，不显示错误信息（避免初始阶段的错误闪现）
     if (url == null) {
       return Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         mainAxisSize: MainAxisSize.min,
         children: [
           // 转录状态或转录文本
           if (widget.message.isTranscribing)
             Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                 SizedBox(
                   width: 12,
                   height: 12,
                   child: CircularProgressIndicator(
                     strokeWidth: 2,
                     valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                   ),
                 ),
                 const SizedBox(width: 8),
                 Text(
                   '转录中...',
                   style: TextStyle(
                     fontSize: 12,
                     color: iconColor,
                   ),
                 ),
               ],
             )
           else if (widget.message.content.isNotEmpty && widget.message.content != "转录中...")
             Text(
               widget.message.content,
               style: TextStyle(
                 fontSize: 14.0,
                 color: iconColor,
               ),
             ),
         ],
       );
     }
     
     // 如果有URL但AudioPlayer初始化失败，显示简化的错误信息和重试选项
     if (_audioPlayer == null) {
       return Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         mainAxisSize: MainAxisSize.min,
         children: [
           // 简化的音频播放器UI（即使初始化失败也显示基本界面）
           Row(
             mainAxisSize: MainAxisSize.min,
             children: [
               // 显示重试按钮而不是播放按钮
               IconButton(
                 icon: Icon(
                   Icons.refresh,
                   color: iconColor.withOpacity(0.7),
                   size: 30,
                 ),
                 onPressed: () {
                   print('[AudioPlayer] Retrying initialization...');
                   _initAudioPlayer();
                 },
                 padding: EdgeInsets.zero,
                 constraints: const BoxConstraints(),
               ),
               const SizedBox(width: 8),
               // 显示音频不可用状态
               Expanded(
                 child: Container(
                   height: 2,
                   decoration: BoxDecoration(
                     color: iconColor.withOpacity(0.3),
                     borderRadius: BorderRadius.circular(1),
                   ),
                 ),
               ),
               const SizedBox(width: 8),
               Text(
                 '音频不可用',
                 style: TextStyle(fontSize: 12.0, color: iconColor.withOpacity(0.7)),
               ),
             ],
           ),
           // 显示转录文本（这是最重要的内容）
           if (widget.message.content.isNotEmpty && widget.message.content != "转录中...")
             Padding(
               padding: const EdgeInsets.only(top: 8.0),
               child: Text(
                 widget.message.content,
                 style: TextStyle(
                   fontSize: 14.0,
                   color: iconColor,
                 ),
               ),
             ),
         ],
       );
     }

    // Format duration helper
    String formatDuration(Duration? d) {
      if (d == null) return '--:--';
      final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      return '$minutes:$seconds';
    }

    final currentPosition = _position ?? Duration.zero;
    final totalDuration = _duration ?? Duration.zero;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 音频播放器
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Play/Pause Button
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                color: iconColor,
                size: 30,
              ),
              onPressed: _isPlaying ? _pause : _play,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(), // Remove default padding
            ),
            const SizedBox(width: 8),
            // Optional: Progress Indicator (Slider or LinearProgressIndicator)
             Expanded( // Allow slider to take available space
               child: SliderTheme( // Customize slider appearance
                 data: SliderTheme.of(context).copyWith(
                   thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                   overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                   trackHeight: 2.0,
                   activeTrackColor: iconColor,
                   inactiveTrackColor: iconColor.withOpacity(0.3),
                   thumbColor: iconColor,
                  ),
                 child: Slider(
                   value: totalDuration.inMilliseconds > 0 
                          ? (currentPosition.inMilliseconds.clamp(0, totalDuration.inMilliseconds) / totalDuration.inMilliseconds)
                          : 0.0,
                   onChanged: (value) async {
                     final newPosition = totalDuration * value;
                     await _audioPlayer!.seek(newPosition);
                     // Optionally resume playback after seeking
                     // if (!_isPlaying && _playerState != PlayerState.completed) {
                     //   _play();
                     // }
                   },
                 ),
               ),
             ),
            const SizedBox(width: 8),
            // Duration Text
            Text(
              '${formatDuration(currentPosition)} / ${formatDuration(totalDuration)}',
              style: TextStyle(fontSize: 12.0, color: iconColor.withOpacity(0.8)),
            ),
          ],
        ),
        
        // 转录文本或转录中状态
        if (widget.message.isTranscribing)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '转录中...',
                  style: TextStyle(
                    fontSize: 12,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          )
        else if (widget.message.content.isNotEmpty && widget.message.content != "转录中...")
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              widget.message.content,
              style: TextStyle(
                fontSize: 14.0,
                color: iconColor,
              ),
            ),
          ),
      ],
    );
  }

  // --- Timestamp formatter (uses widget.message) ---
  String _formatTimestamp(DateTime timestamp) {
    // Example: HH:mm format. Use intl package for robust formatting.
    String hour = timestamp.hour.toString().padLeft(2, '0');
    String minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

// Ensure RelatedServiceEntity is accessible
// If AiChatMessageEntity doesn't export it, import it directly
// import '../../domain/entities/related_service_entity.dart'; // May be needed if not exported by message entity 