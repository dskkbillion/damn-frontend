import '../../domain/entities/favorite.dart';

/// 收藏模型
class FavoriteModel extends Favorite {
  /// 构造函数
  const FavoriteModel({
    required super.id,
    required super.type,
    required super.memberId,
    required super.objectId,
    super.feature,
    super.sort,
    required super.createTime,
    required super.updateTime,
  });

  /// 从JSON创建模型
  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'],
      type: json['type'],
      memberId: json['memberId'],
      objectId: json['objectId'],
      feature: json['feature'],
      sort: json['sort'],
      createTime: DateTime.parse(json['createTime']),
      updateTime: DateTime.parse(json['updateTime']),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'memberId': memberId,
      'objectId': objectId,
      'feature': feature,
      'sort': sort,
      'createTime': createTime.toIso8601String(),
      'updateTime': updateTime.toIso8601String(),
    };
  }

  /// 创建一个新的FavoriteModel实例，并更新指定的字段
  @override
  FavoriteModel copyWith({
    int? id,
    String? type,
    int? memberId,
    int? objectId,
    Map<String, dynamic>? feature,
    int? sort,
    DateTime? createTime,
    DateTime? updateTime,
  }) {
    return FavoriteModel(
      id: id ?? this.id,
      type: type ?? this.type,
      memberId: memberId ?? this.memberId,
      objectId: objectId ?? this.objectId,
      feature: feature ?? this.feature,
      sort: sort ?? this.sort,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
    );
  }
}