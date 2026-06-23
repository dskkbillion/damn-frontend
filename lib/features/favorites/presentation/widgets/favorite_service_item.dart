import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/widgets/app_network_image.dart';

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
    super.key,
    required this.service,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 服务图片
              if (service.imageUrl != null)
                AppNetworkImage(
                  imageUrl: service.imageUrl!,
                  width: 80,
                  height: 80,
                  borderRadius: BorderRadius.circular(8),
                )
              else
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.image,
                    color: AppColors.textSecondary,
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
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: onRemove,
                  tooltip: AppLocalizations.of(context).favorites_remove,
                ),
            ],
          ),
        ),
      ),
    );
  }
}