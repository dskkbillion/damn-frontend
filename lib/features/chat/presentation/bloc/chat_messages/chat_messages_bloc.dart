import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/entities.dart';
import '../../../domain/usecases/usecases.dart';
import 'chat_messages_event.dart';
import 'chat_messages_state.dart';

/// 聊天消息Bloc
class ChatMessagesBloc extends Bloc<ChatMessagesEvent, ChatMessagesState> {
  final GetMessagesUseCase _getMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final GetMessageHistoryUseCase _getMessageHistoryUseCase;
  final ReceiveMessageUseCase _receiveMessageUseCase;
  
  late StreamSubscription<Message> _messagesSubscription;
  late StreamSubscription<MessageStatusUpdate> _statusSubscription;
  
  final _uuid = const Uuid();
  
  ChatMessagesBloc({
    required GetMessagesUseCase getMessagesUseCase,
    required SendMessageUseCase sendMessageUseCase,
    required GetMessageHistoryUseCase getMessageHistoryUseCase,
    required ReceiveMessageUseCase receiveMessageUseCase,
  }) : _getMessagesUseCase = getMessagesUseCase,
       _sendMessageUseCase = sendMessageUseCase,
       _getMessageHistoryUseCase = getMessageHistoryUseCase,
       _receiveMessageUseCase = receiveMessageUseCase,
       super(const MessagesInitial()) {
    on<LoadMessagesEvent>(_onLoadMessages);
    on<LoadMoreMessagesEvent>(_onLoadMoreMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<RetrySendMessageEvent>(_onRetrySendMessage);
    on<RevokeMessageEvent>(_onRevokeMessage);
    on<DeleteMessageEvent>(_onDeleteMessage);
    on<MarkSessionAsReadEvent>(_onMarkSessionAsRead);
    on<ReceiveMessageEvent>(_onReceiveMessage);
    on<MessageStatusUpdateEvent>(_onMessageStatusUpdate);
    
    // 订阅新消息流
    _messagesSubscription = _receiveMessageUseCase.execute().listen((message) {
      add(ReceiveMessageEvent(message: message));
    });
    
    // 订阅消息状态更新流
    _statusSubscription = _receiveMessageUseCase.observeMessageStatusUpdates().listen((statusUpdate) {
      add(MessageStatusUpdateEvent(
        messageId: statusUpdate.messageId,
        newStatus: statusUpdate.newStatus,
      ));
    });
  }
  
  @override
  Future<void> close() {
    _messagesSubscription.cancel();
    _statusSubscription.cancel();
    return super.close();
  }
  
  /// 处理加载消息事件
  Future<void> _onLoadMessages(
    LoadMessagesEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    emit(const MessagesLoading());
    
    try {
      final historyParams = MessageHistoryParams(
        sessionId: event.sessionId,
        pageSize: event.limit,
      );
      
      final result = await _getMessageHistoryUseCase.execute(historyParams);
      
      result.fold(
        (failure) => emit(MessagesError(message: failure.message)),
        (messages) {
          emit(MessagesLoaded(
            messages: messages,
            sessionId: event.sessionId,
            hasMore: messages.length >= event.limit,
          ));
        },
      );
    } catch (e) {
      emit(MessagesError(message: e.toString()));
    }
  }
  
  /// 处理加载更多消息事件
  Future<void> _onLoadMoreMessages(
    LoadMoreMessagesEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      
      if (!currentState.hasMore) {
        return; // 没有更多消息可加载
      }
      
      emit(MessagesLoading(isLoadingMore: true));
      
      try {
        final historyParams = MessageHistoryParams(
          sessionId: event.sessionId,
          beforeMessageId: event.beforeMessageId,
          pageSize: event.limit,
        );
        
        final result = await _getMessageHistoryUseCase.execute(historyParams);
        
        result.fold(
          (failure) => emit(MessagesError(message: failure.message)),
          (newMessages) {
            // 合并现有消息和新加载的消息
            final allMessages = [...currentState.messages, ...newMessages];
            
            emit(MessagesLoaded(
              messages: allMessages,
              sessionId: event.sessionId,
              hasMore: newMessages.length >= event.limit,
            ));
          },
        );
      } catch (e) {
        emit(MessagesError(message: e.toString()));
      }
    }
  }
  
