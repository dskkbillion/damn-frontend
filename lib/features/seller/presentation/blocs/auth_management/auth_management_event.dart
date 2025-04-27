part of 'auth_management_bloc.dart';

/// 认证管理事件基类
abstract class AuthManagementEvent {
  const AuthManagementEvent();
}

/// 加载认证列表事件
class LoadAuthenticationList extends AuthManagementEvent {}

/// 刷新认证列表事件
class RefreshAuthenticationList extends AuthManagementEvent {}

// 可能还需要其他事件，例如导航到申请页面等 