import 'package:equatable/equatable.dart';

/// 收藏实体
class Favorite extends Equatable {
  /// 收藏记录唯一标识
  final int id;
  
  /// 收藏类型，如"org_product"（服务项目）、"org"（服务机构/卖家）等
  final String type;
  
  /// 用户ID
  final int memberId;
  
  /// 收藏对象ID
  final int objectId;
  
  /// 收藏对象的特征信息（可选）
  final Map<String, dynamic>? feature;
  
  /// 排序值（可选）
  final int? sort;
  
  /// 创建时间
  final DateTime createTime;
  
  /// 更新时间
  final DateTime updateTime;

  /// 构造函数
  const Favorite({
    required this.id,
    required this.type,
    required this.memberId,
    required this.objectId,
    this.feature,
    this.sort,
    required this.createTime,
    required this.updateTime,
  });

  @override
  List<Object?> get props => [
    id,
    type,
    memberId,
    objectId,
    feature,
    sort,
    createTime,
    updateTime,
  ];

  /// 创建一个新的Favorite实例，并更新指定的字段
  Favorite copyWith({
    int? id,
    String? type,
    int? memberId,
    int? objectId,
    Map<String, dynamic>? feature,
    int? sort,
    DateTime? createTime,
    DateTime? updateTime,
  }) {
    return Favorite(
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