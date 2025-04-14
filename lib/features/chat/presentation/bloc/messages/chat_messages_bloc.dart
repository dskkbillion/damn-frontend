import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../domain/entities/failure.dart';
import '../../../../domain/entities/message.dart';
import '../../../../domain/entities/message_status.dart';
import '../../../../domain/usecases/get_messages_usecase.dart';
import '../../../../domain/usecases/observe_messages_usecase.dart';
import '../../../../domain/usecases/revoke_message_usecase.dart';
import '../../../../domain/usecases/send_message_usecase.dart';

part 'chat_messages_event.dart';
part 'chat_messages_state.dart';

/// 管理特定会话消息状态的 Bloc
class ChatMessagesBloc extends Bloc<ChatMessagesEvent, ChatMessagesState> {
  final GetMessagesUseCase _getMessagesUseCase;
  final ObserveMessagesUseCase _observeMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final RevokeMessageUseCase _revokeMessageUseCase;
  // TODO: Inject ChatSessionsBloc or a way to notify session updates
  
  StreamSubscription<Either<Failure, List<Message>>>? _messagesSubscription;
  int? _currentChatId; // Keep track of the current chat being viewed

  ChatMessagesBloc({
    required GetMessagesUseCase getMessagesUseCase,
    required ObserveMessagesUseCase observeMessagesUseCase,
    required SendMessageUseCase sendMessageUseCase,
    required RevokeMessageUseCase revokeMessageUseCase,
  })  : _getMessagesUseCase = getMessagesUseCase,
        _observeMessagesUseCase = observeMessagesUseCase,
        _sendMessageUseCase = sendMessageUseCase,
        _revokeMessageUseCase = revokeMessageUseCase,
        super(MessagesInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<_MessagesUpdated>(_onMessagesUpdated);
    on<NewMessageReceived>(_onNewMessageReceived); 
    on<SendMessage>(_onSendMessage);
    on<RetrySendMessage>(_onRetrySendMessage);
    on<_MessageSendStatusUpdated>(_onMessageSendStatusUpdated);
    on<RevokeMessage>(_onRevokeMessage);
    on<_MessageRevoked>(_onMessageRevoked);
    on<_MessagesErrorEvent>(_onMessagesErrorEvent);
  }

  void _startObservingMessages(int chatId) {
    if (chatId == _currentChatId && _messagesSubscription != null) {
      return; // Already observing this chat
    }
    _messagesSubscription?.cancel();
    _currentChatId = chatId;

    _messagesSubscription = _observeMessagesUseCase(chatId).listen(
      (eitherResult) {
        eitherResult.fold(
          (failure) => add(const _MessagesErrorEvent()),
          (messages) => add(_MessagesUpdated(messages)),
        );
      },
      onError: (_) => add(const _MessagesErrorEvent()),
    );
  }

  Future<void> _onLoadMessages(
      LoadMessages event, Emitter<ChatMessagesState> emit) async {
    
     // Start observing this chat if not already
     _startObservingMessages(event.chatId);

     // Show loading state, keeping previous messages if available
     emit(MessagesLoading(state.messages));
    
     // Fetch initial batch of messages
     // TODO: Handle pagination if implemented
    final result = await _getMessagesUseCase(event.chatId);

    // Observer should pick up changes, but handle immediate failure
     result.fold(
        (failure) {
           emit(MessagesError(failure, state.messages));
        },
        (messages) {
           // Initial load successful, rely on observer to emit MessagesLoaded
           // If observer is slow, we might stay in Loading briefly
           // Or emit MessagesLoaded directly? Let's rely on observer for consistency.
           // emit(MessagesLoaded(messages));
        }
     );
  }

  void _onMessagesUpdated(_MessagesUpdated event, Emitter<ChatMessagesState> emit) {
     // Sort messages by timestamp (oldest first for display)
     final sortedMessages = List<Message>.from(event.messages);
     sortedMessages.sort((a, b) {
       final timeA = a.createTime ?? DateTime.fromMillisecondsSinceEpoch(0);
       final timeB = b.createTime ?? DateTime.fromMillisecondsSinceEpoch(0);
       return timeA.compareTo(timeB); // Ascending order
     });
     emit(MessagesLoaded(sortedMessages));
  }

