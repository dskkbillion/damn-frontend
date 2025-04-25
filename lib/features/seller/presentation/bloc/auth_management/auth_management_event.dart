part of 'auth_management_bloc.dart';

/// 认证管理页面事件基类
abstract class AuthManagementEvent extends Equatable {
  const AuthManagementEvent();

  @override
  List<Object> get props => [];
}

/// 加载认证列表事件
class LoadAuthenticationList extends AuthManagementEvent {
  const LoadAuthenticationList();
}

/// 刷新认证列表事件
class RefreshAuthenticationList extends AuthManagementEvent {
  const RefreshAuthenticationList();
}

/// 初始化认证管理
class InitializeAuthManagement extends AuthManagementEvent {
  const InitializeAuthManagement();
}

/// 加载认证状态
class LoadAuthenticationStatus extends AuthManagementEvent {
  const LoadAuthenticationStatus();
}

/// 提交认证申请
class SubmitAuthenticationApplication extends AuthManagementEvent {
  /// 认证类型
  final AuthenticationType type;
  
  /// 认证名称
  final String name;
  
  /// 认证编号
  final String identifier;
  
  /// 认证描述
  final String description;
  
  /// 文件路径列表
  final List<String> filePaths;

  const SubmitAuthenticationApplication({
    required this.type,
    required this.name,
    required this.identifier,
    required this.description,
    required this.filePaths,
  });
  
  @override
  List<Object> get props => [
    type,
    name,
    identifier,
    description,
    filePaths,
  ];
}

/// 刷新认证状态
class RefreshAuthenticationStatus extends AuthManagementEvent {
  const RefreshAuthenticationStatus();
} 