import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for Clipboard
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc

import '../../domain/entities/chat_message.dart';
import '../bloc/chat_messages/chat_messages_bloc.dart'; // Import ChatMessagesBloc
import '../../domain/entities/participant.dart'; // Import Participant

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
    if (widget.message.type == 'audio') {
      _audioPlayer = AudioPlayer();
      // Set player mode for consistency, especially on web
      _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);

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

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUser = widget.message.senderId == widget.currentUserParticipantId;
    final bool isRevoked = widget.message.withdrawFlag || widget.message.type == 'revoke';
    final alignment = isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start;
    final bubbleColor = isCurrentUser 
        ? Theme.of(context).primaryColor.withOpacity(0.15) 
        : Theme.of(context).colorScheme.surfaceVariant;
    final textColor = Theme.of(context).colorScheme.onSurface;

    // Avatar Widget (only for opponent)
    final avatarWidget = !isCurrentUser && widget.opponent != null
      ? Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: CircleAvatar(
            radius: 18,
            backgroundImage: (widget.opponent?.avatar != null && widget.opponent!.avatar!.isNotEmpty)
                ? CachedNetworkImageProvider(widget.opponent!.avatar!)
                : null,
            backgroundColor: Colors.grey[300],
            child: (widget.opponent?.avatar == null || widget.opponent!.avatar!.isEmpty)
                ? Text(
                    widget.opponent?.nickName?.isNotEmpty == true ? widget.opponent!.nickName![0] : '?',
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  )
                : null,
          ),
        )
      : const SizedBox(width: 44);

    final bubbleContent = GestureDetector(
      onLongPressStart: (details) {
        if (!isRevoked) {
          _showActionMenu(context, details.globalPosition, isCurrentUser);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: _buildMessageContent(context, textColor, isCurrentUser, isRevoked, widget.message.context ?? ''),
      ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: alignment,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser) avatarWidget,
          Flexible(child: bubbleContent),
          if (isCurrentUser) const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, Color textColor, bool isCurrentUser, bool isRevoked, String messageContext) {
    if (isRevoked) {
        return Text(
          '消息已撤回',
          style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
        );
     } else if (widget.message.type == 'text') {
       return Text(messageContext, style: TextStyle(color: textColor));
     } else if (widget.message.type == 'image') {
       return _buildImageContent(context, messageContext);
     } else if (widget.message.type == 'audio') {
       return _buildAudioContent(context, textColor, isCurrentUser, messageContext);
     } else {
       return Text('[不受支持的消息类型: ${widget.message.type}]', style: TextStyle(color: Colors.red));
     }
  }

  Widget _buildImageContent(BuildContext context, String imageUrl) {
     final heroTag = 'imagePreview_${widget.message.id}';
     if (imageUrl.isEmpty) {
       return Container(
         width: 150, height: 150,
         color: Colors.grey[300],
         child: const Center(child: Icon(Icons.broken_image, color: Colors.red)),
       );
     }
     return GestureDetector(
       onTap: () => _showImagePreview(context, imageUrl),
       child: Hero(
         tag: heroTag,
         child: Container(
            constraints: const BoxConstraints(
               maxHeight: 200,
               maxWidth: 200,
            ),
           child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) => Container(
                   width: 150, height: 150,
                   color: Colors.grey[300],
                   child: const Center(child: CircularProgressIndicator()),
                 ),
                errorWidget: (context, url, error) => Container(
                   width: 150, height: 150,
                   color: Colors.grey[300],
                   child: const Center(child: Icon(Icons.error, color: Colors.red)),
                ),
                fit: BoxFit.cover,
             ),
           ),
         ),
       ),
     );
  }

  Widget _buildAudioContent(BuildContext context, Color? textColor, bool isCurrentUser, String audioUrl) {
    final iconColor = isCurrentUser ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.8) : Theme.of(context).colorScheme.primary;
    final progressTrackColor = isCurrentUser ? Colors.white70 : Theme.of(context).colorScheme.primary.withOpacity(0.7);
    final progressBackgroundColor = isCurrentUser ? Colors.white38 : Theme.of(context).colorScheme.primary.withOpacity(0.3);

    final String durationText = _duration != null ? _formatDuration(_duration!) : '--:--';
    final double progress = (_duration != null && _position != null && _duration!.inMilliseconds > 0)
        ? (_position!.inMilliseconds / _duration!.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
          color: iconColor,
          onPressed: _playPauseAudio,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SliderTheme(
             data: SliderTheme.of(context).copyWith(
                trackHeight: 3.0,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.0),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10.0),
                activeTrackColor: progressTrackColor,
                inactiveTrackColor: progressBackgroundColor,
                thumbColor: iconColor,
                overlayColor: iconColor.withOpacity(0.2),
             ),
             child: Slider(
               value: progress,
               onChanged: (value) async {
                  if (_duration == null) return; 
                  final newPosition = _duration! * value;
                  try {
                     await _audioPlayer.seek(newPosition);
                     if (_isPaused) {
                        await _audioPlayer.resume();
                        setState(() => _playerState = PlayerState.playing);
                     }
                  } catch (e) {
                     print("Error seeking audio: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error seeking audio: $e')),
                      );
                  }
               },
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          durationText,
          style: TextStyle(fontSize: 12, color: textColor?.withOpacity(0.7)),
        ),
      ],
    );
  }

   Widget _buildStatusIndicator(BuildContext context) {
    IconData iconData;
    Color iconColor = Colors.grey;
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
        iconColor = Colors.red;
        break;
      case MessageStatus.read:
        iconData = Icons.done_all;
        iconColor = Colors.blue;
        break;
    }

    return Padding(
       padding: const EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0),
       child: Icon(iconData, size: iconSize, color: iconColor),
     );
   }

   void _showActionMenu(BuildContext context, Offset tapPosition, bool isCurrentUser) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final List<PopupMenuEntry<String>> menuItems = [];

    if (widget.message.type == 'text') {
        menuItems.add(const PopupMenuItem<String>(value: 'copy', child: Text('复制')));
    }

    if (isCurrentUser) {
        menuItems.add(const PopupMenuItem<String>(value: 'revoke', child: Text('撤回')));
    }

    if (menuItems.isEmpty) return;

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
                    const SnackBar(content: Text('已复制到剪贴板')),
                );
                break;
            case 'revoke':
                context.read<ChatMessagesBloc>().add(RevokeMessageRequested(widget.message.id));
                break;
            case 'delete':
                break;
        }
    });
  }

   String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
} 