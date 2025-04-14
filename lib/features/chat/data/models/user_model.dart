import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.g.dart';

/// API `/api/member/info` 和 嵌入在其他接口中的 User 数据模型
@JsonSerializable(explicitToJson: true)
class UserModel {
  /// 用户 ID (系统内部 ID)
  final int id;

  /// 昵称
  final String? nickName;

  /// 头像 URL
  final String? avatar;

  /// 通用用户 ID (重要: 用于 WebSocket 连接)
  final int? commonUserId;

  // --- 以下字段来自 /api/member/info，其他接口嵌入时可能为 null ---
  final String? createTime;
  final String? updateTime;
  final int? sort;
  final String? signature;
  final String? birthday;
  final String? vipTime;
  final String? mobile;
  final String? trueName;
  final String? gender;
  final String? status;
  final String? type;
  final String? province;
  final String? remarks;
  final String? weminiOpenid;
  final String? weappOpenid;
  final String? weUnionid;
  final bool? realNameFlag;
  final String? attestationName;
  final int? productNum;
  final int? orderNum;
  final int? buyOrderNum;
  final String? ip;
  final String? loginTime;
  final bool? recoverFlag;
  final bool? onlineFlag;
  final String? lastLoginTime;
  final double? payPriceTotal; // API 似乎未返回，但保留可能性
  final String? inviter; // API 似乎未返回，但保留可能性
  final int? isApplyDel;
  final int? age;
  final String? xingzuo;

  UserModel({
    required this.id,
    this.nickName,
    this.avatar,
    this.commonUserId,
    this.createTime,
    this.updateTime,
    this.sort,
    this.signature,
    this.birthday,
    this.vipTime,
    this.mobile,
    this.trueName,
    this.gender,
    this.status,
    this.type,
    this.province,
    this.remarks,
    this.weminiOpenid,
    this.weappOpenid,
    this.weUnionid,
    this.realNameFlag,
    this.attestationName,
    this.productNum,
    this.orderNum,
    this.buyOrderNum,
    this.ip,
    this.loginTime,
    this.recoverFlag,
    this.onlineFlag,
    this.lastLoginTime,
    this.payPriceTotal,
    this.inviter,
    this.isApplyDel,
    this.age,
    this.xingzuo,
  });

  /// 从 JSON 数据创建 UserModel 实例
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  /// 将 UserModel 实例转换为 JSON 数据
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// 将 UserModel 转换为 Domain 层的 User 实体
  User toEntity() {
    // commonUserId 在嵌入 User 模型时可能为 null，但对于 User 实体是必须的。
    // 在实际使用中，应确保从 /api/member/info 获取完整的 UserModel 或有默认处理。
    if (commonUserId == null) {
      // 或者抛出异常，或者提供默认值，取决于业务逻辑
      print("Warning: commonUserId is null for user id: $id. Using default or failing.");
    }
     if (nickName == null) {
      print("Warning: nickName is null for user id: $id. Using default or failing.");
    }

    return User(
      id: id,
      nickName: nickName ?? 'Unknown User', // 提供默认值或确保非空
      avatar: avatar,
      commonUserId: commonUserId ?? -1, // 提供默认值或确保非空
    );
  }

  /// 从 Domain 层的 User 实体创建 UserModel
  /// 注意：这通常只包含实体中存在的字段，用于请求可能不完整
  factory UserModel.fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      nickName: entity.nickName,
      avatar: entity.avatar,
      commonUserId: entity.commonUserId,
      // 其他字段设为 null 或根据需要填充
    );
  }
} 