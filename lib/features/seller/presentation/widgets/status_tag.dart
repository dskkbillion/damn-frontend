import 'package:flutter/material.dart';

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
    Key? key,
    required this.text,
    this.type = StatusTagType.defaultTag,
    this.rounded = true,
    this.large = false,
    this.filled = true,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);
  
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
        horizontal: large ? 12.0 : 8.0, 
        vertical: large ? 6.0 : 4.0
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(rounded ? (large ? 16.0 : 12.0) : 0),
        border: !filled ? Border.all(color: txtColor, width: 1.0) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: large ? 14.0 : 12.0,
          color: txtColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  /// 根据类型获取背景色
  Color _getBackgroundColor(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    switch (type) {
      case StatusTagType.primary:
        return theme.colorScheme.primary;
      case StatusTagType.success:
        return Colors.green;
      case StatusTagType.warning:
        return Colors.orange;
      case StatusTagType.danger:
        return theme.colorScheme.error;
      case StatusTagType.info:
        return Colors.lightBlue;
      case StatusTagType.defaultTag:
        return Colors.grey;
    }
  }
  
  /// 根据类型获取文本颜色
  Color _getTextColor(BuildContext context) {
    return Colors.white;
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