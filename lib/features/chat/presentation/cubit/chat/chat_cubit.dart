import 'dart:async';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_room.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/get_chat_room_details.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/create_chat_room.dart';
import 'package:dskk_flutter_refactor/features/chat/data/datasources/i_chat_web_socket_data_source.dart';

part 'chat_state.dart';
part 'chat_cubit.freezed.dart';

/// Main cubit for coordinating chat functionality
class ChatCubit extends Cubit<ChatState> {
  final GetChatRoomDetails _getChatRoomDetails;
  final CreateChatRoom _createChatRoom;
  final IChatWebSocketDataSource _webSocketDataSource;
  
  StreamSubscription? _messageSubscription;
  
  ChatCubit({
    required GetChatRoomDetails getChatRoomDetails,
    required CreateChatRoom createChatRoom,
    required IChatWebSocketDataSource webSocketDataSource,
  })  : _getChatRoomDetails = getChatRoomDetails,
        _createChatRoom = createChatRoom,
        _webSocketDataSource = webSocketDataSource,
        super(const ChatState.initial());
  
  /// Enter a chat room
  Future<void> enterChatRoom(int chatId) async {
    emit(const ChatState.loading());
    
    // Get chat room details
    final result = await _getChatRoomDetails(GetChatRoomDetailsParams(chatId: chatId));
    
    result.fold(
      (failure) => emit(ChatState.error(failure.toString())),
      (chatRoom) {
        emit(ChatState.ready(chatRoom: chatRoom));
        
        // Note: WebSocket connection is handled separately
        // Join room functionality would be implemented with send/receive pattern
        
        // Listen to incoming messages
        _listenToMessages();
      },
    );
  }
  
  /// Create or get existing chat room
  Future<void> createOrEnterChatRoom({
    required int otherUserId,
    int? productId,
  }) async {
    emit(const ChatState.loading());
    
    final result = await _createChatRoom(
      CreateChatRoomParams(
        participantId: otherUserId,
        productId: productId,
      ),
    );
    
    result.fold(
      (failure) => emit(ChatState.error(failure.toString())),
      (chatRoomId) async {
        // Get the created room details
        final detailsResult = await _getChatRoomDetails(
          GetChatRoomDetailsParams(chatId: chatRoomId),
        );
        
        detailsResult.fold(
          (failure) => emit(ChatState.error(failure.toString())),
          (chatRoom) {
            emit(ChatState.ready(chatRoom: chatRoom));
            // Listen to incoming messages
            _listenToMessages();
          },
        );
      },
    );
  }
  
  /// Listen to incoming WebSocket messages
  void _listenToMessages() {
    _messageSubscription?.cancel();
    _messageSubscription = _webSocketDataSource.messageStream.listen((dto) {
      AppLogger.d('[ChatCubit] Received message from WebSocket: type=${dto.type}, id=${dto.id}, chatId=${dto.chatId}');
      final currentState = state;
      if (currentState is _Ready) {
        // Convert DTO to entity with required parameters
        final message = dto.toEntity(
          currentUserId: 0, // Should come from auth context
          senderId: dto.memberId ?? dto.doctorId ?? 0,
        );
        AppLogger.d('[ChatCubit] Converted to entity: type=${message.type}, id=${message.id}');
        // Emit new message received event
        emit(currentState.copyWith(
          lastReceivedMessage: message,
          hasNewMessage: true,
        ));
        
        // Reset flag after a brief moment
        Future.delayed(const Duration(milliseconds: 100), () {
          final updatedState = state;
          if (updatedState is _Ready) {
            emit(updatedState.copyWith(hasNewMessage: false));
          }
        });
      }
    });
  }
  
  /// Leave current chat room
  void leaveChatRoom() {
    // Note: leaveRoom functionality would be implemented with send pattern
    // For now, just cleanup
    _messageSubscription?.cancel();
    emit(const ChatState.initial());
  }
  
  /// Update chat room (e.g., after product change)
  void updateChatRoom(ChatRoom chatRoom) {
    final currentState = state;
    if (currentState is _Ready) {
      emit(currentState.copyWith(chatRoom: chatRoom));
    }
  }
  
  /// Mark messages as read
  Future<void> markMessagesAsRead() async {
    final currentState = state;
    if (currentState is _Ready) {
      // Update unread count
      emit(currentState.copyWith(
        chatRoom: currentState.chatRoom.copyWith(unreadCount: 0),
      ));
    }
  }
  
  /// Handle typing indicator
  void sendTypingIndicator(bool isTyping) {
    // Note: Typing indicator would be implemented with WebSocket send pattern
    // For now, just track locally if needed
  }
  
  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    leaveChatRoom();
    return super.close();
  }
}