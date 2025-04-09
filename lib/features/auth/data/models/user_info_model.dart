import 'package:equatable/equatable.dart';

import 'package:dskk_flutter_refactor/features/auth/domain/entities/user_info.dart';

/// 用于解析 /api/member/info 响应中 `data` 部分的 DTO
class UserInfoModel extends UserInfo {

  const UserInfoModel({
    required super.id,
    super.mobile,
    super.nickName,
    super.avatar,
    // 可以添加更多来自实际响应的字段作为模型的属性，如果需要的话
    // 例如： final String? createTime;
  });

  /// 从 /api/member/info 响应的 `data` 部分创建模型
  factory UserInfoModel.fromJson(Map<String, dynamic> jsonData) {
    // 确保必要的字段存在且类型正确
    if (!jsonData.containsKey('id') || jsonData['id'] is! int) {
       throw FormatException('UserInfoModel: Missing or invalid type for "id" field.');
    }

    return UserInfoModel(
      id: jsonData['id'] as int,
      // 使用 ?. 和类型检查来安全地解析可选字段
      mobile: jsonData['mobile'] as String?,
      nickName: jsonData['nickName'] as String?,
      avatar: jsonData['avatar'] as String?,
      // 解析其他需要的字段...
      // createTime: jsonData['createTime'] as String?,
    );
  }

  /// 可选：如果需要将模型转换为 Entity (如果模型和实体结构不同)
  // UserInfo toEntity() {
  //   return UserInfo(
  //     id: id,
  //     mobile: mobile,
  //     nickName: nickName,
  //     avatar: avatar,
  //   );
  // }
}
