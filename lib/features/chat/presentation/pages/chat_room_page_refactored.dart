import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/app/di/injection_container.dart';
import 'package:dskk_flutter_refactor/core/storage/secure_storage_repository.dart';
import 'package:dskk_flutter_refactor/core/events/event_bus.dart';

import 'package:dskk_flutter_refactor/features/chat/presentation/cubit/chat/chat_cubit.dart' as chat_cubit;
import 'package:dskk_flutter_refactor/features/chat/presentation/cubit/message_list/message_list_cubit.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/cubit/websocket/websocket_cubit.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/cubit/message_queue/message_queue_cubit.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/widgets/custom_chat_list.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/widgets/custom_input_bar.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/widgets/product_chat_header.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart' as domain;
import 'package:dskk_flutter_refactor/features/chat/domain/entities/participant.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/bloc/chat_list/chat_list_bloc.dart';

class ChatRoomPageRefactored extends StatefulWidget {
  final int chatId;
  final VoidCallback? onMessagesLoaded;
  final Function(int chatId, domain.ChatMessage? newLastMessage)? onMessageRevoked;
  final VoidCallback? onMessageSent;

  const ChatRoomPageRefactored({
    super.key,
    required this.chatId,
    this.onMessagesLoaded,
    this.onMessageRevoked,
    this.onMessageSent,
  });

  @override
  State<ChatRoomPageRefactored> createState() => _ChatRoomPageRefactoredState();
}

class _ChatRoomPageRefactoredState extends State<ChatRoomPageRefactored> {
  late final chat_cubit.ChatCubit _chatCubit;
  late final MessageListCubit _messageListCubit;
  late final WebSocketCubit _webSocketCubit;
  late final MessageQueueCubit _messageQueueCubit;
  
  final ScrollController _scrollController = ScrollController();
  bool _showProductHeader = true;
  bool _isLoadingMore = false;
  bool _showScrollToBottomButton = false;
  int _currentUserParticipantId = 0;
  Participant? _opponent;
  double _lastScrollOffset = 0;
  int? _currentUserId; // 存储当前用户ID
  
  @override
  void initState() {
    super.initState();
    
    // Initialize cubits
    _chatCubit = getIt<chat_cubit.ChatCubit>();
    _messageListCubit = getIt<MessageListCubit>();
    _webSocketCubit = getIt<WebSocketCubit>();
    _messageQueueCubit = getIt<MessageQueueCubit>();
    
    // Setup scroll listener
    _scrollController.addListener(_onScroll);
    
    // Enter chat room
    _initializeChat();
  }
  
