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
    // Updated bubble colors based on frontend.md alignment
    final bubbleColor = isCurrentUser
        ? const Color(0xFFC9E6FF) // Light blue for current user
        : Colors.white;          // White for opponent
    // Consistent text color for both bubble types
    final textColor = Colors.black87;

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
          borderRadius: BorderRadius.circular(16.0), // Keep consistent radius
        ),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7, // Keep max width constraint
        ),
        // Pass the determined text color to the content builder
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
          if (isCurrentUser) const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, Color textColor, bool isCurrentUser, bool isRevoked, String messageContext) {
    if (isRevoked) {
        return Text(
          '消息已撤回',
          // Use a more neutral grey for revoked message text
          style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
        );
     } else if (widget.message.type == 'text') {
       // Use the passed textColor
       return Text(messageContext, style: TextStyle(color: textColor, fontSize: 15)); // Ensure appropriate font size
     } else if (widget.message.type == 'image') {
       return _buildImageContent(context, messageContext);
     } else if (widget.message.type == 'audio') {
       // Pass textColor and isCurrentUser to audio content
       return _buildAudioContent(context, textColor, isCurrentUser, messageContext);
     } else {
       // Keep handling for unsupported types
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
           // Ensure image clip radius matches or is slightly less than bubble radius
           child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0), // Slightly smaller radius for content
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

  Widget _buildAudioContent(BuildContext context, Color iconAndTextColor, bool isCurrentUser, String audioUrl) {
    // Determine icon color based on user (can be same as text or specific)
    final Color effectiveIconColor = isCurrentUser ? Colors.black54 : Colors.black54; // Example: use greyish for both
    final Color effectiveTextColor = isCurrentUser ? Colors.black54 : Colors.black54; // Example: use greyish for both

    return Row(
      mainAxisSize: MainAxisSize.min, // Prevent Row from expanding unnecessarily
      children: [
        IconButton(
          icon: Icon(
            _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
            color: effectiveIconColor,
            size: 28, // Adjust size as needed
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(), // Remove extra padding around icon
          onPressed: _playPauseAudio,
          tooltip: _isPlaying ? '暂停' : '播放',
        ),
        const SizedBox(width: 8), // Space between icon and duration
        // TODO: Add waveform visualization here later
        Text(
          _formatDuration(_duration ?? Duration.zero), // Display formatted duration
          style: TextStyle(color: effectiveTextColor, fontSize: 14),
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
} 