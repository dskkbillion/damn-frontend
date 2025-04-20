import 'package:flutter/material.dart';
import '../../domain/entities/cart_item.dart';

/// 购物车项组件
class CartItemWidget extends StatelessWidget {
  /// 购物车项数据
  final CartItem item;
  
  /// 数量变更回调
  final Function(int) onQuantityChanged;
  
  /// 移除回调
  final VoidCallback onRemove;
  
  /// 点击商品回调
  final VoidCallback onProductTap;

  const CartItemWidget({
    Key? key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
    required this.onProductTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品图片
            GestureDetector(
              onTap: onProductTap,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: item.productSnapshot.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(item.productSnapshot.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: Colors.grey[200],
                ),
                child: item.productSnapshot.imageUrl == null
                    ? const Icon(Icons.image_not_supported, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(width: 12.0),
            // 商品信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 商品名称
                  GestureDetector(
                    onTap: onProductTap,
                    child: Text(
                      item.productSnapshot.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  // 商品规格
                  if (item.productSnapshot.skuDescription != null) ...[
                    Text(
                      item.productSnapshot.skuDescription!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                  ],
                  // 价格和数量控制
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 价格
                      Text(
                        '¥${(item.currentPrice ?? item.productSnapshot.priceAtAddition).toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      // 数量控制
                      Row(
                        children: [
                          // 减少按钮
                          _buildQuantityButton(
                            icon: Icons.remove,
                            onPressed: item.quantity > 1
                                ? () => onQuantityChanged(item.quantity - 1)
                                : null,
                          ),
                          // 数量显示
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // 增加按钮
                          _buildQuantityButton(
                            icon: Icons.add,
                            onPressed: () => onQuantityChanged(item.quantity + 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  // 验证消息
                  if (item.validationMessages != null &&
                      item.validationMessages!.isNotEmpty)
                    ...item.validationMessages!.map(
                      (message) => Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          message,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ),
                  // 移除按钮
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onRemove,
                      child: const Text('移除'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建数量控制按钮
  Widget _buildQuantityButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return Container(
      width: 32.0,
      height: 32.0,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 16.0),
        onPressed: onPressed,
        color: onPressed == null ? Colors.grey[400] : Colors.black87,
      ),
    );
  }
}