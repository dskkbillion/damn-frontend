import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

import '../../domain/entities/favorite_seller.dart';

/// 收藏的卖家组件
class FavoriteSellerItem extends StatelessWidget {
  /// 卖家数据
  final FavoriteSeller seller;
  
  /// 点击事件回调
  final VoidCallback? onTap;
  
  /// 取消关注回调
  final VoidCallback? onUnfollow;

  /// 构造函数
  const FavoriteSellerItem({
    super.key,
    required this.seller,
    this.onTap,
    this.onUnfollow,
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
            children: [
              // 卖家头像
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.backgroundSecondary,
                backgroundImage: seller.avatar != null
                    ? NetworkImage(seller.avatar!)
                    : null,
                child: seller.avatar == null
                    ? Icon(
                        Icons.person,
                        size: 30,
                        color: AppColors.textSecondary,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // 卖家信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 卖家昵称
                    Text(
                      seller.nickName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // 卖家真实姓名（如果有）
                    if (seller.trueName != null) ...[
                      Text(
                        seller.trueName!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                    // 卖家类型
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getSellerTypeText(context, seller.type),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.info,
                            ),
                          ),
                        ),
                        if (seller.status != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(seller.status!)[0],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getStatusText(context, seller.status!),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getStatusColor(seller.status!)[1],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // 取消关注按钮
              if (onUnfollow != null)
                TextButton.icon(
                  onPressed: onUnfollow,
                  icon: const Icon(Icons.person_remove),
                  label: Text(AppLocalizations.of(context).favorites_unfollow),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 获取卖家类型文本
  String _getSellerTypeText(BuildContext context, String type) {
    final s = AppLocalizations.of(context);
    switch (type) {
      case 'MEMBER':
        return s.favorites_seller_type_member;
      case 'ENTERPRISE':
        return s.favorites_seller_type_enterprise;
      case 'PLATFORM':
        return s.favorites_seller_type_platform;
      default:
        return s.favorites_seller_type_default;
    }
  }

  /// 获取状态文本
  String _getStatusText(BuildContext context, String status) {
    final s = AppLocalizations.of(context);
    switch (status) {
      case 'ACTIVE':
        return s.favorites_seller_status_active;
      case 'INACTIVE':
        return s.favorites_seller_status_inactive;
      case 'SUSPENDED':
        return s.favorites_seller_status_suspended;
      case 'BANNED':
        return s.favorites_seller_status_banned;
      default:
        return status;
    }
  }

  /// 获取状态颜色
  List<Color> _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return [Colors.green[100]!, Colors.green[800]!];
      case 'INACTIVE':
        return [AppColors.warning.withOpacity(0.15), AppColors.warning];
      case 'SUSPENDED':
        return [Colors.red[100]!, Colors.red[800]!];
      case 'BANNED':
        return [AppColors.backgroundSecondary, AppColors.textSecondary];
      default:
        return [AppColors.backgroundSecondary, AppColors.textSecondary];
    }
  }
}