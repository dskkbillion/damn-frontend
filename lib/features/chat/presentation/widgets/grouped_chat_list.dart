import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/constants/participant_type.dart';

import '../../domain/entities/chat_room.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/participant.dart';
import '../bloc/chat_list/chat_list_bloc.dart';
import 'chat_list_item.dart';
import 'ai_summary_message_bubble.dart'; // #377 复用 summary 安全清洗
import 'chat_message_bubble.dart'; // #377 复用 isAiSummaryMessage 前缀表

/// #377：会话列表预览安全清洗——allocate(AI summary) 不能直渲原始 context
/// （会泄漏 **User Profile Construction** 等内部 prompt 标记）。命中泄漏前缀显示
/// 中性占位，否则无条件 strip markdown 标记，与 AiSummaryMessageBubble 一致。
String summaryPreviewText(ChatMessage message, AppLocalizations s) {
  if (ChatMessageBubble.isSummaryType(message.type)) {
    if (ChatMessageBubble.isAiSummaryMessage(message.context)) {
      return s.chat_summary_hidden;
    }
    return AiSummaryMessageBubble.stripMarkdownMarkers(message.context);
  }
  return message.context;
}

/// 按卖家分组的聊天列表组件
class GroupedChatList extends StatelessWidget {
  final Function(ChatRoom) onChatTap;
  final int currentUserId;

  const GroupedChatList({
    super.key,
    required this.onChatTap,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    
    return BlocBuilder<ChatListBloc, ChatListState>(
      builder: (context, state) {
        if (state.status == ChatListStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state.chatRooms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textTertiary),
                const SizedBox(height: 16),
                Text(
                  s.chat_no_chat_records,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                ),
              ],
            ),
          );
        }
        
        // 按卖家分组
        final groupedChats = _groupChatsBySeller(state.chatRooms);
        
        return ListView.builder(
          itemCount: groupedChats.length,
          itemBuilder: (context, index) {
            final group = groupedChats[index];
            
            if (group.chatRooms.length == 1) {
              // 单个聊天室，直接显示
              return ChatListItem(
                chatRoom: group.chatRooms.first,
                currentUserId: currentUserId,
                onTap: () => onChatTap(group.chatRooms.first),
              );
            } else {
              // 多个聊天室，显示分组
              return SellerGroupItem(
                group: group,
                currentUserId: currentUserId,
                onTap: onChatTap,
              );
            }
          },
        );
      },
    );
  }
  
  /// 按卖家分组聊天室
  List<SellerChatGroup> _groupChatsBySeller(List<ChatRoom> chatRooms) {
    final Map<int, List<ChatRoom>> grouped = {};
    
    for (final chatRoom in chatRooms) {
      // 确定卖家：根据参与者类型判断
      Participant seller;
      int sellerId;
      
      // 判断当前用户的类型
      if (chatRoom.participant1.referId == currentUserId) {
        // 当前用户是participant1
        if (chatRoom.participant1.type == ParticipantType.member) {
          // 当前用户是买家，对方是卖家
          seller = chatRoom.participant2;
          sellerId = chatRoom.participant2.referId ?? 0;
        } else {
          // 当前用户是卖家，按当前用户分组
          seller = chatRoom.participant1;
          sellerId = chatRoom.participant1.referId ?? 0;
        }
      } else {
        // 当前用户是participant2
        if (chatRoom.participant2.type == ParticipantType.member) {
          // 当前用户是买家，对方是卖家
          seller = chatRoom.participant1;
          sellerId = chatRoom.participant1.referId ?? 0;
        } else {
          // 当前用户是卖家，按当前用户分组
          seller = chatRoom.participant2;
          sellerId = chatRoom.participant2.referId ?? 0;
        }
      }
      
      grouped.putIfAbsent(sellerId, () => []).add(chatRoom);
    }
    
    return grouped.entries.map((entry) {
      final sellerId = entry.key;
      final rooms = entry.value;
      // 从第一个房间获取卖家信息
      final firstRoom = rooms.first;
      Participant seller;
      
      // 重新确定卖家信息（与上面逻辑一致）
      if (firstRoom.participant1.referId == currentUserId) {
        if (firstRoom.participant1.type == ParticipantType.member) {
          seller = firstRoom.participant2;
        } else {
          seller = firstRoom.participant1;
        }
      } else {
        if (firstRoom.participant2.type == ParticipantType.member) {
          seller = firstRoom.participant1;
        } else {
          seller = firstRoom.participant2;
        }
      }
      
      return SellerChatGroup(
        sellerId: sellerId,
        seller: seller,
        chatRooms: rooms,
      );
    }).toList();
  }
}

