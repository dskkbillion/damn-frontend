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
  int? _currentUserParticipantId; // 添加当前用户的participant ID
  final List<ChatMessage> _allMessages = [];
  bool _hasMore = true;
  int _currentPage = 1;
  static const int _pageSize = 50;
  
  /// Set current user participant ID
  void setCurrentUserParticipantId(int participantId) {
    _currentUserParticipantId = participantId;
    print('[MessageListCubit] Set current user participant ID: $_currentUserParticipantId');
  }
  
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
        pageNum: _currentPage,
        pageSize: _pageSize,
      ),
    );
    
    result.fold(
      (failure) => emit(MessageListState.error(failure.toString())),
      (messages) {
        // 消息已经是降序排列（新到旧），直接添加
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
        pageNum: _currentPage,
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
    // 使用本地时间，因为这是用于显示的
    // 当服务器返回真实消息时，会用服务器时间替换
    final optimisticMessage = ChatMessage(
      id: -DateTime.now().millisecondsSinceEpoch, // Temporary negative ID
      chatId: _currentChatId!,
      senderId: _currentUserParticipantId ?? 0, // 使用设置的当前用户participant ID
      context: text,
      type: 'text',
      createTime: DateTime.now(), // 本地时间，用于即时显示
      withdrawFlag: false,
      status: MessageStatus.sending,
    );
    
    // Add optimistic message to list
    _allMessages.insert(0, optimisticMessage);
    
    // Force emit new state with unique list to ensure UI rebuild
    emit(MessageListState.loaded(
      messages: List.from(_allMessages), // Create new list instance
      hasMore: _hasMore,
    ));
    
    // Send message to backend
    final result = await _sendMessage(
      SendMessageParams(
        message: optimisticMessage,
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
  
  /// Add a new message to the list (used when message is sent successfully)
  void addNewMessage(ChatMessage message) {
    final currentState = state;
    if (currentState is! _Loaded) return;
    
    // Check if message already exists (avoid duplicates)
    if (_allMessages.any((m) => m.id == message.id)) return;
    
    // Add message to the beginning (newest first)
    _allMessages.insert(0, message);
    emit(MessageListState.loaded(
      messages: List.from(_allMessages),
      hasMore: _hasMore,
    ));
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
    // 使用本地时间，因为这是用于显示的
    // 当服务器返回真实消息时，会用服务器时间替换
    final optimisticMessage = ChatMessage(
      id: -DateTime.now().millisecondsSinceEpoch,
      chatId: _currentChatId!,
      senderId: 0,
      context: content,
      type: fileType,
      createTime: DateTime.now(), // 本地时间，用于即时显示
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
        message: optimisticMessage,
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
  
  /// Withdraw a message (alias for revokeMessage)
  Future<void> withdrawMessage(int messageId) async {
    return revokeMessage(messageId);
  }
  
  /// Revoke a message
  Future<void> revokeMessage(int messageId) async {
    final currentState = state;
    if (currentState is! _Loaded) return;
    
    final result = await _revokeMessage(RevokeMessageParams(messageId: messageId));
    
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
    
    if (_currentChatId == null) return;
    
    final result = await _deleteChatMessage(DeleteChatMessageParams(
      messageIds: [messageId],
      chatId: _currentChatId!,
    ));
    
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