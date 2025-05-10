import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/ai_chat/ai_chat_bloc.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/entities/ai_chat_message_entity.dart';
import 'chat_message_bubble.dart';

class ChatMessageList extends StatelessWidget {
  const ChatMessageList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiChatBloc, AiChatState>(
      builder: (context, state) {
        // --- Handle Loading/Error/Empty States ---
        if (state.status == AiChatStatus.loadingHistory && state.messages.isEmpty) {
            return const Center(child: CircularProgressIndicator());
        }
         if (state.status == AiChatStatus.historyLoadFailure && state.messages.isEmpty) {
             return Center(
                 child: Padding(
                     padding: const EdgeInsets.all(16.0),
                     child: Text("加载历史记录失败: ${state.errorMessage ?? '未知错误'}", 
                                style: const TextStyle(color: Colors.red)),
                 )
             );
         }
          // Show empty message only if not loading and not currently streaming
          if (state.messages.isEmpty && 
              state.status != AiChatStatus.streamingResponse && 
              state.status != AiChatStatus.loadingHistory) {
             return const Center(
                 child: Text("暂无消息，开始聊天吧！")
             );
         }

        // --- Build Message List ---
        // Use ScrollController for potential programmatic scrolling
        final ScrollController scrollController = ScrollController();
        // Optional: Scroll to bottom when new messages arrive
        // Consider using BlocListener outside the builder for this

        return ListView.builder(
          controller: scrollController, 
          // reverse: true, // Keep reverse true for bottom-up display
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          itemCount: state.messages.length + (state.status == AiChatStatus.streamingResponse ? 1 : 0),
          itemBuilder: (context, index) {
            
            // --- Streaming Placeholder Item ---
            if (state.status == AiChatStatus.streamingResponse && index == state.messages.length) { 
              // Create a temporary entity for the streaming bubble
              final streamingPlaceholder = AiChatMessageEntity(
                // Use a consistent temporary ID if needed for keys
                messageId: 'streaming_placeholder', 
                content: state.streamingResponseText, // Content is the currently streamed text
                sender: MessageSender.ai, // Assume streaming is always from AI
                timestamp: DateTime.now(), // Timestamp might not be relevant here
                // Use the current conversation ID from state
                conversationId: state.selectedConversationId ?? -1, 
                 // fileUrls: state.streamingFileUrls, // Pass if tracking streaming files
                 // relatedServices: state.streamingRelatedServices, // Pass if tracking streaming services
              );
              return ChatMessageBubble(
                key: const ValueKey('streaming_bubble'), // Add a key for stability
                message: streamingPlaceholder,
                isStreaming: true, // Explicitly pass the streaming flag
                 // Pass down the tap handler if needed
                 // onRelatedServiceTap: (service) { ... }, 
              );
            }

            // --- Regular Message Item ---
            final message = state.messages[index];
            return ChatMessageBubble(
              key: ValueKey(message.messageId), // Use messageId as key
              message: message,
              // isStreaming is false by default
               // Pass down the tap handler if needed
               // onRelatedServiceTap: (service) { ... },
            );
          },
        );
      },
    );
  }

  // --- Move _buildMessageItem INSIDE the class --- 
  Widget _buildMessageItem(BuildContext context, AiChatMessageEntity message, {bool isStreaming = false}) {
    bool isUser = message.sender == MessageSender.user;
    
    // Determine background color based on sender and streaming state
    Color bubbleColor;
    if (isUser) {
        bubbleColor = Colors.blue[100]!;
    } else if (isStreaming) {
        bubbleColor = Colors.grey[200]!; // Slightly different grey for streaming
    } else {
        bubbleColor = Colors.grey[300]!;
    }

    return Align(
      // Align user messages to the right, AI/System messages to the left
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        constraints: BoxConstraints(
           maxWidth: MediaQuery.of(context).size.width * 0.75 // Max width for bubbles
        ),
        child: Column(
           crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
           mainAxisSize: MainAxisSize.min, // Prevent column taking full width
           children: [
              // --- Display Image Attachment (if any) ---
              if (message.fileUrls?.isNotEmpty ?? false)
                 Padding(
                   padding: const EdgeInsets.only(bottom: 8.0),
                   child: ClipRRect( // Clip image corners
                     borderRadius: BorderRadius.circular(8.0),
                     child: Image.network( 
                        message.fileUrls!.first,
                        height: 150, 
                        fit: BoxFit.cover,
                        // Add loading and error builders for robustness
                        loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                                height: 150,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(
                                   strokeWidth: 2,
                                   value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                ),
                            );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                            height: 150,
                            color: Colors.grey[200],
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image, color: Colors.red, size: 50),
                        ), 
                     ), 
                   ), 
                 ),
              // --- Display Message Content (with potential cursor for streaming) ---
               Row(
                 mainAxisSize: MainAxisSize.min,
                 crossAxisAlignment: CrossAxisAlignment.end, // Align cursor properly
                 children: [
                   Flexible( // Allow text to wrap
                     child: Text(
                        // Show ellipsis if streaming text is empty initially
                        (isStreaming && message.content.isEmpty) ? "..." : message.content,
                        style: const TextStyle(fontSize: 15.0, color: Colors.black87),
                      ),
                   ),
                    // Add blinking cursor only if streaming
                   if (isStreaming)
                      const _BlinkingCursor(), // Use the new stateful widget
                 ],
               ),
              // --- Display Timestamp (Optional) ---
              if (message.timestamp != null && !isStreaming) // Don't show timestamp for streaming msg
               Padding(
                 padding: const EdgeInsets.only(top: 4.0),
                 child: Text(
                  // Basic HH:mm format. Requires intl package for better localization.
                  message.timestamp!.toIso8601String().substring(11, 16), 
                  style: TextStyle(fontSize: 10.0, color: Colors.grey[600]),
                 ),
               )
           ],
        ),
      ),
    );
  }
}

// --- Stateful Widget for the Blinking Cursor Animation ---

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true); // Make it blink continuously
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: const Text(
         '|', 
         style: TextStyle(fontSize: 15.0, color: Colors.black87, fontWeight: FontWeight.bold)
      ),
    );
  }
} 