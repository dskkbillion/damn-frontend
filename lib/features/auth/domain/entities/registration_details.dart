import 'package:equatable/equatable.dart';

/// 用户注册所需信息 (用于 /api/auth/register)
/// API 文档与 RN 实现存在冲突，字段基于 API 文档，但需与后端最终确认。
class RegistrationDetails extends Equatable {
  final String phone;
  final String code;
  // API 文档定义 scene 为必选 String
  final String scene;
  // API 文档定义 password 为必选 String (RN 代码未使用?)
  final String password;
  // API 文档定义 inviterId 为必选 integer, nullable (RN 代码为可选 String?)
  // TODO: 确认 inviterId 确切类型 (int?) 和是否真的必选
  final int? inviterId;

  const RegistrationDetails({
    required this.phone,
    required this.code,
    required this.scene, // 根据文档设为必选
    required this.password, // 根据文档设为必选
    this.inviterId, // 根据文档设为可选 int?
  });

  @override
  List<Object?> get props => [phone, code, scene, password, inviterId];
}
