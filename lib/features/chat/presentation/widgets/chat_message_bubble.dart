import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for Clipboard
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc

import '../../domain/entities/chat_message.dart';
import '../bloc/chat_messages/chat_messages_bloc.dart'; // Import ChatMessagesBloc

class ChatMessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool isCurrentUser;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
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
    final bool isRevoked = widget.message.withdrawFlag || widget.message.type == 'revoke';
    final alignment = widget.isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = widget.isCurrentUser
        ? Theme.of(context).primaryColor.withOpacity(0.9)
        : Theme.of(context).cardColor;
    final textColor = widget.isCurrentUser ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      alignment: alignment,
      child: Column(
        crossAxisAlignment: widget.isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Optional: Display message time (e.g., format widget.message.createTime)
          Text(
            DateFormat('HH:mm').format(widget.message.createTime),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onLongPress: () {
              if (!isRevoked) { // Don't show menu for revoked messages
                 _showActionMenu(context, Offset.zero);
              }
            },
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ]
              ),
              child: isRevoked
                  ? Text(
                      'Message revoked',
                      style: TextStyle(fontStyle: FontStyle.italic, color: textColor?.withOpacity(0.7)),
                    )
                  : _buildMessageContent(context, textColor),
            ),
          ),
          // Optional: Display status (sending, sent, failed, read)
           if (widget.isCurrentUser && !isRevoked) _buildStatusIndicator(context),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, Color? textColor) {
    switch (widget.message.type) {
      case 'text':
        return Text(widget.message.context, style: TextStyle(color: textColor));
      case 'image':
        return _buildImageContent(context);
      case 'audio':
        return _buildAudioContent(context, textColor);
      default:
        return Text('[Unsupported message type: ${widget.message.type}]', style: TextStyle(color: textColor, fontStyle: FontStyle.italic));
    }
  }

  Widget _buildImageContent(BuildContext context) {
     final heroTag = 'imagePreview_${widget.message.id}';
     return GestureDetector(
       onTap: () => _showImagePreview(context, widget.message.context),
       child: Hero(
         tag: heroTag,
         child: Container(
            constraints: const BoxConstraints(
               maxHeight: 200,
               maxWidth: 200,
            ),
           child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0), // Optional: round corners
              child: CachedNetworkImage(
                imageUrl: widget.message.context,
                placeholder: (context, url) => Container(
                   width: 150, height: 150, // Placeholder size
                   color: Colors.grey[300],
                   child: const Center(child: CircularProgressIndicator()),
                 ),
                errorWidget: (context, url, error) => Container(
                   width: 150, height: 150, // Error placeholder size
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

  Widget _buildAudioContent(BuildContext context, Color? textColor) {
    final iconColor = widget.isCurrentUser ? Colors.white : Theme.of(context).primaryColor;
    final progressColor = widget.isCurrentUser ? Colors.white70 : Theme.of(context).primaryColor.withOpacity(0.7);
    final baseColor = widget.isCurrentUser ? Colors.white38 : Theme.of(context).primaryColor.withOpacity(0.3);

    final String durationText = _duration != null ? _formatDuration(_duration!) : '--:--';
    final String positionText = _position != null ? _formatDuration(_position!) : '00:00';
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(
                 value: progress,
                 backgroundColor: baseColor,
                 valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                 minHeight: 2, // Make the progress bar thinner
               ),
              const SizedBox(height: 4),
              Text(
                '$positionText / $durationText',
                 style: TextStyle(fontSize: 12, color: textColor?.withOpacity(0.8)),
               ),
            ],
          ),
        ),
        // Optional: Add duration display or other info
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
      case MessageStatus.read: // Optional read status
        iconData = Icons.done_all;
        iconColor = Colors.blue; // Or your theme's read color
        break;
      // Default case or handle other statuses if needed
    }

    return Padding(
       padding: const EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0), // Adjust padding as needed
       child: Icon(iconData, size: iconSize, color: iconColor),
     );
   }

   void _showActionMenu(BuildContext context, Offset tapPosition) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final result = await showMenu(
      context: context,
      position: RelativeRect.fromRect(
          tapPosition & const Size(40, 40), // smaller rect, the touch area
          Offset.zero & overlay.size   // Bigger rect, the entire screen
      ),
      items: [
        if (widget.message.type == 'text')
          const PopupMenuItem<String>(value: 'copy', child: Text('复制')),
        // Only allow revoke/delete if it's the current user's message
        if (widget.isCurrentUser)
           const PopupMenuItem<String>(value: 'revoke', child: Text('撤回')),
        if (widget.isCurrentUser)
            const PopupMenuItem<String>(value: 'delete', child: Text('删除')),
      ],
      elevation: 8.0,
    );

    // Handle the selected action
    if (result == 'copy') {
      Clipboard.setData(ClipboardData(text: widget.message.context));
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已复制到剪贴板'), duration: Duration(seconds: 1)),
      );
    } else if (result == 'revoke') {
      // TODO: Implement revoke confirmation?
       context.read<ChatMessagesBloc>().add(RevokeMessageRequested(widget.message.id));
    } else if (result == 'delete') {
      // TODO: Implement delete confirmation?
      // FIX: Pass message ID as a list
      context.read<ChatMessagesBloc>().add(DeleteMessageRequested([widget.message.id]));
    }
  }

   String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
} 