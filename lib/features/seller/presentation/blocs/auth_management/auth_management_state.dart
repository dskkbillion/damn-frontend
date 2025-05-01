part of 'auth_management_bloc.dart';

/// 认证管理状态基类
abstract class AuthManagementState {
  const AuthManagementState();
}

/// 初始状态
class AuthManagementInitial extends AuthManagementState {}

/// 加载中状态
class AuthManagementLoading extends AuthManagementState {}

/// 加载失败状态
class AuthManagementError extends AuthManagementState {
  final String message;

  const AuthManagementError({required this.message});
}

/// 加载成功状态
class AuthManagementLoaded extends AuthManagementState {
  final List<SellerAuthenticationInfo> authList;

  const AuthManagementLoaded({required this.authList});

  /// 获取可用的认证类型（未提交或已拒绝的）
  List<AuthenticationType> get availableAuthenticationTypes {
    final existingTypes = authList
        .where((auth) => 
            auth.status == AuthenticationStatus.approved || 
            auth.status == AuthenticationStatus.pending)
        .map((auth) => auth.type)
        .toSet();
    
    return AuthenticationType.values
        .where((type) => !existingTypes.contains(type))
        .toList();
  }
} 