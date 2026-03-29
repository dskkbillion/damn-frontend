import 'dart:async';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'dart:convert'; // 用于 JSON 解析
import 'dart:io'; // 添加这个import来支持File类型
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for Clipboard
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc
import 'package:flutter_markdown/flutter_markdown.dart'; // 导入Markdown渲染包
import 'package:url_launcher/url_launcher.dart'; // 导入URL处理包
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart'; // 导入国际化资源

import '../../domain/entities/chat_message.dart';
import '../bloc/chat_messages/chat_messages_bloc.dart'; // Import ChatMessagesBloc
import '../cubit/message_list/message_list_cubit.dart';
import '../../domain/entities/participant.dart'; // Import Participant
import 'allocate_message_bubble.dart'; // 导入新创建的allocate消息气泡组件
import '../utils/markdown_style_helper.dart'; // 导入Markdown样式助手
import 'file_message_widget.dart'; // 导入文件消息组件
import '../pages/file_preview_page.dart'; // 导入文件预览页面
import 'payment_prompt_bubble.dart'; // 导入付费提示气泡组件

// 撤回状态检查结果
class RevokeCheckResult {
    final bool canRevoke;
    final String reason;
    final Duration? remainingTime;
    
    RevokeCheckResult({
        required this.canRevoke, 
        required this.reason,
        this.remainingTime,
    });
}

// Helper function to format duration (e.g., 0:05, 1:23)
String _formatDuration(Duration? duration) {
  if (duration == null) return '0:00';
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes:$seconds";
}

class ChatMessageBubble extends StatefulWidget {
  final ChatMessage message;
  final int currentUserParticipantId;
  final Participant? opponent; // Add opponent for avatar

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.currentUserParticipantId,
    required this.opponent, // Make opponent required
  });

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

// 简单的图片预览页面
class _ImagePreviewPage extends StatelessWidget {
  final String imageUrl;
  
  const _ImagePreviewPage({required this.imageUrl});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(
              Icons.error,
              color: Colors.white,
              size: 50,
            ),
            // 预览图片不限制内存缓存大小，以获得最佳质量
            memCacheWidth: null,
            memCacheHeight: null,
          ),
        ),
      ),
    );
  }
}

