import 'dart:async';
import 'package:flutter/foundation.dart';

/// 防抖器
/// 
/// 用于防止函数被频繁调用，只有在指定的延迟时间内没有新的调用时才执行函数
class Debouncer {
  /// 延迟时间
  final Duration delay;
  
  /// 内部定时器
  Timer? _timer;

  /// 构造函数
  /// 
  /// [delay] 防抖延迟时间
  Debouncer({required this.delay});

  /// 执行防抖函数
  /// 
  /// [action] 要执行的函数
  void run(VoidCallback action) {
    // 取消之前的定时器
    _timer?.cancel();
    
    // 创建新的定时器
    _timer = Timer(delay, action);
  }

  /// 立即执行并重置
  /// 
  /// [action] 要执行的函数
  void runImmediate(VoidCallback action) {
    _timer?.cancel();
    action();
  }

  /// 取消当前的防抖
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// 检查是否有待执行的任务
  bool get isActive => _timer?.isActive ?? false;

  /// 释放资源
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// 支持返回值的防抖器
/// 
/// 用于需要返回结果的异步操作
class AsyncDebouncer<T> {
  /// 延迟时间
  final Duration delay;
  
  /// 内部定时器
  Timer? _timer;
  
  /// 完成器
  Completer<T>? _completer;

  /// 构造函数
  AsyncDebouncer({required this.delay});

  /// 执行防抖异步函数
  /// 
  /// [action] 要执行的异步函数
  /// 返回 Future，当防抖完成时返回结果
  Future<T> run(Future<T> Function() action) {
    // 取消之前的定时器
    _timer?.cancel();
    
    // 如果有未完成的completer，将其取消
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError('Debounced');
    }
    
    // 创建新的completer
    _completer = Completer<T>();
    
    // 创建新的定时器
    _timer = Timer(delay, () async {
      try {
        final result = await action();
        if (_completer != null && !_completer!.isCompleted) {
          _completer!.complete(result);
        }
      } catch (error) {
        if (_completer != null && !_completer!.isCompleted) {
          _completer!.completeError(error);
        }
      }
    });
    
    return _completer!.future;
  }

  /// 立即执行
  Future<T> runImmediate(Future<T> Function() action) async {
    _timer?.cancel();
    
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError('Immediate execution');
    }
    
    return await action();
  }

  /// 取消当前的防抖
  void cancel() {
    _timer?.cancel();
    _timer = null;
    
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError('Cancelled');
    }
    _completer = null;
  }

  /// 检查是否有待执行的任务
  bool get isActive => _timer?.isActive ?? false;

  /// 释放资源
  void dispose() {
    cancel();
  }
}

/// 节流器
/// 
/// 确保函数在指定时间间隔内最多只执行一次
class Throttler {
  /// 间隔时间
  final Duration interval;
  
  /// 上次执行时间
  DateTime? _lastExecutionTime;

  /// 构造函数
  Throttler({required this.interval});

  /// 执行节流函数
  /// 
  /// [action] 要执行的函数
  /// 返回是否执行了函数
  bool run(VoidCallback action) {
    final now = DateTime.now();
    
    if (_lastExecutionTime == null || 
        now.difference(_lastExecutionTime!) >= interval) {
      _lastExecutionTime = now;
      action();
      return true;
    }
    
    return false;
  }

  /// 重置节流器
  void reset() {
    _lastExecutionTime = null;
  }
}

/// 常用的防抖器实例
class CommonDebouncers {
  /// 搜索防抖器（300ms）
  static final search = Debouncer(delay: const Duration(milliseconds: 300));
  
  /// 搜索防抖器（异步版本，300ms）
  static final searchAsync = AsyncDebouncer<dynamic>(
    delay: const Duration(milliseconds: 300),
  );
  
  /// 输入防抖器（500ms）
  static final input = Debouncer(delay: const Duration(milliseconds: 500));
  
  /// 快速操作防抖器（100ms）
  static final fastAction = Debouncer(delay: const Duration(milliseconds: 100));
  
  /// API调用防抖器（400ms）
  static final apiCall = AsyncDebouncer<dynamic>(
    delay: const Duration(milliseconds: 400),
  );
  
  /// 按钮点击节流器（1秒）
  static final buttonClick = Throttler(interval: const Duration(seconds: 1));
  
  /// 滚动事件节流器（100ms）
  static final scroll = Throttler(interval: const Duration(milliseconds: 100));
}

/// 防抖器扩展方法
extension DebouncerExtensions on VoidCallback {
  /// 为函数添加防抖
  VoidCallback debounce([Duration? delay]) {
    final debouncer = Debouncer(
      delay: delay ?? const Duration(milliseconds: 300),
    );
    
    return () => debouncer.run(this);
  }
  
  /// 为函数添加节流
  VoidCallback throttle([Duration? interval]) {
    final throttler = Throttler(
      interval: interval ?? const Duration(milliseconds: 300),
    );
    
    return () => throttler.run(this);
  }
}