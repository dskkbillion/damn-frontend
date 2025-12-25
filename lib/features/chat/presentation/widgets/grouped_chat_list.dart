import 'dart:convert'; // For JSON parsing

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/utils/price_formatter.dart';

import '../../domain/entities/chat_room.dart';
import '../../domain/entities/chat_message.dart'; // For ChatMessage type
import '../../domain/entities/participant.dart';
import '../bloc/chat_list/chat_list_bloc.dart';
import 'chat_list_item.dart';

/// 按卖家分组的聊天列表组件
class GroupedChatList extends StatelessWidget {
  final Function(ChatRoom) onChatTap;
  final int currentUserId;

  const GroupedChatList({
    Key? key,
    required this.onChatTap,
    required this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    
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
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  '暂无聊天记录',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
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
        if (chatRoom.participant1.type == 'MEMBER') {
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
        if (chatRoom.participant2.type == 'MEMBER') {
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
        if (firstRoom.participant1.type == 'MEMBER') {
          seller = firstRoom.participant2;
        } else {
          seller = firstRoom.participant1;
        }
      } else {
        if (firstRoom.participant2.type == 'MEMBER') {
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
  final Function(ChatRoom)? onDelete;

  const SellerGroupItem({
    Key? key,
    required this.group,
    required this.currentUserId,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);

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
    final appLocalizations = AppLocalizations.of(context)!;
    
    // 计算总未读数
    final totalUnread = widget.group.chatRooms.fold<int>(
      0, 
      (sum, room) => sum + room.unreadCount,
    );
    
    return Container(
      color: Colors.white,
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
                          ? Border.all(color: Colors.blue, width: 2)
                          : null,
                      ),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundImage: (widget.group.seller.avatar != null && widget.group.seller.avatar!.isNotEmpty)
                            ? CachedNetworkImageProvider(widget.group.seller.avatar!)
                            : null,
                        backgroundColor: Colors.grey[400],
                        child: (widget.group.seller.avatar == null || widget.group.seller.avatar!.isEmpty)
                            ? Text(
                                widget.group.seller.nickName?.isNotEmpty == true
                                    ? widget.group.seller.nickName![0].toUpperCase()
                                    : '?',
                                style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500),
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
                          widget.group.seller.nickName ?? '未知卖家',
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
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.shopping_bag, size: 12),
                                              );
                                            },
                                          )
                                        : Container(
                                            width: 24,
                                            height: 24,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.shopping_bag, size: 12),
                                          ),
                                  ),
                                );
                              }).toList(),
                              
                              // 如果有更多商品，显示数量
                              if (widget.group.chatRooms.length > 3)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '+${widget.group.chatRooms.length - 3}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              
                              // 如果只有一个商品，显示商品名称
                              if (widget.group.chatRooms.length == 1) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.group.chatRooms.first.productName ?? '商品对话',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
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
                            widget.group.chatRooms.length == 1 
                              ? '1个商品对话' 
                              : '${widget.group.chatRooms.length}个商品对话',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
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
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      
                      const SizedBox(height: 4),
                      
                      // 未读消息数量
                      if (totalUnread > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            totalUnread > 99 ? '99+' : totalUnread.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      
                      // 展开/收起指示器
                      const SizedBox(height: 4),
                      if (widget.group.chatRooms.length > 1)
                        Icon(
                          _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.grey[400],
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
              color: Colors.grey[50],
              child: Column(
                children: widget.group.chatRooms.map((chatRoom) {
                  return Container(
                    margin: const EdgeInsets.only(left: 16.0),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.grey[300]!, width: 2),
                      ),
                    ),
                    child: ProductChatItem(
                      chatRoom: chatRoom,
                      currentUserId: widget.currentUserId,
                      onTap: () => widget.onTap(chatRoom),
                      onDelete: widget.onDelete != null ? () => widget.onDelete!(chatRoom) : null,
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);
    final difference = today.difference(messageDate).inDays;

    if (difference == 0) {
      // 今天：显示时间
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference == 1) {
      // 昨天
      return '昨天';
    } else if (difference < 7) {
      // 一周内：显示星期
      const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return weekdays[time.weekday - 1];
    } else {
      // 更早：显示日期
      return '${time.month}/${time.day}';
    }
  }
}

/// 商品聊天项组件
class ProductChatItem extends StatelessWidget {
  final ChatRoom chatRoom;
  final int currentUserId;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ProductChatItem({
    Key? key,
    required this.chatRoom,
    required this.currentUserId,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);
  
  String _getMessagePreview(ChatMessage? message) {
    if (message == null) return '';
    
    switch (message.type) {
      case 'text':
        const maxLength = 30;
        return message.context.length > maxLength 
            ? '${message.context.substring(0, maxLength)}...' 
            : message.context;
      case 'image':
        return '[图片]';
      case 'audio':
        return '[语音]';
      case 'file':
        try {
          if (message.context.startsWith('{')) {
            final Map<String, dynamic> fileInfo = jsonDecode(message.context);
            final fileName = fileInfo['name'] ?? '文件';
            return '[文件] $fileName';
          }
        } catch (e) {
          // 解析失败
        }
        return '[文件]';
      default:
        const maxLength = 30;
        return message.context.length > maxLength 
            ? '${message.context.substring(0, maxLength)}...' 
            : message.context;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;

    final listTile = ListTile(
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
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.shopping_bag, color: Colors.grey),
                  );
                },
              ),
            )
          : Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shopping_bag, color: Colors.grey),
            ),
      title: Text(
        chatRoom.productName ?? '未知商品',
        style: const TextStyle(fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (chatRoom.productPrice != null)
            Text(
              PriceFormatter.format(chatRoom.productPrice!),
              style: TextStyle(
                color: Colors.red[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          if (chatRoom.lastMessage != null)
            Text(
              _getMessagePreview(chatRoom.lastMessage),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
              _formatTime(chatRoom.lastActivityTime!),
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          const SizedBox(height: 4),
          if (chatRoom.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                chatRoom.unreadCount > 99 ? '99+' : chatRoom.unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
        ],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    );

    if (onDelete != null) {
      return Dismissible(
        key: ValueKey('product_chat_${chatRoom.id}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('确认删除'),
                content: const Text('确定要删除这个聊天会话吗？删除后将无法恢复。'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('删除'),
                  ),
                ],
              );
            },
          ) ?? false;
        },
        onDismissed: (direction) {
          onDelete!();
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: Colors.red,
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        child: listTile,
      );
    }

    return listTile;
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);
    final difference = today.difference(messageDate).inDays;

    if (difference == 0) {
      // 今天：显示时间
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference == 1) {
      // 昨天
      return '昨天';
    } else if (difference < 7) {
      // 一周内：显示星期
      const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return weekdays[time.weekday - 1];
    } else {
      // 更早：显示日期
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
  final Function(ChatRoom)? onDelete;

  const ProductGroupItem({
    Key? key,
    required this.group,
    required this.currentUserId,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);

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
    
    return Container(
      color: Colors.white,
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
                          ? Border.all(color: Colors.blue, width: 2)
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
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.shopping_bag, color: Colors.grey),
                                  );
                                },
                              )
                            : Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[200],
                                child: const Icon(Icons.shopping_bag, color: Colors.grey),
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
                          widget.group.productName ?? '未知商品',
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // 商品价格
                        if (widget.group.productPrice != null)
                          Text(
                            PriceFormatter.format(widget.group.productPrice!),
                            style: TextStyle(
                              color: Colors.red[600],
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
                                    backgroundColor: Colors.grey[400],
                                    child: (buyer.avatar == null || buyer.avatar!.isEmpty)
                                        ? Text(
                                            buyer.nickName?.isNotEmpty == true
                                                ? buyer.nickName![0].toUpperCase()
                                                : '?',
                                            style: const TextStyle(fontSize: 10, color: Colors.white),
                                          )
                                        : null,
                                  ),
                                );
                              }).toList(),
                              
                              // 如果有更多用户，显示数量
                              if (widget.group.chatRooms.length > 3)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '+${widget.group.chatRooms.length - 3}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              
                              // 如果只有一个用户，显示用户名称
                              if (widget.group.chatRooms.length == 1) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.group.chatRooms.first.participant2.nickName ?? '未知用户',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
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
                            widget.group.chatRooms.length == 1 
                              ? '1个用户咨询' 
                              : '${widget.group.chatRooms.length}个用户咨询',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
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
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      
                      const SizedBox(height: 4),
                      
                      // 未读消息数量
                      if (totalUnread > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            totalUnread > 99 ? '99+' : totalUnread.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      
                      // 展开/收起指示器
                      const SizedBox(height: 4),
                      if (widget.group.chatRooms.length > 1)
                        Icon(
                          _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.grey[400],
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
              color: Colors.grey[50],
              child: Column(
                children: widget.group.chatRooms.map((chatRoom) {
                  return Container(
                    margin: const EdgeInsets.only(left: 16.0),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.grey[300]!, width: 2),
                      ),
                    ),
                    child: BuyerChatItem(
                      chatRoom: chatRoom,
                      currentUserId: widget.currentUserId,
                      onTap: () => widget.onTap(chatRoom),
                      onDelete: widget.onDelete != null ? () => widget.onDelete!(chatRoom) : null,
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);
    final difference = today.difference(messageDate).inDays;

    if (difference == 0) {
      // 今天：显示时间
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference == 1) {
      // 昨天
      return '昨天';
    } else if (difference < 7) {
      // 一周内：显示星期
      const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return weekdays[time.weekday - 1];
    } else {
      // 更早：显示日期
      return '${time.month}/${time.day}';
    }
  }
}

/// 买家聊天项组件 - 卖家视角下显示买家信息
class BuyerChatItem extends StatelessWidget {
  final ChatRoom chatRoom;
  final int currentUserId;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const BuyerChatItem({
    Key? key,
    required this.chatRoom,
    required this.currentUserId,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);
  
  String _getMessagePreview(ChatMessage? message) {
    if (message == null) return '';
    
    switch (message.type) {
      case 'text':
        const maxLength = 30;
        return message.context.length > maxLength 
            ? '${message.context.substring(0, maxLength)}...' 
            : message.context;
      case 'image':
        return '[图片]';
      case 'audio':
        return '[语音]';
      case 'file':
        try {
          if (message.context.startsWith('{')) {
            final Map<String, dynamic> fileInfo = jsonDecode(message.context);
            final fileName = fileInfo['name'] ?? '文件';
            return '[文件] $fileName';
          }
        } catch (e) {
          // 解析失败
        }
        return '[文件]';
      default:
        const maxLength = 30;
        return message.context.length > maxLength 
            ? '${message.context.substring(0, maxLength)}...' 
            : message.context;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // 在卖家视角下，participant2是买家
    final buyer = chatRoom.participant2;

    final listTile = ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: (buyer.avatar != null && buyer.avatar!.isNotEmpty)
            ? CachedNetworkImageProvider(buyer.avatar!)
            : null,
        backgroundColor: Colors.grey[400],
        child: (buyer.avatar == null || buyer.avatar!.isEmpty)
            ? Text(
                buyer.nickName?.isNotEmpty == true
                    ? buyer.nickName![0].toUpperCase()
                    : '?',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              )
            : null,
      ),
      title: Text(
        buyer.nickName ?? '未知用户',
        style: const TextStyle(fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: chatRoom.lastMessage != null
          ? Text(
              chatRoom.lastMessage!.context,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : Text(
              '暂无消息',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (chatRoom.lastActivityTime != null)
            Text(
              _formatTime(chatRoom.lastActivityTime!),
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          const SizedBox(height: 4),
          if (chatRoom.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                chatRoom.unreadCount > 99 ? '99+' : chatRoom.unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
        ],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    );

    if (onDelete != null) {
      return Dismissible(
        key: ValueKey('buyer_chat_${chatRoom.id}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('确认删除'),
                content: const Text('确定要删除这个聊天会话吗？删除后将无法恢复。'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('删除'),
                  ),
                ],
              );
            },
          ) ?? false;
        },
        onDismissed: (direction) {
          onDelete!();
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: Colors.red,
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        child: listTile,
      );
    }

    return listTile;
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);
    final difference = today.difference(messageDate).inDays;

    if (difference == 0) {
      // 今天：显示时间
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference == 1) {
      // 昨天
      return '昨天';
    } else if (difference < 7) {
      // 一周内：显示星期
      const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return weekdays[time.weekday - 1];
    } else {
      // 更早：显示日期
      return '${time.month}/${time.day}';
    }
  }
} 