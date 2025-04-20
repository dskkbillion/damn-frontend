import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart'; 
import 'package:dartz/dartz.dart'; 
import 'package:flutter/material.dart'; // For @immutable
import 'package:intl/intl.dart'; // If using date formatting inside bloc

// --- Use package imports --- 
// Domain Entities (Required by State/Event parts & Bloc logic)
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart'; 
import 'package:dskk_flutter_refactor/features/chat/domain/entities/participant.dart'; 
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_room.dart'; // Needed for GetChatRoomDetails return type
// Domain UseCases (Required by Bloc logic)
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/get_message_list.dart'; 
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/send_message.dart'; 
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/revoke_message.dart'; 
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/delete_chat_message.dart'; // Import DeleteChatMessage
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/get_chat_room_details.dart'; 
// Auth Feature Dependencies (Required by Bloc logic)
import 'package:dskk_flutter_refactor/features/auth/domain/entities/user.dart'; // Corrected import
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_user_repository.dart'; // Corrected import
// Data Layer Dependencies (for WebSocket)
import 'package:dskk_flutter_refactor/features/chat/data/datasources/i_chat_web_socket_data_source.dart'; // Import WS DataSource Interface
import 'package:dskk_flutter_refactor/features/chat/data/datasources/chat_web_socket_data_source.impl.dart'; // For ConnectionStatus enum
import 'package:dskk_flutter_refactor/features/chat/data/models/chat_message_dto.dart'; // For ChatMessageDto used in event
// Core Dependencies (Required by Bloc logic/Error handling)
import 'package:dskk_flutter_refactor/core/error/failures.dart'; 
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart'; 
// ---------------------------

part 'chat_messages_event.dart';
part 'chat_messages_state.dart';

class ChatMessagesBloc extends Bloc<ChatMessagesEvent, ChatMessagesState> {
  final int chatId;
  final GetMessageList getMessageList;
  final SendMessage sendMessage;
  final RevokeMessage revokeMessage;
  final GetChatRoomDetails getChatRoomDetails;
  final DeleteChatMessage deleteChatMessage;
  final IUserRepository userRepository;
  final IChatWebSocketDataSource webSocketDataSource;

  User? _currentUser;
  Participant? _opponent;
  StreamSubscription? _webSocketMessageSubscription;
  StreamSubscription? _webSocketStatusSubscription;
  String? _token;

  ChatMessagesBloc({
    required this.chatId,
    required this.getMessageList,
    required this.sendMessage,
    required this.revokeMessage,
    required this.getChatRoomDetails,
    required this.userRepository,
    required this.deleteChatMessage,
    required this.webSocketDataSource,
  }) : super(ChatMessagesInitial()) {
    on<LoadChatMessages>(_onLoadChatMessages);
    on<SendMessageRequested>(_onSendMessageRequested);
    on<_MessageReceived>(_onInternalMessageReceived);
    on<RevokeMessageRequested>(_onRevokeMessageRequested);
    on<DeleteMessageRequested>(_onDeleteMessageRequested);
  }

  Future<void> _onLoadChatMessages(
    LoadChatMessages event,
    Emitter<ChatMessagesState> emit
  ) async {
     emit(const ChatMessagesLoading());
    try {
      // 1. Fetch user and token (token logic remains hardcoded for now)
      final userResult = await userRepository.getCurrentUser();
      _currentUser = userResult.getOrElse(() => throw Exception("Failed to get current user"));
      _token = 'eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjFjYjlhZmYyLThjOTktNGMwYy05YTk5LWQ2NjdhYjVkMDY4NSJ9.I7cLrFM0qkBF9D-r90fowh3i9xO5v_39Oafl_K7hXdxJ2pQ1Yd9_PCd_C_M6za_0Y8YHt0bZRVb01am-F8r9ew';
      String commonUserId = '10315';

      if (_currentUser == null || _token == null) {
         throw Exception("User or token not available");
      }
      print("[ChatMessagesBloc] Using commonUserId: $commonUserId, Token: ${_token!.substring(0, 10)}...");

      // 2. Fetch initial messages and opponent details concurrently
      final results = await Future.wait([
        getMessageList(GetMessageListParams(chatId: event.chatId)),
        getChatRoomDetails(GetChatRoomDetailsParams(chatId: event.chatId)),
      ]);

      // FIX: Correctly define and access results with proper types
      final messageResult = results[0] as Either<Failure, List<ChatMessage>>;
      final roomDetailsResult = results[1] as Either<Failure, ChatRoom>;

      // 3. FIX: Process results with correct nested fold structure
      await messageResult.fold(
        (failure) async => emit(ChatMessagesError('Failed to load messages: ${failure.message}')),
        (messages) async {
          await roomDetailsResult.fold(
            (failure) async => emit(ChatMessagesError('Failed to load room details: ${failure.message}')),
            (roomDetails) async {
              // Determine the opponent
              // Use the correct ChatRoom entity structure (participant1, participant2)
               _opponent = roomDetails.getOpponent(_currentUser!.id); // Use getter from entity
              
              print("[ChatMessagesBloc] Messages and details loaded successfully. Opponent: ${_opponent?.nickName} (${_opponent?.id})");

              // FIX: Emit ChatMessagesLoaded with currentUserId
              emit(ChatMessagesLoaded(
                messages: messages, // Assuming API returns newest first or reversed in UseCase/Repo
                opponent: _opponent!, // Assert not null after successful load
                currentUserId: _currentUser!.id, // Provide the required ID
              ));

              // 4. Connect to WebSocket AFTER successfully loading and emitting initial state
              print("[ChatMessagesBloc] Connecting to WebSocket with REAL commonUserId: $commonUserId");
              // FIX: Remove await from void function call inside awaited fold
              _connectAndSubscribeWebSocket(commonUserId, _token!); 
            },
          );
        },
      );

    } catch (e) {
      emit(ChatMessagesError('An error occurred: ${e.toString()}'));
      print("[ChatMessagesBloc] Error loading chat: $e");
    }
  }

