import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart'; // Import GetIt
import 'package:go_router/go_router.dart'; // 添加导入
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dskk_flutter_refactor/core/network/network_info.dart';
import 'package:dskk_flutter_refactor/core/network/mock_network_info.dart' as mock;
import 'dart:async'; // 添加Completer和StreamSubscription导入
import 'package:dskk_flutter_refactor/generated/l10n.dart'; // 导入国际化资源

// 引入通知相关的类
import 'package:dskk_flutter_refactor/features/seller/presentation/blocs/notification_list/notification_list_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/notification_list_page.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_notification_list_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_unread_notification_count_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/data/repositories/seller_repository_impl.dart';
import 'package:dskk_flutter_refactor/features/seller/data/datasources/seller_remote_data_source_impl.dart';
import 'package:dskk_flutter_refactor/features/seller/data/datasources/seller_local_data_source_impl.dart';
// 导入NotificationListContent，它是NotificationListPage的一部分
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/notification_list_page.dart' 
    show NotificationListContent;

import '../bloc/chat_list/chat_list_bloc.dart';
import '../widgets/chat_list_item.dart';
import '../bloc/chat_messages/chat_messages_bloc.dart'; // Import ChatMessagesBloc
import 'chat_room_page.dart'; // Import ChatRoomPage
// Import domain entities needed for fake ChatRoom
import '../../domain/entities/chat_room.dart';
import '../../domain/entities/participant.dart';
import '../../domain/entities/chat_message.dart'; // 添加导入ChatMessage

