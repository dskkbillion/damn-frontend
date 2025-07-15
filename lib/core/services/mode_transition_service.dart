import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:get_it/get_it.dart';
import '../../app/app_mode.dart';

/// 模式切换动画服务
@lazySingleton
class ModeTransitionService {
  final _transitionController = StreamController<ModeTransitionEvent>.broadcast();
  
  Stream<ModeTransitionEvent> get transitionStream => _transitionController.stream;
  
  /// 触发模式切换动画
  void triggerTransition({
    required AppMode targetMode,
    required VoidCallback onAnimationComplete,
  }) {
    _transitionController.add(ModeTransitionEvent(
      targetMode: targetMode,
      onComplete: onAnimationComplete,
    ));
  }
  
  void dispose() {
    _transitionController.close();
  }
}

/// 模式切换事件
class ModeTransitionEvent {
  final AppMode targetMode;
  final VoidCallback onComplete;
  
  ModeTransitionEvent({
    required this.targetMode,
    required this.onComplete,
  });
}

/// 模式切换服务Provider
final modeTransitionServiceProvider = Provider<ModeTransitionService>((ref) {
  // 从 GetIt 获取实例，如果还没有注册则创建新实例
  try {
    return GetIt.instance<ModeTransitionService>();
  } catch (_) {
    // 如果 GetIt 还没有初始化，创建一个新实例
    return ModeTransitionService();
  }
});