import 'package:flutter/material.dart';

/// 通用加载指示器组件
class LoadingIndicator extends StatelessWidget {
  /// 加载指示器的大小
  final double size;

  /// 加载指示器的颜色
  final Color? color;

  /// 构造函数
  const LoadingIndicator({
    Key? key,
    this.size = 40.0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: size / 10,
        color: color ?? Theme.of(context).primaryColor,
      ),
    );
  }
}
