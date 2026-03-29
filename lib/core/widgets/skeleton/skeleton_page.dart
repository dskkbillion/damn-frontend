import 'package:flutter/material.dart';
import '../../config/theme/app_dimensions.dart';
import 'skeleton_list_item.dart';

/// 整页骨架容器
///
/// 接收 [itemCount] 和可选的 [itemBuilder] 参数，
/// 默认使用 [SkeletonListItem] 渲染指定数量的骨架行。
class SkeletonPage extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index)? itemBuilder;

  const SkeletonPage({
    super.key,
    this.itemCount = 6,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacingMd,
      ),
      itemCount: itemCount,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppDimensions.spacingXs),
      itemBuilder: itemBuilder ??
          (context, index) => const SkeletonListItem(),
    );
  }
}