class _ChatMessageBubbleState extends State<ChatMessageBubble> {
  late AudioPlayer _audioPlayer;
  PlayerState? _playerState;
  Duration? _duration;
  Duration? _position;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  void _requestRevokeMessage() {
    try {
      final messageListCubit = context.read<MessageListCubit>();
      messageListCubit.revokeMessage(widget.message.id);
      return;
    } catch (_) {
      // Ignore and try legacy bloc below.
    }

    try {
      final chatMessagesBloc = context.read<ChatMessagesBloc>();
      chatMessagesBloc.add(RevokeMessageRequested(widget.message.id));
      return;
    } catch (_) {
      // Ignore and show fallback message below.
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('当前页面未接入消息撤回能力，请稍后重试')),
    );
  }

  bool get _isPlaying => _playerState == PlayerState.playing;
  bool get _isPaused => _playerState == PlayerState.paused;

  @override
  void initState() {
    super.initState();
    if (widget.message.type == 'audio') {
      _audioPlayer = AudioPlayer();
      // Set player mode for consistency, especially on web
      _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);

      // 预加载音频时长
      _preloadAudioDuration(widget.message.context);

      _durationSubscription = _audioPlayer.onDurationChanged.listen((d) {
        if (mounted) setState(() => _duration = d);
      });

      _positionSubscription = _audioPlayer.onPositionChanged.listen((p) {
        if (mounted) setState(() => _position = p);
      });

      _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
        if (mounted) {
            setState(() {
                _playerState = PlayerState.completed;
                _position = Duration.zero; // Reset position on complete
            });
        }
      });

      _playerStateChangeSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
        if (mounted) setState(() => _playerState = state);
      });
    }
  }

  // 预加载音频时长的方法
  Future<void> _preloadAudioDuration(String audioUrl) async {
    try {
      if (audioUrl.isEmpty) return;
      
      AppLogger.d("[Audio] 预加载音频时长: $audioUrl");
      
      // 设置音频源但不播放
      await _audioPlayer.setSourceUrl(audioUrl);
      
      // 获取音频时长
      final duration = await _audioPlayer.getDuration();
      if (mounted && duration != null) {
        AppLogger.d("[Audio] 获取到时长: ${duration.inSeconds}秒");
        setState(() => _duration = duration);
      }
    } catch (e) {
      AppLogger.d("[Audio] 预加载音频时长出错: $e");
    }
  }

  @override
  void dispose() {
    if (widget.message.type == 'audio') {
      _durationSubscription?.cancel();
      _positionSubscription?.cancel();
      _playerCompleteSubscription?.cancel();
      _playerStateChangeSubscription?.cancel();
      _audioPlayer.dispose();
    }
    super.dispose();
  }

  // 处理文件消息点击
  void _handleFileMessageTap(BuildContext context, ChatMessage message) {
    try {
      final fileInfo = _parseFileInfo(message.context);
      final url = fileInfo['url'] ?? message.context;
      final fileName = fileInfo['name'] ?? 'file';
      final fileExtension = fileInfo['extension'] ?? '';
      
      if (url != null && url.isNotEmpty) {
        // 导航到文件预览页面
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FilePreviewPage(
              fileUrl: url,
              fileName: fileName,
              fileExtension: fileExtension,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('无法打开文件: $e')),
      );
    }
  }
  
  // 处理图片消息点击
  void _handleImageMessageTap(BuildContext context, ChatMessage message) {
    // TODO: 实现图片预览功能
    // 可以导航到一个全屏图片查看页面
    // 使用 photo_view 包可以实现缩放功能
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ImagePreviewPage(
          imageUrl: _parseImageUrl(message.context),
        ),
      ),
    );
  }
  
  // 解析文件信息
  Map<String, dynamic> _parseFileInfo(String context) {
    try {
      String contextStr = context.trim();
      
      // 如果是 URL 编码的内容，先解码
      if (contextStr.contains('%7B') || contextStr.contains('%7b') || contextStr.contains('%22')) {
        contextStr = Uri.decodeFull(contextStr);
      }
      
      // 处理可能的格式：{url: xxx, name: xxx, ...} （没有引号的格式）
      if (contextStr.startsWith('{') && !contextStr.contains('"url"')) {
        // 转换为标准 JSON 格式
        contextStr = contextStr
            .replaceAll(RegExp(r'(\w+):'), '"\\1":')  // 给键加引号
            .replaceAll(RegExp(r':\s*([^,}]+)'), ': "\\1"');  // 给值加引号（除了数字）
        
        // 处理数字值（不需要引号）
        contextStr = contextStr
            .replaceAll(RegExp(r':\s*"(\d+)"'), ': \\1');  // 移除数字的引号
      }
      
      // 如果是标准 JSON 字符串，解析它
      if (contextStr.startsWith('{')) {
        return Map<String, dynamic>.from(jsonDecode(contextStr) as Map);
      }
      
      return {'url': contextStr};
    } catch (e) {
      return {'url': context};
    }
  }
  
  // 解析图片URL
  String _parseImageUrl(String context) {
    try {
      final info = _parseFileInfo(context);
      return info['url'] ?? context;
    } catch (e) {
      return context;
    }
  }

  void _playPauseAudio() async {
    if (widget.message.type != 'audio') return;
    final url = widget.message.context;

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        setState(() => _playerState = PlayerState.paused);
      } else if (_isPaused) {
        await _audioPlayer.resume();
        setState(() => _playerState = PlayerState.playing);
      } else { // Not playing or paused (stopped/completed/initial)
        await _audioPlayer.play(UrlSource(url));
        setState(() => _playerState = PlayerState.playing);
      }
    } catch (e) {
      // Handle error (e.g., show a snackbar)
      AppLogger.d("Error playing audio: $e");
       ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')),
      );
       if (mounted) {
           setState(() => _playerState = PlayerState.stopped); // Or completed/error state
       }
    }
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    final heroTag = 'imagePreview_${widget.message.id}';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Hero(
                tag: heroTag,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 构建消息时间显示
  Widget _buildMessageTime() {
    if (widget.message.createTime == null) return const SizedBox.shrink();
    
    final timeString = DateFormat('HH:mm').format(widget.message.createTime!);
    final bool isCurrentUser = widget.message.senderId == widget.currentUserParticipantId;
    
    return Padding(
      padding: EdgeInsets.only(
        top: 4.0,
        left: isCurrentUser ? 8.0 : 0.0,
        right: isCurrentUser ? 0.0 : 8.0,
      ),
      child: Text(
        timeString,
        style: TextStyle(
          color: AppColors.textTertiary,
          fontSize: 11.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 详细的ID映射调试日志
    AppLogger.d('[ChatMessageBubble] =====消息气泡渲染调试=====');
    AppLogger.d('[ChatMessageBubble] 消息ID: ${widget.message.id}');
    AppLogger.d('[ChatMessageBubble] 消息内容: ${widget.message.context?.substring(0, widget.message.context!.length > 30 ? 30 : widget.message.context!.length)}...');
    AppLogger.d('[ChatMessageBubble] 发送者ID信息:');
    AppLogger.d('[ChatMessageBubble]   senderId(内部): ${widget.message.senderId}');
    AppLogger.d('[ChatMessageBubble]   memberId: ${widget.message.memberId}');
    AppLogger.d('[ChatMessageBubble]   doctorId: ${widget.message.doctorId}');
    AppLogger.d('[ChatMessageBubble] 当前用户信息:');
    AppLogger.d('[ChatMessageBubble]   currentUserParticipantId(内部): ${widget.currentUserParticipantId}');
    AppLogger.d('[ChatMessageBubble] 对手信息:');
    AppLogger.d('[ChatMessageBubble]   opponent.id(内部): ${widget.opponent?.id}');
    AppLogger.d('[ChatMessageBubble]   opponent.referId(外部): ${widget.opponent?.referId}');
    AppLogger.d('[ChatMessageBubble]   opponent.nickName: ${widget.opponent?.nickName}');
    
    final bool isCurrentUser = widget.message.senderId == widget.currentUserParticipantId;
    AppLogger.d('[ChatMessageBubble] 判断结果:');
    AppLogger.d('[ChatMessageBubble]   senderId(${widget.message.senderId}) == currentUserParticipantId(${widget.currentUserParticipantId})?');
    AppLogger.d('[ChatMessageBubble]   isCurrentUser = $isCurrentUser');
    AppLogger.d('[ChatMessageBubble]   消息将显示在: ${isCurrentUser ? "右侧(当前用户)" : "左侧(对手)"}');
    AppLogger.d('[ChatMessageBubble] ========================');
    
    // 由于撤回的消息已在BLoC层过滤，这里不再需要检查撤回状态
    final alignment = isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start;
    // Updated bubble colors based on frontend.md alignment
    final bubbleColor = isCurrentUser
        ? const Color(0xFFC9E6FF) // Light blue for current user
        : AppColors.backgroundCard; // TODO(reskin): opponent bubble background
    // Consistent text color for both bubble types
    final textColor = AppColors.textPrimary;

    // 头像已移除，聊天室不显示头像

    // 对于allocate类型的消息，使用专门的组件
    if (widget.message.type == 'allocate') {
      return AllocateMessageBubble(
        message: widget.message,
        sellerName: _getSellerName(),
        isCurrentUserMessage: isCurrentUser,
      );
    }
    
    // 对于付费提示消息，使用专门的组件
    if (widget.message.type == 'payment_prompt' || _isPaymentPromptMessage()) {
      return _buildPaymentPromptBubble(isCurrentUser);
    }

    // 对于图片和文件消息，使用特殊的布局（不需要气泡背景）
    if (widget.message.type == 'image' || widget.message.type == 'file') {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        child: Row(
          mainAxisAlignment: alignment,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: isCurrentUser 
                    ? CrossAxisAlignment.end 
                    : CrossAxisAlignment.start,
                children: [
                  // 使用 _buildMessageContent 来渲染内容
                  _buildMessageContent(context, textColor, isCurrentUser, widget.message.context ?? ''),
                  _buildMessageTime(),
                ],
              ),
            ),
            if (isCurrentUser) const SizedBox.shrink(),
          ],
        ),
      );
    }

    // 其他类型消息使用标准气泡
    final bubbleContent = GestureDetector(
      onLongPressStart: (details) {
        _showActionMenu(context, details.globalPosition, isCurrentUser);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16.0), // Keep consistent radius
        ),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7, // Keep max width constraint
        ),
        // Pass the determined text color to the content builder
        child: _buildMessageContent(context, textColor, isCurrentUser, widget.message.context ?? ''),
      ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: alignment,
        crossAxisAlignment: CrossAxisAlignment.end, // 改为end对齐
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: isCurrentUser 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                bubbleContent,
                _buildMessageTime(), // 添加时间显示
              ],
            ),
          ),
          if (isCurrentUser) const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, Color textColor, bool isCurrentUser, String messageContext) {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context)!;
    
    if (widget.message.type == 'text') {
       // 用GestureDetector包装Markdown组件，确保长按事件能正确触发
       return GestureDetector(
         onLongPressStart: (details) {
           _showActionMenu(context, details.globalPosition, isCurrentUser);
         },
         child: MarkdownBody(
         data: messageContext,
           selectable: false, // 禁用选择功能，避免与长按菜单冲突
         styleSheet: MarkdownStyleHelper.buildChatBubbleStyle(context, textColor),
         onTapLink: (text, href, title) {
           // 处理链接点击
           if (href != null) {
             launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
           }
         },
         // 确保内容自适应并限制在消息气泡内
         shrinkWrap: true,
         ),
       );
     } else if (widget.message.type == 'file') {
       // 文件消息使用专门的组件
       return FileMessageWidget(
         message: widget.message,
         isMe: isCurrentUser,
         onTap: () {
           // 处理文件点击（下载或预览）
           _handleFileMessageTap(context, widget.message);
         },
       );
     } else if (widget.message.type == 'image') {
       // 图片消息使用专门的组件
       return ImageMessageWidget(
         message: widget.message,
         isMe: isCurrentUser,
         onTap: () {
           // 处理图片点击（预览）
           _handleImageMessageTap(context, widget.message);
         },
         onLongPressStart: (details) {
           _showActionMenu(context, details.globalPosition, isCurrentUser);
         },
       );
     } else if (widget.message.type == 'audio') {
       // Pass textColor and isCurrentUser to audio content
       return _buildAudioContent(context, textColor, isCurrentUser, messageContext);
     } else if (widget.message.type == 'allocate') {
       // allocate类型消息已经在build方法中直接返回特定组件，这里不应该被调用
       // 但为了安全，还是提供一个处理
       return Text(messageContext, style: TextStyle(color: textColor, fontSize: 15));
     } else if (widget.message.type == 'revoke' || widget.message.withdrawFlag) {
       return Row(
         mainAxisSize: MainAxisSize.min,
         children: [
           Icon(
             Icons.block,
             size: 14,
             color: AppColors.textSecondary,
           ),
           const SizedBox(width: 6),
           Text(
             messageContext.isNotEmpty ? messageContext : '消息已撤回',
             style: TextStyle(
               color: AppColors.textSecondary,
               fontSize: 13,
               fontStyle: FontStyle.italic,
             ),
           ),
         ],
       );
     } else {
       // Keep handling for unsupported types
       return Text('[${AppLocalizations.of(context)!.chat_unknown_message}: ${widget.message.type}]', style: TextStyle(color: AppColors.error));
     }
  }

  Widget _buildImageContent(BuildContext context, String imageUrl) {
     // 如果消息正在发送，显示上传进度
     if (widget.message.status == MessageStatus.sending) {
       return Container(
         width: 150,
         height: 150,
         decoration: BoxDecoration(
            color: AppColors.borderInput,
            borderRadius: BorderRadius.circular(16.0),
         ),
         child: const Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             CircularProgressIndicator(strokeWidth: 2.0),
             SizedBox(height: 8),
             Text('上传中...', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
           ],
         ),
       );
     }
     
     // 如果上传失败，显示重试按钮
     if (widget.message.status == MessageStatus.failed) {
       return Container(
         width: 150,
         height: 150,
         decoration: BoxDecoration(
           color: AppColors.borderInput,
           borderRadius: BorderRadius.circular(16.0),
         ),
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             const Icon(Icons.error_outline, color: AppColors.error, size: 40),
             const SizedBox(height: 8),
             const Text('上传失败', style: TextStyle(fontSize: 12)),
             const SizedBox(height: 8),
            ElevatedButton(
               onPressed: () {
                 // 重新发送消息
                 try {
                   final chatMessagesBloc = context.read<ChatMessagesBloc>();
                   chatMessagesBloc.add(
                     SendMessageRequested(
                       type: 'image',
                       file: File(widget.message.context), // 需要保存原始文件路径
                     ),
                   );
                 } catch (_) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('当前页面不支持图片重试发送')),
                   );
                 }
               },
               style: ElevatedButton.styleFrom(
                 minimumSize: const Size(60, 24),
                 padding: const EdgeInsets.symmetric(horizontal: 8),
               ),
               child: const Text('重试', style: TextStyle(fontSize: 12)),
             ),
           ],
         ),
       );
     }

     final heroTag = 'imagePreview_${widget.message.id}';
     final bool isCurrentUser = widget.message.senderId == widget.currentUserParticipantId;
     
     if (imageUrl.isEmpty) {
       return Container(
         width: 150, height: 150,
         decoration: BoxDecoration(
         color: AppColors.borderInput,
            borderRadius: BorderRadius.circular(16.0), // 使用与消息气泡相同的圆角
         ),
         child: const Center(child: Icon(Icons.broken_image, color: AppColors.error)),
       );
     }
     
     return GestureDetector(
       onTap: () => _showImagePreview(context, imageUrl),
       // 添加长按事件处理，支持撤回和复制功能
       onLongPressStart: (details) {
         _showActionMenu(context, details.globalPosition, isCurrentUser);
       },
       child: Hero(
         tag: heroTag,
         child: ConstrainedBox(
            constraints: BoxConstraints(
               maxHeight: 200,
               maxWidth: MediaQuery.of(context).size.width * 0.6, // 控制图片最大宽度
            ),
           child: ClipRRect(
             borderRadius: BorderRadius.circular(16.0), // 给图片添加圆角，与消息气泡一致
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) => Container(
                   width: 150, height: 150,
                   color: AppColors.borderInput,
                   child: const Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       CircularProgressIndicator(strokeWidth: 2),
                       SizedBox(height: 8),
                       Text('加载中...', style: TextStyle(fontSize: 12)),
                     ],
                   ),
                 ),
               errorWidget: (context, url, error) {
                 AppLogger.d("[Image] 加载错误: $url, 错误: $error");
                 // 提供更友好的错误显示并添加重试按钮
                 return Container(
                   width: 150, height: 150,
                   decoration: BoxDecoration(
                     color: AppColors.borderPrimary,
                     borderRadius: BorderRadius.circular(16.0), // 使用与消息气泡相同的圆角
                   ),
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       const Icon(Icons.broken_image, color: AppColors.error, size: 40),
                       const SizedBox(height: 8),
                       const Text('加载失败', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                       const SizedBox(height: 8),
                       // 重试按钮
                       ElevatedButton(
                         onPressed: () {
                           // 强制刷新图片缓存
                           final imageProvider = CachedNetworkImageProvider(imageUrl);
                           imageProvider.evict().then((_) {
                             // 触发重新构建
                             if (mounted) setState(() {});
                           });
                         },
                         style: ElevatedButton.styleFrom(
                           minimumSize: const Size(50, 24),
                           padding: const EdgeInsets.symmetric(horizontal: 8),
                           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                         ),
                         child: const Text('重试', style: TextStyle(fontSize: 12)),
                       ),
                     ],
                   ),
                 );
               },
                fit: BoxFit.cover,
               // 增加重试次数
               maxHeightDiskCache: 400,
               fadeOutDuration: const Duration(milliseconds: 300),
               fadeInDuration: const Duration(milliseconds: 300),
               // 修改缓存配置，可选
               cacheKey: "chat_image_${widget.message.id}",
               // 限制内存中图片的尺寸，减少内存占用
               memCacheWidth: 400,
               memCacheHeight: 400,
             ),
           ),
         ),
       ),
     );
  }

  Widget _buildAudioContent(BuildContext context, Color iconAndTextColor, bool isCurrentUser, String audioUrl) {
    // Determine icon color based on user (can be same as text or specific)
    final Color effectiveIconColor = isCurrentUser ? AppColors.textSecondary : AppColors.textSecondary; // Example: use greyish for both
    final Color effectiveTextColor = isCurrentUser ? AppColors.textSecondary : AppColors.textSecondary; // Example: use greyish for both

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 播放按钮
          Container(
            decoration: BoxDecoration(
              color: effectiveIconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: effectiveIconColor,
                size: 24,
              ),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              onPressed: _playPauseAudio,
              tooltip: _isPlaying ? '暂停' : '播放',
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 音频波形或进度条
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 简单的进度条
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.borderInput,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _duration != null && _position != null
                        ? (_position!.inMilliseconds / _duration!.inMilliseconds).clamp(0.0, 1.0)
                        : 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: effectiveIconColor,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // 时间显示
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position ?? Duration.zero),
                      style: TextStyle(color: effectiveTextColor, fontSize: 12),
                    ),
                    Text(
                      _formatDuration(_duration ?? Duration.zero),
                      style: TextStyle(color: effectiveTextColor, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
        ],
      ),
    );
  }

   Widget _buildStatusIndicator(BuildContext context) {
    IconData iconData;
    Color iconColor = AppColors.textTertiary;
    double iconSize = 16.0;

    switch (widget.message.status) {
      case MessageStatus.sending:
        iconData = Icons.schedule;
        break;
      case MessageStatus.sent:
        iconData = Icons.done;
        break;
      case MessageStatus.failed:
        iconData = Icons.error_outline;
        iconColor = AppColors.error;
        break;
      case MessageStatus.read:
        iconData = Icons.done_all;
        iconColor = AppColors.info;
        break;
    }

    return Padding(
       padding: const EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0),
       child: Icon(iconData, size: iconSize, color: iconColor),
     );
   }

   void _showActionMenu(BuildContext context, Offset tapPosition, bool isCurrentUser) {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context)!;
    
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final List<PopupMenuEntry<String>> menuItems = [];

    // 文本消息支持复制
    if (widget.message.type == 'text') {
        menuItems.add(PopupMenuItem<String>(value: 'copy', child: Text(appLocalizations.chat_copy)));
    }

    // 当前用户的消息支持撤回（包括文本和图片）
    if (isCurrentUser) {
        // 检查消息发送时间，判断是否可以撤回
        final revokeResult = _checkRevokeStatus();
        
        if (revokeResult.canRevoke) {
            // 可以撤回：显示正常的撤回选项
            menuItems.add(PopupMenuItem<String>(
                value: 'revoke', 
                child: Text(appLocalizations.chat_recall)
            ));
    }
        // 注意：超过2分钟的消息不显示任何撤回选项
    }

    // 如果没有可用选项，显示提示信息
    if (menuItems.isEmpty) {
        if (isCurrentUser) {
            // 如果是当前用户的消息但没有可用操作，显示原因
            final revokeResult = _checkRevokeStatus();
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(revokeResult.reason),
                    duration: const Duration(seconds: 2),
                ),
            );
        }
        return;
    }

    showMenu(
        context: context,
        position: RelativeRect.fromRect(
            tapPosition & const Size(40, 40),
            Offset.zero & overlay.size
        ),
        items: menuItems,
        elevation: 8.0,
    ).then<void>((String? selectedValue) {
        if (selectedValue == null) return;

        switch (selectedValue) {
            case 'copy':
                Clipboard.setData(ClipboardData(text: widget.message.context));
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(appLocalizations.chat_copied_to_clipboard)),
                );
                break;
            case 'revoke':
                // 再次检查是否可以撤回（防止时间差问题）
                final revokeResult = _checkRevokeStatus();
                if (revokeResult.canRevoke) {
                _requestRevokeMessage();
                } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(revokeResult.reason),
                            duration: const Duration(seconds: 2),
                        ),
                    );
                }
                break;
        }
    });
  }

  // 检查消息撤回状态（更详细的版本）
  RevokeCheckResult _checkRevokeStatus() {
      if (widget.message.createTime == null) {
          return RevokeCheckResult(
              canRevoke: false, 
              reason: '消息时间信息缺失，无法撤回'
          );
      }
      
      final now = DateTime.now();
      final messageTime = widget.message.createTime!;
      final timeDifference = now.difference(messageTime);
      
      // 允许撤回的时间窗口：2分钟（120秒）
      const revokeTimeLimit = Duration(minutes: 2);
      
      AppLogger.d('[Debug] 消息撤回检查 - 消息时间: $messageTime, 当前时间: $now, 时间差: ${timeDifference.inSeconds}秒');
      
      if (timeDifference <= revokeTimeLimit) {
          final remainingTime = revokeTimeLimit - timeDifference;
          return RevokeCheckResult(
              canRevoke: true, 
              reason: '可以撤回',
              remainingTime: remainingTime
          );
      } else {
          final overTime = timeDifference - revokeTimeLimit;
          return RevokeCheckResult(
              canRevoke: false, 
              reason: '消息发送已超过2分钟，无法撤回（超出${overTime.inSeconds}秒）'
          );
      }
  }

  // 保留原有的简单检查方法（向后兼容）
  bool _canRevokeMessage() {
      return _checkRevokeStatus().canRevoke;
  }

  // 添加一个方法用于获取allocate消息的显示名称
  String _getSellerName() {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context)!;
    
    final bool isCurrentUser = widget.message.senderId == widget.currentUserParticipantId;
    
    // 如果当前用户是消息发送者（买家），显示"我"
    if (isCurrentUser) {
      return appLocalizations.chat_me;
    }
    
    // 如果当前用户是消息接收者（卖家），显示对方名称（买家）
    if (widget.opponent != null && widget.opponent!.nickName != null) {
      return widget.opponent!.nickName!;
    }
    
    // 如果无法获取对方名称，返回默认值
    return appLocalizations.chat_buyer;
  }
  
  // 检查是否为付费提示消息
  bool _isPaymentPromptMessage() {
    try {
      // 尝试解析JSON内容
      if (widget.message.context.contains('"type":"payment_prompt"')) {
        return true;
      }
      final content = jsonDecode(widget.message.context);
      return content['type'] == 'payment_prompt';
    } catch (_) {
      return false;
    }
  }
  
  // 构建付费提示气泡
  Widget _buildPaymentPromptBubble(bool isSeller) {
    try {
      // 解析JSON内容
      final Map<String, dynamic> promptData = jsonDecode(widget.message.context);

      final String content = promptData['content'] ?? '根据平台规则，您已完成5轮免费咨询。继续咨询请选择服务套餐：';
      final String? productId = promptData['productId']?.toString();
      final int? sellerId = promptData['sellerId'] != null
          ? (promptData['sellerId'] is int
              ? promptData['sellerId']
              : int.tryParse(promptData['sellerId'].toString()))
          : null;
      final List<Map<String, dynamic>>? variants = promptData['variants'] != null
          ? List<Map<String, dynamic>>.from(promptData['variants'])
          : null;

      return PaymentPromptBubble(
        isSeller: isSeller,
        productId: productId,
        sellerId: sellerId,
        chatRoomId: widget.message.chatId,
        variants: variants,
        content: content,
      );
    } catch (e) {
      // 如果解析失败，返回默认的付费提示
      return PaymentPromptBubble(
        isSeller: isSeller,
        productId: null,
        sellerId: null,
        chatRoomId: widget.message.chatId,
        variants: null,
        content: '根据平台规则，您已完成5轮免费咨询。继续咨询请选择服务套餐：',
      );
    }
  }
} 
