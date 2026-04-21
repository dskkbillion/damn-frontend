import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

/// 加载中状态组件
///
/// 用于显示数据加载中的状态
class LoadingState extends StatelessWidget {
  /// 加载提示文本
  final String? text;
  
  /// 是否使用半透明背景遮罩
  final bool useOverlay;
  
  /// 构造函数
  const LoadingState({
    super.key,
    this.text,
    this.useOverlay = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final Widget loadingContent = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (text != null) ...[
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              text!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    
    if (useOverlay) {
      return Container(
        color: AppColors.borderSecondary.withOpacity(0.1),
        child: loadingContent,
      );
    }
    
    return loadingContent;
  }
  
  /// 创建一个占据全屏的加载状态
  factory LoadingState.fullScreen({String? text}) {
    return LoadingState(
      text: text,
      useOverlay: true,
    );
  }
  
  /// 创建一个占据列表的加载状态
  factory LoadingState.list({String? text = '加载中...'}) {
    return LoadingState(
      text: text,
    );
  }
  
  /// 创建一个占据按钮的加载状态
  static Widget button({String? text = '提交中...'}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: AppDimensions.spacingLg,
          height: AppDimensions.spacingLg,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
        if (text != null) ...[
          const SizedBox(width: AppDimensions.spacingSm),
          Text(text),
        ],
      ],
    );
  }
} 