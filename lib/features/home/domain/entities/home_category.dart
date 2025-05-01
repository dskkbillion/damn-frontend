import 'package:equatable/equatable.dart';

/// 表示首页展示的快速分类入口
class HomeCategory extends Equatable {
  /// 分类唯一标识
  final String id;
  
  /// 分类名称
  final String name;
  
  /// 图标 URL
  final String iconUrl;
  
  /// 点击后的目标类型
  /// 可能的值: category, search, feature
  final String targetType;
  
  /// 目标的具体值
  final String targetValue;

  const HomeCategory({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.targetType,
    required this.targetValue,
  });

  @override
  List<Object?> get props => [id, name, iconUrl, targetType, targetValue];
}