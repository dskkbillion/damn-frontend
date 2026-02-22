import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:get_it/get_it.dart';
import '../analytics_manager.dart';

/// BLoC分析观察器
/// 自动监听BLoC事件并记录相应的埋点
class AnalyticsBlocObserver extends BlocObserver {
  final AnalyticsManager _analytics;

  AnalyticsBlocObserver() : _analytics = GetIt.instance<AnalyticsManager>();

  @override
  void onEvent(BlocBase bloc, Object? event) {
    super.onEvent(bloc as Bloc, event);
    AppLogger.d('[AnalyticsBlocObserver] BLoC事件: ${bloc.runtimeType} - ${event.runtimeType}');
    _trackBlocEvent(bloc, event);
  }

  /// 根据BLoC类型和事件记录埋点
  void _trackBlocEvent(BlocBase bloc, Object? event) {
    try {
      final blocType = bloc.runtimeType.toString();
      final eventStr = event.toString();
      
      AppLogger.d('[AnalyticsBlocObserver] 分析事件: $blocType - $eventStr');

      // 处理登录事件
      if (eventStr.contains('LoginRequested') || eventStr.contains('SmsLoginRequested')) {
        final loginMethod = _extractLoginMethod(eventStr);
        AppLogger.d('[AnalyticsBlocObserver] 检测到登录事件，方法: $loginMethod');
        
        _analytics.trackEvent(
          businessType: 'login_attempt',
          path: '/login',
          feature: {
            'login_method': loginMethod,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
        );
      }

      // 处理订单事件
      else if (eventStr.contains('ConfirmReceipt')) {
        final orderId = _extractOrderId(eventStr);
        AppLogger.d('[AnalyticsBlocObserver] 检测到确认收货事件，订单ID: $orderId');
        
        if (orderId != null) {
          _analytics.trackOrder(
            action: 'confirm_receipt',
            orderId: orderId,
          );
        } else {
          AppLogger.d('[AnalyticsBlocObserver] 未能从事件中提取订单ID: $eventStr');
        }
      }

      // 处理购物车事件
      else if (eventStr.contains('AddToCart')) {
        final productId = _extractProductId(eventStr);
        AppLogger.d('[AnalyticsBlocObserver] 检测到加入购物车事件，商品ID: $productId');
        
        if (productId != null) {
          _analytics.trackCartAction(
            productId: productId,
            action: 'add',
            quantity: 1,
            sourcePage: 'unknown',
          );
        } else {
          AppLogger.d('[AnalyticsBlocObserver] 未能从事件中提取商品ID: $eventStr');
        }
      }

      // 处理商品点击事件
      else if (eventStr.contains('ProductCardClicked')) {
        final productId = _extractProductId(eventStr);
        AppLogger.d('[AnalyticsBlocObserver] 检测到商品卡片点击事件，商品ID: $productId');
        
        if (productId != null) {
          _analytics.trackClick(
            path: '/product/$productId',
            targetId: productId,
            clickType: 'product_card',
            source: 'home_page',
          );
        } else {
          AppLogger.d('[AnalyticsBlocObserver] 未能从事件中提取商品ID: $eventStr');
        }
      }
    } catch (e) {
      AppLogger.d('[AnalyticsBlocObserver] 处理BLoC事件失败: $e');
    }
  }

  /// 提取登录方法
  String _extractLoginMethod(String eventStr) {
    if (eventStr.contains('sms')) return 'sms';
    if (eventStr.contains('password')) return 'password';
    if (eventStr.contains('wechat')) return 'wechat';
    return 'unknown';
  }

  /// 提取订单ID
  int? _extractOrderId(String eventStr) {
    final RegExp orderIdRegExp = RegExp(r'orderId[:\s]*(\d+)');
    final match = orderIdRegExp.firstMatch(eventStr);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  /// 提取商品ID
  int? _extractProductId(String eventStr) {
    // 尝试提取ProductCardClicked(123)格式的ID
    final RegExp clickedRegExp = RegExp(r'ProductCardClicked\((\d+)\)');
    final clickedMatch = clickedRegExp.firstMatch(eventStr);
    if (clickedMatch != null) {
      return int.tryParse(clickedMatch.group(1)!);
    }
    
    // 尝试提取productId:123格式的ID
    final RegExp productIdRegExp = RegExp(r'productId[:\s]*(\d+)');
    final match = productIdRegExp.firstMatch(eventStr);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    
    // 尝试提取id:123格式的ID
    final RegExp idRegExp = RegExp(r'id[:\s]*(\d+)');
    final idMatch = idRegExp.firstMatch(eventStr);
    return idMatch != null ? int.tryParse(idMatch.group(1)!) : null;
  }
} 