import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 通知导航服务
/// 处理从通知中心或推送通知点击后的页面跳转
class NotificationNavigationService {
  /// 处理通知点击导航
  /// 
  /// [context] - BuildContext
  /// [notificationType] - 通知类型
  /// [entityId] - 相关实体ID（订单ID、聊天室ID等）
  /// [receiverType] - 接收者类型（用于判断买家/卖家）
  /// [extra] - 额外参数
  static void handleNotificationNavigation({
    required BuildContext context,
    required String notificationType,
    String? entityId,
    String? receiverType,
    Map<String, dynamic>? extra,
  }) {
    if (entityId == null || entityId.isEmpty) {
      // 如果没有实体ID，则不进行跳转
      return;
    }

    // 判断是否为卖家模式
    final isSeller = receiverType == 'TenantUser' || receiverType == 'seller';

    switch (notificationType.toLowerCase()) {
      case 'order':
      case '订单':
        _navigateToOrder(context, entityId, isSeller);
        break;
      
      case 'refund':
      case 'aftersales':
      case '售后':
      case '退款':
        _navigateToAfterSales(context, entityId);
        break;
      
      case 'message':
      case 'chat':
      case '消息':
      case '聊天':
        _navigateToChatRoom(context, entityId);
        break;
      
      case 'review':
      case 'evaluation':
      case '评价':
        _navigateToEvaluation(context, entityId);
        break;
      
      case 'authentication':
      case '认证':
        _navigateToAuthentication(context);
        break;
      
      case 'product':
      case '商品':
        _navigateToProduct(context, entityId);
        break;
      
      case 'system':
      case '系统':
        // 系统通知通常不需要跳转
        break;
      
      default:
        // 未知类型，不处理
        debugPrint('Unknown notification type: $notificationType');
        break;
    }
  }

  /// 跳转到订单详情
  static void _navigateToOrder(BuildContext context, String orderId, bool isSeller) {
    try {
      if (isSeller) {
        // 卖家订单详情
        context.push('/seller/orders/$orderId');
      } else {
        // 买家订单详情
        context.push('/orderDetail/$orderId');
      }
    } catch (e) {
      debugPrint('Failed to navigate to order: $e');
      _showNavigationError(context, '无法打开订单详情');
    }
  }

  /// 跳转到售后详情
  static void _navigateToAfterSales(BuildContext context, String afterSalesId) {
    try {
      context.push('/after-sales/detail/$afterSalesId');
    } catch (e) {
      debugPrint('Failed to navigate to after-sales: $e');
      _showNavigationError(context, '无法打开售后详情');
    }
  }

  /// 跳转到聊天室
  static void _navigateToChatRoom(BuildContext context, String chatId) {
    try {
      context.push('/chat/room/$chatId');
    } catch (e) {
      debugPrint('Failed to navigate to chat room: $e');
      _showNavigationError(context, '无法打开聊天页面');
    }
  }

  /// 跳转到评价页面
  static void _navigateToEvaluation(BuildContext context, String itemId) {
    try {
      context.push('/evaluation/$itemId');
    } catch (e) {
      debugPrint('Failed to navigate to evaluation: $e');
      _showNavigationError(context, '无法打开评价页面');
    }
  }

  /// 跳转到认证页面
  static void _navigateToAuthentication(BuildContext context) {
    try {
      context.push('/seller/authentication');
    } catch (e) {
      debugPrint('Failed to navigate to authentication: $e');
      _showNavigationError(context, '无法打开认证页面');
    }
  }

  /// 跳转到商品详情
  static void _navigateToProduct(BuildContext context, String productId) {
    try {
      context.push('/home/product/$productId');
    } catch (e) {
      debugPrint('Failed to navigate to product: $e');
      _showNavigationError(context, '无法打开商品详情');
    }
  }

  /// 显示导航错误提示
  static void _showNavigationError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 处理来自推送通知的深链接
  /// 
  /// [deepLink] - 深链接URL
  /// [context] - BuildContext
  static void handleDeepLink(String deepLink, BuildContext context) {
    try {
      final uri = Uri.parse(deepLink);
      
      // 解析路径和参数
      final pathSegments = uri.pathSegments;
      final queryParams = uri.queryParameters;
      
      if (pathSegments.isEmpty) {
        return;
      }

      // 根据路径第一段判断类型
      final type = pathSegments[0];
      String? entityId;
      
      if (pathSegments.length > 1) {
        entityId = pathSegments[1];
      }

      // 从查询参数中获取接收者类型
      final receiverType = queryParams['receiverType'];
      
      // 调用通知导航处理
      handleNotificationNavigation(
        context: context,
        notificationType: type,
        entityId: entityId,
        receiverType: receiverType,
        extra: queryParams,
      );
    } catch (e) {
      debugPrint('Failed to handle deep link: $e');
    }
  }

  /// 从通知payload解析导航信息
  /// 
  /// [payload] - 通知的payload数据
  /// [context] - BuildContext
  static void handleNotificationPayload(Map<String, dynamic> payload, BuildContext context) {
    try {
      // 提取通知类型和实体ID
      final notificationType = payload['type'] as String?;
      final entityId = payload['entityId']?.toString();
      final receiverType = payload['receiverType'] as String?;
      
      if (notificationType == null) {
        debugPrint('Notification type is missing in payload');
        return;
      }

      // 处理导航
      handleNotificationNavigation(
        context: context,
        notificationType: notificationType,
        entityId: entityId,
        receiverType: receiverType,
        extra: payload,
      );
    } catch (e) {
      debugPrint('Failed to handle notification payload: $e');
    }
  }
}