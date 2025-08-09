import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_notification.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/blocs/notification_list/notification_list_bloc.dart';
import 'package:dskk_flutter_refactor/core/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dskk_flutter_refactor/core/network/network_info.dart';
import 'package:dskk_flutter_refactor/core/network/mock_network_info.dart' as mock;
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_notification_list_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_unread_notification_count_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:dskk_flutter_refactor/features/seller/data/repositories/seller_repository_impl.dart';
import 'package:dskk_flutter_refactor/features/seller/data/datasources/seller_remote_data_source_impl.dart';
import 'package:dskk_flutter_refactor/features/seller/data/datasources/seller_local_data_source_impl.dart';
import 'package:dskk_flutter_refactor/core/services/notification_navigation_service.dart';

/// 通知列表页面
class NotificationListPage extends StatelessWidget {
  /// 路由名称
  static const routeName = '/seller/notifications';

  /// 构造函数
  const NotificationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      // 获取主应用的GetIt实例
      final getIt = GetIt.I;
            
      // 尝试从GetIt获取主应用的Dio实例
      final dio = getIt<Dio>();
      
      // 获取主应用的其他必要依赖
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
      
      // 使用BlocProvider提供NotificationListBloc
      return BlocProvider(
        create: (context) => NotificationListBloc(
          getSellerNotificationListUseCase,
          markNotificationAsReadUseCase,
          markAllNotificationsAsReadUseCase,
          getUnreadNotificationCountUseCase,
        )..add(LoadNotificationList()), // 加载初始数据
        child: Scaffold(
          appBar: AppBar(
            title: const Text('通知中心'),
            centerTitle: true,
          ),
          body: const NotificationListContent(),
        ),
      );
    } catch (e) {
      print('Error creating NotificationListBloc: $e');
      return Scaffold(
        appBar: AppBar(
          title: const Text('通知中心'),
          centerTitle: true,
        ),
        body: Center(
          child: Text('加载通知中心失败: $e'),
        ),
      );
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
      NotificationType? type;
      switch (_tabController.index) {
        case 0:
          type = null;
          break;
        case 1:
          type = NotificationType.order;
          break;
        case 2:
          type = NotificationType.system;
          break;
        case 3:
          type = NotificationType.refund;
          break;
        case 4:
          type = NotificationType.message;
          break;
        default:
          type = null;
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
            Tab(text: '消息'),
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
  NotificationType? _getCurrentTypeFromTabIndex() {
    switch (_tabController.index) {
      case 0:
        return null;
      case 1:
        return NotificationType.order;
      case 2:
        return NotificationType.system;
      case 3:
        return NotificationType.refund;
      case 4:
        return NotificationType.message;
      default:
        return null;
    }
  }
  
  /// 构建空状态
  Widget _buildEmptyState(NotificationType? type) {
    String message;
    if (type == null) {
      message = '暂无任何通知';
    } else {
      switch (type) {
        case NotificationType.order:
          message = '暂无订单通知';
          break;
        case NotificationType.system:
          message = '暂无系统通知';
          break;
        case NotificationType.refund:
          message = '暂无售后通知';
          break;
        case NotificationType.message:
          message = '暂无消息通知';
          break;
        case NotificationType.review:
          message = '暂无评价通知';
          break;
        case NotificationType.authentication:
          message = '暂无认证通知';
          break;
        case NotificationType.other:
          message = '暂无其他通知';
          break;
        default:
          message = '暂无通知';
      }
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
    
    // 处理标题和内容，确保它们不是JSON格式字符串
    String displayTitle = notification.title;
    String displayContent = notification.content;
    
    // 如果标题或内容仍包含JSON格式，尝试提取
    if (displayTitle.contains('{title:') || displayTitle.contains('content:')) {
      displayTitle = '通知详情';
    }
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(displayTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('yyyy-MM-dd HH:mm').format(notification.createdAt),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Text(displayContent),
          ],
        ),
        actions: [
          if (notification.relatedEntityId != null)
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // 根据通知类型跳转到相应页面
                _navigateToRelatedPage(context, notification);
              },
              child: const Text('查看详情'),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
  
  /// 根据通知类型导航到相关页面
  void _navigateToRelatedPage(BuildContext context, SellerNotification notification) {
    // 使用统一的通知导航服务处理跳转
    // 注意：这里假设从NotificationListPage访问的都是当前用户角色的通知
    // 可以根据页面路由来判断是买家还是卖家
    final currentPath = ModalRoute.of(context)?.settings.name ?? '';
    final isSeller = currentPath.contains('seller');
    
    NotificationNavigationService.handleNotificationNavigation(
      context: context,
      notificationType: notification.type.toString().split('.').last, // 获取枚举名称
      entityId: notification.relatedEntityId?.toString(),
      receiverType: isSeller ? 'TenantUser' : 'Member', // 根据当前路由判断用户类型
      extra: {
        'notificationId': notification.notificationId,
        'title': notification.title,
        'content': notification.content,
      },
    );
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title.startsWith('{') 
                            ? '通知'
                            : notification.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
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
                  const SizedBox(height: 4),
                  Text(
                    notification.content.startsWith('{') 
                      ? '点击查看详情'
                      : notification.content,
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
      case NotificationType.refund:
        iconData = Icons.assignment_return;
        iconColor = Colors.orange;
        break;
      case NotificationType.message:
        iconData = Icons.message;
        iconColor = Colors.cyan;
        break;
      case NotificationType.review:
        iconData = Icons.rate_review;
        iconColor = Colors.yellow.shade700;
        break;
      case NotificationType.authentication:
        iconData = Icons.verified_user;
        iconColor = Colors.teal;
        break;
      default:
        iconData = Icons.info;
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