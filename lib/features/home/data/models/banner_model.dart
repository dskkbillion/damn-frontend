import '../../domain/entities/banner.dart';

/// Banner 模型，用于序列化和反序列化 API 响应
class BannerModel extends Banner {
  const BannerModel({
    required String id,
    required String imageUrl,
    required String targetType,
    required String targetValue,
    required String createTime,
    required String updateTime,
  }) : super(
          id: id,
          imageUrl: imageUrl,
          targetType: targetType,
          targetValue: targetValue,
          createTime: createTime,
          updateTime: updateTime,
        );

  /// 从 JSON 创建 BannerModel 实例
  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'].toString(),
      imageUrl: json['image'] ?? '',
      targetType: json['targetType'] ?? 'none',
      targetValue: json['targetValue'] ?? '',
      createTime: json['createTime'] ?? '',
      updateTime: json['updateTime'] ?? '',
    );
  }

  /// 将 BannerModel 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': imageUrl,
      'targetType': targetType,
      'targetValue': targetValue,
      'createTime': createTime,
      'updateTime': updateTime,
    };
  }

  /// 创建一个新的 BannerModel 实例，并替换指定的属性
  BannerModel copyWith({
    String? id,
    String? imageUrl,
    String? targetType,
    String? targetValue,
    String? createTime,
    String? updateTime,
  }) {
    return BannerModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      targetType: targetType ?? this.targetType,
      targetValue: targetValue ?? this.targetValue,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
    );
  }
}