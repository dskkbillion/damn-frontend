import 'package:flutter/material.dart';

/// 空状态组件
///
/// 用于列表为空时显示提示信息
class EmptyState extends StatelessWidget {
  /// 提示文本
  final String text;
  
  /// 副标题文本
  final String? subText;
  
  /// 图标
  final IconData icon;
  
  /// 操作按钮
  final Widget? action;
  
  /// 构造函数
  const EmptyState({
    Key? key,
    required this.text,
    this.subText,
    this.icon = Icons.info_outline,
    this.action,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            if (subText != null) ...[
              const SizedBox(height: 8),
              Text(
                subText!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
  
  /// 商品为空状态
  factory EmptyState.noProducts({
    String text = '暂无商品',
    String? subText = '点击添加按钮发布您的商品',
    VoidCallback? onAddPressed,
  }) {
    return EmptyState(
      text: text,
      subText: subText,
      icon: Icons.inventory_2_outlined,
      action: onAddPressed != null 
          ? FilledButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('添加商品'),
            )
          : null,
    );
  }
  
  /// 订单为空状态
  factory EmptyState.noOrders({
    String text = '暂无订单',
    String? subText = '当有买家下单时，订单将显示在这里',
  }) {
    return EmptyState(
      text: text,
      subText: subText,
      icon: Icons.receipt_long_outlined,
    );
  }
  
  /// 通知为空状态
  factory EmptyState.noNotifications({
    String text = '暂无通知',
    String? subText = '您的通知将显示在这里',
  }) {
    return EmptyState(
      text: text,
      subText: subText,
      icon: Icons.notifications_none_outlined,
    );
  }
  
  /// 售后申请为空状态
  factory EmptyState.noRefunds({
    String text = '暂无售后申请',
    String? subText = '当买家申请售后时，记录将显示在这里',
  }) {
    return EmptyState(
      text: text,
      subText: subText,
      icon: Icons.assignment_return_outlined,
    );
  }
  
  /// 搜索结果为空状态
  factory EmptyState.noSearchResults({
    String text = '未找到结果',
    String? subText = '请尝试不同的搜索条件',
  }) {
    return EmptyState(
      text: text,
      subText: subText,
      icon: Icons.search_off_outlined,
    );
  }
  
  /// 错误状态
  factory EmptyState.error({
    String text = '加载失败',
    String? subText = '请检查网络连接后重试',
    VoidCallback? onRetryPressed,
  }) {
    return EmptyState(
      text: text,
      subText: subText,
      icon: Icons.error_outline,
      action: onRetryPressed != null 
          ? OutlinedButton.icon(
              onPressed: onRetryPressed,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            )
          : null,
    );
  }
} 