import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/stripe_connect_remote_data_source.dart';
import 'connect_account_event.dart';
import 'connect_account_state.dart';

class ConnectAccountBloc extends Bloc<ConnectAccountEvent, ConnectAccountState> {
  final IStripeConnectRemoteDataSource _dataSource;

  ConnectAccountBloc({required IStripeConnectRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(ConnectAccountInitial()) {
    on<CheckConnectAccountStatus>(_onCheckStatus);
    on<CreateConnectAccount>(_onCreateAccount);
    on<FetchOnboardingLink>(_onFetchOnboardingLink);
    on<FetchAccountSession>(_onFetchAccountSession);
    on<RefreshConnectAccountStatus>(_onRefreshStatus);
  }

  Future<void> _onCheckStatus(
    CheckConnectAccountStatus event,
    Emitter<ConnectAccountState> emit,
  ) async {
    emit(ConnectAccountLoading());
    try {
      final status = await _dataSource.getAccountStatus();
      _emitStateFromStatus(status, emit);
    } catch (e) {
      AppLogger.d('[ConnectAccountBloc] 查询账户状态失败: $e');
      emit(const ConnectAccountError(message: '查询账户状态失败'));
    }
  }

  Future<void> _onCreateAccount(
    CreateConnectAccount event,
    Emitter<ConnectAccountState> emit,
  ) async {
    emit(ConnectAccountLoading());
    try {
      final status = await _dataSource.createConnectAccount();
      AppLogger.d('[ConnectAccountBloc] 账户创建成功，状态: ${status.status}');

      // 创建成功后走嵌入式路径（自动降级到跳转式）
      add(FetchAccountSession());
    } catch (e) {
      AppLogger.d('[ConnectAccountBloc] 创建账户失败: $e');
      // 已绑定时直接检查状态（会自动进入 onboarding 流程）
      if (e.toString().contains('已绑定')) {
        add(CheckConnectAccountStatus());
        return;
      }
      emit(const ConnectAccountError(message: '创建收款账户失败'));
    }
  }

  Future<void> _onFetchOnboardingLink(
    FetchOnboardingLink event,
    Emitter<ConnectAccountState> emit,
  ) async {
    emit(ConnectAccountLoading());
    try {
      final url = await _dataSource.getOnboardingLink();
      emit(ConnectAccountOnboardingReady(onboardingUrl: url));
    } catch (e) {
      AppLogger.d('[ConnectAccountBloc] 获取 Onboarding 链接失败: $e');
      emit(const ConnectAccountError(message: '获取认证链接失败，请重试'));
    }
  }

  Future<void> _onFetchAccountSession(
    FetchAccountSession event,
    Emitter<ConnectAccountState> emit,
  ) async {
    emit(ConnectAccountLoading());
    try {
      final clientSecret = await _dataSource.createAccountSession();
      emit(ConnectAccountSessionReady(clientSecret: clientSecret));
    } catch (e) {
      // 嵌入式失败，自动降级到跳转式 Onboarding
      AppLogger.d('[ConnectAccountBloc] AccountSession 失败，降级到 Hosted: $e');
      add(FetchOnboardingLink());
    }
  }

  Future<void> _onRefreshStatus(
    RefreshConnectAccountStatus event,
    Emitter<ConnectAccountState> emit,
  ) async {
    emit(ConnectAccountLoading());
    try {
      final status = await _dataSource.getAccountStatus(refresh: true);
      _emitStateFromStatus(status, emit);
    } catch (e) {
      AppLogger.d('[ConnectAccountBloc] 刷新账户状态失败: $e');
      emit(const ConnectAccountError(message: '刷新状态失败'));
    }
  }

  void _emitStateFromStatus(ConnectAccountStatus status, Emitter<ConnectAccountState> emit) {
    switch (status.status) {
      case ConnectStatus.notCreated:
        emit(ConnectAccountUnlinked());
      case ConnectStatus.pendingOnboarding:
        // 需要继续 onboarding，优先嵌入式（失败自动降级）
        add(FetchAccountSession());
      case ConnectStatus.pendingVerification:
        emit(ConnectAccountPendingVerification(accountStatus: status));
      case ConnectStatus.active:
        emit(ConnectAccountActive(accountStatus: status));
      case ConnectStatus.restricted:
        emit(ConnectAccountActive(accountStatus: status));
    }
  }
}
