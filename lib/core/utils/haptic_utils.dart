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
} 