final sl = GetIt.instance; // Get GetIt instance

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  // Helper to build the static admin list item
  Widget _buildAdminListItem(BuildContext context, int currentUserId) {
    // 获取国际化资源
    final s = S.of(context);
    
    // Create a fake ChatRoom representing the admin chat
    // Use placeholder IDs and potentially a specific icon/avatar later
    final adminParticipant = Participant(
      id: 1, // Admin's internal ID (assuming 1 based on doctorId parameter)
      referId: 1, // Admin's referId (assuming 1, adjust if known)
      nickName: s.chat_admin_title,
      type: 'ADMIN',
      avatar: null, // TODO: Add a specific admin icon/avatar URL later
    );
    // Create a fake participant for the current user for the ChatRoom structure
    final currentUserParticipant = Participant(
      id: -1, // Placeholder internal ID
      referId: currentUserId,
      nickName: 'Me',
      type: 'MEMBER',
    );

    final fakeAdminChatRoom = ChatRoom(
      id: -1, // Special ID for admin chat entry, not from API
      participant1: currentUserParticipant, // Assign based on who should be p1/p2
      participant2: adminParticipant,
      unreadCount: 0,
      lastMessage: null, // Or a placeholder message like "Tap to start chat"
    );

    return Material(
      color: Colors.white, 
      child: ChatListItem(
        key: const ValueKey('admin_chat_entry'), // Unique key
        chatRoom: fakeAdminChatRoom,
        currentUserId: currentUserId, // Pass the actual current user referId
        onTap: () {
          print('[ChatListPage] Admin chat item tapped.');
          // TODO: Show loading indicator?
          context.read<ChatListBloc>().add(StartAdminChatRequested());
        },
        // TODO: Add visual differentiation (e.g., different icon/background)
      ),
    );
  }
  
  // 添加通知中心条目构建方法
  Widget _buildNotificationItem(BuildContext context, int currentUserId) {
    // 获取国际化资源
    final s = S.of(context);
    
    // 创建通知中心参与者
    final notificationParticipant = Participant(
      id: 2, // 使用不同于系统管理员的ID
      referId: 2, // 使用不同于系统管理员的referId
      nickName: s.chat_notification_center,
      type: 'NOTIFICATION',
      avatar: null, // 可以添加特定图标
    );
    
    // 创建当前用户参与者（与系统管理员中相同）
    final currentUserParticipant = Participant(
      id: -1,
      referId: currentUserId,
      nickName: 'Me',
      type: 'MEMBER',
    );
    
    // 创建假的聊天室对象，与系统管理员类似
    final fakeNotificationChatRoom = ChatRoom(
      id: -2, // 使用不同于系统管理员的ID
      participant1: currentUserParticipant,
      participant2: notificationParticipant,
      unreadCount: 0, // 可以从仓库获取未读数量
      // 添加一条最后消息以显示更有吸引力
      lastMessage: ChatMessage(
        id: -1,
        chatId: -2,
        senderId: 2,
        context: s.chat_notification_description,
        type: 'text',
        createTime: DateTime.now(),
        withdrawFlag: false,
      ),
    );
    
    return Material(
      color: Colors.white,
      child: ChatListItem(
        key: const ValueKey('notification_entry'),
        chatRoom: fakeNotificationChatRoom,
        currentUserId: currentUserId,
        onTap: () {
          // 检查当前应用模式
          // 注：这里我们使用临时方法，理想情况下应该使用Provider或其他状态管理方式来获取当前模式
          // 判断是否为卖家模式（简单示例）
          bool isSellerMode = false;
          
          try {
            // 尝试检查当前路由
            final currentPath = GoRouterState.of(context).matchedLocation;
            isSellerMode = currentPath.startsWith('/seller');
          } catch (e) {
            print('Error detecting current mode: $e');
          }
          
          if (isSellerMode) {
            // 卖家模式 - 导航到卖家通知页面
            context.go('/seller/notifications');
          } else {
            // 买家模式 - 使用Navigator.push保留底部导航栏
            // 创建NotificationListPage所需的依赖
            final getIt = GetIt.I;
            final dio = getIt<Dio>();
            final secureStorage = getIt<FlutterSecureStorage>();
            final sharedPreferences = getIt<SharedPreferences>();
            
            // 创建网络信息服务
            NetworkInfo networkInfo;
            try {
              networkInfo = getIt<NetworkInfo>();
            } catch (e) {
              print('NetworkInfo not found in GetIt, using mock');
              networkInfo = mock.MockNetworkInfo();
            }
            
            // 创建数据源
            final remoteDataSource = SellerRemoteDataSourceImpl(dio);
            final localDataSource = SellerLocalDataSourceImpl(sharedPreferences);
            
            // 创建仓库
            final sellerRepository = SellerRepositoryImpl(
              remoteDataSource,
              localDataSource,
              networkInfo,
            );
            
            // 创建用例
            final getSellerNotificationListUseCase = GetSellerNotificationListUseCase(sellerRepository);
            final markNotificationAsReadUseCase = MarkNotificationAsReadUseCase(sellerRepository);
            final markAllNotificationsAsReadUseCase = MarkAllNotificationsAsReadUseCase(sellerRepository);
            final getUnreadNotificationCountUseCase = GetUnreadNotificationCountUseCase(sellerRepository);
            
            // 使用Navigator.push而不是context.go，这样可以保留底部导航栏
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => NotificationListBloc(
                    getSellerNotificationListUseCase,
                    markNotificationAsReadUseCase,
                    markAllNotificationsAsReadUseCase,
                    getUnreadNotificationCountUseCase,
                  )..add(LoadNotificationList()), // 加载初始数据
                  child: Scaffold(
                    appBar: AppBar(
                      title: Text(s.chat_notification_center),
                      centerTitle: true,
                      // 添加返回按钮
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    body: const NotificationListContent(),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 获取国际化资源
    final s = S.of(context);
    
    // TODO: Replace this placeholder with actual user ID from state/provider
    const int currentUserId = 10307; // Temporary fix, use actual referId

    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      appBar: AppBar(
        title: Text(s.chat_list_title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, 
        elevation: 0.5, 
        shadowColor: Colors.grey[300],
      ),
      // Add BlocListener to handle navigation
      body: BlocListener<ChatListBloc, ChatListState>(
        listener: (context, state) {
          // 获取国际化资源
          final s = S.of(context);
          
          if (state.navigateToChatId != null) {
            final chatId = state.navigateToChatId!;
            print('[ChatListPage] BlocListener triggered navigation to chatId: $chatId');
            // Navigate to ChatRoomPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => sl<ChatMessagesBloc>(param1: chatId)
                                ..add(LoadChatMessages(chatId)),
                  child: ChatRoomPage(chatId: chatId),
                ),
              ),
            ).then((result) {
               // Reset navigation trigger in Bloc state after navigation
               context.read<ChatListBloc>().add(ClearNavigationTrigger()); // Need to add this event
               // Handle potential refresh logic if needed after returning
               if (result == true) {
                 print('[ChatListPage] Refreshing list after viewing chat $chatId');
                 context.read<ChatListBloc>().add(RefreshChatList()); 
               }
            });
          }
          // Handle potential error messages from StartAdminChatRequested
          if (state.status == ChatListStatus.failure && state.errorMessage != null && state.errorMessage!.contains(s.chat_admin_connection_error)) {
             // Show SnackBar or Dialog with the error
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text(state.errorMessage!)),
             );
             // Optionally reset the error message in the state
             // context.read<ChatListBloc>().add(ClearErrorMessage()); // Need to add this event
          }
        },
        child: BlocBuilder<ChatListBloc, ChatListState>(
          builder: (context, state) {
            if (state.status == ChatListStatus.loading && state.chatRooms.isEmpty) { // Show loading only initially
              return Center(child: CircularProgressIndicator()); 
            } else if (state.chatRooms.isNotEmpty) {
              // Always show the list if we have rooms, even while loading more/refreshing
              // final itemCount = state.chatRooms.length + 1; // Add 1 for admin entry
              
              // 使用RefreshIndicator包装ListView实现下拉刷新
              return RefreshIndicator(
                onRefresh: () async {
                  // 触发刷新事件
                  print('[ChatListPage] Pull-to-refresh triggered');
                  context.read<ChatListBloc>().add(RefreshChatList());
                  
                  // 创建一个Completer，等待刷新完成
                  final completer = Completer();
                  
                  // 声明subscription变量
                  late StreamSubscription subscription;
                  
                  // 订阅状态变化
                  subscription = context.read<ChatListBloc>().stream.listen((newState) {
                    // 当状态不再是loading，表示刷新完成
                    if (newState.status != ChatListStatus.loading) {
                      completer.complete();
                      subscription.cancel();
                    }
                  });
                  
                  // 设置超时，防止无限等待
                  Future.delayed(const Duration(seconds: 5), () {
                    if (!completer.isCompleted) {
                      completer.complete();
                      subscription.cancel();
                    }
                  });
                  
                  return completer.future;
                },
                child: ListView.separated(
                 // 修改为+2，包含管理员和通知中心两个固定条目
                 itemCount: state.chatRooms.length + 2, 
                 itemBuilder: (context, index) {
                   // 第一个项是管理员聊天入口
                   if (index == 0) {
                     return _buildAdminListItem(context, currentUserId);
                   }
                   // 第二个项是通知中心
                   else if (index == 1) {
                     return _buildNotificationItem(context, currentUserId);
                   }
                   // 后续项是常规聊天室
                   final chatRoom = state.chatRooms[index - 2]; // 调整索引
                   return Material(
                     color: Colors.white, 
                     child: ChatListItem(
                       key: ValueKey(chatRoom.id), 
                       chatRoom: chatRoom,
                       currentUserId: currentUserId, 
                       onTap: () {
                         Navigator.push(
                           context,
                           MaterialPageRoute(
                             builder: (_) => BlocProvider(
                               create: (_) => sl<ChatMessagesBloc>(param1: chatRoom.id)
                                             ..add(LoadChatMessages(chatRoom.id)),
                               child: ChatRoomPage(chatId: chatRoom.id),
                             ),
                           ),
                         ).then((result) {
                           if (result == true) {
                             print('[ChatListPage] Refreshing list after viewing chat ${chatRoom.id}');
                             context.read<ChatListBloc>().add(RefreshChatList()); 
                           }
                         });
                       },
                     ),
                   );
                 },
                 separatorBuilder: (context, index) {
                   // 系统管理员和通知中心后使用粗分隔线
                   if (index < 2) {
                       return const Divider(height: 8, thickness: 8, color: Color(0xFFEDEDED)); // Thicker separator
                   } 
                   // Regular separator
                   return Divider(
                     height: 1,
                     indent: 80, 
                     endIndent: 16,
                     color: Colors.grey[100], 
                     thickness: 0.5, 
                   );
                 },
               ),
               );
            } else if (state.status == ChatListStatus.failure) {
              return Center(
                 // Display error, but potentially still show the Admin entry above it?
                 // For now, just show the error.
                child: Text(s.chat_error_loading(state.errorMessage ?? s.chat_unknown_message)), 
              );
            } else { // Initial state
               return Center(child: Text(s.chat_loading)); 
            }
          },
        ),
      ),
    );
  }
} 