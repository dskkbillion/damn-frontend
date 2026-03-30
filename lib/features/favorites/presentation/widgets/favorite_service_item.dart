import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

import '../../domain/entities/favorite_service.dart';

/// 收藏的服务项目组件
class FavoriteServiceItem extends StatelessWidget {
  /// 服务数据
  final FavoriteService service;
  
  /// 点击事件回调
  final VoidCallback? onTap;
  
  /// 取消收藏回调
  final VoidCallback? onRemove;

  /// 构造函数
  const FavoriteServiceItem({
    Key? key,
    required this.service,
    this.onTap,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 服务图片
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                child: service.imageUrl != null
                    ? Image.network(
                        service.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: AppColors.borderInput,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: AppColors.textTertiary,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: AppColors.borderInput,
                        child: const Icon(
                          Icons.image,
                          color: AppColors.textTertiary,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              // 服务信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 服务标题
                    Text(
                      service.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // 服务描述
                    if (service.description != null) ...[
                      Text(
                        service.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                    ],
                    // 服务价格
                    Text(
                      '¥${service.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              // 取消收藏按钮
              if (onRemove != null)
                IconButton(
                  icon: const Icon(Icons.favorite, color: AppColors.error),
                  onPressed: onRemove,
                  tooltip: '取消收藏',
                ),
            ],
          ),
        ),
      ),
    );
  }
}