import '../../domain/entities/home_category.dart';

/// HomeCategory 模型，用于序列化和反序列化 API 响应
class HomeCategoryModel extends HomeCategory {
  const HomeCategoryModel({
    required super.id,
    required super.name,
    required super.iconUrl,
    required super.targetType,
    required super.targetValue,
  });

  /// 从 JSON 创建 HomeCategoryModel 实例
  factory HomeCategoryModel.fromJson(Map<String, dynamic> json) {
    return HomeCategoryModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      targetType: json['targetType'] ?? 'category',
      targetValue: json['targetValue'] ?? '',
    );
  }

  /// 将 HomeCategoryModel 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconUrl': iconUrl,
      'targetType': targetType,
      'targetValue': targetValue,
    };
  }

  /// 创建一个新的 HomeCategoryModel 实例，并替换指定的属性
  HomeCategoryModel copyWith({
    String? id,
    String? name,
    String? iconUrl,
    String? targetType,
    String? targetValue,
  }) {
    return HomeCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconUrl: iconUrl ?? this.iconUrl,
      targetType: targetType ?? this.targetType,
      targetValue: targetValue ?? this.targetValue,
    );
  }
}