  // Handle a single new message (e.g., from WebSocket outside the main observer)
   void _onNewMessageReceived(NewMessageReceived event, Emitter<ChatMessagesState> emit) {
      // Only add if it belongs to the currently viewed chat
      if (event.message.chatId == _currentChatId) {
         final currentMessages = List<Message>.from(state.messages);
         // Avoid duplicates if observer already added it
         if (!currentMessages.any((m) => m.id == event.message.id || m.localId == event.message.localId)) {
             currentMessages.add(event.message);
             // Re-sort may not be strictly necessary if always adding to end, but safer
              currentMessages.sort((a, b) {
                 final timeA = a.createTime ?? DateTime.fromMillisecondsSinceEpoch(0);
                 final timeB = b.createTime ?? DateTime.fromMillisecondsSinceEpoch(0);
                 return timeA.compareTo(timeB); 
              });
             emit(MessagesLoaded(currentMessages));
         }
      } else {
         // TODO: If message is for another chat, maybe notify ChatSessionsBloc to update unread count?
         print("Received message for a different chat: ${event.message.chatId}");
      }
   }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatMessagesState> emit) async {
     // Optimistic UI update: Add message with 'sending' status
     final optimisticMessage = event.message.copyWith(status: MessageStatus.sending);
     final updatedMessages = List<Message>.from(state.messages)..add(optimisticMessage);
     emit(MessagesLoaded(updatedMessages)); // Assume MessagesLoaded or similar state

     // Call the use case to send the message
     final result = await _sendMessageUseCase(event.message);

     // Update status based on result
     result.fold(
       (failure) {
         // Send failed
         add(_MessageSendStatusUpdated(localId: event.message.localId!, status: MessageStatus.failed));
         print("Failed to send message (${event.message.localId}): ${failure.message}");
       },
       (sentMessage) {
          // Send succeeded
         add(_MessageSendStatusUpdated(
              localId: event.message.localId!, 
              status: MessageStatus.sent, // Or delivered depending on API response meaning
              serverId: sentMessage.id,
              createTime: sentMessage.createTime // Use server time if available
            ));
          // TODO: Notify ChatSessionsBloc about the new message for session update
       }
     );
  }

   Future<void> _onRetrySendMessage(RetrySendMessage event, Emitter<ChatMessagesState> emit) async {
       // Find the message by localId and update its status to sending
       final List<Message> currentMessages = List.from(state.messages);
       final messageIndex = currentMessages.indexWhere((m) => m.localId == event.failedMessage.localId);

       if (messageIndex == -1) return; // Message not found, should not happen

       final messageToRetry = currentMessages[messageIndex].copyWith(status: MessageStatus.sending);
       currentMessages[messageIndex] = messageToRetry;
       emit(MessagesLoaded(currentMessages)); // Show sending status

      // Re-call the send use case
       final result = await _sendMessageUseCase(messageToRetry);

       // Update status based on result
       result.fold(
         (failure) {
           add(_MessageSendStatusUpdated(localId: messageToRetry.localId!, status: MessageStatus.failed));
           print("Retry failed for message (${messageToRetry.localId}): ${failure.message}");
         },
         (sentMessage) {
           add(_MessageSendStatusUpdated(
                localId: messageToRetry.localId!, 
                status: MessageStatus.sent,
                serverId: sentMessage.id,
                createTime: sentMessage.createTime
              ));
             // TODO: Notify ChatSessionsBloc 
         }
       );
   }



  void _onMessageSendStatusUpdated(
      _MessageSendStatusUpdated event, Emitter<ChatMessagesState> emit) {
    final updatedMessages = state.messages.map((message) {
      if (message.localId == event.localId) {
        return message.copyWith(
            status: event.status,
            id: event.serverId ?? message.id, // Update ID if server provided it
            createTime: event.createTime ?? message.createTime // Update time if server provided it
        );
      }
      return message;
    }).toList();
    emit(MessagesLoaded(updatedMessages));
  }

  Future<void> _onRevokeMessage(
      RevokeMessage event, Emitter<ChatMessagesState> emit) async {
      // No optimistic UI for revoke? Or show a temporary "revoking..." state?
      // Let's perform the action first.
      
      final result = await _revokeMessageUseCase(event.messageId);
      
      result.fold(
         (failure) {
            print("Failed to revoke message ${event.messageId}: ${failure.message}");
             // TODO: Show error to user (e.g., snackbar)
             add(_MessageRevoked(event.messageId, success: false)); // Notify internally
         },
         (_) {
             print("Revoke successful for message ${event.messageId} (API)");
             add(_MessageRevoked(event.messageId, success: true)); // Notify internally
            // TODO: Notify ChatSessionsBloc that the last message might have changed
         }
      );
  }

  void _onMessageRevoked(_MessageRevoked event, Emitter<ChatMessagesState> emit) {
     if (!event.success) return; // Do nothing if revoke failed

     final updatedMessages = state.messages.map((message) {
        if (message.id == event.messageId) {
           // Mark the message as revoked
           return message.copyWith(withdrawFlag: true, msgType: MessageType.system); // Optionally change type
        }
        return message;
     }).toList();
     emit(MessagesLoaded(updatedMessages));
  }

  void _onMessagesErrorEvent(
      _MessagesErrorEvent event, Emitter<ChatMessagesState> emit) {
      // Handle errors from the observer stream
      if (state is! MessagesLoaded) { // Only transition to error state if no data loaded yet
         emit(MessagesError(const GenericFailure("Failed to observe messages"), state.messages));
      } else {
         print("Error observing messages, but keeping existing data displayed.");
          // TODO: Optionally show a non-blocking error indicator to the user
      }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _currentChatId = null;
    return super.close();
  }
} 