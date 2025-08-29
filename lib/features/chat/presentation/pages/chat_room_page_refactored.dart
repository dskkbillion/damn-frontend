import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/generated/l10n.dart';
import 'package:dskk_flutter_refactor/app/di/injection_container.dart';

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
    // Enter the chat room
    await _chatCubit.enterChatRoom(widget.chatId);
    
    // Get chat room info and set current user participant ID
    _chatCubit.state.maybeWhen(
      ready: (chatRoom, lastReceivedMessage, hasNewMessage) {
        // Find current user participant
        final currentUserParticipant = chatRoom.participants.firstWhere(
          (p) => p.type == 'member', // Current user is always 'member' type
          orElse: () => chatRoom.participants.first,
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
        
        print('DEBUG: Set currentUserParticipantId to $_currentUserParticipantId at initialization');
      },
      orElse: () {},
    );
    
    // Load initial messages
    await _messageListCubit.loadMessages(widget.chatId);
    
    // Connect WebSocket
    _webSocketCubit.connect();
    
    // Notify that messages have been loaded
    widget.onMessagesLoaded?.call();
  }
  
  @override
  void dispose() {
    // Leave chat room
    _chatCubit.leaveChatRoom();
    
    // Disconnect WebSocket if no other chats are active
    _webSocketCubit.disconnect();
    
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
    final s = S.of(context);
    
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _chatCubit),
        BlocProvider.value(value: _messageListCubit),
        BlocProvider.value(value: _webSocketCubit),
        BlocProvider.value(value: _messageQueueCubit),
      ],
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
                initial: () => Text(s.chat_loading),
                loading: () => Text(s.chat_loading),
                ready: (chatRoom, lastReceivedMessage, hasNewMessage) => Text(
                  chatRoom.participants
                      .firstWhere((p) => p.referId != _currentUserParticipantId, 
                          orElse: () => chatRoom.participants.first)
                      .nickName ?? s.chat_unknown_user,
                ),
                error: (message) => Text(s.chat_unknown_user),
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
                                context.push('/product/${chatRoom.productId}');
                              }
                            },
                            onActionTap: () {
                              if (chatRoom.productId != null) {
                                context.push('/product/${chatRoom.productId}');
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
                          
                          // Find current user participant
                          final currentUserParticipant = chatRoom.participants.firstWhere(
                            (p) => p.type == 'member', // Adjust based on your user type
                            orElse: () => chatRoom.participants.first,
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
                              child: Text(s.chat_error_loading(message)),
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
              child: CustomInputBar(
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
            ),
          ],
        ),
      ),
    );
  }
}