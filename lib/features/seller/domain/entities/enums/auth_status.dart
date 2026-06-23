import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';

/// 认证状态枚举
enum AuthenticationStatus {
  /// 未提交
  notSubmitted('NOT_SUBMITTED', '未提交'),
  
  /// 等待审核
  pending('PENDING', '审核中'),
  
  /// 审核通过
  approved('APPROVED', '已认证'),
  
  /// 审核拒绝
  rejected('REJECTED', '未通过'),
  
  /// 已过期
  expired('EXPIRED', '已过期');

  /// 认证状态的API值
  final String value;
  
  /// 认证状态的显示名称
  final String displayName;

  const AuthenticationStatus(this.value, this.displayName);

  /// 从API值获取枚举
  static AuthenticationStatus fromValue(String value) {
    return AuthenticationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AuthenticationStatus.notSubmitted,
    );
  }
  
  /// 检查是否可以提交认证
  bool get canSubmit => this == AuthenticationStatus.notSubmitted || 
                        this == AuthenticationStatus.rejected ||
                        this == AuthenticationStatus.expired;
                        
  /// 检查是否已认证通过
  bool get isApproved => this == AuthenticationStatus.approved;
  
  /// 检查是否正在审核中
  bool get isPending => this == AuthenticationStatus.pending;
}

/// 认证状态扩展
extension AuthStatusExtension on AuthenticationStatus {
  /// 获取状态显示名称
  String get displayName {
    return this.displayName;
  }
  
  /// 获取状态API值
  String get value {
    return this.value;
  }
  
  /// 获取状态颜色
  Color get color {
    switch (this) {
      case AuthenticationStatus.notSubmitted:
        return AppColors.textTertiary;
      case AuthenticationStatus.pending:
        return AppColors.warning;
      case AuthenticationStatus.approved:
        return AppColors.success;
      case AuthenticationStatus.rejected:
        return AppColors.error;
      case AuthenticationStatus.expired:
        return AppColors.textTertiary;
    }
  }
  
  /// 获取状态图标
  IconData get icon {
    switch (this) {
      case AuthenticationStatus.notSubmitted:
        return Icons.pending_outlined;
      case AuthenticationStatus.pending:
        return Icons.hourglass_empty;
      case AuthenticationStatus.approved:
        return Icons.check_circle;
      case AuthenticationStatus.rejected:
        return Icons.cancel;
      case AuthenticationStatus.expired:
        return Icons.access_time;
    }
  }
} 