import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 添加Riverpod导入
import 'package:get_it/get_it.dart'; // Import GetIt
import 'package:go_router/go_router.dart'; // 添加导入
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 添加SharedPreferences导入
import 'dart:async'; // 添加Completer和StreamSubscription导入
import 'package:dskk_flutter_refactor/generated/l10n.dart'; // 导入国际化资源
import 'package:dskk_flutter_refactor/app/app_mode.dart'; // 导入应用模式

import '../bloc/chat_list/chat_list_bloc.dart';
import '../widgets/chat_list_item.dart';
import '../widgets/grouped_chat_list.dart'; // 导入分组组件
import '../services/chat_preload_service.dart'; // 导入预加载服务
// Import domain entities needed for fake ChatRoom
import '../../domain/entities/chat_room.dart';
import '../../domain/entities/participant.dart';
import '../../domain/entities/chat_message.dart'; // 添加导入ChatMessage

final sl = GetIt.instance; // Get GetIt instance

class ChatListPage extends ConsumerStatefulWidget { // 改为ConsumerStatefulWidget以支持Riverpod
  const ChatListPage({super.key});

  @override
  ConsumerState<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends ConsumerState<ChatListPage> {
  // 添加用户身份状态
  String? _currentUserType; // 'MEMBER' 或 'DOCTOR'
  
  // 添加Future存储变量，避免在每次build时创建新的Future
  late Future<int?> _referIdFuture;
  
  // 添加预加载服务
  late final ChatPreloadService _preloadService;
  
  // 添加混合模式状态
  bool _isMixedMode = false; // 默认不混合，根据买家/卖家模式分开显示
  
  @override
  void initState() {
    super.initState();
    // 在initState中初始化Future，只执行一次
    _referIdFuture = _getReferIdFromStorage();
    // 初始化预加载服务
    _preloadService = ChatPreloadService();
    // 从本地存储读取混合模式设置
    _loadMixedModeSetting();
  }
  
  // 加载混合模式设置
  Future<void> _loadMixedModeSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isMixedMode = prefs.getBool('chat_mixed_mode') ?? false;
      });
    } catch (e) {
      print('[ChatListPage] Error loading mixed mode setting: $e');
    }
  }
  
  // 保存混合模式设置
  Future<void> _saveMixedModeSetting(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('chat_mixed_mode', value);
    } catch (e) {
      print('[ChatListPage] Error saving mixed mode setting: $e');
    }
  }
  
  @override
  void dispose() {
    // 清理预加载服务
    _preloadService.dispose();
    super.dispose();
  }
  
  // 添加获取referId的方法 - 使用common_user_id进行聊天室匹配
  Future<int?> _getReferIdFromStorage() async {
    try {
      final secureStorage = GetIt.instance<FlutterSecureStorage>();
      // 获取common_user_id作为聊天室匹配的ID
      final commonUserIdStr = await secureStorage.read(key: 'common_user_id');
      
      if (commonUserIdStr != null) {
        final commonUserId = int.tryParse(commonUserIdStr);
        print('[ChatListPage] Retrieved common_user_id from secure storage: $commonUserId');
        return commonUserId;
      } else {
        // 如果没有common_user_id，尝试获取refer_id作为备选
        final referIdStr = await secureStorage.read(key: 'refer_id');
        if (referIdStr != null) {
          final referId = int.tryParse(referIdStr);
          print('[ChatListPage] Using refer_id as fallback: $referId');
          return referId;
        }
        print('[ChatListPage] Neither common_user_id nor refer_id found in secure storage');
        return null;
      }
    } catch (e) {
      print('[ChatListPage] Error reading user ID from secure storage: $e');
      return null;
    }
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
            context.push('/seller/notifications');
          } else {
            // 买家模式 - 导航到买家通知页面
            // 重要：必须使用 /notifications 而不是 /seller/notifications
            // 否则会被路由器的模式检查重定向回买家主页
            print('[ChatListPage] Navigating to buyer notifications: /notifications');
            context.push('/notifications');
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 获取国际化资源
    final s = S.of(context);
    
    // 获取当前应用模式
    final currentAppMode = ref.watch(appModeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      appBar: AppBar(
        title: Text(s.chat_list_title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, 
        elevation: 0.5, 
        shadowColor: Colors.grey[300],
        actions: [
          // 添加混合模式切换按钮
          IconButton(
            icon: Icon(
              _isMixedMode ? Icons.folder_open : Icons.folder,
              color: _isMixedMode ? Theme.of(context).primaryColor : Colors.grey,
            ),
            tooltip: _isMixedMode ? '显示全部聊天' : '按身份分类',
            onPressed: () {
              setState(() {
                _isMixedMode = !_isMixedMode;
              });
              _saveMixedModeSetting(_isMixedMode);
            },
          ),
        ],
      ),
      // 使用FutureBuilder获取referId
      body: FutureBuilder<int?>(
        future: _referIdFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            print('[ChatListPage] Error getting referId: ${snapshot.error}');
            return Center(child: Text('获取用户信息失败: ${snapshot.error}'));
          }
          
          final referId = snapshot.data;
          if (referId == null) {
            return const Center(child: Text('用户referId未找到'));
          }
          
          // 使用获取到的ID作为currentUserId
          final currentUserId = referId;
          print('[ChatListPage] Using userId: $referId as currentUserId for both data and UI, appMode: $currentAppMode');
          
          return BlocListener<ChatListBloc, ChatListState>(
            listener: (context, state) {
              // 获取国际化资源
              final s = S.of(context);
              
              if (state.navigateToChatId != null) {
                final chatId = state.navigateToChatId!;
                print('[ChatListPage] BlocListener triggered navigation to chatId: $chatId');
                // Navigate to ChatRoomPage using GoRouter
                context.push('/chat/$chatId').then((result) {
                   // Reset navigation trigger in Bloc state after navigation
                   context.read<ChatListBloc>().add(ClearNavigationTrigger());
                   // Remove the RefreshChatList since we now update unread count directly
                   // if (result == true) {
                   //   print('[ChatListPage] Refreshing list after viewing chat $chatId');
                   //   context.read<ChatListBloc>().add(RefreshChatList()); 
                   // }
                });
              }

            },
            child: BlocBuilder<ChatListBloc, ChatListState>(
              builder: (context, state) {
                if (state.status == ChatListStatus.loading && state.chatRooms.isEmpty) {
                  return Center(child: CircularProgressIndicator()); 
                } else if (state.status == ChatListStatus.failure) {
                  return _buildSystemItemsOnly(context, currentUserId, s.chat_error_loading(state.errorMessage ?? s.chat_unknown_message));
                } else if (state.status == ChatListStatus.success || state.chatRooms.isNotEmpty) {
                  // 调试：打印当前用户信息
                  print('[ChatListPage] Current user referId: $referId, AppMode: $currentAppMode, MixedMode: $_isMixedMode');
                  print('[ChatListPage] Total chat rooms from API: ${state.chatRooms.length}');
                  
                  // 打印每个聊天室的参与者信息
                  for (final room in state.chatRooms) {
                    print('[ChatListPage] Room ${room.id}: participant1(id=${room.participant1.id}, referId=${room.participant1.referId}, type=${room.participant1.type}), participant2(id=${room.participant2.id}, referId=${room.participant2.referId}, type=${room.participant2.type})');
                  }
                  
                  // 根据混合模式决定是否筛选
                  final filteredRooms = _isMixedMode 
                      ? _filterChatRoomsForMixedMode(state.chatRooms, referId) // 混合模式：显示所有聊天
                      : _filterChatRoomsByAppMode(state.chatRooms, currentAppMode, referId); // 分类模式：根据身份筛选
                  
                  print('[ChatListPage] Filtered rooms count: ${filteredRooms.length}');
                  
                  // 触发头像预加载（异步执行，不阻塞UI）
                  if (filteredRooms.isNotEmpty && context.mounted) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) {
                        _preloadService.preloadChatRoomAvatars(context, filteredRooms);
                      }
                    });
                  }
                  
                  return _buildChatListView(context, filteredRooms, currentAppMode, currentUserId);
                } else {
                  // 真正的加载状态
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          );
        },
      ),
    );
  }
  
  // 提取导航逻辑到单独方法
  void _navigateToChat(BuildContext context, ChatRoom chatRoom) {
    // Navigate to ChatRoomPage using GoRouter
    // 使用新的重构版本
    context.push('/chat/refactored/${chatRoom.id}');
  }
  
  // 混合模式筛选：显示所有当前用户参与的聊天，不区分身份
  List<ChatRoom> _filterChatRoomsForMixedMode(List<ChatRoom> chatRooms, int referId) {
    final filteredRooms = <ChatRoom>[];
    
    print("[ChatListPage] Mixed mode filter with referId: $referId, total rooms: ${chatRooms.length}");
    
    for (final room in chatRooms) {
      // 检查是否是系统管理员聊天室
      bool isAdminChat = false;
      if ((room.participant1.type == 'ADMIN' && room.participant1.referId == 0) ||
          (room.participant2.type == 'ADMIN' && room.participant2.referId == 0)) {
        isAdminChat = true;
      }
      
      // 排除系统管理员聊天室
      if (isAdminChat) {
        continue;
      }
      
      // 检查当前用户是否是参与者（使用id匹配，不管什么身份）
      if (room.participant1.id == referId || room.participant2.id == referId) {
        filteredRooms.add(room);
        print("[ChatListPage] Mixed mode: Including room ${room.id}");
      }
    }
    
    print("[ChatListPage] Mixed mode: filtered ${filteredRooms.length} rooms");
    return filteredRooms;
  }
  
  // 新的筛选方法：根据应用模式筛选聊天室，同时排除系统管理员聊天室
  List<ChatRoom> _filterChatRoomsByAppMode(List<ChatRoom> chatRooms, AppMode appMode, int userId) {
    final filteredRooms = <ChatRoom>[];
    
    print("[ChatListPage] ===== Filter Debug Info =====");
    print("[ChatListPage] Current user ID: $userId");
    print("[ChatListPage] Current app mode: $appMode");
    print("[ChatListPage] Total rooms before filter: ${chatRooms.length}");
    print("[ChatListPage] =============================");
    
    for (final room in chatRooms) {
      print("[ChatListPage] Checking room ${room.id}:");
      print("  - participant1: type=${room.participant1.type}, referId=${room.participant1.referId}, id=${room.participant1.id}, name=${room.participant1.nickName}");
      print("  - participant2: type=${room.participant2.type}, referId=${room.participant2.referId}, id=${room.participant2.id}, name=${room.participant2.nickName}");
      
      // 检查是否是系统管理员聊天室
      bool isAdminChat = false;
      if ((room.participant1.type == 'ADMIN' && room.participant1.referId == 0) ||
          (room.participant2.type == 'ADMIN' && room.participant2.referId == 0)) {
        isAdminChat = true;
        print("[ChatListPage] 🚫 Skipping admin chat room ${room.id} - will be shown in system items");
      }
      
      // 排除系统管理员聊天室
      if (isAdminChat) {
        continue;
      }
      
      // 检查当前用户是否是这个聊天室的参与者，使用id字段进行匹配
      bool shouldInclude = false;
      String? userRole;
      
      if (room.participant1.id == userId) {
        userRole = room.participant1.type;
        _currentUserType = userRole; // 记录当前用户类型
        
        // 根据应用模式筛选：
        // - 买家模式：只显示用户作为MEMBER（买家）的聊天
        // - 卖家模式：只显示用户作为DOCTOR（卖家）的聊天
        if (appMode == AppMode.buyer && userRole == 'MEMBER') {
          shouldInclude = true;
          print("[ChatListPage] ✅ Buyer mode: Including room ${room.id} where user is MEMBER, chatting with ${room.participant2.nickName}");
        } else if (appMode == AppMode.seller && userRole == 'DOCTOR') {
          shouldInclude = true;
          print("[ChatListPage] ✅ Seller mode: Including room ${room.id} where user is DOCTOR, chatting with ${room.participant2.nickName}");
        } else {
          print("[ChatListPage] ❌ Mode mismatch: room ${room.id}, user role: $userRole, app mode: $appMode");
        }
      } else if (room.participant2.id == userId) {
        userRole = room.participant2.type;
        _currentUserType = userRole; // 记录当前用户类型
        
        // 根据应用模式筛选
        if (appMode == AppMode.buyer && userRole == 'MEMBER') {
          shouldInclude = true;
          print("[ChatListPage] ✅ Buyer mode: Including room ${room.id} where user is MEMBER, chatting with ${room.participant1.nickName}");
        } else if (appMode == AppMode.seller && userRole == 'DOCTOR') {
          shouldInclude = true;
          print("[ChatListPage] ✅ Seller mode: Including room ${room.id} where user is DOCTOR, chatting with ${room.participant1.nickName}");
        } else {
          print("[ChatListPage] ❌ Mode mismatch: room ${room.id}, user role: $userRole, app mode: $appMode");
        }
      } else {
        print("[ChatListPage] ❌ User not participant: userId $userId not in room ${room.id}");
      }
      
      if (shouldInclude) {
        filteredRooms.add(room);
      }
    }
    
    print("[ChatListPage] App mode: $appMode, filtered ${filteredRooms.length} rooms (mode-specific and admin excluded)");
    return filteredRooms;
  }

  // 构建聊天列表视图
  Widget _buildChatListView(BuildContext context, List<ChatRoom> filteredRooms, AppMode appMode, int currentUserId) {
    return RefreshIndicator(
      onRefresh: () async {
        print('[ChatListPage] Pull-to-refresh triggered');
        context.read<ChatListBloc>().add(RefreshChatList());
        
        final completer = Completer();
        late StreamSubscription subscription;
        
        subscription = context.read<ChatListBloc>().stream.listen((newState) {
          if (newState.status != ChatListStatus.loading) {
            completer.complete();
            subscription.cancel();
          }
        });
        
        Future.delayed(const Duration(seconds: 5), () {
          if (!completer.isCompleted) {
            completer.complete();
            subscription.cancel();
          }
        });
        
        return completer.future;
      },
      child: CustomScrollView(
        slivers: [
          // 系统条目始终显示
          _buildSystemItems(context, currentUserId),
          
          // 根据模式显示不同的聊天列表
          if (filteredRooms.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text('暂无聊天记录'),
                ),
              ),
            )
          else if (appMode == AppMode.buyer)
            // 买家模式：按卖家分组显示
            _buildBuyerChatList(filteredRooms, currentUserId)
          else
            // 卖家模式：按商品分组显示
            _buildSellerChatList(filteredRooms, currentUserId),
        ],
      ),
    );
  }

  // 构建系统条目（始终显示）
  Widget _buildSystemItems(BuildContext context, int currentUserId) {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildNotificationItem(context, currentUserId),
            const Divider(height: 1, color: Color(0xFFEDEDED)),
          ],
        ),
      ),
    );
  }
  

  // 只显示系统条目（用于错误或空状态）
  Widget _buildSystemItemsOnly(BuildContext context, int currentUserId, String message) {
    return CustomScrollView(
      slivers: [
        _buildSystemItems(context, currentUserId),
        SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(message),
            ),
          ),
        ),
      ],
    );
  }

  // 买家模式聊天列表（分组显示）
  Widget _buildBuyerChatList(List<ChatRoom> chatRooms, int currentUserId) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final groupedChats = _groupChatsBySeller(chatRooms, currentUserId);
          
          if (index >= groupedChats.length) return null;
          
          final group = groupedChats[index];
          
          return SellerGroupItem(
            group: group,
            currentUserId: currentUserId,
            onTap: (chatRoom) => _navigateToChat(context, chatRoom),
          );
        },
        childCount: _groupChatsBySeller(chatRooms, currentUserId).length,
      ),
    );
  }

  // 卖家模式聊天列表（按商品分组显示）
  Widget _buildSellerChatList(List<ChatRoom> chatRooms, int currentUserId) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final groupedChats = _groupChatsByProduct(chatRooms, currentUserId);
          
          if (index >= groupedChats.length) return null;
          
          final group = groupedChats[index];
          
          return ProductGroupItem(
            group: group,
            currentUserId: currentUserId,
            onTap: (chatRoom) => _navigateToChat(context, chatRoom),
          );
        },
        childCount: _groupChatsByProduct(chatRooms, currentUserId).length,
      ),
    );
  }

  // 提取分组逻辑到单独方法 - 买家模式使用
  List<SellerChatGroup> _groupChatsBySeller(List<ChatRoom> chatRooms, int currentUserId) {
    final Map<int, List<ChatRoom>> grouped = {};
    
    for (final chatRoom in chatRooms) {
      // 在买家模式下，对方（participant2）应该是卖家
      // 因为在ChatRoomDto.toEntity中已经确保了participant1是当前用户，participant2是对方
      final seller = chatRoom.participant2;
      final sellerId = seller.referId ?? 0;
      
      grouped.putIfAbsent(sellerId, () => []).add(chatRoom);
      print("[ChatListPage] Grouping chat room ${chatRoom.id} under seller: ${seller.nickName} (ID: $sellerId)");
    }
    
    return grouped.entries.map((entry) {
      final sellerId = entry.key;
      final rooms = entry.value;
      final seller = rooms.first.participant2; // 卖家信息
      
      print("[ChatListPage] Created seller group: ${seller.nickName} with ${rooms.length} chat rooms");
      
      return SellerChatGroup(
        sellerId: sellerId,
        seller: seller,
        chatRooms: rooms,
      );
    }).toList();
  }

  // 提取分组逻辑到单独方法 - 卖家模式使用，按商品分组
  List<ProductChatGroup> _groupChatsByProduct(List<ChatRoom> chatRooms, int currentUserId) {
    final Map<String, List<ChatRoom>> grouped = {};
    
    for (final chatRoom in chatRooms) {
      // 使用商品ID作为分组键，如果没有商品ID则使用特殊键
      final productId = chatRoom.productId ?? 'no_product';
      
      grouped.putIfAbsent(productId, () => []).add(chatRoom);
      print("[ChatListPage] Grouping chat room ${chatRoom.id} under product: ${chatRoom.productName ?? 'Unknown'} (ID: $productId)");
    }
    
    return grouped.entries.map((entry) {
      final productId = entry.key;
      final rooms = entry.value;
      final firstRoom = rooms.first; // 从第一个房间获取商品信息
      
      print("[ChatListPage] Created product group: ${firstRoom.productName ?? 'Unknown'} with ${rooms.length} chat rooms");
      
      return ProductChatGroup(
        productId: productId,
        productName: firstRoom.productName,
        productImage: firstRoom.productImage,
        productPrice: firstRoom.productPrice,
        chatRooms: rooms,
      );
    }).toList();
  }
} 