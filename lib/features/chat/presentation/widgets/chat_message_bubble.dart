import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'dart:async';
import 'dart:io'; // 添加这个import来支持File类型
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for Clipboard
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/core/widgets/skeleton/shimmer_effect.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc
import 'package:flutter_markdown/flutter_markdown.dart'; // 导入Markdown渲染包
import 'package:url_launcher/url_launcher.dart'; // 导入URL处理包
import 'package:dskk_flutter_refactor/generated/app_localizations.dart'; // 导入国际化资源

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/payment_prompt_payload.dart';
import '../../domain/constants/message_type.dart';
import 'payment_prompt_bubble.dart';
import '../bloc/chat_messages/chat_messages_bloc.dart'; // Import ChatMessagesBloc
import '../cubit/message_list/message_list_cubit.dart';
import '../../domain/entities/participant.dart'; // Import Participant
import '../../domain/constants/chat_constants.dart';
import 'ai_summary_message_bubble.dart'; // allocate 类型改用安全渲染的 AI 摘要气泡 (#377)
import 'file_message_widget.dart'; // file 类型消息渲染组件
import '../utils/markdown_style_helper.dart'; // 导入Markdown样式助手

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

  // 检测 AI 内部 summary 消息（后端当前以 text 类型下发，#377 / backend#20）。
  // 前端根据内容前缀过滤，避免将系统内容展示给用户。
  // 后端正式添加 summary 消息类型后，可删除此方法并改用类型过滤。
  //
  // 唯一事实来源：AiSummaryMessageBubble 也复用此前缀表判定泄漏样本，
  // 切勿在别处另行维护前缀列表。
  static bool isAiSummaryMessage(String context) {
    const aiSummaryPrefixes = [
      '**Service Conversation Summary',
      '**User Profile Construction',
    ];
    for (final prefix in aiSummaryPrefixes) {
      if (context.startsWith(prefix)) return true;
    }
    return false;
  }

  /// #377 第②层双认：AI summary 既可能以历史 [ChatMessageType.allocate] 也可能以
  /// 新 [ChatMessageType.aiSummary] 下发，两者都用 AiSummaryMessageBubble 安全渲染。
  /// 历史 allocate 数据因此免迁移。
  static bool isSummaryType(String type) =>
      type == ChatMessageType.allocate || type == ChatMessageType.aiSummary;

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
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

  bool get _isPlaying => _playerState == PlayerState.playing;
  bool get _isPaused => _playerState == PlayerState.paused;

  @override
  void initState() {
    super.initState();
    if (widget.message.type == ChatMessageType.audio) {
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
      
      print("[Audio] 预加载音频时长: $audioUrl");
      
      // 设置音频源但不播放
      await _audioPlayer.setSourceUrl(audioUrl);
      
      // 获取音频时长
      final duration = await _audioPlayer.getDuration();
      if (mounted && duration != null) {
        print("[Audio] 获取到时长: ${duration.inSeconds}秒");
        setState(() => _duration = duration);
      }
    } catch (e) {
      print("[Audio] 预加载音频时长出错: $e");
    }
  }

  @override
  void dispose() {
    if (widget.message.type == ChatMessageType.audio) {
      _durationSubscription?.cancel();
      _positionSubscription?.cancel();
      _playerCompleteSubscription?.cancel();
      _playerStateChangeSubscription?.cancel();
      _audioPlayer.dispose();
    }
    super.dispose();
  }

  void _playPauseAudio() async {
    if (widget.message.type != ChatMessageType.audio) return;
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
      print("Error playing audio: $e");
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
                  placeholder: (ctx, url) => const Center(
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: ShimmerEffect(child: CircleAvatar()),
                    ),
                  ),
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
    final timeString = DateFormat('HH:mm').format(widget.message.createTime);
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
          color: AppColors.textSecondary,
          fontSize: 11.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 撤回的消息渲染居中灰色提示(#333),否则会因为不匹配 text/audio/image/allocate
    // 默认分支而不显示任何内容。MessageListCubit.revokeMessage 已把
    // type 设为 revoke + withdrawFlag=true + context='消息已撤回'。
    if (widget.message.withdrawFlag ||
        widget.message.type == ChatMessageType.revoke) {
      final isCurrentUser =
          widget.message.senderId == widget.currentUserParticipantId;
      final tipText = isCurrentUser ? '你撤回了一条消息' : '对方撤回了一条消息';
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Center(
          child: Text(
            tipText,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ),
      );
    }

    // Payment-prompt messages are encoded as text-typed messages whose
    // context is a JSON envelope. Detect & dispatch to the rich bubble
    // before falling through to the default text/image/audio renderers.
    // isSeller here means "viewer is the seller": payment_prompt is always
    // sent by the seller, so viewer-is-sender ⇔ viewer-is-seller.
    final paymentPrompt = PaymentPromptPayload.tryParse(widget.message.context);
    if (paymentPrompt != null) {
      return PaymentPromptBubble(
        payload: paymentPrompt,
        isSeller: widget.message.senderId == widget.currentUserParticipantId,
        chatRoomId: widget.message.chatId,
      );
    }

    // AI summary messages are currently sent by the backend as plain text
    // (type='text') but are internal system content not intended for users.
    // Hide them until the backend adds a dedicated message type (#377 / backend#20).
    if (widget.message.type == ChatMessageType.text &&
        ChatMessageBubble.isAiSummaryMessage(widget.message.context)) {
      return const SizedBox.shrink();
    }

    final bool isCurrentUser = widget.message.senderId == widget.currentUserParticipantId;
    // 由于撤回的消息已在BLoC层过滤，这里不再需要检查撤回状态
    final alignment = isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start;
    // 发送方向保留蓝色强调，同时统一为半透明玻璃材质。
    final bubbleColor = isCurrentUser
        ? AppColors.primary.withValues(alpha: 0.18)
        : AppColors.backgroundCard.withValues(alpha: 0.74);
    // Consistent text color for both bubble types
    const textColor = AppColors.textPrimary;

    // Avatar Widget (only for opponent) — 点击跳对方公开主页 (#334)
    final avatarWidget = !isCurrentUser && widget.opponent != null
      ? Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GestureDetector(
            onTap: () {
              final sellerId = widget.opponent?.referId;
              if (sellerId != null) {
                context.push('/seller-profile/$sellerId');
              }
            },
            child: CircleAvatar(
              radius: 18,
              backgroundImage: (widget.opponent?.avatar != null && widget.opponent!.avatar!.isNotEmpty)
                  ? CachedNetworkImageProvider(widget.opponent!.avatar!)
                  : null,
              backgroundColor: AppColors.borderInput,
              child: (widget.opponent?.avatar == null || widget.opponent!.avatar!.isEmpty)
                  ? Text(
                      widget.opponent?.nickName?.isNotEmpty == true ? widget.opponent!.nickName![0] : '?',
                      style: const TextStyle(fontSize: 14, color: AppColors.onPrimary),
                    )
                  : null,
            ),
          ),
        )
      : const SizedBox(width: 44);

    // 对于 AI 需求摘要消息（历史 allocate / 新 ai_summary 双认），使用安全渲染组件，
    // 杜绝内部 prompt 结构（**...** 标题）泄漏进聊天 UI (#377)。
    if (ChatMessageBubble.isSummaryType(widget.message.type)) {
      return AiSummaryMessageBubble(
        message: widget.message,
        sellerName: _getSellerName(),
        isCurrentUserMessage: isCurrentUser,
      );
    }

    // 对于图片消息，包含时间显示
    if (widget.message.type == ChatMessageType.image) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        child: Row(
          mainAxisAlignment: alignment,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isCurrentUser) avatarWidget,
            Flexible(
              child: Column(
                crossAxisAlignment: isCurrentUser 
                    ? CrossAxisAlignment.end 
                    : CrossAxisAlignment.start,
                children: [
                  _buildImageContent(context, widget.message.context ?? ''),
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
          borderRadius: BorderRadius.circular(18.0),
          border: Border.all(
            color: isCurrentUser
                ? AppColors.primary.withValues(alpha: 0.22)
                : Colors.white.withValues(alpha: 0.88),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: isCurrentUser ? 0.10 : 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
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
          if (!isCurrentUser) avatarWidget,
          Flexible(
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                bubbleContent,
                // 翻译区域（微信风格）
                if (!isCurrentUser && widget.message.type == ChatMessageType.text)
                  _buildTranslationArea(),
                _buildMessageTime(), // 添加时间显示
              ],
            ),
          ),
          if (isCurrentUser) const SizedBox.shrink(),
        ],
      ),
    );
  }

  /// 构建翻译区域（微信风格灰色背景）
  Widget _buildTranslationArea() {
    final message = widget.message;

    if (message.isTranslating) {
      return Container(
        margin: const EdgeInsets.only(top: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8.0),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).chat_translating,
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 13.0,
              ),
            ),
          ],
        ),
      );
    }

    if (message.translatedContext != null && message.translatedContext!.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8.0),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).chat_translation_label,
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 11.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.translatedContext!,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15.0,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildMessageContent(BuildContext context, Color textColor, bool isCurrentUser, String messageContext) {
    // 获取国际化资源
    final s = AppLocalizations.of(context);
    
    if (widget.message.type == ChatMessageType.text) {
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
     } else if (widget.message.type == ChatMessageType.audio) {
       // Pass textColor and isCurrentUser to audio content
       return _buildAudioContent(context, textColor, isCurrentUser, messageContext);
     } else if (ChatMessageBubble.isSummaryType(widget.message.type)) {
       // summary 消息（allocate/ai_summary）已在 build 方法中直接路由到
       // AiSummaryMessageBubble，这里正常不会被调用。但为防止内部 prompt 结构
       // （**...**）泄漏，兜底也走确定性 strip，绝不渲染原文。
       return Text(
         AiSummaryMessageBubble.stripMarkdownMarkers(messageContext),
         style: TextStyle(color: textColor, fontSize: 15),
       );
     } else if (widget.message.type == ChatMessageType.file) {
       // 文件消息：复用 FileMessageWidget 渲染（文件名/大小/图标 + 点击预览下载）。
       // 不可落入下方"未知 type"分支。
       return FileMessageWidget(
         message: widget.message,
         isMe: isCurrentUser,
       );
     } else {
       // 未知/暂不支持的 type：中性降级文案，绝不暗示"请升级 App / 版本太老"，
       // 避免正常 file 或未来未知 type 被误导成版本问题。颜色用中性色而非红字。
       return Text(
         AppLocalizations.of(context).chat_unsupported_message,
         style: const TextStyle(color: AppColors.textTertiary, fontSize: 15),
       );
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
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             const CircularProgressIndicator(strokeWidth: 2.0),
             const SizedBox(height: 8),
             Text(AppLocalizations.of(context).chat_uploading, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
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
             Text(AppLocalizations.of(context).chat_upload_failed, style: const TextStyle(fontSize: 12)),
             const SizedBox(height: 8),
             ElevatedButton(
               onPressed: () {
                 // 重新发送消息
                 context.read<ChatMessagesBloc>().add(
                   SendMessageRequested(
                     type: ChatMessageType.image,
                     file: File(widget.message.context), // 需要保存原始文件路径
                   ),
                 );
               },
               style: ElevatedButton.styleFrom(
                 minimumSize: const Size(60, 24),
                 padding: const EdgeInsets.symmetric(horizontal: 8),
               ),
               child: Text(AppLocalizations.of(context).chat_retry, style: const TextStyle(fontSize: 12)),
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
                placeholder: (ctx, url) => const Center(
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: ShimmerEffect(child: CircleAvatar()),
                  ),
                ),
               errorWidget: (context, url, error) {
                 print("[Image] 加载错误: $url, 错误: $error");
                 // 提供更友好的错误显示并添加重试按钮
                 return Container(
                   width: 150, height: 150,
                   decoration: BoxDecoration(
                     color: AppColors.backgroundSecondary,
                     borderRadius: BorderRadius.circular(16.0), // 使用与消息气泡相同的圆角
                   ),
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       const Icon(Icons.broken_image, color: AppColors.error, size: 40),
                       const SizedBox(height: 8),
                       Text(AppLocalizations.of(context).chat_image_load_failed, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
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
                         child: Text(AppLocalizations.of(context).chat_retry, style: const TextStyle(fontSize: 12)),
                       ),
                     ],
                   ),
                 );
               },
                fit: BoxFit.cover,
               // 增加重试次数
               maxHeightDiskCache: 300,
               fadeOutDuration: const Duration(milliseconds: 300),
               fadeInDuration: const Duration(milliseconds: 300),
               // 修改缓存配置，可选
               cacheKey: "chat_image_${widget.message.id}",
               memCacheWidth: 300,
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
              tooltip: _isPlaying ? AppLocalizations.of(context).chat_audio_pause : AppLocalizations.of(context).chat_audio_play,
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
        iconColor = AppColors.primary;
        break;
    }

    return Padding(
       padding: const EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0),
       child: Icon(iconData, size: iconSize, color: iconColor),
     );
   }

   void _showActionMenu(BuildContext context, Offset tapPosition, bool isCurrentUser) {
    // 获取国际化资源
    final s = AppLocalizations.of(context);
    
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final List<PopupMenuEntry<String>> menuItems = [];

    // 文本消息支持复制
    if (widget.message.type == ChatMessageType.text) {
        menuItems.add(PopupMenuItem<String>(value: 'copy', child: Text(s.chat_copy)));
    }

    // 当前用户的消息支持撤回（包括文本和图片）
    if (isCurrentUser) {
        // 检查消息发送时间，判断是否可以撤回
        final revokeResult = _checkRevokeStatus();
        
        if (revokeResult.canRevoke) {
            // 可以撤回：显示正常的撤回选项
            menuItems.add(PopupMenuItem<String>(
                value: 'revoke', 
                child: Text(s.chat_recall)
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
                    SnackBar(content: Text(s.chat_copied_to_clipboard)),
                );
                break;
            case 'revoke':
                // 再次检查是否可以撤回（防止时间差问题）
                final revokeResult = _checkRevokeStatus();
                if (revokeResult.canRevoke) {
                  // refactored 聊天室走 MessageListCubit 链路,不是 ChatMessagesBloc (#333)
                  context.read<MessageListCubit>().revokeMessage(widget.message.id);
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
      final s = AppLocalizations.of(context);

      final now = DateTime.now();
      final messageTime = widget.message.createTime;
      final timeDifference = now.difference(messageTime);

      // 允许撤回的时间窗口：2分钟（120秒）
      const revokeTimeLimit = ChatConstants.revokeTimeLimit;

      print('[Debug] Revoke check - messageTime: $messageTime, now: $now, diff: ${timeDifference.inSeconds}s');

      if (timeDifference <= revokeTimeLimit) {
          final remainingTime = revokeTimeLimit - timeDifference;
          return RevokeCheckResult(
              canRevoke: true,
              reason: s.chat_revoke_available,
              remainingTime: remainingTime
          );
      } else {
          final overTime = timeDifference - revokeTimeLimit;
          return RevokeCheckResult(
              canRevoke: false,
              reason: s.chat_revoke_expired(overTime.inSeconds)
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
    final s = AppLocalizations.of(context);
    
    final bool isCurrentUser = widget.message.senderId == widget.currentUserParticipantId;
    
    // 如果当前用户是消息发送者（买家），显示"我"
    if (isCurrentUser) {
      return s.chat_me;
    }
    
    // 如果当前用户是消息接收者（卖家），显示对方名称（买家）
    if (widget.opponent != null && widget.opponent!.nickName != null) {
      return widget.opponent!.nickName!;
    }
    
    // 如果无法获取对方名称，返回默认值
    return s.chat_buyer;
  }
}
