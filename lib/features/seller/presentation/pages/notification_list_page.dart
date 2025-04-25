import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/notification_type.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_notification.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/blocs/notification_list/notification_list_bloc.dart';
import 'package:dskk_flutter_refactor/core/widgets/loading_indicator.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

/// 通知列表页面
class NotificationListPage extends StatelessWidget {
  /// 路由名称
  static const routeName = '/seller/notifications';

  /// 构造函数
  const NotificationListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<NotificationListBloc>()
        ..add(LoadNotificationList(type: NotificationType.all, refresh: true)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('通知'),
          actions: [
            BlocBuilder<NotificationListBloc, NotificationListState>(
              builder: (context, state) {
                if (state is NotificationListLoaded) {
                  return IconButton(
                    icon: const Icon(Icons.done_all),
                    tooltip: '全部标记为已读',
                    onPressed: () {
                      _showMarkAllReadConfirmation(context, state.currentType);
                    },
                  );
                }
                return Container();
              },
            ),
          ],
        ),
        body: const NotificationListContent(),
      ),
    );
  }

  /// 显示全部标记为已读确认对话框
  void _showMarkAllReadConfirmation(BuildContext context, NotificationType type) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('标记全部已读'),
        content: Text('确定要将${type == NotificationType.all ? '所有' : _getTypeDisplayName(type)}通知标记为已读吗？'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<NotificationListBloc>().add(MarkAllNotificationsAsRead(type: type));
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 获取通知类型显示名称
  String _getTypeDisplayName(NotificationType type) {
    switch (type) {
      case NotificationType.system:
        return '系统';
      case NotificationType.order:
        return '订单';
      case NotificationType.afterSale:
        return '售后';
      case NotificationType.promotion:
        return '活动';
      case NotificationType.other:
        return '其他';
      default:
        return '';
    }
  }
}

/// 通知列表内容组件
class NotificationListContent extends StatefulWidget {
  /// 构造函数
  const NotificationListContent({Key? key}) : super(key: key);

  @override
  State<NotificationListContent> createState() => _NotificationListContentState();
}