  Future<void> _onSendMessageRequested(
    SendMessageRequested event,
    Emitter<ChatMessagesState> emit,
  ) async {
    if (state is! ChatMessagesLoaded) return; // Can only send when loaded
    final loadedState = state as ChatMessagesLoaded;

    if (_currentUser == null) {
      emit(loadedState.copyWith(error: 'Cannot send message: User not loaded'));
      return;
    }

    // 1. Create optimistic message
    final optimisticMessage = ChatMessage(
      id: Random().nextInt(1000000) + 1000000, // Temporary client-side ID
      chatId: chatId,
      senderId: _currentUser!.id, // Use current user ID
      memberId: _currentUser!.type == 'MEMBER' ? _currentUser!.id : loadedState.opponent.id, // Determine member/doctor ID based on type
      doctorId: _currentUser!.type == 'DOCTOR' ? _currentUser!.id : loadedState.opponent.id,
      context: event.type == 'text' ? event.text! : (event.file?.path ?? 'Sending file...'), // Use event fields correctly
      type: event.type, // Use event field correctly
      createTime: DateTime.now(),
      withdrawFlag: false,
      status: MessageStatus.sending, // Initial status
    );

    // 2. Emit state with optimistic message
    emit(loadedState.copyWith(
      messages: [optimisticMessage, ...loadedState.messages], // Add to the top
      error: null // Clear error using corrected copyWith
    ));

    // 3. Prepare Use Case parameters
    final params = SendMessageParams(
      message: optimisticMessage.copyWith(id: 0), // Use a temp ID or 0 for API call if backend assigns ID
      file: event.file, // Use event field correctly
    );

    // 4. Call Use Case
    final result = await sendMessage(params);

    // 5. Handle result and update state
    if (state is! ChatMessagesLoaded) return; // State might have changed
    final currentState = state as ChatMessagesLoaded;

    result.fold(
      (failure) {
        // Update message status to failed
        final updatedMessages = currentState.messages.map((msg) {
          return msg.id == optimisticMessage.id
              ? msg.copyWith(status: MessageStatus.failed)
              : msg;
        }).toList();
        emit(currentState.copyWith(
          messages: updatedMessages,
          error: failure.message, // Use corrected copyWith
        ));
        print("Failed to send message: ${failure.message}");
      },
      (sentMessage) {
        // Replace optimistic message with confirmed message from server
        final updatedMessages = currentState.messages.map((msg) {
          // Use optimistic ID for matching
          return msg.id == optimisticMessage.id
              ? sentMessage.copyWith(status: MessageStatus.sent) // Ensure status is sent
              : msg;
        }).toList();
        emit(currentState.copyWith(
          messages: updatedMessages,
          error: null, // Use corrected copyWith to clear error
        ));
         print("Message sent successfully: ${sentMessage.id}");
      },
    );
  }

  void _onInternalMessageReceived(_MessageReceived event, Emitter<ChatMessagesState> emit) {
    if (state is ChatMessagesLoaded && _currentUser != null) {
      final currentState = state as ChatMessagesLoaded;
      final ChatMessageDto messageDto = event.messageDto; // Correct: _MessageReceived contains DTO

      print("[Bloc] Received message via WebSocket: ${messageDto.id}");

      // Convert DTO to Entity
      try {
        final messageEntity = messageDto.toEntity(
          currentUserId: _currentUser!.id,
          senderId: messageDto.memberId == _currentUser!.id ? messageDto.memberId! :
                    messageDto.doctorId == _currentUser!.id ? messageDto.doctorId! :
                    (messageDto.memberId ?? messageDto.doctorId ?? 0)
        );

        if (!currentState.messages.any((m) => m.id == messageEntity.id)) {
          emit(currentState.copyWith(
            messages: [messageEntity.copyWith(status: MessageStatus.sent), ...currentState.messages],
            error: null
          ));
        } else {
           print("[Bloc] Received duplicate message ID via WebSocket: ${messageEntity.id}");
        }
      } catch (e) {
         print("[Bloc] Error converting WebSocket DTO to Entity: $e");
         emit(currentState.copyWith(error: "Error processing incoming message"));
      }
    }
  }

