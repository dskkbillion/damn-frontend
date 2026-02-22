import 'dart:async';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../analytics_manager.dart';

/// 可追踪的点击Widget
/// 自动记录点击事件的埋点
class TrackableGestureDetector extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? trackingPath;
  final int? targetId;
  final String? clickType;
  final String? source;
  final Map<String, dynamic>? additionalData;

  const TrackableGestureDetector({
    Key? key,
    required this.child,
    this.onTap,
    this.trackingPath,
    this.targetId,
    this.clickType,
    this.source,
    this.additionalData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // 先记录埋点
        if (trackingPath != null && targetId != null && clickType != null) {
          try {
            await GetIt.instance<AnalyticsManager>().trackClick(
              path: trackingPath!,
              targetId: targetId!,
              clickType: clickType!,
              source: source,
              additionalData: additionalData,
            );
          } catch (e) {
            AppLogger.d('[TrackableGestureDetector] 埋点记录失败: $e');
          }
        }
        
        // 然后执行原有的点击逻辑
        onTap?.call();
      },
      child: child,
    );
  }
}

/// 可追踪的商品卡片
/// 专门用于商品列表和推荐位的埋点
class TrackableProductCard extends StatelessWidget {
  final Widget child;
  final int productId;
  final VoidCallback? onTap;
  final String? source;
  final int? position;
  final String? scenario;
  final String? recId;
  final Map<String, dynamic>? additionalData;

  const TrackableProductCard({
    Key? key,
    required this.child,
    required this.productId,
    this.onTap,
    this.source,
    this.position,
    this.scenario,
    this.recId,
    this.additionalData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          final analytics = GetIt.instance<AnalyticsManager>();
          
          // 如果是推荐来源，使用推荐专用埋点
          if (source == 'recommendation' && scenario != null && position != null && recId != null) {
            await analytics.trackRecommendationClick(
              itemId: productId,
              scenario: scenario!,
              position: position!,
              recId: recId!,
              additionalData: additionalData,
            );
          } else {
            // 普通商品点击埋点
            await analytics.trackProductView(
              productId: productId,
              source: source,
              position: position,
              scenario: scenario,
              recId: recId,
              additionalData: additionalData,
            );
          }
        } catch (e) {
          AppLogger.d('[TrackableProductCard] 埋点记录失败: $e');
        }
        
        // 执行原有的点击逻辑
        onTap?.call();
      },
      child: child,
    );
  }
}

/// 可追踪的按钮
/// 为各种按钮添加埋点支持
class TrackableButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? actionName;
  final String? source;
  final int? targetId;
  final Map<String, dynamic>? additionalData;

  const TrackableButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.actionName,
    this.source,
    this.targetId,
    this.additionalData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // 记录按钮点击埋点
        if (actionName != null) {
          try {
            await GetIt.instance<AnalyticsManager>().trackEvent(
              businessType: 'click',
              path: ModalRoute.of(context)?.settings.name ?? '/unknown',
              businessId: targetId,
              feature: {
                'action_name': actionName,
                'click_type': 'button',
                if (source != null) 'source': source,
                if (additionalData != null) ...additionalData!,
              },
            );
          } catch (e) {
            AppLogger.d('[TrackableButton] 埋点记录失败: $e');
          }
        }
        
        // 执行原有的点击逻辑
        onPressed?.call();
      },
      child: child,
    );
  }
}

/// 页面停留时间追踪Mixin
/// 可以混入到StatefulWidget中自动追踪页面停留时间
mixin PageTrackingMixin<T extends StatefulWidget> on State<T> {
  DateTime? _enterTime;
  Timer? _heartbeatTimer;
  
  @override
  void initState() {
    super.initState();
    _enterTime = DateTime.now();
    _startHeartbeat();
    _trackPageEnter();
  }
  
  @override
  void dispose() {
    _stopHeartbeat();
    _trackPageLeave();
    super.dispose();
  }
  
  /// 开始心跳记录
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _trackHeartbeat();
    });
  }
  
  /// 停止心跳记录
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
  }
  
  /// 记录页面进入
  void _trackPageEnter() {
    final routeName = ModalRoute.of(context)?.settings.name;
    if (routeName != null) {
      GetIt.instance<AnalyticsManager>().trackPageView(
        path: routeName,
        pageType: getPageType(),
        businessId: getBusinessId(),
        source: getPageSource(),
        additionalData: getAdditionalTrackingData(),
      );
    }
  }
  
  /// 记录页面离开
  void _trackPageLeave() {
    if (_enterTime != null) {
      final stayDuration = DateTime.now().difference(_enterTime!).inSeconds;
      final routeName = ModalRoute.of(context)?.settings.name;
      
      if (routeName != null && stayDuration > 1) {
        GetIt.instance<AnalyticsManager>().trackPageView(
          path: routeName,
          pageType: getPageType(),
          businessId: getBusinessId(),
          stayDuration: stayDuration,
          additionalData: {
            'action': 'leave',
            ...?getAdditionalTrackingData(),
          },
        );
      }
    }
  }
  
  /// 记录心跳（用于长时间停留的页面）
  void _trackHeartbeat() {
    if (_enterTime != null) {
      final currentStay = DateTime.now().difference(_enterTime!).inSeconds;
      final routeName = ModalRoute.of(context)?.settings.name;
      
      if (routeName != null) {
        GetIt.instance<AnalyticsManager>().trackEvent(
          businessType: 'heartbeat',
          path: routeName,
          businessId: getBusinessId(),
          interval: currentStay,
          feature: {
            'page_type': getPageType(),
            'action': 'heartbeat',
            ...?getAdditionalTrackingData(),
          },
        );
      }
    }
  }
  
  // 以下方法可以在子类中重写以提供具体的页面信息
  
  /// 获取页面类型
  String getPageType() => 'unknown';
  
  /// 获取业务ID
  int? getBusinessId() => null;
  
  /// 获取页面来源
  String? getPageSource() => null;
  
  /// 获取额外的追踪数据
  Map<String, dynamic>? getAdditionalTrackingData() => null;
} 