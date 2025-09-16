import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/get_message_list.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/send_message.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/revoke_message.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/delete_chat_message.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/bloc/chat_list/chat_list_bloc.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/services/chat_preload_service.dart';
import 'package:dskk_flutter_refactor/features/chat/data/datasources/i_chat_local_data_source.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_room.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/get_chat_room_details.dart';

part 'message_list_state.dart';
part 'message_list_cubit.freezed.dart';

/// Cubit for managing chat message list
class MessageListCubit extends Cubit<MessageListState> {
  /// Payment prompt messages pool (without "free" terminology)
  static const List<String> _paymentPromptMessages = [
    "如果您对这次咨询感兴趣，可以选择付费支持获得更深入的交流",
    "想要了解更多？选择合适的服务套餐继续深入交流",
    "觉得有帮助吗？付费支持可以获得更专业的咨询服务",
    "感兴趣的话，可以选择付费获得持续的专业指导",
    "如果需要更详细的建议，欢迎选择付费支持",
    "想要深入探讨？选择服务套餐获得更全面的咨询",
    "对话很愉快！付费后可以获得更多专业建议",
    "希望继续交流？选择合适的套餐支持专业服务",
  ];
  final GetMessageList _getMessageList;
  final SendMessage _sendMessage;
  final RevokeMessage _revokeMessage;
  final DeleteChatMessage _deleteChatMessage;
  final ChatPreloadService? _preloadService; // 可选的预加载服务
  final IChatLocalDataSource? _localDataSource; // 本地数据源
  final GetChatRoomDetails? _getChatRoomDetails; // 获取聊天室详情
  
  MessageListCubit({
    required GetMessageList getMessageList,
    required SendMessage sendMessage,
    required RevokeMessage revokeMessage,
    required DeleteChatMessage deleteChatMessage,
    ChatPreloadService? preloadService,
    IChatLocalDataSource? localDataSource,
    GetChatRoomDetails? getChatRoomDetails,
  })  : _getMessageList = getMessageList,
        _sendMessage = sendMessage,
        _revokeMessage = revokeMessage,
        _deleteChatMessage = deleteChatMessage,
        _preloadService = preloadService,
        _localDataSource = localDataSource,
        _getChatRoomDetails = getChatRoomDetails,
        super(const MessageListState.initial());
  
  int? _currentChatId;
  int? _currentUserParticipantId; // 添加当前用户的participant ID
  final List<ChatMessage> _allMessages = [];
  bool _hasMore = true;
  int _currentPage = 1;
  static const int _pageSize = 50;
  BuildContext? _context; // 保存context用于预加载
  
  // 轻咨询付费提示相关
  bool _isSeller = false; // 当前用户是否是卖家
  bool _isLightConsultation = false; // 是否是轻咨询模式
  int _roundCount = 0; // 对话轮次计数
  ChatRoom? _currentChatRoom; // 当前聊天室信息
  
  /// Set current user participant ID
  void setCurrentUserParticipantId(int participantId) {
    _currentUserParticipantId = participantId;
  }
  
  /// Set seller status and consultation mode
  void setSellerAndConsultationMode({
    required bool isSeller,
    required bool isLightConsultation,
  }) {
    _isSeller = isSeller;
    _isLightConsultation = isLightConsultation;
  }
  
  /// Set context for preloading
  void setContext(BuildContext context) {
    _context = context;
  }
  
