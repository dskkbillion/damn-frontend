import 'package:flutter/material.dart';

/// 收藏为空时的展示组件
class EmptyFavorites extends StatelessWidget {
  /// 标签页索引（0: 服务, 1: 卖家）
  final int tabIndex;

  /// 构造函数
  const EmptyFavorites({
    Key? key,
    required this.tabIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 空状态图标
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          // 空状态文本
          Text(
            tabIndex == 0 ? '暂无收藏的服务' : '暂无关注的卖家',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          // 空状态提示
          Text(
            tabIndex == 0
                ? '您可以在浏览服务时点击收藏按钮'
                : '您可以在浏览卖家时点击关注按钮',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}