import 'dart:async';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
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
import 'package:dskk_flutter_refactor/core/events/event_bus.dart'; // For EventBus
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
  Function(ChatMessage)? onNewMessageReceived; // Callback for new messages

  User? _currentUser;
  Participant? _opponent;
  ChatRoom? _currentRoom;
  String? _token;
  StreamSubscription? _messageSubscription;

  // 添加公共getter来访问当前聊天室信息
  ChatRoom? get currentRoom => _currentRoom;

  ChatMessagesBloc({
    required this.chatId,
    required this.getMessageList,
    required this.sendMessage,
    required this.revokeMessage,
    required this.getChatRoomDetails,
    required this.deleteChatMessage,
    required this.userRepository,
    required this.webSocketDataSource,
  }) : super(ChatMessagesInitial()) {
    on<LoadChatMessages>(_onLoadChatMessages);
    on<LoadMoreChatMessages>(_onLoadMoreChatMessages);
    on<SendMessageRequested>(_onSendMessageRequested);
    on<_MessageReceived>(_onInternalMessageReceived);
    on<RevokeMessageRequested>(_onRevokeMessageRequested);
    on<DeleteMessageRequested>(_onDeleteMessageRequested);
    on<ResetMessageRevokedFlag>(_onResetMessageRevokedFlag);
    on<ResetMessageSentFlag>(_onResetMessageSentFlag);
  }

  Future<void> _onLoadChatMessages(
    LoadChatMessages event,
    Emitter<ChatMessagesState> emit
  ) async {
    emit(ChatMessagesLoading());
    try {
      // 1. Fetch current user's main ID (referId)
      final userResult = await userRepository.getCurrentUser();
      final userEither = await userResult.fold(
        (failure) {
          emit(ChatMessagesError('Failed to get current user: ${failure.message}'));
          return null;
        },
        (user) {
          _currentUser = user; // Store current user
          AppLogger.d("[ChatMessagesBloc] Current User loaded: ID=${user.id} (referId)");
          return user;
        },
      );

      if (userEither == null) return;
      final currentReferId = userEither.id; // This is the referId (e.g., 10307)
      AppLogger.d("[ChatMessagesBloc] =====ID映射调试开始=====");
      AppLogger.d("[ChatMessagesBloc] 当前用户referId (外部ID): $currentReferId");

      // 2. Fetch initial messages and room details concurrently
      final results = await Future.wait([
        getMessageList(GetMessageListParams(
          chatId: chatId,
          pageNum: 1,
          pageSize: 20, // 改为20条，支持分页
        )),
        getChatRoomDetails(GetChatRoomDetailsParams(chatId: chatId)),
      ]);

      final messageResult = results[0] as Either<Failure, List<ChatMessage>>;
      final roomDetailsResult = results[1] as Either<Failure, ChatRoom>;

      // 3. Process results only if both succeed
      int? currentUserParticipantId; // This will be the internal ID (e.g., 10304)
      Participant? opponentParticipant;
      ChatRoom? fetchedRoomDetails;

      final success = await roomDetailsResult.fold(
        (failure) async {
          emit(ChatMessagesError('Failed to load room details: ${failure.message}'));
          return false;
        },
        (roomDetails) async {
           fetchedRoomDetails = roomDetails; // Store fetched room details
           _currentRoom = roomDetails; // Also store globally if needed

           // Determine current user's INTERNAL participant ID and the opponent
           final p1 = roomDetails.participant1;
           final p2 = roomDetails.participant2;
           
           AppLogger.d("[ChatMessagesBloc] 聊天室参与者信息:");
           AppLogger.d("[ChatMessagesBloc]   participant1: id=${p1.id} (内部ID), referId=${p1.referId} (外部ID), nickName=${p1.nickName}");
           AppLogger.d("[ChatMessagesBloc]   participant2: id=${p2.id} (内部ID), referId=${p2.referId} (外部ID), nickName=${p2.nickName}");

           AppLogger.d("[ChatMessagesBloc] 开始匹配当前用户...");
           // 修复：使用participant.id与currentReferId(实际是commonUserId)进行匹配
          // 因为ChatUserRepositoryImpl返回的User.id实际上是commonUserId(10320)
          // 而participant的id字段也是10320，referId是10322
          if (p1.id == currentReferId) {
               currentUserParticipantId = p1.id;
               opponentParticipant = p2;
               AppLogger.d("[ChatMessagesBloc] 匹配成功: 当前用户是participant1");
               AppLogger.d("[ChatMessagesBloc]   当前用户内部ID: $currentUserParticipantId");
               AppLogger.d("[ChatMessagesBloc]   对手用户: ${p2.nickName} (内部ID=${p2.id}, 外部ID=${p2.referId})");
           } else if (p2.id == currentReferId) {
               currentUserParticipantId = p2.id;
               opponentParticipant = p1;
               AppLogger.d("[ChatMessagesBloc] 匹配成功: 当前用户是participant2");
               AppLogger.d("[ChatMessagesBloc]   当前用户内部ID: $currentUserParticipantId");
               AppLogger.d("[ChatMessagesBloc]   对手用户: ${p1.nickName} (内部ID=${p1.id}, 外部ID=${p1.referId})");
           } else {
               AppLogger.d("[ChatMessagesBloc] Error: Current user (id: $currentReferId) not found in room participants!");
              AppLogger.d("[ChatMessagesBloc]   p1.id=${p1.id}, p1.referId=${p1.referId}");
              AppLogger.d("[ChatMessagesBloc]   p2.id=${p2.id}, p2.referId=${p2.referId}");
               emit(ChatMessagesError('Error: You are not a participant in this chat.'));
               return false; // Indicate failure
           }

           if (currentUserParticipantId == null || opponentParticipant == null) {
              emit(ChatMessagesError('Failed to identify participants in chat.'));
              return false; // Indicate failure
           }

           _opponent = opponentParticipant; // Store opponent
           AppLogger.d("[ChatMessagesBloc] =====ID映射完成=====");
           AppLogger.d("[ChatMessagesBloc] 最终结果:");
           AppLogger.d("[ChatMessagesBloc]   当前用户内部参与者ID: $currentUserParticipantId");
           AppLogger.d("[ChatMessagesBloc]   对手: ${_opponent?.nickName} (内部ID=${_opponent?.id}, 外部ID=${_opponent?.referId})");
           return true; // Indicate success
        },
      );

      // If room details failed or participant identification failed, stop here
      if (!success || currentUserParticipantId == null || opponentParticipant == null || fetchedRoomDetails == null) {
           return;
      }

      // Process message results now that we know room details are valid
      await messageResult.fold(
        (failure) async => emit(ChatMessagesError('Failed to load messages: ${failure.message}')),
        (messages) async {
          // 过滤掉撤回的消息
          final filteredMessages = messages.where((msg) => !msg.withdrawFlag && msg.type != 'revoke').toList();
          
          AppLogger.d("[ChatMessagesBloc] =====消息列表调试=====");
          AppLogger.d("[ChatMessagesBloc] 收到${filteredMessages.length}条消息");
          for (int i = 0; i < filteredMessages.length && i < 3; i++) {
            final msg = filteredMessages[i];
            AppLogger.d("[ChatMessagesBloc] 消息${i + 1}:");
            AppLogger.d("[ChatMessagesBloc]   messageId: ${msg.id}");
            AppLogger.d("[ChatMessagesBloc]   senderId(内部): ${msg.senderId}");
            AppLogger.d("[ChatMessagesBloc]   memberId: ${msg.memberId}");
            AppLogger.d("[ChatMessagesBloc]   doctorId: ${msg.doctorId}");
            AppLogger.d("[ChatMessagesBloc]   content: ${msg.context?.substring(0, msg.context!.length > 20 ? 20 : msg.context!.length)}...");
            AppLogger.d("[ChatMessagesBloc]   是否应该在右侧(senderId=$currentUserParticipantId): ${msg.senderId == currentUserParticipantId}");
          }
          
          // Emit loaded state with all necessary info
          emit(ChatMessagesLoaded(
            messages: filteredMessages, // 使用过滤后的消息
            opponent: opponentParticipant!,
            currentUserId: currentReferId, // Pass referId as currentUserId
            currentUserParticipantId: currentUserParticipantId!, // Pass internal ID
            isInitialLoad: true, // 标记为初始加载
            hasNewMessage: false,
            hasMore: messages.length >= 20 // 假设默认页大小为20
          ));

          // 4. Connect to WebSocket using the INTERNAL participant ID
          // TODO: Fetch token dynamically
          _token = 'eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjA5NjhhMDNkLTM1NzYtNDkzZi1iMjA5LTc2YWEzMzMwYzYzMCJ9.AJ_IIJypohoKS_5EJa7bpE5erREM9qqbFXNoeaTaD0tpGSDhaqcdeccjU2y4z3Y_MuXWyzBCoq24HPna6itjJQ';
          final String commonUserIdForWS = currentUserParticipantId!.toString(); // Use internal ID

          if (_token == null) {
            AppLogger.d("[ChatMessagesBloc] Error: Token is null, cannot connect WebSocket.");
             emit(ChatMessagesError("Authentication token not available."));
            return;
          }

          AppLogger.d("[ChatMessagesBloc] Connecting to WebSocket with commonUserIdForWS: $commonUserIdForWS (Internal Participant ID)");
          _connectAndSubscribeWebSocket(commonUserIdForWS, _token!); 
        },
      );

    } catch (e, stacktrace) { // Catch potential errors from Future.wait or elsewhere
      emit(ChatMessagesError('An unexpected error occurred: ${e.toString()}'));
      AppLogger.d("[ChatMessagesBloc] Error loading chat: $e\n$stacktrace");
    }
  }

  Future<void> _onLoadMoreChatMessages(
    LoadMoreChatMessages event,
    Emitter<ChatMessagesState> emit
  ) async {
    if (state is! ChatMessagesLoaded) return;
    final currentState = state as ChatMessagesLoaded;
    
    try {
      // 调用用例加载更多消息
      final result = await getMessageList(GetMessageListParams(
        chatId: event.chatId,
        pageNum: event.pageNum,
        pageSize: event.pageSize
      ));
      
      await result.fold(
        (failure) {
          emit(currentState.copyWith(
            error: () => failure.message,
            isInitialLoad: false,
            hasNewMessage: false
          ));
        },
        (moreMessages) {
          // 检查是否有更多消息
          final hasMore = moreMessages.isNotEmpty && moreMessages.length >= event.pageSize;
          
          // 合并消息并去重
          final allMessages = [...moreMessages, ...currentState.messages];
          final uniqueMessages = _removeDuplicateMessages(allMessages);
          
          emit(currentState.copyWith(
            messages: uniqueMessages,
            isInitialLoad: false,
            hasNewMessage: false,
            hasMore: hasMore,
            error: () => null
          ));
        },
      );
    } catch (e) {
      emit(currentState.copyWith(
        error: () => '加载更多消息失败: ${e.toString()}',
        isInitialLoad: false,
        hasNewMessage: false
      ));
    }
  }

  List<ChatMessage> _removeDuplicateMessages(List<ChatMessage> messages) {
    final uniqueMessages = <ChatMessage>[];
    final messageIds = <int>{};
    
    for (final message in messages) {
      // 过滤掉撤回的消息
      if (!message.withdrawFlag && message.type != 'revoke' && !messageIds.contains(message.id)) {
        messageIds.add(message.id);
        uniqueMessages.add(message);
      }
    }
    
    // 按时间排序
    uniqueMessages.sort((a, b) => a.createTime!.compareTo(b.createTime!));
    
    return uniqueMessages;
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
    AppLogger.d("[ChatMessagesBloc] =====发送消息调试=====");
    AppLogger.d("[ChatMessagesBloc] 消息类型: ${event.type}");
    AppLogger.d("[ChatMessagesBloc] 文件是否存在: ${event.file != null}");
    if (event.file != null) {
      AppLogger.d("[ChatMessagesBloc] 文件路径: ${event.file!.path}");
    }
    AppLogger.d("[ChatMessagesBloc] 当前用户类型: ${_currentUser!.type}");
    AppLogger.d("[ChatMessagesBloc] 当前用户referId(外部): ${_currentUser!.id}");
    AppLogger.d("[ChatMessagesBloc] 当前用户participantId(内部): ${loadedState.currentUserParticipantId}");
    AppLogger.d("[ChatMessagesBloc] 对手 participantId(内部): ${loadedState.opponent.id}");
    AppLogger.d("[ChatMessagesBloc] 对手 referId(外部): ${loadedState.opponent.referId}");
    
    final optimisticMessage = ChatMessage(
      id: Random().nextInt(1000000) + 1000000,
      chatId: chatId,
      senderId: loadedState.currentUserParticipantId, // Use participant ID for sender
      memberId: _currentUser!.type == 'MEMBER' ? loadedState.currentUserParticipantId : loadedState.opponent.id,
      doctorId: _currentUser!.type == 'DOCTOR' ? loadedState.currentUserParticipantId : loadedState.opponent.id,
      context: event.type == 'text' ? event.text! : '', // 对于文件类型，context留空，等待上传后填充URL
      type: event.type,
      createTime: DateTime.now(),
      withdrawFlag: false,
      status: MessageStatus.sending,
    );
    
    AppLogger.d("[ChatMessagesBloc] 创建的消息:");
    AppLogger.d("[ChatMessagesBloc]   senderId: ${optimisticMessage.senderId}");
    AppLogger.d("[ChatMessagesBloc]   memberId: ${optimisticMessage.memberId}");
    AppLogger.d("[ChatMessagesBloc]   doctorId: ${optimisticMessage.doctorId}");
    AppLogger.d("[ChatMessagesBloc]   内容: ${optimisticMessage.context?.substring(0, optimisticMessage.context!.length > 30 ? 30 : optimisticMessage.context!.length)}...");
    AppLogger.d("[ChatMessagesBloc] ========================");

    // 2. Emit state with optimistic message ADDED TO THE END
    emit(loadedState.copyWith(
      messages: [...loadedState.messages, optimisticMessage], // Append new message
      hasNewMessage: true,
      error: () => null
    ));

    // 3. Prepare Use Case parameters
    AppLogger.d("[ChatMessagesBloc] 准备发送参数:");
    AppLogger.d("[ChatMessagesBloc]   message.context: ${optimisticMessage.context}");
    AppLogger.d("[ChatMessagesBloc]   file: ${event.file}");
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
        AppLogger.d("Failed to send message: ${failure.message}");
      },
      (sentMessage) {
        AppLogger.d("[ChatMessagesBloc] Message sent successfully: ID=${sentMessage.id}, Context=${sentMessage.context}");
        // Replace optimistic message with confirmed message (map logic is fine)
        final updatedMessages = currentState.messages.map((msg) {
          return msg.id == optimisticMessage.id
              ? sentMessage.copyWith(status: MessageStatus.sent)
              : msg;
        }).toList();
        emit(currentState.copyWith(
          messages: updatedMessages,
          error: () => null,
          hasMessageSent: true, // 设置发送成功标志
        ));

        // 触发聊天列表更新事件
        EventBus().fireChatListUpdateEvent(ChatListUpdateEvent(
          chatId: chatId,
          lastMessage: sentMessage.context ?? '',
          lastMessageTime: sentMessage.createTime,
          // 发送消息不改变未读数，因为是自己发的
        ));
        AppLogger.d("[ChatMessagesBloc] Triggered chat list update for sent message");
      },
    );
  }

  void _onInternalMessageReceived(_MessageReceived event, Emitter<ChatMessagesState> emit) {
    if (state is ChatMessagesLoaded && _currentUser != null) {
      final currentState = state as ChatMessagesLoaded;
      final ChatMessageDto messageDto = event.messageDto;

      AppLogger.d("[Bloc] =====WebSocket消息接收调试=====");
      AppLogger.d("[Bloc] 接收到WebSocket消息ID: ${messageDto.id}");
      AppLogger.d("[Bloc] 消息内容: ${messageDto.context?.substring(0, messageDto.context!.length > 30 ? 30 : messageDto.context!.length)}...");
      AppLogger.d("[Bloc] DTO中的ID信息:");
      AppLogger.d("[Bloc]   memberId: ${messageDto.memberId}");
      AppLogger.d("[Bloc]   doctorId: ${messageDto.doctorId}");

      try {
        // 根据memberId和doctorId判断发送者
        // memberId有值说明是买家（participant1）发送的
        // doctorId有值说明是卖家（participant2）发送的
        int senderParticipantId;
        
        if (messageDto.memberId != null && messageDto.doctorId == null) {
          // 买家发送的消息，使用participant1的内部ID
          senderParticipantId = _currentRoom!.participant1.id;
          AppLogger.d("[Bloc] WebSocket消息: memberId=${messageDto.memberId}, 买家(participant1)发送, senderId=${senderParticipantId}");
        } else if (messageDto.doctorId != null && messageDto.memberId == null) {
          // 卖家发送的消息，使用participant2的内部ID
          senderParticipantId = _currentRoom!.participant2.id;
          AppLogger.d("[Bloc] WebSocket消息: doctorId=${messageDto.doctorId}, 卖家(participant2)发送, senderId=${senderParticipantId}");
        } else if (messageDto.memberId != null && messageDto.doctorId != null) {
          // 两者都有值，根据当前用户类型判断
          if (_currentUser!.type == 'MEMBER') {
            senderParticipantId = _currentRoom!.participant1.id;
            AppLogger.d("[Bloc] WebSocket消息: 两者都有值，当前用户是买家，使用participant1.id作为senderId=${senderParticipantId}");
          } else {
            senderParticipantId = _currentRoom!.participant2.id;
            AppLogger.d("[Bloc] WebSocket消息: 两者都有值，当前用户是卖家，使用participant2.id作为senderId=${senderParticipantId}");
          }
        } else {
          AppLogger.d("[Bloc] 错误: 消息DTO既没有memberId也没有doctorId. DTO: ${messageDto.toJson()}");
          emit(currentState.copyWith(error: () => "Received invalid message data from WebSocket"));
          return;
        }
        
        AppLogger.d("[Bloc] 确定的senderId(内部): $senderParticipantId");
        AppLogger.d("[Bloc] 当前用户participantId(内部): ${currentState.currentUserParticipantId}");
        AppLogger.d("[Bloc] 是当前用户发送的吗? ${senderParticipantId == currentState.currentUserParticipantId}");

        // Convert DTO to Entity
        final newMessage = messageDto.toEntity(
          currentUserId: currentState.currentUserId,
          senderId: senderParticipantId, // Pass determined sender ID
        );

        // 过滤掉撤回的消息，不添加到UI中
        if (newMessage.withdrawFlag || newMessage.type == 'revoke') {
          AppLogger.d("[Bloc] Received revoked message ${newMessage.id} from WebSocket, ignoring.");
          return;
        }

        // Check if message already exists (e.g., from optimistic update)
        final messageExists = currentState.messages.any((m) => m.id == newMessage.id);
        
        if (!messageExists) {
             // FIX: Append the new message to the END of the list
            emit(currentState.copyWith(
              messages: [...currentState.messages, newMessage], // Append new message
            ));
             AppLogger.d("[Bloc] Appended new message ${newMessage.id} from WebSocket");

             // Trigger callback to update chat list locally
             if (onNewMessageReceived != null) {
               onNewMessageReceived!(newMessage);
             }

             // 如果不是自己发送的消息，触发聊天列表更新事件
             if (senderParticipantId != currentState.currentUserParticipantId) {
               EventBus().fireChatListUpdateEvent(ChatListUpdateEvent(
                 chatId: chatId,
                 lastMessage: newMessage.context ?? '',
                 lastMessageTime: newMessage.createTime,
                 unreadCountDelta: 1, // 收到别人的新消息，未读数+1
               ));
               AppLogger.d("[Bloc] Triggered chat list update for received message from other user");
             }
        } else {
             AppLogger.d("[Bloc] Message ${newMessage.id} from WebSocket already exists, ignoring.");
        }

      } catch (e) {
        AppLogger.d("[Bloc] Error processing WebSocket message: $e");
        // FIX: Wrap error message in ValueGetter
        emit(currentState.copyWith(error: () => "Error processing received message"));
      }
    } else {
       AppLogger.d("[Bloc] Received WebSocket message but state is not ChatMessagesLoaded or currentUser is null. State: $state");
    }
  }

  Future<void> _onRevokeMessageRequested(
    RevokeMessageRequested event,
    Emitter<ChatMessagesState> emit,
  ) async {
    if (state is! ChatMessagesLoaded) return;
    final loadedState = state as ChatMessagesLoaded;

    // 保存撤回前的原始消息状态用于失败时恢复
    final originalMessage = loadedState.messages.firstWhere(
      (msg) => msg.id == event.messageId,
      orElse: () => throw Exception('Message not found'),
    );

    // Optimistic update - 立即从列表中移除消息
    final updatedMessagesOptimistic = loadedState.messages
        .where((msg) => msg.id != event.messageId)
        .toList();
    
    emit(loadedState.copyWith(messages: updatedMessagesOptimistic, error: () => null));

    final result = await revokeMessage(RevokeMessageParams(messageId: event.messageId));

    if (state is! ChatMessagesLoaded) return;
    final currentState = state as ChatMessagesLoaded;

    result.fold(
      (failure) {
        // 撤回失败，恢复原始消息到列表中
        final revertedMessages = [...currentState.messages];
        // 找到原始消息应该插入的位置（保持时间顺序）
        int insertIndex = revertedMessages.length;
        for (int i = 0; i < revertedMessages.length; i++) {
          if (revertedMessages[i].createTime!.isAfter(originalMessage.createTime!)) {
            insertIndex = i;
            break;
          }
        }
        revertedMessages.insert(insertIndex, originalMessage);
        
        emit(currentState.copyWith(
          messages: revertedMessages,
          error: () => '撤回失败: ${failure.message}',
        ));
        AppLogger.d("Failed to revoke message: ${failure.message}");
      },
      (_) {
        AppLogger.d("Message revoked successfully: ${event.messageId}");
        
        // 更新聊天室的最后一条消息（如果撤回的是最后一条消息）
        ChatRoom? updatedRoom = _currentRoom;
        if (_currentRoom != null && 
            _currentRoom!.lastMessage != null && 
            _currentRoom!.lastMessage!.id == event.messageId) {
          // 如果撤回的是最后一条消息，更新为新的最后一条消息
          final newLastMessage = currentState.messages.isNotEmpty 
              ? currentState.messages.last 
              : null;
          updatedRoom = _currentRoom!.copyWith(lastMessage: newLastMessage);
          _currentRoom = updatedRoom;
        }
        
        // 撤回成功，消息已从列表中移除，设置撤回标志
        emit(currentState.copyWith(
          error: () => null,
          hasMessageRevoked: true,
        ));
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
        AppLogger.d("Failed to delete messages: ${failure.message}");
         // FIX: Wrap error message in ValueGetter
         emit(loadedState.copyWith(error: () => 'Failed to delete: ${failure.message}'));
      },
      (_) {
        AppLogger.d("Messages deleted successfully: ${event.messageIds}");
        // FIX: Wrap null in ValueGetter
         emit(currentState.copyWith(error: () => null));
      },
    );
  }

  void _onResetMessageRevokedFlag(
    ResetMessageRevokedFlag event,
    Emitter<ChatMessagesState> emit,
  ) {
    if (state is ChatMessagesLoaded) {
      final currentState = state as ChatMessagesLoaded;
      emit(currentState.copyWith(hasMessageRevoked: false));
    }
  }

  void _onResetMessageSentFlag(
    ResetMessageSentFlag event,
    Emitter<ChatMessagesState> emit,
  ) {
    if (state is ChatMessagesLoaded) {
      final currentState = state as ChatMessagesLoaded;
      emit(currentState.copyWith(hasMessageSent: false));
    }
  }

  void _connectAndSubscribeWebSocket(String commonUserIdForWS, String token) {
     AppLogger.d("[WebSocket] Attempting to connect for user $commonUserIdForWS");
     // Cancel previous subscription before connecting/subscribing again
     _messageSubscription?.cancel();
     
     // Connect and then subscribe
     // Assuming connect is async or returns a future that completes on connection
     // or status stream indicates connection.
     // For simplicity, calling subscribe immediately after connect request.
     webSocketDataSource.connect(commonUserIdForWS, token); 

     // Subscribe to the messages stream
     _messageSubscription = webSocketDataSource.messageStream.listen(
       (messageDto) {
         // Ensure DTO is not null before adding event
         if (messageDto != null) { 
             add(_MessageReceived(messageDto));
         } else {
            AppLogger.d("[WebSocket] Received null message DTO from stream.");
         }
       },
       onError: (error) {
          AppLogger.d("[WebSocket] Error on message stream: $error");
          // Handle stream error, maybe emit failure state
          emit(ChatMessagesError("WebSocket connection error."));
       },
       onDone: () {
         AppLogger.d("[WebSocket] Message stream closed.");
         // Handle stream closing, maybe try reconnecting or emit state
       }
     );
     // TODO: Also listen to webSocketDataSource.status stream for connection feedback
  }

  @override
  Future<void> close() {
    AppLogger.d("[Bloc] Closing ChatMessagesBloc for chatId: $chatId");
    _messageSubscription?.cancel();
    // ❌ 不要断开 WebSocket！它是全局单例，应该保持连接
    // webSocketDataSource.disconnect();
    return super.close();
  }
} 