  Future<void> _initializeChat() async {
    // 获取当前用户ID (common_user_id)
    try {
      final secureStorage = getIt<FlutterSecureStorage>();
      final commonUserIdStr = await secureStorage.read(key: 'common_user_id');
      if (commonUserIdStr != null) {
        final userId = int.tryParse(commonUserIdStr);
        if (userId != null) {
          setState(() {
            _currentUserId = userId;
          });
          print('DEBUG: Got current user ID from storage: $_currentUserId');
        } else {
          print('ERROR: Failed to parse common_user_id: $commonUserIdStr');
        }
      } else {
        print('WARNING: No common_user_id found in storage');
      }
    } catch (e) {
      print('ERROR: Failed to get current user ID: $e');
    }

    // Enter the chat room
    await _chatCubit.enterChatRoom(widget.chatId);

    // 进入聊天室时，重置该聊天室的未读数
    EventBus().fireChatListUpdateEvent(ChatListUpdateEvent(
      chatId: widget.chatId,
      resetUnread: true,
    ));
    print('[ChatRoomPage] Reset unread count for chat ${widget.chatId}');

    // Get chat room info and set current user participant ID
    // 修改为await确保在设置ID之后再继续
    await Future.microtask(() {
      _chatCubit.state.maybeWhen(
        ready: (chatRoom, lastReceivedMessage, hasNewMessage) {
          // 使用获取的currentUserId来确定当前用户是哪个参与者
          final currentUserParticipant = chatRoom.participants.firstWhere(
            (p) => p.id == _currentUserId,
            orElse: () {
              // 如果找不到，直接报错
              print('ERROR: Could not find participant with id=$_currentUserId in room ${chatRoom.id}');
              print('ERROR: Available participants: ${chatRoom.participants.map((p) => 'id=${p.id}, type=${p.type}').join(', ')}');
              throw Exception('Current user is not a participant in this chat room');
            },
          );

          final opponent = chatRoom.participants.firstWhere(
            (p) => p.id != currentUserParticipant.id,
            orElse: () => chatRoom.participants.last,
          );

          // Set these values immediately
          setState(() {
            _currentUserParticipantId = currentUserParticipant.id;
            _opponent = opponent;
          });

          // 同时设置到 MessageListCubit
          _messageListCubit.setCurrentUserParticipantId(currentUserParticipant.id);

          // 设置轻咨询模式 - 默认全部启用轻咨询
          // 判断当前用户是否是卖家
          // 最可靠的方法：直接从 ChatRoomDto 的判断结果获取
          // 在 ChatRoomDto.toEntity 中已经正确识别了：
          // - 如果 currentUserId == doctorId，则是卖家(DOCTOR)
          // - 如果 currentUserId == memberId，则是买家(MEMBER)

          // 我们知道 participant1 总是当前用户，participant2 总是对方
          // 所以判断逻辑应该基于原始的聊天室数据
          // 从日志可以看到 "[ChatRoomDto] Current user (by id) is DOCTOR (seller)"
          // 这个判断是正确的，我们应该复用这个结果

          // 使用 ChatRoom 实体中的 doctorId 字段来判断是否是卖家
          // API 返回的结构中：doctorId 是卖家的 participant ID，memberId 是买家的 participant ID
          // 这是固定的业务规则，不会变化
          bool isSeller = false;

          // 直接使用 ChatRoom 实体的 doctorId 字段进行判断
          // 如果当前用户的 participant ID 等于 doctorId，则是卖家
          if (chatRoom.doctorId != null && currentUserParticipant.id == chatRoom.doctorId) {
            isSeller = true;
            print('[ChatRoom] Current user is SELLER (doctor) - participantId: ${currentUserParticipant.id} matches doctorId: ${chatRoom.doctorId}');
          } else if (chatRoom.memberId != null && currentUserParticipant.id == chatRoom.memberId) {
            isSeller = false;
            print('[ChatRoom] Current user is BUYER (member) - participantId: ${currentUserParticipant.id} matches memberId: ${chatRoom.memberId}');
          } else {
            // 如果无法确定，记录错误信息
            print('[ChatRoom] WARNING: Cannot determine user role');
            print('[ChatRoom] currentUserParticipant.id: ${currentUserParticipant.id}');
            print('[ChatRoom] chatRoom.doctorId: ${chatRoom.doctorId}');
            print('[ChatRoom] chatRoom.memberId: ${chatRoom.memberId}');
            // 默认设为买家
            isSeller = false;
          }

          print('[ChatRoom] Analyzing role - currentUserParticipantId: $_currentUserParticipantId');
          print('[ChatRoom] Current user: ${currentUserParticipant.nickName}, opponent: ${opponent.nickName}');
          print('[ChatRoom] Final determination - isSeller: $isSeller');
          _messageListCubit.setSellerAndConsultationMode(
            isSeller: isSeller,
            isLightConsultation: true, // 默认启用轻咨询模式
          );

          print('DEBUG: Set currentUserParticipantId to $_currentUserParticipantId at initialization');
          print('DEBUG: Current user participant: id=${currentUserParticipant.id}, type=${currentUserParticipant.type}');
          print('DEBUG: Opponent participant: id=${opponent.id}, type=${opponent.type}');
          print('DEBUG: Light consultation mode enabled, isSeller: $isSeller');
        },
        orElse: () {},
      );
    });

    // Load initial messages
    await _messageListCubit.loadMessages(widget.chatId);
    
    // Connect WebSocket with user credentials
    try {
      final storage = getIt<ISecureStorageRepository>();
      final commonUserId = await storage.getCommonUserId();
      final token = await storage.getToken();
      
      if (commonUserId != null && token != null) {
        _webSocketCubit.connect(
          commonUserId: commonUserId.toString(),
          token: token,
        );
        print('[ChatRoom] WebSocket connecting with userId: $commonUserId');
      } else {
        print('[ChatRoom] WARNING: Cannot connect WebSocket - missing credentials');
      }
    } catch (e) {
      print('[ChatRoom] ERROR connecting WebSocket: $e');
    }
    
    // Notify that messages have been loaded
    widget.onMessagesLoaded?.call();
  }
  
