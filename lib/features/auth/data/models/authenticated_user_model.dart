// import 'package:damn_frontend/features/auth/domain/entities/authenticated_user.dart';

// TODO: 此 Model 用于解析 /api/auth/login 的响应
// 它不再需要继承 AuthenticatedUser，只包含 token 和 code

/// `/api/auth/login` 成功响应的 DTO (Data Transfer Object)
/// 主要包含 token，可能包含 code。
class AuthenticatedUserModel {
  // API 返回的 code 字段，含义和类型 (int?) 待确认，暂时保留
  final int? code;
  final String token;

  const AuthenticatedUserModel({
    this.code,
    required this.token,
  });

  factory AuthenticatedUserModel.fromJson(Map<String, dynamic> json) {
    // 确认响应中必须包含 token
    if (json.containsKey('token')) {
      return AuthenticatedUserModel(
        // code 字段可选，如果不存在或类型不匹配，则为 null
        code: json['code'] is int ? json['code'] as int : null,
        token: json['token'] as String,
      );
    } else {
      // 如果 API 响应缺少 token
      throw FormatException(
          'Failed to parse AuthenticatedUserModel from JSON. Expected "token" field.');
    }
  }
}

// --- 原 AuthenticatedUserModel 内容已移除 ---
// // TODO: 这个 Model 的具体字段完全依赖于 API 响应，并添加占位符解析逻辑
// // 当前只是一个占位符结构，必须根据 API 确认结果进行修改。
//
// /// 后端返回的认证用户信息 DTO (Data Transfer Object)
// /// 可能包含与 Domain Entity 不同的字段或结构。
// class AuthenticatedUserModel extends AuthenticatedUser {
//   // 假设后端返回了这些字段，需要根据实际情况修改
//   final String backendUserId; // 可能 API 返回的是 user_id
//   final String backendToken;  // 可能 API 返回的是 access_token
//   final int? expiresIn;       // 可能 API 还返回了 token 过期时间
//
//   const AuthenticatedUserModel({
//     required this.backendUserId,
//     required this.backendToken,
//     this.expiresIn,
//   }) : super(userId: backendUserId, token: backendToken); // 将 DTO 字段映射到 Entity 字段
//
//   // TODO: 实现从 JSON 对象创建 AuthenticatedUserModel 的工厂构造函数
//   // 这将依赖于 API 的实际 JSON 响应结构
//   factory AuthenticatedUserModel.fromJson(Map<String, dynamic> json) {
//     // 这里是完全的猜测，必须修改！
//     if (json.containsKey('user_id') && json.containsKey('token')) {
//        return AuthenticatedUserModel(
//          backendUserId: json['user_id'] as String,
//          backendToken: json['token'] as String,
//          expiresIn: json['expires_in'] as int?,
//        );
//     } else if (json.containsKey('userId') && json.containsKey('accessToken')) {
//       // 另一种可能的猜测
//       return AuthenticatedUserModel(
//         backendUserId: json['userId'] as String,
//         backendToken: json['accessToken'] as String,
//         expiresIn: json['expiresIn'] as int?,
//       );
//     } else {
//       // 如果无法解析，抛出错误或返回默认值，但这表示 API 响应未知！
//       throw FormatException('Failed to parse AuthenticatedUser from JSON. Unknown API response structure.');
//     }
//
//     // // 示例：如果 API 响应是 {"data": {"id": "123", "access_token": "abc"}}
//     // final data = json['data'];
//     // return AuthenticatedUserModel(
//     //   backendUserId: data['id'],
//     //   backendToken: data['access_token'],
//     // );
//   }
//
//   // TODO: 实现将 AuthenticatedUserModel 转换为 JSON 对象的方法（如果需要）
//   Map<String, dynamic> toJson() {
//     // 实现取决于你的需求，通常用于发送数据到服务器，对认证模型可能不需要
//     throw UnimplementedError('toJson() not implemented for AuthenticatedUserModel');
//   }
//
//   // (可选) DTO 到 Entity 的转换方法，如果 DTO 和 Entity 结构差异大
//   // AuthenticatedUser toEntity() {
//   //   return AuthenticatedUser(
//   //     userId: backendUserId,
//   //     token: backendToken,
//   //   );
//   // }
// }
