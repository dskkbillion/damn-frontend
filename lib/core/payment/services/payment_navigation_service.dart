import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/payment_models.dart';
import '../../../features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/core/widgets/app_toast.dart';

/// 支付导航服务
/// 根据不同的支付结果类型，采用相应的导航策略
class PaymentNavigationService {
  
  /// 处理支付结果并进行相应的导航
  static void handlePaymentResult(
    BuildContext context, 
    PaymentResponse response,
  ) {
    final resultType = response.resultType;
    final orderId = response.orderId;
    
    switch (resultType) {
      case PaymentResultType.success:
        // 支付成功 - 跳转到支付成功页面或订单详情
        _navigateToPaymentSuccess(context, response);
        break;
        
      case PaymentResultType.userCancelled:
        // 用户取消 - 跳转到订单页面的待付款状态
        _navigateToOrdersWithMessage(
          context, 
          orderId,
          '您已取消支付，可以继续完成订单支付',
          OrderStatus.awaitingPayment,
        );
        break;
        
      case PaymentResultType.networkError:
        // 网络错误 - 提供重试选项，跳转到待付款订单
        _showRetryDialog(context, response);
        break;
        
      case PaymentResultType.unknown:
        // 结果未知 - 提供状态查询功能，跳转到待付款订单
        _showUnknownResultDialog(context, response);
        break;
        
      case PaymentResultType.processing:
        // 处理中 - 提示用户等待，跳转到待付款订单
        _navigateToOrdersWithMessage(
          context,
          orderId,
          '支付正在处理中，请稍后查看订单状态',
          OrderStatus.awaitingPayment,
        );
        break;
        
      case PaymentResultType.failed:
      default:
        // 其他支付失败 - 跳转到支付失败页面
        _navigateToPaymentFailure(context, response);
        break;
    }
  }
  
  /// 跳转到支付成功页面
  static void _navigateToPaymentSuccess(
    BuildContext context, 
    PaymentResponse response,
  ) {
    // 显示支付成功提示
    _showSuccessSnackBar(context, response.message ?? '支付成功');
    
    // 如果当前已经在订单详情页，触发数据刷新而不是导航
    final currentRoute = GoRouter.of(context).routeInformationProvider.value.uri.toString();
    if (currentRoute.contains('/orderDetail/${response.orderId}')) {
      // 不需要导航，OrderDetailPage 的 BlocListener 会处理刷新
      return;
    }
    
    // 否则，跳转到订单详情页面
    if (response.orderId != null) {
      // 使用 push 而不是 go，保持导航栈
      context.push('/orderDetail/${response.orderId}');
    } else {
      // 没有订单ID，跳转到订单列表
      context.go('/orders');
    }
  }
  
  /// 跳转到支付失败页面
  static void _navigateToPaymentFailure(
    BuildContext context, 
    PaymentResponse response,
  ) {
    // 显示失败提示
    _showErrorSnackBar(context, response.message ?? '支付失败');
    
    // 如果当前在订单详情页，只需返回即可
    final currentRoute = GoRouter.of(context).routeInformationProvider.value.uri.toString();
    if (currentRoute.contains('/orderDetail/')) {
      Navigator.of(context).pop();
      return;
    }
    
    // 跳转到订单列表的待付款状态
    context.go('/orders?status=awaitingPayment');
  }
  
  /// 跳转到订单页面并显示消息
  static void _navigateToOrdersWithMessage(
    BuildContext context,
    String? orderId,
    String message,
    OrderStatus status,
  ) {
    // 显示提示消息
    _showInfoSnackBar(context, message);
    
    // 如果当前在订单详情页，只需返回即可
    final currentRoute = GoRouter.of(context).routeInformationProvider.value.uri.toString();
    if (currentRoute.contains('/orderDetail/')) {
      Navigator.of(context).pop();
      return;
    }
    
    // 跳转到订单列表的指定状态
    final statusString = status.toJsonString();
    context.go('/orders?status=$statusString');
  }
  
  /// 显示重试对话框
  static void _showRetryDialog(
    BuildContext context,
    PaymentResponse response,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('网络连接失败'),
        content: Text(response.message ?? '网络连接出错，请检查网络后重试'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 跳转到待付款订单
              context.go('/orders?status=awaitingPayment');
            },
            child: const Text('查看订单'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 触发重新支付逻辑
              _retryPayment(context, response.orderId);
            },
            child: const Text('重试支付'),
          ),
        ],
      ),
    );
  }
  
  /// 显示未知结果对话框
  static void _showUnknownResultDialog(
    BuildContext context,
    PaymentResponse response,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('支付结果未知'),
        content: const Text('支付结果暂时无法确认，请稍后查看订单状态或联系客服'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 跳转到待付款订单
              context.go('/orders?status=awaitingPayment');
            },
            child: const Text('查看订单'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 触发状态查询
              _queryPaymentStatus(context, response.orderId);
            },
            child: const Text('查询状态'),
          ),
        ],
      ),
    );
  }
  
  /// 重试支付逻辑
  static void _retryPayment(BuildContext context, String? orderId) {
    if (orderId != null) {
      // 重新跳转到支付页面或触发支付流程
      // 这里需要根据实际的支付流程来实现
      _showInfoSnackBar(context, '正在重新发起支付...');
      
      // 示例：跳转到订单详情页面，用户可以在那里重新支付
      context.push('/orderDetail/$orderId');
    } else {
      _showErrorSnackBar(context, '无法重试支付，订单信息丢失');
    }
  }

  /// 查询支付状态
  static void _queryPaymentStatus(BuildContext context, String? orderId) {
    if (orderId != null) {
      // 触发支付状态查询
      _showInfoSnackBar(context, '正在查询支付状态...');

      // 跳转到订单详情页面，用户可以查看最新状态
      context.push('/orderDetail/$orderId');
    } else {
      _showErrorSnackBar(context, '无法查询状态，订单信息丢失');
    }
  }
  
  /// 显示成功提示
  static void _showSuccessSnackBar(BuildContext context, String message) {
    AppToast.success(context, message);
  }

  /// 显示错误提示
  static void _showErrorSnackBar(BuildContext context, String message) {
    AppToast.error(context, message);
  }

  /// 显示信息提示
  static void _showInfoSnackBar(BuildContext context, String message) {
    AppToast.info(context, message);
  }
} 