class _NotificationListContentState extends State<NotificationListContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabChange);
  }
  
  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }
  
  /// 处理标签页变化
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      NotificationType type;
      switch (_tabController.index) {
        case 0:
          type = NotificationType.all;
          break;
        case 1:
          type = NotificationType.order;
          break;
        case 2:
          type = NotificationType.system;
          break;
        case 3:
          type = NotificationType.afterSale;
          break;
        case 4:
          type = NotificationType.promotion;
          break;
        default:
          type = NotificationType.all;
      }
      context.read<NotificationListBloc>().add(ChangeNotificationType(type: type));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: '全部'),
            Tab(text: '订单'),
            Tab(text: '系统'),
            Tab(text: '售后'),
            Tab(text: '活动'),
          ],
        ),
        Expanded(
          child: BlocConsumer<NotificationListBloc, NotificationListState>(
            listener: (context, state) {
              if (state is NotificationListLoaded && state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error!)),
                );
              }
            },
            builder: (context, state) {
              if (state is NotificationListInitial || state is NotificationListLoading) {
                return const Center(child: LoadingIndicator());
              }
              
              if (state is NotificationListError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<NotificationListBloc>().add(
                            LoadNotificationList(
                              type: _getCurrentTypeFromTabIndex(),
                              refresh: true,
                            ),
                          );
                        },
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                );
              }
              
              if (state is NotificationListLoaded) {
                if (state.notifications.isEmpty) {
                  return _buildEmptyState(state.currentType);
                }
                
                return _buildNotificationList(context, state);
              }
              
              return const Center(child: Text('加载失败'));
            },
          ),
        ),
      ],
    );
  }
  
  /// 从当前Tab索引获取通知类型
  NotificationType _getCurrentTypeFromTabIndex() {
    switch (_tabController.index) {
      case 0:
        return NotificationType.all;
      case 1:
        return NotificationType.order;
      case 2:
        return NotificationType.system;
      case 3:
        return NotificationType.afterSale;
      case 4:
        return NotificationType.promotion;
      default:
        return NotificationType.all;
    }
  }
  
  /// 构建空状态
  Widget _buildEmptyState(NotificationType type) {
    String message;
    switch (type) {
      case NotificationType.all:
        message = '暂无任何通知';
        break;
      case NotificationType.order:
        message = '暂无订单通知';
        break;
      case NotificationType.system:
        message = '暂无系统通知';
        break;
      case NotificationType.afterSale:
        message = '暂无售后通知';
        break;
      case NotificationType.promotion:
        message = '暂无活动通知';
        break;
      default:
        message = '暂无通知';
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<NotificationListBloc>().add(
                LoadNotificationList(type: type, refresh: true),
              );
            },
            child: const Text('刷新'),
          ),
        ],
      ),
    );
  }
  
  /// 构建通知列表
  Widget _buildNotificationList(BuildContext context, NotificationListLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<NotificationListBloc>().add(
          LoadNotificationList(type: state.currentType, refresh: true),
        );
      },
      child: ListView.builder(
        itemCount: state.notifications.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // 加载更多判断
          if (index >= state.notifications.length) {
            // 如果当前不是正在加载更多，则触发加载更多事件
            if (!state.isLoadingMore) {
              context.read<NotificationListBloc>().add(
                LoadNotificationList(type: state.currentType),
              );
            }
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: LoadingIndicator(size: 24.0)),
            );
          }
          
          final notification = state.notifications[index];
          return _NotificationItem(
            notification: notification,
            onTap: () {
              _showNotificationDetail(context, notification);
            },
          );
        },
      ),
    );
  }
  
  /// 显示通知详情对话框
  void _showNotificationDetail(BuildContext context, SellerNotification notification) {
    // 如果通知未读，标记为已读
    if (!notification.isRead) {
      context.read<NotificationListBloc>().add(
        MarkNotificationAsRead(notificationId: notification.notificationId),
      );
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('yyyy-MM-dd HH:mm').format(notification.createdAt),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Text(notification.content),
          ],
        ),
        actions: [
          if (notification.relatedEntityId != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 根据通知类型跳转到相应页面
                _navigateToRelatedPage(context, notification);
              },
              child: const Text('查看详情'),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
  
  /// 根据通知类型导航到相关页面
  void _navigateToRelatedPage(BuildContext context, SellerNotification notification) {
    // 实现导航逻辑
    switch (notification.type) {
      case NotificationType.order:
        // 跳转到订单详情页
        break;
      case NotificationType.afterSale:
        // 跳转到售后详情页
        break;
      default:
        // 其他类型可能不需要跳转
        break;
    }
  }
}

/// 通知列表项组件
class _NotificationItem extends StatelessWidget {
  final SellerNotification notification;
  final VoidCallback onTap;

  const _NotificationItem({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? null : Colors.blue.withOpacity(0.05),
          border: const Border(bottom: BorderSide(color: Colors.black12)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDateTime(notification.createdAt),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建通知图标
  Widget _buildNotificationIcon() {
    IconData iconData;
    Color iconColor;
    
    switch (notification.type) {
      case NotificationType.order:
        iconData = Icons.shopping_bag;
        iconColor = Colors.blue;
        break;
      case NotificationType.system:
        iconData = Icons.notifications;
        iconColor = Colors.green;
        break;
      case NotificationType.afterSale:
        iconData = Icons.assignment_return;
        iconColor = Colors.orange;
        break;
      case NotificationType.promotion:
        iconData = Icons.campaign;
        iconColor = Colors.purple;
        break;
      default:
        iconData = Icons.message;
        iconColor = Colors.grey;
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      return DateFormat('yyyy-MM-dd').format(dateTime);
    } else if (difference.inDays > 30) {
      return '${difference.inDays ~/ 30}个月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
} 