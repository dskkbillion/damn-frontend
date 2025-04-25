part of 'auth_application_bloc.dart';

/// 认证申请事件基类
abstract class AuthApplicationEvent extends Equatable {
  const AuthApplicationEvent();

  @override
  List<Object?> get props => [];
}

/// 提交认证申请事件
class SubmitAuthApplication extends AuthApplicationEvent {
  /// 认证类型
  final AuthenticationType authenticationType;
  
  /// 认证名称
  final String name;
  
  /// 认证编号
  final String identifier;
  
  /// 认证描述
  final String description;
  
  /// 文件路径列表
  final List<String> filePaths;
  
  /// 认证信息（如果是编辑现有认证）
  final SellerAuthenticationInfo? authInfo;

  /// 构造函数
  const SubmitAuthApplication({
    required this.authenticationType,
    required this.name,
    required this.identifier,
    required this.description,
    required this.filePaths,
    this.authInfo,
  });
  
  @override
  List<Object?> get props => [
    authenticationType,
    name,
    identifier,
    description,
    filePaths,
    authInfo,
  ];
}

/// 初始化表单事件
class InitializeAuthApplicationForm extends AuthApplicationEvent {
  /// 认证类型
  final AuthenticationType authenticationType;
  
  /// 认证信息（如果是编辑现有认证）
  final SellerAuthenticationInfo? authInfo;

  /// 构造函数
  const InitializeAuthApplicationForm({
    required this.authenticationType,
    this.authInfo,
  });
  
  @override
  List<Object?> get props => [authenticationType, authInfo];
} 