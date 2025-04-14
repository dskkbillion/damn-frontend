import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart'; // To generate local message IDs

import '../../../domain/entities/message.dart';
import '../../../domain/entities/message_status.dart';
import '../../../domain/entities/message_type.dart';
import '../bloc/messages/chat_messages_bloc.dart';
import '../bloc/messages/chat_messages_event.dart';
import '../bloc/messages/chat_messages_state.dart';
import '../widgets/chat_input_field.dart'; // Needs to be created
import '../widgets/chat_message_list.dart'; // Needs to be created

/// 聊天详情页面
class ChatDetailPage extends StatefulWidget {
  final int chatId;
  final String chatPartnerName; // Keep simple name for AppBar
  // Remove currentUserId, should be obtainable globally via AuthBloc/Service
  // final int currentUserId; 

  const ChatDetailPage({
    super.key,
    required this.chatId,
    required this.chatPartnerName,
    // required this.currentUserId, // Removed
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _textController = TextEditingController();
  final Uuid _uuid = const Uuid();
  // TODO: Get current user ID from an Auth service/bloc
  final int _currentUserId = 10290; // Placeholder

  @override
  void initState() {
    super.initState();
    // TODO: Dispatch event to load messages for widget.chatId using Bloc
    // context.read<ChatMessagesBloc>().add(LoadMessages(widget.chatId));
    print("ChatDetailPage initialized for chatId: ${widget.chatId}");
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Create ChatMessagesBloc instance for this specific chat
      // Assuming GetIt is configured to provide a factory or similar for ChatMessagesBloc
      // OR manually provide dependencies if GetIt isn't used for Blocs.
       create: (context) => GetIt.instance<ChatMessagesBloc>(param1: widget.chatId)
         ..add(LoadMessages(widget.chatId)), // Initial event
      // Example manual creation if needed:
      // create: (context) => ChatMessagesBloc(
      //   getMessagesUseCase: GetIt.instance<GetMessagesUseCase>(),
      //   observeMessagesUseCase: GetIt.instance<ObserveMessagesUseCase>(),
      //   sendMessageUseCase: GetIt.instance<SendMessageUseCase>(),
      //   revokeMessageUseCase: GetIt.instance<RevokeMessageUseCase>(),
      // )..add(LoadMessages(widget.chatId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.chatPartnerName),
          actions: [
            IconButton(
              icon: const Icon(Icons.receipt_long_outlined),
              onPressed: () {
                print("View Order Details pressed for chatId: ${widget.chatId}");
                // TODO: Implement navigation/logic
              },
              tooltip: '查看订单',
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                 print("More Chat Options pressed for chatId: ${widget.chatId}");
                _showChatOptionsMenu(context);
                 // TODO: Implement options menu
              },
              tooltip: '聊天选项',
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatMessagesBloc, ChatMessagesState>(
                builder: (context, state) {
                  // Handle initial loading
                  if (state is MessagesInitial || (state is MessagesLoading && state.messages.isEmpty)) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Handle initial error
                  if (state is MessagesError && state.messages.isEmpty) {
                    return Center(
                      child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Text('加载消息失败: ${state.failure.message}'),
                           const SizedBox(height: 16),
                           ElevatedButton(
                             onPressed: () => context.read<ChatMessagesBloc>().add(LoadMessages(widget.chatId)),
                             child: const Text('重试'),
                           )
                         ],
                      )
                    );
                  }
                   // Display messages if available (covers Loaded, Loading with data, Error with data)
                   return ChatMessageList(
                      messages: state.messages,
                      currentUserId: _currentUserId, // Provide current user ID
                      onRevoke: (messageId) {
                          print("UI requesting revoke for messageId: $messageId");
                          context.read<ChatMessagesBloc>().add(RevokeMessage(messageId));
                      },
                      onRetry: (failedMessage) {
                          print("UI requesting retry for localId: ${failedMessage.localId}");
                           context.read<ChatMessagesBloc>().add(RetrySendMessage(failedMessage));
                      },
                   );
                },
              ),
            ),
            // Listener for non-UI effects like showing snackbars on error
            BlocListener<ChatMessagesBloc, ChatMessagesState>(
              listener: (context, state) {
                 if (state is MessagesError && state.messages.isNotEmpty) {
                    // Show error snackbar only if there was already data displayed
                    ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text('发生错误: ${state.failure.message}')),
                    );
                 }
                 // Can add other listeners here (e.g., message sent confirmation)
              },
              child: const SizedBox.shrink(), // Listener doesn't build UI
            ),
            ChatInputField(
              controller: _textController,
              onSendPressed: () {
                final text = _textController.text.trim();
                if (text.isNotEmpty) {
                  final localId = _uuid.v4();
                  final newMessage = Message(
                     // Server will assign ID
                     id: 0,
                     localId: localId,
                     chatId: widget.chatId,
                     senderId: _currentUserId,
                     recipientId: 0, // TODO: Determine recipient ID correctly
                     context: text,
                     msgType: MessageType.text,
                     status: MessageStatus.sending, // Initial status handled by Bloc
                     createTime: DateTime.now(), // Client time, server might override
                      withdrawFlag: false,
                      senderDelFlag: false,
                      receiverDelFlag: false,
                      // senderName: // Get from Auth/User service
                      // senderAvatar: // Get from Auth/User service
                  );
                  print("UI sending message with localId: $localId");
                  context.read<ChatMessagesBloc>().add(SendMessage(newMessage));
                  _textController.clear();
                }
              },
              onAttachmentPressed: () {
                 print('Attachment button pressed');
                // TODO: Implement attachment selection (image, file, etc.)
                // This would likely show a picker, get a File, create a Message
                // object with type image/file and the file path/data, then dispatch
                // a SendMessage event to the Bloc.
                 final localId = _uuid.v4();
                 final placeholderFileMessage = Message(
                    id: 0, localId: localId, chatId: widget.chatId, senderId: _currentUserId,
                    recipientId: 0, context: '[文件占位符]', msgType: MessageType.file,
                    status: MessageStatus.sending, createTime: DateTime.now(),
                    withdrawFlag: false, senderDelFlag: false, receiverDelFlag: false,
                    extra: { 'filePath': '/path/to/dummy/file.pdf' } // Example extra data
                 );
                 // context.read<ChatMessagesBloc>().add(SendMessage(placeholderFileMessage));
              },
              onVoiceModeChanged: (isVoice) {
                 print("Voice mode changed: $isVoice");
                 // Handle UI changes if needed
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    // BlocProvider automatically handles closing the Bloc
    super.dispose();
  }

   void _showChatOptionsMenu(BuildContext context) {
    // Placeholder implementation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('聊天选项'),
        content: const Text('选项菜单待实现'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('关闭'))],
      ),
    );
  }
} 