import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/get_message_list.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/send_message.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/revoke_message.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/delete_chat_message.dart';

part 'message_list_state.dart';
part 'message_list_cubit.freezed.dart';

/// Cubit for managing chat message list
class MessageListCubit extends Cubit<MessageListState> {
  final GetMessageList _getMessageList;
  final SendMessage _sendMessage;
  final RevokeMessage _revokeMessage;
  final DeleteChatMessage _deleteChatMessage;
  
  MessageListCubit({
    required GetMessageList getMessageList,
    required SendMessage sendMessage,
    required RevokeMessage revokeMessage,
    required DeleteChatMessage deleteChatMessage,
  })  : _getMessageList = getMessageList,
        _sendMessage = sendMessage,
        _revokeMessage = revokeMessage,
        _deleteChatMessage = deleteChatMessage,
        super(const MessageListState.initial());
  
  int? _currentChatId;
  final List<ChatMessage> _allMessages = [];
  bool _hasMore = true;
  int _currentPage = 1;
  static const int _pageSize = 50;
  
  /// Load initial messages for a chat
  Future<void> loadMessages(int chatId) async {
    if (state is _Loading) return;
    
    emit(const MessageListState.loading());
    _currentChatId = chatId;
    _allMessages.clear();
    _currentPage = 1;
    _hasMore = true;
    
    final result = await _getMessageList(
      GetMessageListParams(
        chatId: chatId,
        page: _currentPage,
        pageSize: _pageSize,
      ),
    );
    
    result.fold(
      (failure) => emit(MessageListState.error(failure.toString())),
      (messages) {
        _allMessages.addAll(messages);
        _hasMore = messages.length >= _pageSize;
        emit(MessageListState.loaded(
          messages: List.from(_allMessages),
          hasMore: _hasMore,
        ));
      },
    );
  }
  
  /// Load more messages (pagination)
  Future<void> loadMoreMessages() async {
    if (!_hasMore || _currentChatId == null) return;
    
    final currentState = state;
    if (currentState is! _Loaded) return;
    
    emit(currentState.copyWith(isLoadingMore: true));
    _currentPage++;
    
    final result = await _getMessageList(
      GetMessageListParams(
        chatId: _currentChatId!,
        page: _currentPage,
        pageSize: _pageSize,
      ),
    );
    
    result.fold(
      (failure) {
        _currentPage--; // Revert page increment on failure
        emit(currentState.copyWith(
          isLoadingMore: false,
          loadMoreError: failure.toString(),
        ));
      },
      (messages) {
        _allMessages.addAll(messages);
        _hasMore = messages.length >= _pageSize;
        emit(MessageListState.loaded(
          messages: List.from(_allMessages),
          hasMore: _hasMore,
          isLoadingMore: false,
        ));
      },
    );
  }
  
  /// Send a new message
  Future<void> sendTextMessage(String text) async {
    if (_currentChatId == null) return;
    
    final currentState = state;
    if (currentState is! _Loaded) return;
    
    // Create optimistic message
    final optimisticMessage = ChatMessage(
      id: -DateTime.now().millisecondsSinceEpoch, // Temporary negative ID
      chatId: _currentChatId!,
      senderId: 0, // Will be set by backend
      context: text,
      type: 'text',
      createTime: DateTime.now(),
      withdrawFlag: false,
      status: MessageStatus.sending,
    );
    
    // Add optimistic message to list
    _allMessages.insert(0, optimisticMessage);
    emit(currentState.copyWith(
      messages: List.from(_allMessages),
    ));
    
    // Send message to backend
    final result = await _sendMessage(
      SendMessageParams(
        chatId: _currentChatId!,
        content: text,
        type: 'text',
      ),
    );
    
    result.fold(
      (failure) {
        // Remove failed message and show error
        _allMessages.removeWhere((m) => m.id == optimisticMessage.id);
        emit(MessageListState.loaded(
          messages: List.from(_allMessages),
          hasMore: _hasMore,
          sendError: failure.toString(),
        ));
      },
      (sentMessage) {
        // Replace optimistic message with real one
        final index = _allMessages.indexWhere((m) => m.id == optimisticMessage.id);
        if (index != -1) {
          _allMessages[index] = sentMessage;
        } else {
          _allMessages.insert(0, sentMessage);
        }
        emit(MessageListState.loaded(
          messages: List.from(_allMessages),
          hasMore: _hasMore,
        ));
      },
    );
  }
  
