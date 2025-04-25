part of 'auth_application_bloc.dart';

/// 认证申请状态基类
abstract class AuthApplicationState extends Equatable {
  const AuthApplicationState();
  
  @override
  List<Object?> get props => [];
}

/// 初始状态
class AuthApplicationInitial extends AuthApplicationState {}

/// 表单初始化完成
class AuthApplicationFormInitialized extends AuthApplicationState {
  /// 认证类型
  final AuthenticationType authenticationType;
  
  /// 认证信息（如果是编辑现有认证）
  final SellerAuthenticationInfo? authInfo;
  
  /// 构造函数
  const AuthApplicationFormInitialized({
    required this.authenticationType,
    this.authInfo,
  });
  
  @override
  List<Object?> get props => [authenticationType, authInfo];
}

/// 提交中状态
class AuthApplicationSubmitting extends AuthApplicationState {}

/// 提交成功状态
class AuthApplicationSuccess extends AuthApplicationState {}

/// 提交失败状态
class AuthApplicationFailure extends AuthApplicationState {
  /// 错误信息
  final String message;
  
  /// 构造函数
  const AuthApplicationFailure({required this.message});
  
  @override
  List<Object> get props => [message];
}

/// 表单验证错误状态
class AuthApplicationValidationError extends AuthApplicationState {
  /// 字段错误信息映射
  final Map<String, String> fieldErrors;
  
  /// 构造函数
  const AuthApplicationValidationError({required this.fieldErrors});
  
  @override
  List<Object> get props => [fieldErrors];
} 