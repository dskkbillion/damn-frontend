import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

/// 收藏为空时的展示组件
class EmptyFavorites extends StatelessWidget {
  /// 标签页索引（0: 服务, 1: 卖家）
  final int tabIndex;

  /// 构造函数
  const EmptyFavorites({
    super.key,
    required this.tabIndex,
  });

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
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          // 空状态文本
          Text(
            tabIndex == 0 ? AppLocalizations.of(context).favorites_empty_services : AppLocalizations.of(context).favorites_empty_sellers,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          // 空状态提示
          Text(
            tabIndex == 0
                ? AppLocalizations.of(context).favorites_empty_services_hint
                : AppLocalizations.of(context).favorites_empty_sellers_hint,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}