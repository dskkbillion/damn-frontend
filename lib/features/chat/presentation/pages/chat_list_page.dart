import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 添加Riverpod导入
import 'package:get_it/get_it.dart'; // Import GetIt
import 'package:go_router/go_router.dart'; // 添加导入
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async'; // 添加Completer和StreamSubscription导入
import 'package:dskk_flutter_refactor/generated/app_localizations.dart'; // 导入国际化资源
import 'package:dskk_flutter_refactor/app/app_mode.dart'; // 导入应用模式
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';

import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dskk_flutter_refactor/core/widgets/skeleton/skeleton_page.dart';
import 'package:dskk_flutter_refactor/core/widgets/skeleton/skeleton_chat_item.dart';
import 'package:dskk_flutter_refactor/core/widgets/skeleton/skeleton_card.dart';
import '../bloc/chat_list/chat_list_bloc.dart';
import '../widgets/grouped_chat_list.dart'; // 导入分组组件
// Import domain entities needed for fake ChatRoom
import '../../domain/entities/chat_room.dart';
import '../../domain/constants/chat_constants.dart';
import '../../domain/constants/participant_type.dart';

final sl = GetIt.instance; // Get GetIt instance

class ChatListPage extends ConsumerStatefulWidget {
  // 改为ConsumerStatefulWidget以支持Riverpod
  const ChatListPage({super.key});

  @override
  ConsumerState<ChatListPage> createState() => _ChatListPageState();
}

