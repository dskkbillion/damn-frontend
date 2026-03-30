import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:dskk_flutter_refactor/core/utils/price_formatter.dart';
import '../../domain/entities/chat_room.dart';

/// 商品聊天头部组件
/// 参考闲鱼的设计，在聊天室顶部显示商品信息
class ProductChatHeader extends StatelessWidget {
  final ChatRoom chatRoom;
  final VoidCallback? onProductTap;
  final VoidCallback? onActionTap;
  final String? actionText;

  const ProductChatHeader({
    Key? key,
    required this.chatRoom,
    this.onProductTap,
    this.onActionTap,
    this.actionText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 如果没有商品信息，不显示
    if (!chatRoom.hasProduct) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.borderSecondary,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onProductTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // 商品图片
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: chatRoom.productImage != null
                      ? CachedNetworkImage(
                          imageUrl: chatRoom.productImage!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: AppColors.borderPrimary,
                              child: const Icon(
                                Icons.shopping_bag,
                                color: AppColors.textTertiary,
                                size: 30,
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.borderPrimary,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                          ),
                          child: const Icon(
                            Icons.shopping_bag,
                            color: AppColors.textTertiary,
                            size: 30,
                          ),
                        ),
                ),
                
                const SizedBox(width: 12),
                
                // 商品信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 商品名称
                      Text(
                        chatRoom.productName ?? '商品',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // 商品价格
                      if (chatRoom.productPrice != null)
                        Text(
                          PriceFormatter.format(chatRoom.productPrice!),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                      
                      const SizedBox(height: 4),
                      
                      // 额外信息（可以根据需要添加）
                      Text(
                        '点击查看商品详情',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // 操作按钮
                if (actionText != null && onActionTap != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                    ),
                    child: InkWell(
                      onTap: onActionTap,
                      child: Text(
                        actionText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 