  /// 处理发送消息事件
  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    final temporaryId = _uuid.v4();
    
    // 创建临时消息对象
    final message = Message(
      id: temporaryId,
      content: event.content,
      senderId: 'current_user', // 这应该从认证服务获取
      senderType: MessageSenderType.USER,
      receiverId: 'target_user', // 这应该从会话上下文获取
      receiverType: MessageReceiverType.USER,
      timestamp: DateTime.now(),
      sessionId: event.sessionId,
      status: MessageStatus.SENDING,
      type: event.type,
      syncStatus: MessageSyncStatus.PENDING,
      retryCount: 0,
    );
    
    // 添加临时消息到状态
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      emit(currentState.copyWith(
        messages: [message, ...currentState.messages],
      ));
    }
    
    emit(MessageSending(message: message));
    
    try {
      final result = await _sendMessageUseCase.execute(message);
      
      result.fold(
        (failure) {
          // 更新临时消息状态为失败
          final updatedMessage = message.copyWith(
            status: MessageStatus.FAILED,
            syncStatus: MessageSyncStatus.FAILED,
          );
          
          if (state is MessagesLoaded) {
            final currentState = state as MessagesLoaded;
            final updatedMessages = _updateMessageInList(
              currentState.messages,
              updatedMessage,
            );
            
            emit(currentState.copyWith(messages: updatedMessages));
          }
          
          emit(MessageSendFailed(
            message: updatedMessage,
            errorMessage: failure.message,
          ));
        },
        (sentMessage) {
          // 更新临时消息为发送成功的消息
          if (state is MessagesLoaded) {
            final currentState = state as MessagesLoaded;
            final updatedMessages = _updateMessageInList(
              currentState.messages,
              sentMessage,
              oldId: temporaryId,
            );
            
            emit(currentState.copyWith(messages: updatedMessages));
          }
          
          emit(MessageSent(message: sentMessage));
        },
      );
    } catch (e) {
      // 更新临时消息状态为失败
      final updatedMessage = message.copyWith(
        status: MessageStatus.FAILED,
        syncStatus: MessageSyncStatus.FAILED,
      );
      
      if (state is MessagesLoaded) {
        final currentState = state as MessagesLoaded;
        final updatedMessages = _updateMessageInList(
          currentState.messages,
          updatedMessage,
        );
        
        emit(currentState.copyWith(messages: updatedMessages));
      }
      
      emit(MessageSendFailed(
        message: updatedMessage,
        errorMessage: e.toString(),
      ));
    }
  }
  
  /// 处理重试发送消息事件
  Future<void> _onRetrySendMessage(
    RetrySendMessageEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      final messageToRetry = currentState.messages.firstWhere(
        (msg) => msg.id == event.messageId,
        orElse: () => throw Exception('Message not found'),
      );
      
      // 更新消息状态为发送中
      final updatedMessage = messageToRetry.copyWith(
        status: MessageStatus.SENDING,
        syncStatus: MessageSyncStatus.PENDING,
        retryCount: messageToRetry.retryCount + 1,
      );
      
      final updatedMessages = _updateMessageInList(
        currentState.messages,
        updatedMessage,
      );
      
      emit(currentState.copyWith(messages: updatedMessages));
      emit(MessageSending(message: updatedMessage));
      
      try {
        final result = await _sendMessageUseCase.execute(updatedMessage);
        
        result.fold(
          (failure) {
            // 更新消息状态为失败
            final failedMessage = updatedMessage.copyWith(
              status: MessageStatus.FAILED,
              syncStatus: MessageSyncStatus.FAILED,
            );
            
            final newMessages = _updateMessageInList(
              updatedMessages,
              failedMessage,
            );
            
            emit(currentState.copyWith(messages: newMessages));
            emit(MessageSendFailed(
              message: failedMessage,
              errorMessage: failure.message,
            ));
          },
          (sentMessage) {
            // 更新消息为发送成功
            final newMessages = _updateMessageInList(
              updatedMessages,
              sentMessage,
            );
            
            emit(currentState.copyWith(messages: newMessages));
            emit(MessageSent(message: sentMessage));
          },
        );
      } catch (e) {
        // 更新消息状态为失败
        final failedMessage = updatedMessage.copyWith(
          status: MessageStatus.FAILED,
          syncStatus: MessageSyncStatus.FAILED,
        );
        
        final newMessages = _updateMessageInList(
          updatedMessages,
          failedMessage,
        );
        
        emit(currentState.copyWith(messages: newMessages));
        emit(MessageSendFailed(
          message: failedMessage,
          errorMessage: e.toString(),
        ));
      }
    }
  }
  
  /// 处理撤回消息事件
  Future<void> _onRevokeMessage(
    RevokeMessageEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      
      try {
        // 创建撤回消息的系统消息
        final result = await _sendMessageUseCase.revokeMessage(event.messageId);
        
        result.fold(
          (failure) => emit(MessagesError(message: failure.message)),
          (_) {
            // 从消息列表中移除已撤回的消息
            final updatedMessages = currentState.messages
                .where((msg) => msg.id != event.messageId)
                .toList();
            
            emit(currentState.copyWith(messages: updatedMessages));
            emit(MessageActionSuccess(
              actionType: 'revoke',
              messageId: event.messageId,
            ));
          },
        );
      } catch (e) {
        emit(MessagesError(message: e.toString()));
      }
    }
  }
  
  /// 处理删除消息事件
  Future<void> _onDeleteMessage(
    DeleteMessageEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      
      try {
        final result = await _sendMessageUseCase.deleteMessage(event.messageId);
        
        result.fold(
          (failure) => emit(MessagesError(message: failure.message)),
          (_) {
            // 从消息列表中移除已删除的消息
            final updatedMessages = currentState.messages
                .where((msg) => msg.id != event.messageId)
                .toList();
            
            emit(currentState.copyWith(messages: updatedMessages));
            emit(MessageActionSuccess(
              actionType: 'delete',
              messageId: event.messageId,
            ));
          },
        );
      } catch (e) {
        emit(MessagesError(message: e.toString()));
      }
    }
  }
  
  /// 处理标记会话已读事件
  Future<void> _onMarkSessionAsRead(
    MarkSessionAsReadEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    if (state is MessagesLoaded) {
      try {
        final result = await _sendMessageUseCase.markSessionAsRead(event.sessionId);
        
        result.fold(
          (failure) => emit(MessagesError(message: failure.message)),
          (_) {
            // 不需要更新UI状态，因为这只是通知服务器
          },
        );
      } catch (e) {
        emit(MessagesError(message: e.toString()));
      }
    }
  }
  
  /// 处理接收新消息事件
  void _onReceiveMessage(
    ReceiveMessageEvent event,
    Emitter<ChatMessagesState> emit,
  ) {
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      
      // 检查消息是否属于当前会话
      if (event.message.sessionId == currentState.sessionId) {
        // 检查消息是否已存在
        final exists = currentState.messages.any((msg) => msg.id == event.message.id);
        
        if (!exists) {
          // 将新消息添加到列表开头
          final updatedMessages = [event.message, ...currentState.messages];
          emit(currentState.copyWith(messages: updatedMessages));
        }
      }
    }
  }
  
  /// 处理消息状态更新事件
  void _onMessageStatusUpdate(
    MessageStatusUpdateEvent event,
    Emitter<ChatMessagesState> emit,
  ) {
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      
      // 查找要更新的消息
      final messageIndex = currentState.messages.indexWhere(
        (msg) => msg.id == event.messageId,
      );
      
      if (messageIndex >= 0) {
        // 更新消息状态
        final message = currentState.messages[messageIndex];
        final updatedMessage = message.copyWith(status: event.newStatus);
        
        // 更新消息列表
        final updatedMessages = List<Message>.from(currentState.messages);
        updatedMessages[messageIndex] = updatedMessage;
        
        emit(currentState.copyWith(messages: updatedMessages));
      }
    }
  }
  
  /// 在消息列表中更新指定消息
  List<Message> _updateMessageInList(
    List<Message> messages,
    Message updatedMessage, {
    String? oldId,
  }) {
    final idToFind = oldId ?? updatedMessage.id;
    
    final messageIndex = messages.indexWhere((msg) => msg.id == idToFind);
    
    if (messageIndex >= 0) {
      final updatedMessages = List<Message>.from(messages);
      updatedMessages[messageIndex] = updatedMessage;
      return updatedMessages;
    }
    
    return messages;
  }
} 