  /// Send a file message
  Future<void> sendFileMessage({
    required String filePath,
    required String fileType,
    Map<String, dynamic>? metadata,
  }) async {
    if (_currentChatId == null) return;
    
    final currentState = state;
    if (currentState is! _Loaded) return;
    
    // Create content based on file type
    final content = metadata != null 
        ? Uri.encodeFull(metadata.toString())
        : filePath;
    
    // Create optimistic message
    final optimisticMessage = ChatMessage(
      id: -DateTime.now().millisecondsSinceEpoch,
      chatId: _currentChatId!,
      senderId: 0,
      context: content,
      type: fileType,
      createTime: DateTime.now(),
      withdrawFlag: false,
      status: MessageStatus.sending,
    );
    
    // Add optimistic message
    _allMessages.insert(0, optimisticMessage);
    emit(currentState.copyWith(
      messages: List.from(_allMessages),
    ));
    
    // Send to backend
    final result = await _sendMessage(
      SendMessageParams(
        chatId: _currentChatId!,
        content: content,
        type: fileType,
      ),
    );
    
    result.fold(
      (failure) {
        // Remove failed message
        _allMessages.removeWhere((m) => m.id == optimisticMessage.id);
        emit(MessageListState.loaded(
          messages: List.from(_allMessages),
          hasMore: _hasMore,
          sendError: failure.toString(),
        ));
      },
      (sentMessage) {
        // Replace optimistic message
        final index = _allMessages.indexWhere((m) => m.id == optimisticMessage.id);
        if (index != -1) {
          _allMessages[index] = sentMessage;
        } else {
          _allMessages.insert(0, sentMessage);
        }
        emit(MessageListState.loaded(
          messages: List.from(_allMessages),
          hasMore: _hasMore,
        ));
      },
    );
  }
  
  /// Revoke a message
  Future<void> revokeMessage(int messageId) async {
    final currentState = state;
    if (currentState is! _Loaded) return;
    
    final result = await _revokeMessage(messageId);
    
    result.fold(
      (failure) {
        emit(currentState.copyWith(
          actionError: failure.toString(),
        ));
      },
      (_) {
        // Update message to show as revoked
        final index = _allMessages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          _allMessages[index] = _allMessages[index].copyWith(
            withdrawFlag: true,
            type: 'revoke',
            context: '消息已撤回',
          );
          emit(MessageListState.loaded(
            messages: List.from(_allMessages),
            hasMore: _hasMore,
          ));
        }
      },
    );
  }
  
  /// Delete a message locally
  Future<void> deleteMessage(int messageId) async {
    final currentState = state;
    if (currentState is! _Loaded) return;
    
    final result = await _deleteChatMessage(messageId);
    
    result.fold(
      (failure) {
        emit(currentState.copyWith(
          actionError: failure.toString(),
        ));
      },
      (_) {
        // Remove message from list
        _allMessages.removeWhere((m) => m.id == messageId);
        emit(MessageListState.loaded(
          messages: List.from(_allMessages),
          hasMore: _hasMore,
        ));
      },
    );
  }
  
  /// Add a received message (from WebSocket)
  void addReceivedMessage(ChatMessage message) {
    if (message.chatId != _currentChatId) return;
    
    final currentState = state;
    if (currentState is! _Loaded) return;
    
    // Check if message already exists
    if (_allMessages.any((m) => m.id == message.id)) return;
    
    _allMessages.insert(0, message);
    emit(MessageListState.loaded(
      messages: List.from(_allMessages),
      hasMore: _hasMore,
    ));
  }
  
  /// Update message status
  void updateMessageStatus(int messageId, MessageStatus status) {
    final index = _allMessages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      _allMessages[index] = _allMessages[index].copyWith(status: status);
      
      final currentState = state;
      if (currentState is _Loaded) {
        emit(MessageListState.loaded(
          messages: List.from(_allMessages),
          hasMore: _hasMore,
        ));
      }
    }
  }
  
  /// Clear messages
  void clearMessages() {
    _allMessages.clear();
    _currentChatId = null;
    _currentPage = 1;
    _hasMore = true;
    emit(const MessageListState.initial());
  }
}