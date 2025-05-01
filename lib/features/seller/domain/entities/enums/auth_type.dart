import 'package:flutter/material.dart';

/// 认证类型枚举
enum AuthenticationType {
  /// 身份证认证
  idCard('ID_CARD', '身份认证', '上传身份证正反面进行认证'),
  
  /// 学历认证
  education('EDUCATION', '学历认证', '上传学历证明进行认证'),
  
  /// 职业认证
  profession('PROFESSION', '职业认证', '上传职业资格证书进行认证'),
  
  /// 公司认证
  company('COMPANY', '公司认证', '上传营业执照等进行认证'),
  
  /// 其他认证
  other('OTHER', '其他认证', '');

  /// 认证类型的API值
  final String value;
  
  /// 认证类型的显示名称
  final String displayName;
  
  /// 认证类型的描述
  final String description;

  const AuthenticationType(this.value, this.displayName, this.description);

  /// 从API值获取枚举
  static AuthenticationType fromValue(String value) {
    return AuthenticationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => AuthenticationType.other,
    );
  }
}

/// 认证类型扩展
extension AuthTypeExtension on AuthenticationType {
  /// 获取认证类型图标
  IconData get icon {
    switch (this) {
      case AuthenticationType.idCard:
        return Icons.credit_card;
      case AuthenticationType.education:
        return Icons.school;
      case AuthenticationType.profession:
        return Icons.work;
      case AuthenticationType.company:
        return Icons.business;
      case AuthenticationType.other:
        return Icons.help_outline;
    }
  }
} 