import 'package:flutter/material.dart';

/// 加载指示器组件
class LoadingIndicator extends StatelessWidget {
  /// 指示器大小
  final double size;
  
  /// 指示器颜色
  final Color? color;
  
  /// 额外的文本
  final String? text;

  const LoadingIndicator({
    Key? key,
    this.size = 40.0,
    this.color,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: color != null 
                  ? AlwaysStoppedAnimation<Color>(color!)
                  : null,
              strokeWidth: size / 10,
            ),
          ),
          if (text != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                text!,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
} 