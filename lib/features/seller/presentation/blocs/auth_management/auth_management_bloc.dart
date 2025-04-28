import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_authentication_info.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_authentication_status_usecase.dart';

part 'auth_management_event.dart';
part 'auth_management_state.dart';

/// 认证管理BLoC
@injectable
class AuthManagementBloc extends Bloc<AuthManagementEvent, AuthManagementState> {
  final GetSellerAuthenticationStatusUseCase _getAuthenticationStatusUseCase;

  /// 构造函数
  AuthManagementBloc(this._getAuthenticationStatusUseCase) : super(AuthManagementInitial()) {
    on<LoadAuthenticationList>(_onLoadAuthenticationList);
    on<RefreshAuthenticationList>(_onRefreshAuthenticationList);
  }

  /// 加载认证列表
  Future<void> _onLoadAuthenticationList(
    LoadAuthenticationList event,
    Emitter<AuthManagementState> emit,
  ) async {
    emit(AuthManagementLoading());
    final result = await _getAuthenticationStatusUseCase(NoParams());
    _emitResultState(result, emit);
  }

  /// 刷新认证列表
  Future<void> _onRefreshAuthenticationList(
    RefreshAuthenticationList event,
    Emitter<AuthManagementState> emit,
  ) async {
    // 不显示loading状态，静默刷新
    final result = await _getAuthenticationStatusUseCase(NoParams());
    _emitResultState(result, emit);
  }

  /// 处理加载结果
  void _emitResultState(
    Either<Failure, List<SellerAuthenticationInfo>> result,
    Emitter<AuthManagementState> emit,
  ) {
    result.fold(
      (failure) => emit(AuthManagementError(message: failure.message)),
      (authList) => emit(AuthManagementLoaded(authList: authList)),
    );
  }
} 
 