class _ChatHeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  const _ChatHeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.backgroundCard.withValues(alpha: 0.66),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.onPrimary.withValues(alpha: 0.86),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(icon, size: 21, color: color ?? AppColors.textSecondary),
          tooltip: tooltip,
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class _ChatListPageState extends ConsumerState<ChatListPage> {
  // 添加用户身份状态
  String? _currentUserType; // 'MEMBER' 或 'DOCTOR'

  // 添加Future存储变量，避免在每次build时创建新的Future
  late Future<int?> _referIdFuture;

  // 混合模式状态：false=按身份分类显示，true=显示所有聊天
  bool _isMixedMode = false;

  @override
  void initState() {
    super.initState();
    // 在initState中初始化Future，只执行一次
    _referIdFuture = _getReferIdFromStorage();
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

  // #335 添加获取referId的方法 — 加 5s timeout 防止 SecureStorage 偶发卡死导致整页白屏
  Future<int?> _getReferIdFromStorage() async {
    try {
      final secureStorage = GetIt.instance<FlutterSecureStorage>();
      final referIdStr = await secureStorage
          .read(key: 'refer_id')
          .timeout(const Duration(seconds: 5));

      if (referIdStr != null) {
        final referId = int.tryParse(referIdStr);
        AppLogger.d(
            '[ChatListPage] Retrieved refer_id from secure storage: $referId');
        return referId;
      } else {
        AppLogger.d('[ChatListPage] refer_id not found in secure storage');
        return null;
      }
    } on TimeoutException catch (e) {
      // #335 关键修复:SecureStorage 偶发慢,5s 超时后允许 UI 显示重试按钮(原代码会永久卡在 ConnectionState.waiting)
      AppLogger.e(
          '[ChatListPage] SecureStorage read timeout (#335 — chat 偶发无法进入): $e');
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
          '[ChatListPage] Error reading refer_id from secure storage: $e\n$stack');
      return null;
    }
  }

  // #335 手动重试入口
  void _retryReferId() {
    setState(() {
      _referIdFuture = _getReferIdFromStorage();
    });
  }

  void _openNotifications(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final notificationPath = currentPath.startsWith('/seller')
        ? '/seller/notifications'
        : '/notifications';
    context.push(notificationPath);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);

    // 获取当前应用模式
    final currentAppMode = ref.watch(appModeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        forceMaterialTransparency: true,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          _ChatHeaderIconButton(
            icon: Icons.notifications_none_rounded,
            tooltip: s.chat_notification_center,
            onPressed: () => _openNotifications(context),
          ),
          _ChatHeaderIconButton(
            icon: _isMixedMode ? Icons.filter_alt_off : Icons.filter_alt,
            tooltip: _isMixedMode
                ? s.chat_filter_all
                : (currentAppMode == AppMode.buyer
                    ? s.chat_filter_buyer
                    : s.chat_filter_seller),
            color: _isMixedMode
                ? AppColors.textTertiary
                : Theme.of(context).primaryColor,
            onPressed: () {
              setState(() {
                _isMixedMode = !_isMixedMode;
              });
              _saveMixedModeSetting(_isMixedMode);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor:
                      AppColors.backgroundCard.withValues(alpha: 0.92),
                  elevation: 0,
                  shape: const StadiumBorder(),
                  content: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isMixedMode
                            ? Icons.filter_alt_off_rounded
                            : Icons.filter_alt_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _isMixedMode
                              ? s.chat_filter_mode_all
                              : (currentAppMode == AppMode.buyer
                                  ? s.chat_filter_mode_buyer
                                  : s.chat_filter_mode_seller),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      // 使用FutureBuilder获取referId
      body: GlassBackdrop(
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top + kToolbarHeight,
          ),
          child: FutureBuilder<int?>(
          future: _referIdFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SkeletonPage(
                  itemCount: 5, itemBuilder: (_, __) => const SkeletonCard());
            }

            // #335 SecureStorage 超时或异常 → 提供重试入口,不再卡死白屏
            if (snapshot.hasError) {
              AppLogger.e(
                  '[ChatListPage] Error getting referId: ${snapshot.error}');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(s.chat_get_user_info_failed('${snapshot.error}')),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _retryReferId,
                      icon: const Icon(Icons.refresh),
                      label: const Text('重试'),
                    ),
                  ],
                ),
              );
            }

            final referId = snapshot.data;
            if (referId == null) {
              return Center(child: Text(s.chat_user_refer_id_not_found));
            }

            print(
                '[ChatListPage] Using referId(commonUserId): $referId, appMode: $currentAppMode');

            return BlocListener<ChatListBloc, ChatListState>(
              listener: (context, state) {
                if (state.navigateToChatId != null) {
                  final chatId = state.navigateToChatId!;
                  print(
                      '[ChatListPage] BlocListener triggered navigation to chatId: $chatId');
                  context.push(_chatRoomPath(chatId)).then((result) {
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
                  if (state.status == ChatListStatus.loading &&
                      state.chatRooms.isEmpty) {
                    return SkeletonPage(
                        itemCount: 5,
                        itemBuilder: (_, __) => const SkeletonChatItem());
                  } else if (state.status == ChatListStatus.failure) {
                    return _buildSystemItemsOnly(
                      context,
                      s.chat_error_loading(
                          state.errorMessage ?? s.chat_unknown_message),
                    );
                  } else if (state.status == ChatListStatus.success ||
                      state.chatRooms.isNotEmpty) {
                    // 根据混合模式决定是否筛选
                    final filteredRooms = _isMixedMode
                        ? _filterChatRoomsForMixedMode(state.chatRooms, referId)
                        : _filterChatRoomsByAppMode(
                            state.chatRooms, currentAppMode, referId);

                    return _buildChatListView(
                        context, filteredRooms, currentAppMode, referId);
                  } else {
                    // 真正的加载状态
                    return SkeletonPage(
                        itemCount: 5,
                        itemBuilder: (_, __) => const SkeletonChatItem());
                  }
                },
              ),
            );
          },
          ),
        ),
      ),
    );
  }

  // 根据当前路由前缀决定聊天室路径
  String _chatRoomPath(int chatId) {
    // 卖家模式下使用 /seller/chat/:chatId，买家模式下使用 /chat/:chatId
    final currentPath = GoRouterState.of(context).matchedLocation;
    final prefix = currentPath.startsWith('/seller') ? '/seller/chat' : '/chat';
    return '$prefix/$chatId';
  }

  // 提取导航逻辑到单独方法
  void _navigateToChat(BuildContext context, ChatRoom chatRoom) {
    context.push(_chatRoomPath(chatRoom.id));
  }

  // 混合模式筛选：显示所有当前用户参与的聊天，不区分身份
  List<ChatRoom> _filterChatRoomsForMixedMode(
      List<ChatRoom> chatRooms, int referId) {
    final filteredRooms = <ChatRoom>[];

    for (final room in chatRooms) {
      // 排除系统管理员聊天室
      if ((room.participant1.type == ParticipantType.admin &&
              room.participant1.referId == ChatConstants.adminReferId) ||
          (room.participant2.type == ParticipantType.admin &&
              room.participant2.referId == ChatConstants.adminReferId)) {
        continue;
      }

      // 检查当前用户是否是参与者（使用id匹配，不管什么身份）
      if (room.participant1.id == referId || room.participant2.id == referId) {
        filteredRooms.add(room);
      }
    }

    return filteredRooms;
  }

  // 根据应用模式筛选聊天室：买家模式只显示用户作为买家的聊天，卖家模式只显示用户作为卖家的聊天
  List<ChatRoom> _filterChatRoomsByAppMode(
      List<ChatRoom> chatRooms, AppMode appMode, int referId) {
    final filteredRooms = <ChatRoom>[];

    for (final room in chatRooms) {
      // 排除系统管理员聊天室
      if ((room.participant1.type == ParticipantType.admin &&
              room.participant1.referId == ChatConstants.adminReferId) ||
          (room.participant2.type == ParticipantType.admin &&
              room.participant2.referId == ChatConstants.adminReferId)) {
        continue;
      }

      // 先判断用户是否是这个聊天室的参与者
      final isParticipant =
          room.participant1.id == referId || room.participant2.id == referId;
      if (!isParticipant) continue;

      // 判断当前用户在这个聊天室中的角色
      // 优先使用 memberId/doctorId（API 新鲜数据），缓存数据可能为 null 则回退到 participant type
      bool shouldInclude = false;
      if (room.memberId != null && room.doctorId != null) {
        // 有角色 ID：精确匹配
        if (appMode == AppMode.buyer) {
          shouldInclude = room.memberId == referId;
        } else if (appMode == AppMode.seller) {
          shouldInclude = room.doctorId == referId;
        }
      } else {
        // 缓存回退：用 participant1（toEntity 中始终是当前用户）的 type 判断
        // participant1.type == 'MEMBER' 表示当前用户是买家
        // participant1.type == 'DOCTOR' 表示当前用户是卖家
        final currentUserParticipant = room.participant1.id == referId
            ? room.participant1
            : room.participant2;
        if (appMode == AppMode.buyer) {
          shouldInclude = currentUserParticipant.type == ParticipantType.member;
        } else if (appMode == AppMode.seller) {
          shouldInclude = currentUserParticipant.type == ParticipantType.doctor;
        }
      }

      if (shouldInclude) {
        filteredRooms.add(room);
      }
    }

    return filteredRooms;
  }

  // 构建聊天列表视图
  Widget _buildChatListView(BuildContext context, List<ChatRoom> filteredRooms,
      AppMode appMode, int currentUserId) {
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
          // 根据模式显示不同的聊天列表
          if (filteredRooms.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child:
                      Text(AppLocalizations.of(context).chat_no_chat_records),
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

  // 错误状态只展示提示；通知入口固定留在 AppBar，不伪装成聊天会话。
  Widget _buildSystemItemsOnly(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(message),
      ),
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
  List<SellerChatGroup> _groupChatsBySeller(
      List<ChatRoom> chatRooms, int currentUserId) {
    final Map<int, List<ChatRoom>> grouped = {};

    for (final chatRoom in chatRooms) {
      // 在买家模式下，对方（participant2）应该是卖家
      // 因为在ChatRoomDto.toEntity中已经确保了participant1是当前用户，participant2是对方
      final seller = chatRoom.participant2;
      final sellerId = seller.referId ?? 0;

      grouped.putIfAbsent(sellerId, () => []).add(chatRoom);
      print(
          "[ChatListPage] Grouping chat room ${chatRoom.id} under seller: ${seller.nickName} (ID: $sellerId)");
    }

    return grouped.entries.map((entry) {
      final sellerId = entry.key;
      final rooms = entry.value;
      final seller = rooms.first.participant2; // 卖家信息

      print(
          "[ChatListPage] Created seller group: ${seller.nickName} with ${rooms.length} chat rooms");

      return SellerChatGroup(
        sellerId: sellerId,
        seller: seller,
        chatRooms: rooms,
      );
    }).toList();
  }

  // 提取分组逻辑到单独方法 - 卖家模式使用，按商品分组
  List<ProductChatGroup> _groupChatsByProduct(
      List<ChatRoom> chatRooms, int currentUserId) {
    final Map<String, List<ChatRoom>> grouped = {};

    for (final chatRoom in chatRooms) {
      // 使用商品ID作为分组键，如果没有商品ID则使用特殊键
      final productId = chatRoom.productId ?? 'no_product';

      grouped.putIfAbsent(productId, () => []).add(chatRoom);
      print(
          "[ChatListPage] Grouping chat room ${chatRoom.id} under product: ${chatRoom.productName ?? 'Unknown'} (ID: $productId)");
    }

    return grouped.entries.map((entry) {
      final productId = entry.key;
      final rooms = entry.value;
      final firstRoom = rooms.first; // 从第一个房间获取商品信息

      print(
          "[ChatListPage] Created product group: ${firstRoom.productName ?? 'Unknown'} with ${rooms.length} chat rooms");

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