  Future<void> _onRevokeMessageRequested(
    RevokeMessageRequested event,
    Emitter<ChatMessagesState> emit,
  ) async {
     if (state is! ChatMessagesLoaded) return;
    final loadedState = state as ChatMessagesLoaded;

    // Optimistic update
    final updatedMessagesOptimistic = loadedState.messages.map((msg) {
      // FIX: Use withdrawFlag and type for revoked status
      return msg.id == event.messageId ? msg.copyWith(withdrawFlag: true, type: 'revoke', status: MessageStatus.sent) : msg;
    }).toList();
    emit(loadedState.copyWith(messages: updatedMessagesOptimistic, error: null));

    final result = await revokeMessage(RevokeMessageParams(messageId: event.messageId));

     if (state is! ChatMessagesLoaded) return; // Re-check state
     final currentState = state as ChatMessagesLoaded;

    result.fold(
      (failure) {
        // Revert optimistic update (complex, just show error)
         final revertedMessages = currentState.messages.map((msg) {
           // Find the original message? For now, just keep the revoked UI but show error.
           if (msg.id == event.messageId) {
                // Maybe revert UI? msg.copyWith(withdrawFlag: false, type: originalType?)
           }
           return msg;
         }).toList();
        emit(currentState.copyWith(
             messages: revertedMessages, // Or revert fully if possible
             error: 'Failed to revoke: ${failure.message}'
             ));
         print("Failed to revoke message: ${failure.message}");
      },
      (_) {
         print("Message revoked successfully: ${event.messageId}");
          emit(currentState.copyWith(error: null));
      },
    );
  }

   Future<void> _onDeleteMessageRequested(
    DeleteMessageRequested event,
    Emitter<ChatMessagesState> emit,
  ) async {
     if (state is! ChatMessagesLoaded) return;
    final loadedState = state as ChatMessagesLoaded;

    // Optimistic update
     final List<ChatMessage> updatedMessagesOptimistic = loadedState.messages
        .where((msg) => !event.messageIds.contains(msg.id))
        .toList();
    emit(loadedState.copyWith(messages: updatedMessagesOptimistic, error: null));

    // FIX: Use correct params name `messageIds`
    final result = await deleteChatMessage(DeleteChatMessageParams(messageIds: event.messageIds, chatId: chatId));

     if (state is! ChatMessagesLoaded) return; // Re-check state
     final currentState = state as ChatMessagesLoaded;

     result.fold(
      (failure) {
        // Revert optimistic update is complex. Show error.
        print("Failed to delete messages: ${failure.message}");
         emit(loadedState.copyWith(error: 'Failed to delete: ${failure.message}'));
      },
      (_) {
        print("Messages deleted successfully: ${event.messageIds}");
         emit(currentState.copyWith(error: null));
      },
    );
  }

  Future<void> _connectAndSubscribeWebSocket(String commonUserId, String token) async {
    if (_currentUser == null || _token == null) {
      print("[Bloc] Cannot connect WebSocket: Missing user info or token.");
      return;
    }
    print("[Bloc] Attempting to connect WebSocket...");
    
    _webSocketStatusSubscription?.cancel();
    _webSocketMessageSubscription?.cancel();
    
    // Connect WS (DataSource handles reconnection logic internally)
    // Use await here as connect itself is async and we want to ensure it's called
    await webSocketDataSource.connect(commonUserId, token);

    // Subscribe to connection status changes
    _webSocketStatusSubscription = webSocketDataSource.connectionStatusStream.listen((status) {
        print("[Bloc] WebSocket Status: $status");
         // TODO: Could update UI based on status if needed
         if (status == ConnectionStatus.error) {
            // Optionally emit an error state or show feedback
         }
    });

    // Subscribe to incoming messages
    _webSocketMessageSubscription = webSocketDataSource.messageStream.listen((messageDto) {
      print("[Bloc] Received message DTO via WebSocket listener: ${messageDto.id}");
      // Dispatch internal event to handle message processing
      add(_MessageReceived(messageDto)); 
    }, onError: (error) {
       print("[Bloc] Error on WebSocket message stream: $error");
    });
  }

  @override
  Future<void> close() {
    print("[Bloc] Closing ChatMessagesBloc for chatId: $chatId");
    _webSocketMessageSubscription?.cancel();
    _webSocketStatusSubscription?.cancel();
    // Consider if disconnect should happen here or be managed globally
    // If WebSocket connection is per ChatRoomPage, disconnect here.
    // If it's a single global connection, manage elsewhere.
    // For preview, let's assume we disconnect when this Bloc closes.
    webSocketDataSource.disconnect(); 
    return super.close();
  }
} 