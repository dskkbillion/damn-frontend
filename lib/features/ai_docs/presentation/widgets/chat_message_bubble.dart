import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // Import audioplayers
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
    if (_isAudioMessage && _audioUrl != null) {
      _initAudioPlayer();
    }
  }

  void _initAudioPlayer() {
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
    _audioPlayer!.setSourceUrl(_audioUrl!); 
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
    // If player is not initialized or disposed, re-initialize
     if (_audioPlayer == null || _playerState == PlayerState.stopped || _playerState == PlayerState.completed) {
       _initAudioPlayer(); // Re-initialize if needed (e.g., after completion)
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

    Color bubbleColor = isUser
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.secondaryContainer;

    // Use surfaceVariant for AI streaming text messages
    if (!isUser && widget.isStreaming && widget.message.messageType == MessageType.text) {
       bubbleColor = Theme.of(context).colorScheme.surfaceVariant;
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
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
                 _buildImageContent(context) // Still placeholder
              else if (widget.message.messageType == MessageType.audio)
                 _buildAudioContent(context, isUser) // Use the new stateful player
              else // Default or unknown type
                 const Text("[Unsupported Message Type]"),

              // --- Display Timestamp (Optional) ---
              // Don't show timestamp for streaming text message
              if (widget.message.timestamp != null && !(widget.isStreaming && widget.message.messageType == MessageType.text))
               Padding(
                 padding: const EdgeInsets.only(top: 4.0),
                 child: Text(
                    _formatTimestamp(widget.message.timestamp!), 
                    style: TextStyle(
                        fontSize: 10.0, 
                        color: isUser 
                           ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7) 
                           : Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.7),
                    ),
                 ),
               )
           ],
        ),
      ),
    );
  }

  // --- Text content builder (uses widget.message and widget.isStreaming) ---
  Widget _buildTextContent(BuildContext context, bool isUser) {
     return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Text(
               (widget.isStreaming && widget.message.content.isEmpty) ? "..." : widget.message.content,
                style: TextStyle(
                  fontSize: 15.0, 
                  color: isUser 
                      ? Theme.of(context).colorScheme.onPrimaryContainer 
                      : Theme.of(context).colorScheme.onSecondaryContainer,
                ),
             ),
          ),
          if (widget.isStreaming)
              BlinkingCursor( 
                cursorColor: isUser 
                      ? Theme.of(context).colorScheme.onPrimaryContainer 
                      : Theme.of(context).colorScheme.onSecondaryContainer,
              ),
        ],
      );
  }

  // --- Image content builder (uses widget.message) ---
  Widget _buildImageContent(BuildContext context) {
     if (widget.message.fileUrls?.isNotEmpty ?? false) {
       return Text("[Image: ${widget.message.fileUrls!.first}]"); 
     } else {
       return Text("[Missing Image URL]");
     }
  }

  // --- Audio player builder (uses state variables and widget.message) ---
  Widget _buildAudioContent(BuildContext context, bool isUser) {
     final iconColor = isUser 
                      ? Theme.of(context).colorScheme.onPrimaryContainer 
                      : Theme.of(context).colorScheme.onSecondaryContainer;
    
     final url = _audioUrl;
     if (url == null || _audioPlayer == null) {
       // Show error or loading state if URL is missing or player failed init
       return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
             Icon(Icons.error_outline, color: Colors.red, size: 20),
             const SizedBox(width: 8),
             Text("[Audio Unavailable]", style: TextStyle(color: iconColor)),
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

    return Row(
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