  /// Trigger image preloading for current messages
  void _triggerImagePreload(List<ChatMessage> messages) {
    if (_preloadService != null && _context != null && _context!.mounted) {
      // 延迟执行预加载，避免阻塞UI
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_context!.mounted) {
          _preloadService.preloadMessageImages(_context!, messages);
        }
      });
    }
  }
  
  /// Load initial messages for a chat
  Future<void> loadMessages(int chatId) async {
    if (state is _Loading) return;
    
    emit(const MessageListState.loading());
    _currentChatId = chatId;
    _allMessages.clear();
    _currentPage = 1;
    _hasMore = true;
    _roundCount = 0;
    
    final result = await _getMessageList(
      GetMessageListParams(
        chatId: chatId,
        pageNum: _currentPage,
        pageSize: _pageSize,
      ),
    );
    
    result.fold(
      (failure) => emit(MessageListState.error(failure.toString())),
      (messages) async {
        // 消息已经是降序排列（新到旧），直接添加
        _allMessages.addAll(messages);
        _hasMore = messages.length >= _pageSize;
        
        // 计算对话轮次并检查付费提示状态
        await _initializePaymentPromptStatus(messages);
        
        emit(MessageListState.loaded(
          messages: List.from(_allMessages),
          hasMore: _hasMore,
        ));
        
        // 检查是否需要插入本地付费提示（买卖双方都检查）
        if (_isLightConsultation) {
          // 延迟执行避免阻塞响应
          Future.microtask(() => _checkAndInsertLocalPaymentPrompt());
        }
        
        // 触发图片预加载
        _triggerImagePreload(messages);
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
        
        // 触发图片预加载
        _triggerImagePreload(messages);
      },
    );
  }
  
  /// Send a document message (PDF, DOC, etc.)
  Future<void> sendDocumentMessage({
    required String url,
    required String fileName,
    required int fileSize,
    required String fileExtension,
  }) async {
    if (_currentChatId == null) return;
    
    // 构建文件消息的 context（JSON格式字符串）
    final fileContext = {
      'url': url,
      'name': fileName,
      'size': fileSize,
      'extension': fileExtension,
    };
    
    // 转换为 JSON 字符串
    final jsonString = jsonEncode(fileContext);
    
    // 调用通用的文件发送方法，直接传递 JSON 字符串
    await sendFileMessage(
      filePath: jsonString,  // 直接使用 JSON 字符串
      fileType: 'file',
      metadata: null,  // 不需要额外的 metadata
    );
  }
  
  /// Send an image message with URL
  Future<void> sendImageMessage({
    required String url,
    String? fileName,
  }) async {
    if (_currentChatId == null) return;
    
    // 构建图片消息的 context（JSON格式字符串）
    final imageContext = {
      'url': url,
      'name': fileName ?? 'image.jpg',
    };
    
    // 转换为 JSON 字符串
    final jsonString = jsonEncode(imageContext);
    
    // 调用通用的文件发送方法，传递 JSON 字符串
    await sendFileMessage(
      filePath: jsonString,  // 传递 JSON 字符串而不是 URL
      fileType: 'image',
      metadata: null,  // 不需要额外的 metadata
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

    // Import File class
    final file = File(filePath);

    // For audio and image files, we need to upload first
    // Leave context empty for files that need upload
    final needsUpload = fileType == 'audio' || fileType == 'image';
    final content = needsUpload
        ? '' // Empty for files that need upload
        : (metadata != null ? jsonEncode(metadata) : filePath);

    // Create optimistic message
    // 使用本地时间，因为这是用于显示的
    // 当服务器返回真实消息时，会用服务器时间替换
    final optimisticMessage = ChatMessage(
      id: -DateTime.now().millisecondsSinceEpoch,
      chatId: _currentChatId!,
      senderId: _currentUserParticipantId ?? 0, // 使用设置的当前用户participant ID
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

    // Send to backend with file if needed
    final result = await _sendMessage(
      SendMessageParams(
        message: optimisticMessage,
        file: needsUpload ? file : null, // Pass file for upload
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

        // 通知 ChatListBloc 更新最后一条消息
        _updateChatListLastMessage(sentMessage);

        // 检查是否需要插入本地付费提示（买卖双方都检查）
        if (_isLightConsultation) {
          // 延迟执行避免阻塞响应
          Future.microtask(() => _checkAndInsertLocalPaymentPrompt());
        }
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
  
  /// Add received message from WebSocket
  void addReceivedMessage(ChatMessage message) {
    // 检查消息是否属于当前聊天室
    if (_currentChatId != null && message.chatId == _currentChatId) {
      // 检查消息是否已存在（防止重复）
      final exists = _allMessages.any((m) => m.id == message.id);
      if (!exists) {
        // 添加到消息列表开头（最新消息）
        _allMessages.insert(0, message);
        
        // 更新UI
        _emitLoadedState();
        
        // 更新聊天列表的最后一条消息
        _updateChatListLastMessage(message);
        
        // 如果是轻咨询，检查是否需要显示付费提示
        if (_isLightConsultation) {
          // 重新计算轮次
          _calculateRoundCount(_allMessages);
          // 检查付费提示
          Future.microtask(() => _checkAndInsertLocalPaymentPrompt());
        }
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
  
  /// 通知 ChatListBloc 更新最后一条消息
  void _updateChatListLastMessage(ChatMessage message) {
    try {
      final chatListBloc = GetIt.instance<ChatListBloc>();
      if (_currentChatId != null) {
        chatListBloc.add(UpdateChatRoomLastMessage(
          chatId: _currentChatId!,
          lastMessage: message,
        ));
      }
    } catch (e) {
      // 如果获取 ChatListBloc 失败，忽略错误
      // 这可能发生在某些测试场景或独立预览场景中
    }
  }
  
  /// 初始化付费提示状态
  Future<void> _initializePaymentPromptStatus(List<ChatMessage> messages) async {
    if (!_isLightConsultation || _currentChatId == null) return;
    
    // 1. 计算对话轮次
    _calculateRoundCount(messages);
    
    // 2. 获取聊天室详情以备后用
    if (_getChatRoomDetails != null && _currentChatRoom == null) {
      final roomResult = await _getChatRoomDetails(
        GetChatRoomDetailsParams(chatId: _currentChatId!),
      );
      roomResult.fold(
        (failure) => print('[MessageListCubit] Failed to get chat room detail: $failure'),
        (room) => _currentChatRoom = room,
      );
    }
  }
  
  /// 计算对话轮次
  void _calculateRoundCount(List<ChatMessage> messages) {
    if (messages.isEmpty || _currentUserParticipantId == null) {
      _roundCount = 0;
      return;
    }
    
    // 按时间排序（旧到新）
    final sortedMessages = List<ChatMessage>.from(messages)
      ..sort((a, b) => a.createTime.compareTo(b.createTime));
    
    int buyerMessageCount = 0;
    int sellerMessageCount = 0;
    
    for (final msg in sortedMessages) {
      // 跳过系统消息和付费提示
      if (msg.type == 'payment_prompt' || msg.type == 'system') continue;
      
      if (msg.senderId == _currentUserParticipantId) {
        if (_isSeller) {
          sellerMessageCount++;
        } else {
          buyerMessageCount++;
        }
      } else {
        if (_isSeller) {
          buyerMessageCount++;
        } else {
          sellerMessageCount++;
        }
      }
    }
    
    // 一轮对话 = min(买家消息数, 卖家消息数)
    _roundCount = buyerMessageCount < sellerMessageCount ? buyerMessageCount : sellerMessageCount;
  }
  
  /// 检查并插入本地付费提示（纯前端实现，不调用后端）
  Future<void> _checkAndInsertLocalPaymentPrompt() async {
    if (!_isLightConsultation || _currentChatId == null) return;
    
    // 获取显示次数
    final count = await _localDataSource?.getPaymentPromptCount(_currentChatId!) ?? 0;
    
    // 已显示4次，不再提醒（1-5-10-20共4次）
    if (count >= 4) return;
    
    // 判断是否触发（1-5-10-20轮次）
    bool shouldShow = false;
    if (count == 0 && _roundCount >= 1) {
      shouldShow = true; // 第一次：1轮（便于测试）
    } else if (count == 1 && _roundCount >= 5) {
      shouldShow = true; // 第二次：5轮
    } else if (count == 2 && _roundCount >= 10) {
      shouldShow = true; // 第三次：10轮  
    } else if (count == 3 && _roundCount >= 20) {
      shouldShow = true; // 第四次：20轮
    }
    
    if (!shouldShow) return;
    
    // 创建虚拟消息
    final virtualMessage = _createLocalPaymentPromptMessage();
    
    // 插入到消息列表开头（最新消息）
    _allMessages.insert(0, virtualMessage);
    
    // 更新计数
    await _localDataSource?.savePaymentPromptCount(_currentChatId!, count + 1);
    
    // 更新UI
    _emitLoadedState();
  }
  
  /// 创建本地付费提示消息
  ChatMessage _createLocalPaymentPromptMessage() {
    final random = Random();
    final promptText = _paymentPromptMessages[random.nextInt(_paymentPromptMessages.length)];
    
    return ChatMessage(
      id: -DateTime.now().millisecondsSinceEpoch, // 负数ID标识虚拟消息
      chatId: _currentChatId!,
      senderId: 0, // 系统消息
      type: 'payment_prompt',
      context: jsonEncode({
        'type': 'payment_prompt',
        'source': 'local', // 标记为本地生成
        'content': promptText,
        'productId': _currentChatRoom?.productId?.toString(),
        'variants': [
          {'id': 1, 'price': 30, 'name': '基础咨询'},
          {'id': 2, 'price': 50, 'name': '标准咨询', 'recommended': true},
          {'id': 3, 'price': 100, 'name': '深度咨询'},
        ],
      }),
      createTime: DateTime.now(),
      withdrawFlag: false,
      status: MessageStatus.read,
    );
  }
  
  /// 发送简单的状态更新
  void _emitLoadedState() {
    emit(MessageListState.loaded(
      messages: List.from(_allMessages),
      hasMore: _hasMore,
    ));
  }
  
  /// Send a new message (extended with payment prompt check)
  Future<void> sendTextMessage(String text) async {
    if (_currentChatId == null) return;
    
    final currentState = state;
    if (currentState is! _Loaded) return;
    
    // 创建乐观消息（保持原有逻辑）
    final optimisticMessage = ChatMessage(
      id: -DateTime.now().millisecondsSinceEpoch,
      chatId: _currentChatId!,
      senderId: _currentUserParticipantId ?? 0,
      context: text,
      type: 'text',
      createTime: DateTime.now(),
      withdrawFlag: false,
      status: MessageStatus.sending,
    );
    
    // 添加乐观消息
    _allMessages.insert(0, optimisticMessage);
    
    // 更新轮次计数（如果是卖家发送）
    if (_isSeller) {
      // 重新计算轮次
      _calculateRoundCount(_allMessages);
    }
    
    emit(MessageListState.loaded(
      messages: List.from(_allMessages),
      hasMore: _hasMore,
    ));
    
    // 发送到后端
    final result = await _sendMessage(
      SendMessageParams(message: optimisticMessage),
    );
    
    result.fold(
      (failure) {
        // 移除失败的消息
        _allMessages.removeWhere((m) => m.id == optimisticMessage.id);
        emit(MessageListState.loaded(
          messages: List.from(_allMessages),
          hasMore: _hasMore,
          sendError: failure.toString(),
        ));
      },
      (sentMessage) async {
        // 替换乐观消息
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
        
        // 通知更新最后一条消息
        _updateChatListLastMessage(sentMessage);
        
        // 检查是否需要插入本地付费提示（买卖双方都检查）
        if (_isLightConsultation) {
          // 延迟执行避免阻塞响应
          Future.microtask(() => _checkAndInsertLocalPaymentPrompt());
        }
      },
    );
  }
}