/// 卖家聊天分组数据类
class SellerChatGroup {
  final int sellerId;
  final Participant seller;
  final List<ChatRoom> chatRooms;
  
  SellerChatGroup({
    required this.sellerId,
    required this.seller,
    required this.chatRooms,
  });
}

/// 卖家分组项组件
class SellerGroupItem extends StatefulWidget {
  final SellerChatGroup group;
  final int currentUserId;
  final Function(ChatRoom) onTap;
  
  const SellerGroupItem({
    super.key,
    required this.group,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  State<SellerGroupItem> createState() => _SellerGroupItemState();
}

class _SellerGroupItemState extends State<SellerGroupItem> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    // 如果只有一个商品，直接进入聊天
    if (widget.group.chatRooms.length == 1) {
      widget.onTap(widget.group.chatRooms.first);
      return;
    }
    
    // 多个商品时才展开/收起
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    
    // 计算总未读数
    final totalUnread = widget.group.chatRooms.fold<int>(
      0, 
      (sum, room) => sum + room.unreadCount,
    );
    
    return GlassCard(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(18),
      tintOpacity: 0.62,
      child: Column(
        children: [
          // 主要内容区域
          InkWell(
            onTap: _toggleExpansion, // 整行都可以点击展开
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  // 卖家头像（保持可点击，但功能相同）
                  GestureDetector(
                    onTap: _toggleExpansion,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: _isExpanded
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                      ),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundImage: (widget.group.seller.avatar != null && widget.group.seller.avatar!.isNotEmpty)
                            ? CachedNetworkImageProvider(widget.group.seller.avatar!)
                            : null,
                        backgroundColor: AppColors.backgroundSecondary,
                        child: (widget.group.seller.avatar == null || widget.group.seller.avatar!.isEmpty)
                            ? Text(
                                widget.group.seller.nickName?.isNotEmpty == true
                                    ? widget.group.seller.nickName![0].toUpperCase()
                                    : '?',
                                style: const TextStyle(fontSize: 20, color: AppColors.onPrimary),
                              )
                            : null,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // 卖家信息和商品预览
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 卖家名称
                        Text(
                          widget.group.seller.nickName ?? AppLocalizations.of(context).chat_unknown_seller,
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                        
                        const SizedBox(height: 6),
                        
                        // 商品缩略图预览行（无论单个还是多个都显示）
                        if (!_isExpanded) ...[
                          Row(
                            children: [
                              // 显示前3个商品的缩略图
                              ...widget.group.chatRooms.take(3).map((chatRoom) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 4),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: chatRoom.productImage != null
                                        ? CachedNetworkImage(
                                            imageUrl: chatRoom.productImage!,
                                            width: 24,
                                            height: 24,
                                            fit: BoxFit.cover,
                                            errorWidget: (context, url, error) {
                                              return Container(
                                                width: 24,
                                                height: 24,
                                                color: AppColors.borderInput,
                                                child: const Icon(Icons.shopping_bag, size: 12),
                                              );
                                            },
                                          )
                                        : Container(
                                            width: 24,
                                            height: 24,
                                            color: AppColors.borderInput,
                                            child: const Icon(Icons.shopping_bag, size: 12),
                                          ),
                                  ),
                                );
                              }),
                              
                              // 如果有更多商品，显示数量
                              if (widget.group.chatRooms.length > 3)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundSecondary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '+${widget.group.chatRooms.length - 3}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                              // 如果只有一个商品，显示商品名称
                              if (widget.group.chatRooms.length == 1) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.group.chatRooms.first.hasProduct &&
                                            !widget.group.chatRooms.first.hasAvailableProduct
                                        ? AppLocalizations.of(context).chat_product_info_incomplete
                                        : widget.group.chatRooms.first.productName ??
                                            AppLocalizations.of(context).chat_product_conversation,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ] else ...[
                          // 展开状态下显示商品数量
                          Text(
                            AppLocalizations.of(context).chat_product_conversation_count(widget.group.chatRooms.length),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // 右侧信息
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 最新消息时间
                      if (widget.group.chatRooms.isNotEmpty && widget.group.chatRooms.first.lastActivityTime != null)
                        Text(
                          _formatTime(widget.group.chatRooms.first.lastActivityTime!),
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),

                      const SizedBox(height: 4),

                      // 未读消息数量
                      if (totalUnread > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            totalUnread > 99 ? '99+' : totalUnread.toString(),
                            style: const TextStyle(color: AppColors.onPrimary, fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // 展开/收起指示器
                      const SizedBox(height: 4),
                      if (widget.group.chatRooms.length > 1)
                        Icon(
                          _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: AppColors.textTertiary,
                          size: 20,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 展开的商品列表
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary.withValues(alpha: 0.52),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: widget.group.chatRooms.map((chatRoom) {
                  return Container(
                    margin: const EdgeInsets.only(left: 16.0),
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: AppColors.borderInput, width: 2),
                      ),
                    ),
                    child: ProductChatItem(
                      chatRoom: chatRoom,
                      currentUserId: widget.currentUserId,
                      onTap: () => widget.onTap(chatRoom),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    final s = AppLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);
    final difference = today.difference(messageDate).inDays;

    if (difference == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference == 1) {
      return s.chat_yesterday;
    } else if (difference < 7) {
      final weekdays = [
        s.chat_weekday_mon, s.chat_weekday_tue, s.chat_weekday_wed,
        s.chat_weekday_thu, s.chat_weekday_fri, s.chat_weekday_sat,
        s.chat_weekday_sun,
      ];
      return weekdays[time.weekday - 1];
    } else {
      return '${time.month}/${time.day}';
    }
  }
}

/// 商品聊天项组件
class ProductChatItem extends StatelessWidget {
  final ChatRoom chatRoom;
  final int currentUserId;
  final VoidCallback onTap;
  
  const ProductChatItem({
    super.key,
    required this.chatRoom,
    required this.currentUserId,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    
    return ListTile(
      leading: chatRoom.productImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: chatRoom.productImage!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) {
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.shopping_bag, color: AppColors.textTertiary),
                  );
                },
              ),
            )
          : Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shopping_bag, color: AppColors.textTertiary),
            ),
      title: Text(
        chatRoom.hasProduct && !chatRoom.hasAvailableProduct
            ? s.chat_product_info_incomplete
            : chatRoom.productName ?? s.chat_unknown_product,
        style: const TextStyle(fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (chatRoom.hasAvailableProduct)
            Text(
              '¥${chatRoom.productPrice!.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (chatRoom.lastMessage != null)
            Text(
              summaryPreviewText(chatRoom.lastMessage!, s),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (chatRoom.lastActivityTime != null)
            Text(
              _formatTime(context, chatRoom.lastActivityTime!),
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          const SizedBox(height: 4),
          if (chatRoom.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                chatRoom.unreadCount > 99 ? '99+' : chatRoom.unreadCount.toString(),
                style: const TextStyle(color: AppColors.onPrimary, fontSize: 10),
              ),
            ),
        ],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    );
  }

  String _formatTime(BuildContext context, DateTime time) {
    final s = AppLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);
    final difference = today.difference(messageDate).inDays;

    if (difference == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference == 1) {
      return s.chat_yesterday;
    } else if (difference < 7) {
      final weekdays = [
        s.chat_weekday_mon, s.chat_weekday_tue, s.chat_weekday_wed,
        s.chat_weekday_thu, s.chat_weekday_fri, s.chat_weekday_sat,
        s.chat_weekday_sun,
      ];
      return weekdays[time.weekday - 1];
    } else {
      return '${time.month}/${time.day}';
    }
  }
}

/// 商品聊天分组数据类 - 卖家模式使用
class ProductChatGroup {
  final String productId;
  final String? productName;
  final String? productImage;
  final double? productPrice;
  final List<ChatRoom> chatRooms;
  
  ProductChatGroup({
    required this.productId,
    this.productName,
    this.productImage,
    this.productPrice,
    required this.chatRooms,
  });
}

/// 商品分组项组件 - 卖家模式使用
class ProductGroupItem extends StatefulWidget {
  final ProductChatGroup group;
  final int currentUserId;
  final Function(ChatRoom) onTap;
  
  const ProductGroupItem({
    super.key,
    required this.group,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  State<ProductGroupItem> createState() => _ProductGroupItemState();
}

class _ProductGroupItemState extends State<ProductGroupItem> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    // 如果只有一个用户，直接进入聊天
    if (widget.group.chatRooms.length == 1) {
      widget.onTap(widget.group.chatRooms.first);
      return;
    }
    
    // 多个用户时才展开/收起
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // 计算总未读数
    final totalUnread = widget.group.chatRooms.fold<int>(
      0, 
      (sum, room) => sum + room.unreadCount,
    );
    
    return GlassCard(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(18),
      tintOpacity: 0.62,
      child: Column(
        children: [
          // 主要内容区域
          InkWell(
            onTap: _toggleExpansion,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  // 商品图片
                  GestureDetector(
                    onTap: _toggleExpansion,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: _isExpanded
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: widget.group.productImage != null
                            ? CachedNetworkImage(
                                imageUrl: widget.group.productImage!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) {
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    color: AppColors.backgroundSecondary,
                                    child: const Icon(Icons.shopping_bag, color: AppColors.textTertiary),
                                  );
                                },
                              )
                            : Container(
                                width: 50,
                                height: 50,
                                color: AppColors.backgroundSecondary,
                                child: const Icon(Icons.shopping_bag, color: AppColors.textTertiary),
                              ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // 商品信息和用户预览
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 商品名称
                        Text(
                          widget.group.productName ??
                              AppLocalizations.of(context).chat_product_info_incomplete,
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // 商品价格
                        if (widget.group.productName != null &&
                            widget.group.productPrice != null &&
                            widget.group.productPrice! > 0)
                          Text(
                            '¥${widget.group.productPrice!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        
                        const SizedBox(height: 6),
                        
                        // 用户头像预览行（无论单个还是多个都显示）
                        if (!_isExpanded) ...[
                          Row(
                            children: [
                              // 显示前3个用户的头像
                              ...widget.group.chatRooms.take(3).map((chatRoom) {
                                final buyer = chatRoom.participant2; // 在卖家视角下，participant2是买家
                                return Container(
                                  margin: const EdgeInsets.only(right: 4),
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundImage: (buyer.avatar != null && buyer.avatar!.isNotEmpty)
                                        ? CachedNetworkImageProvider(buyer.avatar!)
                                        : null,
                                    backgroundColor: AppColors.borderInput,
                                    child: (buyer.avatar == null || buyer.avatar!.isEmpty)
                                        ? Text(
                                            buyer.nickName?.isNotEmpty == true
                                                ? buyer.nickName![0].toUpperCase()
                                                : '?',
                                            style: const TextStyle(fontSize: 10, color: AppColors.onPrimary),
                                          )
                                        : null,
                                  ),
                                );
                              }),
                              
                              // 如果有更多用户，显示数量
                              if (widget.group.chatRooms.length > 3)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundSecondary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '+${widget.group.chatRooms.length - 3}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                              // 如果只有一个用户，显示用户名称
                              if (widget.group.chatRooms.length == 1) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.group.chatRooms.first.participant2.nickName ?? AppLocalizations.of(context).chat_unknown_user,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ] else ...[
                          // 展开状态下显示用户数量
                          Text(
                            AppLocalizations.of(context).chat_user_inquiry_count(widget.group.chatRooms.length),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // 右侧信息
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 最新消息时间
                      if (widget.group.chatRooms.isNotEmpty && widget.group.chatRooms.first.lastActivityTime != null)
                        Text(
                          _formatTime(widget.group.chatRooms.first.lastActivityTime!),
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),

                      const SizedBox(height: 4),

                      // 未读消息数量
                      if (totalUnread > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            totalUnread > 99 ? '99+' : totalUnread.toString(),
                            style: const TextStyle(color: AppColors.onPrimary, fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // 展开/收起指示器
                      const SizedBox(height: 4),
                      if (widget.group.chatRooms.length > 1)
                        Icon(
                          _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: AppColors.textTertiary,
                          size: 20,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // 展开的用户列表
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary.withValues(alpha: 0.52),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: widget.group.chatRooms.map((chatRoom) {
                  return Container(
                    margin: const EdgeInsets.only(left: 16.0),
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: AppColors.borderInput, width: 2),
                      ),
                    ),
                    child: BuyerChatItem(
                      chatRoom: chatRoom,
                      currentUserId: widget.currentUserId,
                      onTap: () => widget.onTap(chatRoom),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    final s = AppLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);
    final difference = today.difference(messageDate).inDays;

    if (difference == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference == 1) {
      return s.chat_yesterday;
    } else if (difference < 7) {
      final weekdays = [
        s.chat_weekday_mon, s.chat_weekday_tue, s.chat_weekday_wed,
        s.chat_weekday_thu, s.chat_weekday_fri, s.chat_weekday_sat,
        s.chat_weekday_sun,
      ];
      return weekdays[time.weekday - 1];
    } else {
      return '${time.month}/${time.day}';
    }
  }
}

/// 买家聊天项组件 - 卖家视角下显示买家信息
class BuyerChatItem extends StatelessWidget {
  final ChatRoom chatRoom;
  final int currentUserId;
  final VoidCallback onTap;
  
  const BuyerChatItem({
    super.key,
    required this.chatRoom,
    required this.currentUserId,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    // 在卖家视角下，participant2是买家
    final buyer = chatRoom.participant2;

    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: (buyer.avatar != null && buyer.avatar!.isNotEmpty)
            ? CachedNetworkImageProvider(buyer.avatar!)
            : null,
        backgroundColor: AppColors.backgroundSecondary,
        child: (buyer.avatar == null || buyer.avatar!.isEmpty)
            ? Text(
                buyer.nickName?.isNotEmpty == true
                    ? buyer.nickName![0].toUpperCase()
                    : '?',
                style: const TextStyle(fontSize: 16, color: AppColors.onPrimary),
              )
            : null,
      ),
      title: Text(
        buyer.nickName ?? s.chat_unknown_user,
        style: const TextStyle(fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: chatRoom.lastMessage != null
          ? Text(
              summaryPreviewText(chatRoom.lastMessage!, s),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : Text(
              s.chat_no_messages_brief,
              style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
            ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (chatRoom.lastActivityTime != null)
            Text(
              _formatTime(context, chatRoom.lastActivityTime!),
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          const SizedBox(height: 4),
          if (chatRoom.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                chatRoom.unreadCount > 99 ? '99+' : chatRoom.unreadCount.toString(),
                style: const TextStyle(color: AppColors.onPrimary, fontSize: 10),
              ),
            ),
        ],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    );
  }

  String _formatTime(BuildContext context, DateTime time) {
    final s = AppLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);
    final difference = today.difference(messageDate).inDays;

    if (difference == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference == 1) {
      return s.chat_yesterday;
    } else if (difference < 7) {
      final weekdays = [
        s.chat_weekday_mon, s.chat_weekday_tue, s.chat_weekday_wed,
        s.chat_weekday_thu, s.chat_weekday_fri, s.chat_weekday_sat,
        s.chat_weekday_sun,
      ];
      return weekdays[time.weekday - 1];
    } else {
      return '${time.month}/${time.day}';
    }
  }
}
