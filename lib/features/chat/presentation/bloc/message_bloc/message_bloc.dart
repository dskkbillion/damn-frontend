import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/message.dart';
import '../../../domain/repositories/i_chat_repository.dart';
import '../../../domain/services/i_chat_realtime_service.dart';
import '../../../domain/usecases/delete_message.dart';
import '../../../domain/usecases/get_messages.dart';
import '../../../domain/usecases/revoke_message.dart';
import '../../../domain/usecases/send_message.dart';
import '../../../domain/usecases/sync_messages.dart';
import './message_event.dart';
import './message_state.dart';

/// 消息Bloc，处理消息相关的业务逻辑
class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final GetMessagesUseCase _getMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final DeleteMessageUseCase _deleteMessageUseCase;
  final RevokeMessageUseCase _revokeMessageUseCase;
  final SyncMessagesUseCase _syncMessagesUseCase;
  final IChatRealtimeService _chatRealtimeService;
  
  /// 消息更新订阅
  StreamSubscription? _messageUpdateSubscription;
  
  /// 消息状态更新订阅
  StreamSubscription? _messageStatusSubscription;
  
  MessageBloc({
    required GetMessagesUseCase getMessagesUseCase,
    required SendMessageUseCase sendMessageUseCase,
    required DeleteMessageUseCase deleteMessageUseCase,
    required RevokeMessageUseCase revokeMessageUseCase,
    required SyncMessagesUseCase syncMessagesUseCase,
    required IChatRealtimeService chatRealtimeService,
  }) : _getMessagesUseCase = getMessagesUseCase,
       _sendMessageUseCase = sendMessageUseCase,
       _deleteMessageUseCase = deleteMessageUseCase,
       _revokeMessageUseCase = revokeMessageUseCase,
       _syncMessagesUseCase = syncMessagesUseCase,
       _chatRealtimeService = chatRealtimeService,
       super(MessageInitial()) {
    // 注册事件处理函数
    on<LoadMessages>(_onLoadMessages);
    on<LoadMoreMessages>(_onLoadMoreMessages);
    on<MessagesUpdated>(_onMessagesUpdated);
    on<SendMessage>(_onSendMessage);
    on<RetrySendMessage>(_onRetrySendMessage);
    on<DeleteMessage>(_onDeleteMessage);
    on<RevokeMessage>(_onRevokeMessage);
    on<ReceiveMessage>(_onReceiveMessage);
    on<MessageStatusChanged>(_onMessageStatusChanged);
    
    // 订阅实时消息更新
    _messageUpdateSubscription = _chatRealtimeService.messageStream.listen((message) {
      add(ReceiveMessage(message: message));
    });
    
    // 订阅消息状态更新
    _messageStatusSubscription = _chatRealtimeService.messageStatusStream.listen((event) {
      add(MessageStatusChanged(
        messageId: event.messageId,
        status: event.status,
      ));
    });
  }
  
  /// 处理加载消息事件
  Future<void> _onLoadMessages(LoadMessages event, Emitter<MessageState> emit) async {
    // 如果是初次加载，显示加载状态
    if (event.initial) {
      emit(MessagesLoading(isInitialLoading: true));
    }
    
    try {
      final result = await _getMessagesUseCase(GetMessagesParams(
        sessionId: event.sessionId,
        limit: event.limit,
      ));
      
      result.fold(
        (failure) => emit(MessagesLoadFailure(
          message: _mapFailureToMessage(failure),
          sessionId: event.sessionId,
        )),
        (messages) => emit(MessagesLoaded(
          sessionId: event.sessionId,
          messages: messages,
          hasMore: messages.length >= event.limit,
          isInitialLoad: event.initial,
          currentUserId: '', // 从认证服务获取当前用户ID
        )),
      );
      
      // 如果消息已加载，标记为已读
      if (event.initial) {
        add(MarkAsRead(sessionId: event.sessionId));
      }
    } catch (e) {
      emit(MessagesLoadFailure(
        message: e.toString(),
        sessionId: event.sessionId,
      ));
    }
  }
  
  /// 处理加载更多消息事件
  Future<void> _onLoadMoreMessages(LoadMoreMessages event, Emitter<MessageState> emit) async {
    // 获取当前状态
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      
      // 标记为正在加载更多
      emit(MessagesLoading(
        isInitialLoading: false,
        isLoadingMore: true,
      ));
      
      try {
        final result = await _getMessagesUseCase(GetMessagesParams(
          sessionId: event.sessionId,
          limit: event.limit,
          beforeMessageId: event.beforeMessageId,
        ));
        
        result.fold(
          (failure) => emit(currentState.copyWith(
            hasMore: false,
          )),
          (newMessages) {
            // 合并原有消息和新消息
            final allMessages = List<Message>.from(currentState.messages)
              ..addAll(newMessages);
            
            emit(currentState.copyWith(
              messages: allMessages,
              hasMore: newMessages.length >= event.limit,
              isInitialLoad: false,
            ));
          },
        );
      } catch (e) {
        // 加载失败，回退到原状态，但标记没有更多消息
        emit(currentState.copyWith(
          hasMore: false,
        ));
      }
    }
  }
  
  /// 处理消息列表更新事件
  void _onMessagesUpdated(MessagesUpdated event, Emitter<MessageState> emit) {
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      
      if (event.append) {
        // 在现有消息列表后追加新消息
        final updatedMessages = List<Message>.from(currentState.messages)
          ..addAll(event.messages);
        
        emit(currentState.copyWith(
          messages: updatedMessages,
        ));
      } else {
        // 替换整个消息列表
        emit(currentState.copyWith(
          messages: event.messages,
        ));
      }
    }
  }
  
  /// 处理发送消息事件
  Future<void> _onSendMessage(SendMessage event, Emitter<MessageState> emit) async {
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      
      // 创建待发送的临时消息对象（本地消息ID，状态为发送中）
      final temporaryMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionId: event.sessionId,
        senderId: '', // 从认证服务获取当前用户ID
        content: event.content,
        timestamp: DateTime.now(),
        status: MessageStatus.sending,
        type: _determineMessageType(event.content),
        metadata: event.metadata,
        currentUserId: '', // 从认证服务获取
      );
      
      // 更新UI，显示发送中的消息
      final updatedMessages = [temporaryMessage, ...currentState.messages];
      emit(currentState.copyWith(
        messages: updatedMessages,
        isSending: true,
      ));
      
      try {
        // 调用发送消息用例
        final result = await _sendMessageUseCase(SendMessageParams(
          sessionId: event.sessionId,
          content: event.content,
          receiverId: event.receiverId,
          type: _determineMessageType(event.content),
          metadata: event.metadata,
          localMessageId: temporaryMessage.id,
        ));
        
        result.fold(
          (failure) {
            // 发送失败，更新消息状态
            final updatedList = _updateMessageInList(
              currentState.messages,
              temporaryMessage.id,
              (message) => message.copyWith(status: MessageStatus.failed),
            );
            
            emit(currentState.copyWith(
              messages: updatedList,
              isSending: false,
            ));
            
            emit(MessageSendFailure(
              message: _mapFailureToMessage(failure),
              failedMessage: temporaryMessage,
            ));
          },
          (sentMessage) {
            // 发送成功，用服务端返回的消息替换临时消息
            final updatedList = _replaceMessageInList(
              currentState.messages,
              temporaryMessage.id,
              sentMessage,
            );
            
            emit(currentState.copyWith(
              messages: updatedList,
              isSending: false,
            ));
            
            emit(MessageSent(message: sentMessage));
          },
        );
      } catch (e) {
        // 发送过程中出错
        final updatedList = _updateMessageInList(
          currentState.messages,
          temporaryMessage.id,
          (message) => message.copyWith(status: MessageStatus.failed),
        );
        
        emit(currentState.copyWith(
          messages: updatedList,
          isSending: false,
        ));
        
        emit(MessageSendFailure(
          message: e.toString(),
          failedMessage: temporaryMessage,
        ));
      }
    }
  }
  
  /// 处理重试发送消息事件
  Future<void> _onRetrySendMessage(RetrySendMessage event, Emitter<MessageState> emit) async {
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      
      // 查找失败的消息
      final failedMessage = currentState.messages.firstWhere(
        (message) => message.id == event.messageId,
        orElse: () => throw Exception('Message not found'),
      );
      
      // 更新消息状态为发送中
      final updatedList = _updateMessageInList(
        currentState.messages,
        event.messageId,
        (message) => message.copyWith(status: MessageStatus.sending),
      );
      
      emit(currentState.copyWith(
        messages: updatedList,
        isSending: true,
      ));
      
      try {
        // 重新调用发送消息用例
        final result = await _sendMessageUseCase(SendMessageParams(
          sessionId: failedMessage.sessionId,
          content: failedMessage.content,
          receiverId: '', // 从会话中获取接收者ID
          type: failedMessage.type,
          metadata: failedMessage.metadata,
          localMessageId: failedMessage.id,
        ));
        
        result.fold(
          (failure) {
            // 重试失败
            final updatedList = _updateMessageInList(
              currentState.messages,
              event.messageId,
              (message) => message.copyWith(status: MessageStatus.failed),
            );
            
            emit(currentState.copyWith(
              messages: updatedList,
              isSending: false,
            ));
            
            emit(MessageSendFailure(
              message: _mapFailureToMessage(failure),
              failedMessage: failedMessage,
            ));
          },
          (sentMessage) {
            // 重试成功
            final updatedList = _replaceMessageInList(
              currentState.messages,
              event.messageId,
              sentMessage,
            );
            
            emit(currentState.copyWith(
              messages: updatedList,
              isSending: false,
            ));
            
            emit(MessageSent(message: sentMessage));
          },
        );
      } catch (e) {
        // 重试过程中出错
        final updatedList = _updateMessageInList(
          currentState.messages,
          event.messageId,
          (message) => message.copyWith(status: MessageStatus.failed),
        );
        
        emit(currentState.copyWith(
          messages: updatedList,
          isSending: false,
        ));
        
        emit(MessageSendFailure(
          message: e.toString(),
          failedMessage: failedMessage,
        ));
      }
    }
  }
  
  /// 处理删除消息事件
  Future<void> _onDeleteMessage(DeleteMessage event, Emitter<MessageState> emit) async {
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      
      emit(MessageActionInProgress(
        action: '正在删除消息',
        messageId: event.messageId,
      ));
      
      try {
        final result = await _deleteMessageUseCase(DeleteMessageParams(
          messageId: event.messageId,
        ));
        
        result.fold(
          (failure) {
            emit(currentState);
            emit(MessageActionFailed(
              message: _mapFailureToMessage(failure),
              messageId: event.messageId,
            ));
          },
          (_) {
            // 删除成功，从消息列表中移除该消息
            final updatedMessages = currentState.messages
                .where((message) => message.id != event.messageId)
                .toList();
            
            emit(currentState.copyWith(
              messages: updatedMessages,
            ));
          },
        );
      } catch (e) {
        emit(currentState);
        emit(MessageActionFailed(
          message: e.toString(),
          messageId: event.messageId,
        ));
      }
    }
  }
  
  /// 处理撤回消息事件
  Future<void> _onRevokeMessage(RevokeMessage event, Emitter<MessageState> emit) async {
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      
      emit(MessageActionInProgress(
        action: '正在撤回消息',
        messageId: event.messageId,
      ));
      
      try {
        final result = await _revokeMessageUseCase(RevokeMessageParams(
          messageId: event.messageId,
        ));
        
        result.fold(
          (failure) {
            emit(currentState);
            emit(MessageActionFailed(
              message: _mapFailureToMessage(failure),
              messageId: event.messageId,
            ));
          },
          (revokedMessage) {
            // 撤回成功，用撤回后的消息替换原消息
            final updatedList = _replaceMessageInList(
              currentState.messages,
              event.messageId,
              revokedMessage,
            );
            
            emit(currentState.copyWith(
              messages: updatedList,
            ));
          },
        );
      } catch (e) {
        emit(currentState);
        emit(MessageActionFailed(
          message: e.toString(),
          messageId: event.messageId,
        ));
      }
    }
  }
  
  /// 处理接收新消息事件
  void _onReceiveMessage(ReceiveMessage event, Emitter<MessageState> emit) {
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      
      // 只处理当前会话的消息
      if (event.message.sessionId == currentState.sessionId) {
        // 检查消息是否已在列表中
        final messageExists = currentState.messages.any((m) => m.id == event.message.id);
        
        if (!messageExists) {
          // 添加新消息到列表开头
          final updatedMessages = [event.message, ...currentState.messages];
          
          emit(currentState.copyWith(
            messages: updatedMessages,
          ));
          
          // 如果是对方发送的消息，标记为已读
          if (event.message.senderId != currentState.currentUserId) {
            add(MarkAsRead(sessionId: currentState.sessionId));
          }
        }
      }
    }
  }
  
  /// 处理消息状态更新事件
  void _onMessageStatusChanged(MessageStatusChanged event, Emitter<MessageState> emit) {
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      
      // 更新消息状态
      final updatedList = _updateMessageInList(
        currentState.messages,
        event.messageId,
        (message) => message.copyWith(status: event.status),
      );
      
      if (updatedList != currentState.messages) {
        emit(currentState.copyWith(
          messages: updatedList,
        ));
      }
    }
  }
  
  @override
  Future<void> close() {
    _messageUpdateSubscription?.cancel();
    _messageStatusSubscription?.cancel();
    return super.close();
  }
  
  /// 根据内容确定消息类型
  MessageType _determineMessageType(String content) {
    // 在实际应用中，可能需要根据内容格式或元数据判断消息类型
    // 这里简化处理，默认为文本消息
    return MessageType.text;
  }
  
  /// 在消息列表中更新指定消息
  List<Message> _updateMessageInList(
    List<Message> messages,
    String messageId,
    Message Function(Message) updater,
  ) {
    return messages.map((message) {
      if (message.id == messageId) {
        return updater(message);
      }
      return message;
    }).toList();
  }
  
  /// 在消息列表中替换指定消息
  List<Message> _replaceMessageInList(
    List<Message> messages,
    String messageId,
    Message newMessage,
  ) {
    return messages.map((message) {
      if (message.id == messageId) {
        return newMessage;
      }
      return message;
    }).toList();
  }
  
  /// 将错误类型转换为用户友好的消息
  String _mapFailureToMessage(Object failure) {
    // 根据实际错误类型返回对应的错误信息
    return failure.toString();
  }
} 