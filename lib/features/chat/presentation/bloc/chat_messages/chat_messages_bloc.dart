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
      // 1. Fetch current user and commonUserId
      final userResult = await userRepository.getCurrentUser();
      _currentUser = userResult.getOrElse(() => throw Exception("Failed to get current user"));
      final currentCommonUserId = _currentUser!.id; // Assuming User.id is commonUserId

      // Use real token and commonUserId for WebSocket
      _token = 'eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjFjYjlhZmYyLThjOTktNGMwYy05YTk5LWQ2NjdhYjVkMDY4NSJ9.I7cLrFM0qkBF9D-r90fowh3i9xO5v_39Oafl_K7hXdxJ2pQ1Yd9_PCd_C_M6za_0Y8YHt0bZRVb01am-F8r9ew';
      String commonUserIdForWS = '10315';

      if (_currentUser == null || _token == null) {
         throw Exception("User or token not available");
      }
      print("[ChatMessagesBloc] Current commonUserId: $currentCommonUserId");
      print("[ChatMessagesBloc] Using WebSocket commonUserId: $commonUserIdForWS, Token: ${_token!.substring(0, 10)}...");

      // 2. Fetch initial messages and opponent details concurrently
      final results = await Future.wait([
        getMessageList(GetMessageListParams(chatId: event.chatId)),
        getChatRoomDetails(GetChatRoomDetailsParams(chatId: event.chatId)),
      ]);

      final messageResult = results[0] as Either<Failure, List<ChatMessage>>;
      final roomDetailsResult = results[1] as Either<Failure, ChatRoom>;

      // 3. Process results
      await messageResult.fold(
        (failure) async => emit(ChatMessagesError('Failed to load messages: ${failure.message}')),
        (messages) async {
          await roomDetailsResult.fold(
            (failure) async => emit(ChatMessagesError('Failed to load room details: ${failure.message}')),
            (roomDetails) async {
              // FIX: Find opponent AND current user's participant ID
              Participant? opponentParticipant;
              int? currentUserParticipantId;

              // Assuming ChatRoom entity now uses participant1 and participant2
              final p1 = roomDetails.participant1;
              final p2 = roomDetails.participant2;

              if (p1.referId == currentCommonUserId) {
                  currentUserParticipantId = p1.id;
                  opponentParticipant = p2;
              } else if (p2.referId == currentCommonUserId) {
                  currentUserParticipantId = p2.id;
                  opponentParticipant = p1;
              } else {
                   // Error: Current user (based on commonUserId) not found in this chat's participants
                  print("Error: Current user commonId ($currentCommonUserId) doesn't match referId of participant ${p1.id} (${p1.referId}) or ${p2.id} (${p2.referId})");
                  emit(ChatMessagesError('Error: You are not a participant in this chat.'));
                  return; // Stop processing
              }

              if (currentUserParticipantId == null || opponentParticipant == null) {
                 emit(ChatMessagesError('Failed to identify participants in chat.'));
                 return;
              }
              
              _opponent = opponentParticipant; // Store opponent locally if needed elsewhere
              print("[ChatMessagesBloc] Messages and details loaded. Opponent: ${_opponent?.nickName} (${_opponent?.id}), CurrentUserParticipantId: $currentUserParticipantId");

              // Emit ChatMessagesLoaded with the found participant ID
              // FIX: REMOVE the .reversed call, assuming getMessageList returns messages in chronological order (oldest first).
              // final sortedMessages = List<ChatMessage>.from(messages.reversed);
              emit(ChatMessagesLoaded(
                messages: messages, // Emit the list directly as received
                opponent: _opponent!, 
                currentUserId: currentCommonUserId, // Keep commonUserId here if needed globally
                currentUserParticipantId: currentUserParticipantId, // Pass the specific participant ID
              ));

              // 4. Connect to WebSocket
              print("[ChatMessagesBloc] Connecting to WebSocket with commonUserId: $commonUserIdForWS");
              _connectAndSubscribeWebSocket(commonUserIdForWS, _token!); 
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
    if (state is! ChatMessagesLoaded) return; 
    final loadedState = state as ChatMessagesLoaded;

    if (_currentUser == null) {
      // FIX: Wrap error message in ValueGetter
      emit(loadedState.copyWith(error: () => 'Cannot send message: User not loaded'));
      return;
    }

    // 1. Create optimistic message
    final optimisticMessage = ChatMessage(
      id: Random().nextInt(1000000) + 1000000,
      chatId: chatId,
      senderId: loadedState.currentUserParticipantId, // Use participant ID for sender
      memberId: _currentUser!.type == 'MEMBER' ? loadedState.currentUserParticipantId : loadedState.opponent.id,
      doctorId: _currentUser!.type == 'DOCTOR' ? loadedState.currentUserParticipantId : loadedState.opponent.id,
      context: event.type == 'text' ? event.text! : (event.file?.path ?? 'Sending file...'),
      type: event.type,
      createTime: DateTime.now(),
      withdrawFlag: false,
      status: MessageStatus.sending,
    );

    // 2. Emit state with optimistic message ADDED TO THE END
    emit(loadedState.copyWith(
      messages: [...loadedState.messages, optimisticMessage], // Append new message
      error: () => null
    ));

    // 3. Prepare Use Case parameters
    final params = SendMessageParams(
      message: optimisticMessage.copyWith(id: 0), 
      file: event.file,
    );

    // 4. Call Use Case
    final result = await sendMessage(params);

    if (state is! ChatMessagesLoaded) return;
    final currentState = state as ChatMessagesLoaded;

    result.fold(
      (failure) {
        // Update message status to failed (map logic is fine)
        final updatedMessages = currentState.messages.map((msg) {
          return msg.id == optimisticMessage.id
              ? msg.copyWith(status: MessageStatus.failed)
              : msg;
        }).toList();
        emit(currentState.copyWith(
          messages: updatedMessages,
          error: () => failure.message,
        ));
        print("Failed to send message: ${failure.message}");
      },
      (sentMessage) {
        // Replace optimistic message with confirmed message (map logic is fine)
        final updatedMessages = currentState.messages.map((msg) {
          return msg.id == optimisticMessage.id
              ? sentMessage.copyWith(status: MessageStatus.sent)
              : msg;
        }).toList();
        emit(currentState.copyWith(
          messages: updatedMessages,
          error: () => null,
        ));
         print("Message sent successfully: ${sentMessage.id}");
      },
    );
  }

  void _onInternalMessageReceived(_MessageReceived event, Emitter<ChatMessagesState> emit) {
    if (state is ChatMessagesLoaded && _currentUser != null) {
      final currentState = state as ChatMessagesLoaded;
      final ChatMessageDto messageDto = event.messageDto;

      print("[Bloc] Received message via WebSocket: ${messageDto.id}");

      try {
        // FIX: Determine sender participant ID from DTO
        final int senderParticipantId = messageDto.memberId ?? messageDto.doctorId ?? 0;
        if (senderParticipantId == 0) {
           print("[Bloc] Error: Received message DTO has neither memberId nor doctorId. DTO: ${messageDto.toJson()}");
           emit(currentState.copyWith(error: () => "Received invalid message data from WebSocket"));
           return;
        }

        // Convert DTO to Entity
        final newMessage = messageDto.toEntity(
          currentUserId: currentState.currentUserId,
          senderId: senderParticipantId, // Pass determined sender ID
        );

        // Check if message already exists (e.g., from optimistic update)
        final messageExists = currentState.messages.any((m) => m.id == newMessage.id);
        
        if (!messageExists) {
             // FIX: Append the new message to the END of the list
            emit(currentState.copyWith(
              messages: [...currentState.messages, newMessage], // Append new message
            ));
             print("[Bloc] Appended new message ${newMessage.id} from WebSocket");
        } else {
             print("[Bloc] Message ${newMessage.id} from WebSocket already exists, ignoring.");
        }

      } catch (e) {
        print("[Bloc] Error processing WebSocket message: $e");
        // FIX: Wrap error message in ValueGetter
        emit(currentState.copyWith(error: () => "Error processing received message"));
      }
    } else {
       print("[Bloc] Received WebSocket message but state is not ChatMessagesLoaded or currentUser is null. State: $state");
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
      return msg.id == event.messageId ? msg.copyWith(withdrawFlag: true, type: 'revoke', status: MessageStatus.sent) : msg;
    }).toList();
    // FIX: Wrap null in ValueGetter
    emit(loadedState.copyWith(messages: updatedMessagesOptimistic, error: () => null));

    final result = await revokeMessage(RevokeMessageParams(messageId: event.messageId));

    if (state is! ChatMessagesLoaded) return;
    final currentState = state as ChatMessagesLoaded;

    result.fold(
      (failure) {
         final revertedMessages = currentState.messages.map((msg) { return msg; }).toList();
        emit(currentState.copyWith(
             messages: revertedMessages,
             // FIX: Wrap error message in ValueGetter
             error: () => 'Failed to revoke: ${failure.message}'
             ));
         print("Failed to revoke message: ${failure.message}");
      },
      (_) {
         print("Message revoked successfully: ${event.messageId}");
         // FIX: Wrap null in ValueGetter
          emit(currentState.copyWith(error: () => null));
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
    // FIX: Wrap null in ValueGetter
    emit(loadedState.copyWith(messages: updatedMessagesOptimistic, error: () => null));

    final result = await deleteChatMessage(DeleteChatMessageParams(messageIds: event.messageIds, chatId: chatId));

    if (state is! ChatMessagesLoaded) return;
    final currentState = state as ChatMessagesLoaded;

     result.fold(
      (failure) {
        print("Failed to delete messages: ${failure.message}");
         // FIX: Wrap error message in ValueGetter
         emit(loadedState.copyWith(error: () => 'Failed to delete: ${failure.message}'));
      },
      (_) {
        print("Messages deleted successfully: ${event.messageIds}");
        // FIX: Wrap null in ValueGetter
         emit(currentState.copyWith(error: () => null));
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