  @override
  void dispose() {
    // Leave chat room
    _chatCubit.leaveChatRoom();

    // ❌ 不要在这里断开 WebSocket！
    // WebSocket 是全局单例，应该保持连接，以便聊天列表接收实时消息
    // 只在用户登出或应用关闭时才应该断开 WebSocket
    // _webSocketCubit.disconnect();

    // Dispose scroll controller
    _scrollController.dispose();

    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.hasClients) {
      final currentScroll = _scrollController.offset;
      
      // In reversed list, scrolling up means offset is increasing
      // scrolling down means offset is decreasing (towards 0)
      final isScrollingUp = currentScroll > _lastScrollOffset;
      final scrollDelta = (currentScroll - _lastScrollOffset).abs();
      
      // Update scroll to bottom button visibility
      setState(() {
        _showScrollToBottomButton = currentScroll > 300;
        
        // Hide product header when scrolling up (viewing older messages)
        // Show product header when scrolling down (towards recent messages)
        if (scrollDelta > 5) { // Add threshold to avoid flickering
          if (isScrollingUp && currentScroll > 100) {
            _showProductHeader = false;
          } else if (!isScrollingUp) {
            _showProductHeader = true;
          }
        }
      });
      
      _lastScrollOffset = currentScroll;
    }
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0, // In reversed list, bottom is at 0
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  
  void _handleSendPressed(String text) {
    // Use MessageListCubit's sendTextMessage which handles everything
    _messageListCubit.sendTextMessage(text);
    
    // Notify message sent
    widget.onMessageSent?.call();
    
    // Scroll to bottom after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToBottom();
    });
  }
  
  Future<void> _handleEndReached() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    await _messageListCubit.loadMoreMessages();
    
    setState(() {
      _isLoadingMore = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _chatCubit),
        BlocProvider.value(value: _messageListCubit),
        BlocProvider.value(value: _webSocketCubit),
        BlocProvider.value(value: _messageQueueCubit),
      ],
      child: GestureDetector(
        // 点击聊天区域时隐藏键盘
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFEDEDED),
          // FAB will be added later when we have access to scroll controller
          appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
          shadowColor: Colors.grey[300],
          centerTitle: true,
          leading: BackButton(
            onPressed: () {
              // Check if messages were loaded
              bool chatWasViewed = _messageListCubit.state.maybeWhen(
                loaded: (messages, hasMore, isLoadingMore, loadMoreError, sendError, actionError,
                        substantiveMessageCount, isPaid, hasShownPaymentDialog, userRole, productId) => true,
                orElse: () => false,
              );
              Navigator.pop(context, chatWasViewed);
            },
          ),
          title: BlocBuilder<chat_cubit.ChatCubit, chat_cubit.ChatState>(
            builder: (context, state) {
              return state.when(
                initial: () => Text(appLocalizations.chat_loading),
                loading: () => Text(appLocalizations.chat_loading),
                ready: (chatRoom, lastReceivedMessage, hasNewMessage) {
                  // 如果_currentUserId还没加载完成，显示加载中
                  if (_currentUserId == null) {
                    print('DEBUG: _currentUserId is still loading when trying to display title');
                    return Text(appLocalizations.chat_loading);
                  }
                  
                  // 找到当前用户的参与者对象
                  final currentUserParticipant = chatRoom.participants.firstWhere(
                    (p) => p.id == _currentUserId,
                    orElse: () {
                      print('ERROR: Could not find current user participant with id=$_currentUserId');
                      print('ERROR: Available participants: ${chatRoom.participants.map((p) => 'id=${p.id}, name=${p.nickName}').join(', ')}');
                      throw Exception('Current user is not in this chat room');
                    },
                  );
                  
                  // 找到对方参与者 - 使用不同的ID
                  final opponent = chatRoom.participants.firstWhere(
                    (p) => p.id != currentUserParticipant.id,
                    orElse: () {
                      print('ERROR: Could not find opponent, currentUserParticipantId=${currentUserParticipant.id}');
                      print('ERROR: Participants: ${chatRoom.participants.map((p) => 'id=${p.id}, name=${p.nickName}').join(', ')}');
                      throw Exception('Could not find opponent in chat room');
                    },
                  );
                  
                  print('DEBUG: Title display - currentUserId=$_currentUserId, currentParticipantId=${currentUserParticipant.id}, opponentId=${opponent.id}, opponentName=${opponent.nickName}');
                  
                  return Text(opponent.nickName ?? appLocalizations.chat_unknown_user);
                },
                error: (message) => Text(appLocalizations.chat_unknown_user),
              );
            },
          ),
        ),
        body: Column(
          children: [
            // Product header
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _showProductHeader ? null : 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showProductHeader ? 1.0 : 0.0,
                child: BlocBuilder<chat_cubit.ChatCubit, chat_cubit.ChatState>(
                  builder: (context, state) {
                    return state.maybeWhen(
                      ready: (chatRoom, lastReceivedMessage, hasNewMessage) {
                        if (chatRoom.hasProduct) {
                          return ProductChatHeader(
                            chatRoom: chatRoom,
                            actionText: '查看详情',
                            onProductTap: () {
                              if (chatRoom.productId != null) {
                                context.push('/home/product/${chatRoom.productId}');
                              }
                            },
                            onActionTap: () {
                              if (chatRoom.productId != null) {
                                context.push('/home/product/${chatRoom.productId}');
                              }
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      orElse: () => const SizedBox.shrink(),
                    );
                  },
                ),
              ),
            ),
            
            // Chat messages
            Expanded(
              child: Stack(
                children: [
                  // WebSocket message listener - listens for new messages from ChatCubit
                  BlocListener<chat_cubit.ChatCubit, chat_cubit.ChatState>(
                    listener: (context, state) {
                      state.maybeWhen(
                        ready: (chatRoom, lastReceivedMessage, hasNewMessage) {
                          // When a new message is received via WebSocket
                          if (hasNewMessage && lastReceivedMessage != null) {
                            print('[ChatRoomPage] New message received via WebSocket: type=${lastReceivedMessage.type}, id=${lastReceivedMessage.id}');
                            // Add the message to the message list
                            _messageListCubit.addReceivedMessage(lastReceivedMessage);
                            
                            // Scroll to bottom for new messages
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_scrollController.hasClients) {
                                _scrollToBottom();
                              }
                            });
                          }
                        },
                        orElse: () {},
                      );
                    },
                    child: BlocConsumer<MessageListCubit, MessageListState>(
                      listener: (context, state) {
                      // Handle message events
                      state.maybeWhen(
                        loaded: (messages, hasMore, isLoadingMore, loadMoreError, sendError, actionError,
                                substantiveMessageCount, isPaid, hasShownPaymentDialog, userRole, productId) {
                          // Scroll to bottom on new message
                          if (messages.isNotEmpty) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_scrollController.hasClients && _scrollController.offset < 100) {
                                _scrollToBottom();
                              }
                            });
                          }
                        },
                        orElse: () {},
                      );
                    },
                    builder: (context, messageState) {
                      return BlocBuilder<chat_cubit.ChatCubit, chat_cubit.ChatState>(
                        builder: (context, chatState) {
                          // Get current user and opponent from chat state
                          final chatRoom = chatState.maybeWhen(
                            ready: (room, lastReceivedMessage, hasNewMessage) => room,
                            orElse: () => null,
                          );
                          
                          if (chatRoom == null) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          // Find current user participant using the stored user ID
                          if (_currentUserId == null) {
                            print('ERROR: _currentUserId is null in build method');
                            return Center(child: Text('Error: User ID not loaded'));
                          }
                          
                          final currentUserParticipant = chatRoom.participants.firstWhere(
                            (p) => p.id == _currentUserId,
                            orElse: () {
                              print('ERROR: Could not find participant with id=$_currentUserId in room ${chatRoom.id}');
                              print('ERROR: Available participants: ${chatRoom.participants.map((p) => 'id=${p.id}, type=${p.type}').join(', ')}');
                              throw Exception('Current user is not a participant in this chat room');
                            },
                          );
                          
                          final opponent = chatRoom.participants.firstWhere(
                            (p) => p.id != currentUserParticipant.id,
                            orElse: () => chatRoom.participants.last,
                          );
                          
                          // Update current user info
                          // Use participant ID (not referId) for message comparison
                          _currentUserParticipantId = currentUserParticipant.id;
                          _opponent = opponent;
                          
                          return messageState.when(
                            initial: () => const Center(child: CircularProgressIndicator()),
                            loading: () => const Center(child: CircularProgressIndicator()),
                            loaded: (messages, hasMore, isLoadingMore, loadMoreError, sendError, actionError,
                                    substantiveMessageCount, isPaid, hasShownPaymentDialog, userRole, productId) {
                              return CustomChatList(
                                messages: messages,
                                currentUserParticipantId: _currentUserParticipantId,
                                opponent: _opponent,
                                scrollController: _scrollController,
                                onEndReached: _handleEndReached,
                                isLoadingMore: _isLoadingMore,
                              );
                            },
                            error: (message) => Center(
                              child: Text(appLocalizations.chat_error_loading(message)),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  ),  // Close the BlocListener
                  
                  // Scroll to bottom FAB
                  if (_showScrollToBottomButton)
                    Positioned(
                      right: 16.0,
                      bottom: 16.0,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.white,
                        elevation: 4.0,
                        onPressed: _scrollToBottom,
                        child: const Icon(Icons.arrow_downward, color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
            
            // Message input bar - Use CustomInputBar from refactored implementation
            BlocListener<MessageQueueCubit, MessageQueueState>(
              listener: (context, state) {
                // Listen for message sent events
                state.maybeWhen(
                  itemSent: (remainingItems) {
                    widget.onMessageSent?.call();
                    _scrollToBottom();
                  },
                  orElse: () {},
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 付费提示按钮 - 只在满足条件时显示
                  BlocBuilder<MessageListCubit, MessageListState>(
                    builder: (context, state) {
                      if (_messageListCubit.shouldShowPaymentPromptButton) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            border: Border(
                              top: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.amber.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '达到免费咨询轮次，可发送付费提示',
                                  style: TextStyle(
                                    color: Colors.amber.shade800,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () async {
                                  try {
                                    // 发送付费提示消息
                                    await _messageListCubit.sendPaymentPromptMessage();

                                    // 滚动到底部
                                    Future.delayed(const Duration(milliseconds: 100), () {
                                      _scrollToBottom();
                                    });

                                    // 刷新聊天列表
                                    try {
                                      final chatListBloc = getIt<ChatListBloc>();
                                      chatListBloc.add(RefreshChatList());
                                    } catch (e) {
                                      print('[ChatRoomPageRefactored] Failed to refresh chat list: $e');
                                    }
                                  } catch (e) {
                                    // 显示错误提示
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(e.toString().replaceAll('Exception: ', '')),
                                          backgroundColor: Colors.red,
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.send, size: 18),
                                label: const Text('发送提示'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.amber.shade600,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  CustomInputBar(
                    chatId: widget.chatId,
                    onSendPressed: (text) {
                      // Directly call MessageListCubit instead of _handleSendPressed
                      _messageListCubit.sendTextMessage(text);
                      widget.onMessageSent?.call();

                      // 同时刷新聊天列表
                      try {
                        final chatListBloc = getIt<ChatListBloc>();
                        chatListBloc.add(RefreshChatList());
                        print('[ChatRoomPageRefactored] Refreshing chat list after sending message');
                      } catch (e) {
                        print('[ChatRoomPageRefactored] Failed to refresh chat list: $e');
                      }

                      Future.delayed(const Duration(milliseconds: 100), () {
                        _scrollToBottom();
                      });
                    },
                    onAttachmentPressed: () {
                      // Handle attachment - you can customize this
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}