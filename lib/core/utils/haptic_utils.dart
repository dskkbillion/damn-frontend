import 'dart:io';
import 'package:flutter/services.dart';

/// 提供不同类型震动反馈的工具类
class HapticUtils {
  /// 检查设备是否支持震动
  static Future<bool> isVibrationSupported() async {
    // iOS几乎所有设备都支持，但Android需要检查
    if (Platform.isAndroid) {
      // 可以尝试简单震动来检测，如果失败则返回false
      try {
        HapticFeedback.lightImpact();
        return true;
      } catch (e) {
        return false;
      }
    }
    return true;
  }
  
  /// Tab切换时的轻微震动
  static void lightTabFeedback() {
    // 使用轻微点击反馈，适合按钮和tab切换
    HapticFeedback.selectionClick();
  }
  
  /// AI文档分发成功时的中度双震
  static Future<void> allocationSuccessFeedback() async {
    // 先进行第一次震动
    if (Platform.isIOS) {
      HapticFeedback.mediumImpact();
    } else {
      // Android平台震动感受性不同，使用较重的震动
      HapticFeedback.heavyImpact();
    }
    
    // 短暂延迟
    await Future.delayed(const Duration(milliseconds: 150));
    
    // 进行第二次震动
    if (Platform.isIOS) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  /// AI流式输出时的轻微震动策略
  /// 设计为每隔几个字符进行一次轻微震动，模拟打字机效果
  static int _streamingCharCount = 0; // 字符计数器
  static DateTime? _lastStreamVibration; // 上次震动时间
  
  static void streamingTextFeedback() {
    _streamingCharCount++;
    final now = DateTime.now();
    
    // 震动策略：每5个字符或每50毫秒进行一次轻微震动（以较慢的为准）
    final shouldVibrate = _streamingCharCount % 5 == 0 && 
                         (_lastStreamVibration == null || 
                          now.difference(_lastStreamVibration!) > const Duration(milliseconds: 50));
    
    if (shouldVibrate) {
      // 使用最轻微的震动，避免打扰用户
      HapticFeedback.selectionClick();
      _lastStreamVibration = now;
    }
  }
  
  /// 重置流式输出震动计数器（在新的AI回复开始时调用）
  static void resetStreamingFeedback() {
    _streamingCharCount = 0;
    _lastStreamVibration = null;
  }
} 