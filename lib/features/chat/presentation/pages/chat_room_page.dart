import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting
import 'package:dskk_flutter_refactor/generated/l10n.dart'; // 导入国际化资源

import 'package:dskk_flutter_refactor/features/chat/presentation/bloc/chat_messages/chat_messages_bloc.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/widgets/chat_message_bubble.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/widgets/message_input_bar.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart'; // For MessageStatus

class ChatRoomPage extends StatefulWidget {
  final int chatId;

  const ChatRoomPage({super.key, required this.chatId});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final ScrollController _scrollController = ScrollController();
  // 添加一个标志来跟踪是否在底部
  bool _showScrollToBottomButton = false;
  // 添加分页加载参数 - 暂时注释掉分页功能
  // int _pageNum = 1;
  // final int _pageSize = 20;
  // bool _isLoadingMore = false;
  // bool _hasMoreMessages = true;

  @override
  void initState() {
    super.initState();
    // 监听滚动事件
    _scrollController.addListener(_onScroll);
    
    // 添加延迟滚动，确保页面加载完成后滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
    });
  }

  // 处理滚动事件
  void _onScroll() {
    // 如果距离底部超过300像素，显示回到底部按钮
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      
      // 注意：使用reverse时，底部是在位置0
      setState(() {
        _showScrollToBottomButton = currentScroll > 300; // 超过300像素，显示滚动到底部按钮
      });
      
      // 暂时注释掉分页加载逻辑
      // 在reverse模式下，加载更多是在滚动到最大位置（即顶部，显示最早的消息）
      // if (currentScroll >= maxScroll - 50 && 
      //     !_isLoadingMore && 
      //     _hasMoreMessages) {
      //   _loadMoreMessages();
      //   print("[ChatRoom] Loading more messages at maxScroll: $maxScroll, currentScroll: $currentScroll");
      // }
    }
  }

  // 暂时注释掉加载更多历史消息的方法
  // void _loadMoreMessages() {
  //   if (_isLoadingMore) return;
  //   
  //   setState(() {
  //     _isLoadingMore = true;
  //   });
  //   
  //   // 调用bloc加载更多消息
  //   context.read<ChatMessagesBloc>().add(
  //     LoadMoreChatMessages(
  //       chatId: widget.chatId,
  //       pageNum: _pageNum + 1,
  //       pageSize: _pageSize,
  //     ),
  //   );
  //   
  //   // 增加页码
  //   _pageNum++;
  // }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // 优化滚动到底部的方法 - 在reverse模式下，底部是位置0
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      try {
        final currentScroll = _scrollController.position.pixels;
        
        // 在reverse模式下，如果当前不在底部（位置0），使用直接跳转，避免卡顿
        if (currentScroll > 10) { // 允许10像素的误差
          _scrollController.jumpTo(0); // 在reverse模式下，底部是位置0
          print("[ChatRoom] Scrolled to bottom (position 0)");
        }
      } catch (e) {
        // 处理可能的异常，避免因滚动问题导致应用崩溃
        print("[ChatRoom] Error scrolling to bottom: $e");
      }
    } else {
      print("[ChatRoom] ScrollController has no clients yet");
    }
  }

  // Helper to check if timestamp separator is needed
  bool _shouldShowTimestampSeparator(ChatMessage current, ChatMessage? previous) {
    if (previous == null) {
      return true; // Always show for the very first message displayed
    }
    
    // 检查是否跨天
    final currentDate = DateTime(current.createTime!.year, current.createTime!.month, current.createTime!.day);
    final previousDate = DateTime(previous.createTime!.year, previous.createTime!.month, previous.createTime!.day);
    
    if (!currentDate.isAtSameMomentAs(previousDate)) {
      return true; // 跨天时显示时间分隔符
    }
    
    // 同一天内，检查时间间隔是否超过5分钟
    final difference = previous.createTime!.difference(current.createTime!).abs(); 
    return difference.inMinutes >= 5;
  }

  // Helper to build the timestamp separator widget
  Widget _buildTimestampSeparator(DateTime timestamp, bool isFirstMessage) {
    String formattedTime;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate.isAtSameMomentAs(today)) {
      // 今天的消息只显示时间
      formattedTime = DateFormat('HH:mm').format(timestamp);
    } else if (messageDate.isAtSameMomentAs(yesterday)) {
      // 昨天的消息
      formattedTime = '昨天 ${DateFormat('HH:mm').format(timestamp)}';
    } else if (timestamp.year == now.year) {
      // 今年的消息显示月日和时间
      formattedTime = DateFormat('MM月dd日 HH:mm', 'zh_CN').format(timestamp);
    } else {
      // 跨年的消息显示完整日期
      formattedTime = DateFormat('yyyy年MM月dd日 HH:mm', 'zh_CN').format(timestamp);
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          formattedTime,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 获取国际化资源
    final s = S.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED), // Set background color here
      appBar: AppBar(
        backgroundColor: Colors.white,    // Set AppBar background
        foregroundColor: Colors.black,    // Set AppBar foreground (text/icons)
        elevation: 0.5,                 // Add subtle elevation
        shadowColor: Colors.grey[300],    // Set shadow color
        centerTitle: true,              // Center the title
        // Add custom leading to control back button behavior
        leading: BackButton(
           onPressed: () {
               // Check if messages were loaded (implies chat was potentially read)
               // You might want a more robust check, e.g., tracking if the user scrolled or sent a message
               bool chatWasViewed = context.read<ChatMessagesBloc>().state is ChatMessagesLoaded;
               Navigator.pop(context, chatWasViewed); // Return true if viewed, false otherwise
           },
        ),
        title: BlocBuilder<ChatMessagesBloc, ChatMessagesState>(
          builder: (context, state) {
            if (state is ChatMessagesLoaded) {
              return Text(state.opponent.nickName ?? s.chat_unknown_user);
            } else if (state is ChatMessagesLoading && state is! ChatMessagesInitial) {
                 final bloc = context.read<ChatMessagesBloc>();
                 if (bloc.state is ChatMessagesLoaded) {
                     return Text((bloc.state as ChatMessagesLoaded).opponent.nickName ?? s.chat_unknown_user);
                 }
                  return Text(s.chat_loading);
            } else if (state is ChatMessagesInitial) {
                 return Text(s.chat_loading);
            } else {
              return Text(s.chat_unknown_user);
            }
          },
        ),
        // TODO: Add actions like viewing opponent profile
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: BlocConsumer<ChatMessagesBloc, ChatMessagesState>(
                  listener: (context, state) {
                     // 优化滚动逻辑
                     if (state is ChatMessagesLoaded) {
                        // 如果是初始加载或发送新消息，滚动到底部
                        if (state.isInitialLoad || state.hasNewMessage) {
                          // 使用多层延迟，确保在各种情况下都能滚动到底部
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToBottom();
                            
                            // 再延迟100毫秒尝试滚动一次
                            Future.delayed(const Duration(milliseconds: 100), () {
                              _scrollToBottom();
                              
                              // 最后再延迟200毫秒尝试最后一次
                              Future.delayed(const Duration(milliseconds: 200), _scrollToBottom);
                            });
                          });
                        }
                        
                        // 更新加载状态
                        // setState(() {
                        //   _isLoadingMore = false;
                        //   _hasMoreMessages = state.hasMore;
                        // });
                     }
                  },
                  builder: (context, state) {
                    if (state is ChatMessagesLoading && state is! ChatMessagesLoaded) {
                      // 显示加载中
                      return Center(child: CircularProgressIndicator());
                    } else if (state is ChatMessagesLoaded) {
                      if (state.messages.isEmpty) {
                        return Center(child: Text(s.chat_no_messages));
                      }
                      
                      return Stack(
                        children: [
                          // 消息列表
                          ListView.builder(
                            controller: _scrollController,
                            reverse: true, // 使用reverse，这样最新消息会在底部
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                            cacheExtent: 200, // 增加缓存范围，提高渲染性能
                            itemCount: state.messages.length, // 暂时注释掉分页功能: + (_isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              // 暂时注释掉分页加载指示器
                              // 底部加载更多指示器（在reverse模式下显示在顶部）
                              // if (index == state.messages.length && _isLoadingMore) {
                              //   return Center(
                              //     child: Padding(
                              //       padding: const EdgeInsets.all(8.0),
                              //       child: CircularProgressIndicator(strokeWidth: 2),
                              //     ),
                              //   );
                              // }
                              
                              // 确保索引在有效范围内
                              if (index >= state.messages.length) {
                                return Container(); // 防止越界
                              }
                              
                              // 在reverse模式下，索引0是最新的消息，需要反转索引关系
                              // 在数据层已经排序为从旧到新，所以显示时需要反转
                              final messageIndex = state.messages.length - 1 - index;
                              
                              // 以下是原有的消息气泡构建逻辑...
                              if (messageIndex < 0 || messageIndex >= state.messages.length) {
                                return Container(); // 防止越界
                              }
                              
                              // 使用调整后的索引获取消息
                              final currentMessage = state.messages[messageIndex]; 
                              // 在reverse模式下，previous实际上是更新的消息
                              final previousMessage = (messageIndex > 0) 
                                  ? state.messages[messageIndex - 1]
                                  : null;

                              final bool isFirstInList = messageIndex == 0;

                              if (currentMessage.createTime == null) {
                                print('Error: Message ID ${currentMessage.id} has null createTime.');
                                return ChatMessageBubble(
                                  key: ValueKey(currentMessage.id), 
                                  message: currentMessage,
                                  currentUserParticipantId: state.currentUserParticipantId,
                                  opponent: state.opponent,
                                );
                              }

                              final bool showTimestamp = _shouldShowTimestampSeparator(currentMessage, previousMessage);

                              return Column(
                                children: [
                                  if (showTimestamp) 
                                    _buildTimestampSeparator(currentMessage.createTime!, isFirstInList),
                                  
                                  ChatMessageBubble(
                                    key: ValueKey(currentMessage.id), 
                                    message: currentMessage,
                                    currentUserParticipantId: state.currentUserParticipantId,
                                    opponent: state.opponent,
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      );
                    } else if (state is ChatMessagesError) {
                      return Center(
                        child: Text(s.chat_error_loading(state.message)),
                      );
                    } else {
                      // Initial state or unexpected state
                      return Center(child: Text(s.chat_loading));
                    }
                  },
                ),
              ),
              MessageInputBar(chatId: widget.chatId),
            ],
          ),
          // 精确定位的滚动到底部按钮
          if (_showScrollToBottomButton)
            Positioned(
              right: 16.0,
              bottom: 80.0, // 距离底部80像素，避免与输入栏重合
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
    );
  }
} 