import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_authentication_info.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_authentication_status.dart';

part 'auth_management_event.dart';
part 'auth_management_state.dart';

/// 认证管理BLoC
@injectable
class AuthManagementBloc extends Bloc<AuthManagementEvent, AuthManagementState> {
  final GetAuthenticationStatus _getAuthenticationStatus;

  /// 构造函数
  AuthManagementBloc(this._getAuthenticationStatus) : super(AuthManagementInitial()) {
    on<LoadAuthenticationList>(_onLoadAuthenticationList);
    on<RefreshAuthenticationList>(_onRefreshAuthenticationList);
  }

  /// 加载认证列表
  Future<void> _onLoadAuthenticationList(
    LoadAuthenticationList event,
    Emitter<AuthManagementState> emit,
  ) async {
    emit(AuthManagementLoading());
    final result = await _getAuthenticationStatus(NoParams());
    _emitResultState(result, emit);
  }

  /// 刷新认证列表
  Future<void> _onRefreshAuthenticationList(
    RefreshAuthenticationList event,
    Emitter<AuthManagementState> emit,
  ) async {
    // 不显示loading状态，静默刷新
    final result = await _getAuthenticationStatus(NoParams());
    _emitResultState(result, emit);
  }

  /// 处理结果状态
  void _emitResultState(
    Either<Failure, List<SellerAuthenticationInfo>> result,
    Emitter<AuthManagementState> emit,
  ) {
    result.fold(
      (failure) => emit(AuthManagementError(message: _mapFailureToMessage(failure))),
      (authList) {
        // 将认证列表分为已提交和未提交两部分
        final submittedAuthList = authList.where((auth) => 
          auth.status != AuthenticationStatus.notSubmitted).toList();
        final availableAuthList = authList.where((auth) => 
          auth.enabled && auth.status.canSubmit).toList();
        
        if (submittedAuthList.isEmpty && availableAuthList.isEmpty) {
          emit(AuthManagementEmpty());
        } else {
          emit(AuthManagementLoaded(
            submittedAuthList: submittedAuthList,
            availableAuthList: availableAuthList,
          ));
        }
      },
    );
  }

  /// 将失败类型映射为错误消息
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return '服务器错误，请稍后再试';
      case NetworkFailure:
        return '网络错误，请检查网络连接';
      case CacheFailure:
        return '缓存错误，请重新加载';
      default:
        return '发生未知错误，请稍后再试';
    }
  }
} 