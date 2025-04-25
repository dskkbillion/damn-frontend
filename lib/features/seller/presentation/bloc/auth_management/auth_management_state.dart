part of 'auth_management_bloc.dart';

/// 认证管理页面状态基类 - 用于AuthManagementBloc
abstract class AuthManagementState extends Equatable {
  const AuthManagementState();
  
  @override
  List<Object> get props => [];
}

/// 初始状态
class AuthManagementInitial extends AuthManagementState {}

/// 加载中状态
class AuthManagementLoading extends AuthManagementState {}

/// 加载完成状态
class AuthManagementLoaded extends AuthManagementState {
  /// 已提交的认证列表
  final List<SellerAuthenticationInfo> submittedAuthList;
  
  /// 可申请的认证列表
  final List<SellerAuthenticationInfo> availableAuthList;

  const AuthManagementLoaded({
    required this.submittedAuthList,
    required this.availableAuthList,
  });

  @override
  List<Object> get props => [submittedAuthList, availableAuthList];
}

/// 空数据状态
class AuthManagementEmpty extends AuthManagementState {}

/// 错误状态
class AuthManagementError extends AuthManagementState {
  final String message;

  const AuthManagementError({required this.message});

  @override
  List<Object> get props => [message];
}

/// 认证管理详细状态 - 独立状态类，不继承自AuthManagementState
class AuthenticationManagementState extends Equatable {
  /// 是否正在加载
  final bool isLoading;

  /// 是否发生错误
  final bool hasError;

  /// 错误信息
  final String? errorMessage;

  /// 认证列表
  final List<SellerAuthenticationInfo> authList;

  const AuthenticationManagementState({
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.authList = const [],
  });

  /// 初始状态
  factory AuthenticationManagementState.initial() => const AuthenticationManagementState();

  /// 加载中状态
  factory AuthenticationManagementState.loading() => const AuthenticationManagementState(isLoading: true);

  /// 加载成功状态
  factory AuthenticationManagementState.loaded(List<SellerAuthenticationInfo> authList) => 
    AuthenticationManagementState(authList: authList);

  /// 错误状态
  factory AuthenticationManagementState.error(String message) => 
    AuthenticationManagementState(hasError: true, errorMessage: message);

  /// 创建新的状态
  AuthenticationManagementState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    List<SellerAuthenticationInfo>? authList,
  }) {
    return AuthenticationManagementState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      authList: authList ?? this.authList,
    );
  }

  /// 已批准的认证列表
  List<SellerAuthenticationInfo> get approvedAuthentications => authList
      .where((auth) => auth.status == AuthenticationStatus.approved)
      .toList();

  /// 待审核的认证列表
  List<SellerAuthenticationInfo> get pendingAuthentications => authList
      .where((auth) => auth.status == AuthenticationStatus.pending)
      .toList();

  /// 可申请的认证类型
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

  @override
  List<Object> get props => [isLoading, hasError, errorMessage ?? '', authList];
} 