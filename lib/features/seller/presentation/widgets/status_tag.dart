import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

/// 状态标签类型
enum StatusTagType {
  /// 主要 - 蓝色
  primary,
  
  /// 成功 - 绿色
  success,
  
  /// 警告 - 橙色
  warning,
  
  /// 危险 - 红色
  danger,
  
  /// 信息 - 浅蓝色
  info,
  
  /// 默认 - 灰色
  defaultTag
}

/// 状态标签组件
/// 
/// 用于显示商品状态、售后状态、认证状态等
class StatusTag extends StatelessWidget {
  /// 标签文本
  final String text;
  
  /// 标签类型
  final StatusTagType type;
  
  /// 是否为圆角
  final bool rounded;
  
  /// 是否为大号
  final bool large;
  
  /// 是否填充背景
  final bool filled;
  
  /// 自定义背景色
  final Color? backgroundColor;
  
  /// 自定义文本颜色
  final Color? textColor;
  
  /// 构造函数
  const StatusTag({
    super.key,
    required this.text,
    this.type = StatusTagType.defaultTag,
    this.rounded = true,
    this.large = false,
    this.filled = true,
    this.backgroundColor,
    this.textColor,
  });
  
  @override
  Widget build(BuildContext context) {
    // 根据类型确定颜色
    Color bgColor = backgroundColor ?? _getBackgroundColor(context);
    Color txtColor = textColor ?? _getTextColor(context);
    
    // 如果不是填充模式，交换背景色和文字色
    if (!filled) {
      final Color temp = bgColor;
      bgColor = Colors.transparent;
      txtColor = temp;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? AppDimensions.spacingMd : AppDimensions.spacingSm, 
        vertical: large ? AppDimensions.spacingSm : AppDimensions.spacingXs
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(rounded ? (large ? AppDimensions.radiusLg : AppDimensions.radiusMd) : 0),
        border: !filled ? Border.all(color: txtColor, width: AppDimensions.borderStandard) : null,
      ),
      child: Text(
        text,
        style: (large
                ? Theme.of(context).textTheme.bodyMedium
                : Theme.of(context).textTheme.bodySmall)
            ?.copyWith(color: txtColor, fontWeight: FontWeight.w500),
      ),
    );
  }
  
  /// 根据类型获取背景色
  Color _getBackgroundColor(BuildContext context) {
    switch (type) {
      case StatusTagType.primary:
        return AppColors.primary;
      case StatusTagType.success:
        return AppColors.success;
      case StatusTagType.warning:
        return AppColors.warning;
      case StatusTagType.danger:
        return AppColors.error;
      case StatusTagType.info:
        return AppColors.info;
      case StatusTagType.defaultTag:
        return AppColors.grey[500]!;
    }
  }
  
  /// 根据类型获取文本颜色
  Color _getTextColor(BuildContext context) {
    switch (type) {
      case StatusTagType.primary:
        return AppColors.getOnPrimaryColor();
      case StatusTagType.success:
        return AppColors.getOnSuccessColor();
      case StatusTagType.warning:
        return AppColors.getOnWarningColor();
      case StatusTagType.danger:
        return AppColors.getOnErrorColor();
      case StatusTagType.info:
        return AppColors.getOnInfoColor();
      case StatusTagType.defaultTag:
        return AppColors.getOnPrimaryColor();
    }
  }
}

/// 预定义状态标签生成工厂
class StatusTags {
  /// 待审核状态标签
  static StatusTag pending({String text = '待审核'}) {
    return StatusTag(
      text: text,
      type: StatusTagType.warning,
    );
  }
  
  /// 审核通过状态标签
  static StatusTag approved({String text = '已通过'}) {
    return StatusTag(
      text: text,
      type: StatusTagType.success,
    );
  }
  
  /// 已拒绝状态标签
  static StatusTag rejected({String text = '已拒绝'}) {
    return StatusTag(
      text: text,
      type: StatusTagType.danger,
    );
  }
  
  /// 已取消状态标签
  static StatusTag canceled({String text = '已取消'}) {
    return StatusTag(
      text: text,
      type: StatusTagType.defaultTag,
    );
  }
  
  /// 已完成状态标签
  static StatusTag completed({String text = '已完成'}) {
    return StatusTag(
      text: text,
      type: StatusTagType.success,
    );
  }
  
  /// 进行中状态标签
  static StatusTag inProgress({String text = '进行中'}) {
    return StatusTag(
      text: text,
      type: StatusTagType.primary,
    );
  }
  
  /// 售卖中状态标签
  static StatusTag selling({String text = '售卖中'}) {
    return StatusTag(
      text: text,
      type: StatusTagType.success,
    );
  }
  
  /// 已下架状态标签
  static StatusTag disabled({String text = '已下架'}) {
    return StatusTag(
      text: text,
      type: StatusTagType.defaultTag,
    );
  }
  
  /// 草稿状态标签
  static StatusTag draft({String text = '草稿'}) {
    return StatusTag(
      text: text,
      type: StatusTagType.info,
    );
  }
} 