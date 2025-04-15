import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/wallet_summary.dart';
import '../../domain/usecases/get_wallet_summary.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

/// 钱包Bloc类，用于处理钱包相关的状态管理
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletSummary getWalletSummary;

  WalletBloc({
    required this.getWalletSummary,
  }) : super(const WalletInitial()) {
    on<FetchWalletSummary>(_onFetchWalletSummary);
    on<RefreshWalletSummary>(_onRefreshWalletSummary);
  }

  /// 处理获取钱包摘要信息事件
  Future<void> _onFetchWalletSummary(
    FetchWalletSummary event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());
    final result = await getWalletSummary(NoParams());
    _emitWalletSummaryResult(result, emit);
  }

  /// 处理刷新钱包摘要信息事件
  Future<void> _onRefreshWalletSummary(
    RefreshWalletSummary event,
    Emitter<WalletState> emit,
  ) async {
    // 不显示加载状态，直接获取并更新
    final result = await getWalletSummary(NoParams());
    _emitWalletSummaryResult(result, emit);
  }

  /// 根据获取结果发出对应状态
  void _emitWalletSummaryResult(
    Either<Failure, WalletSummary> result,
    Emitter<WalletState> emit,
  ) {
    result.fold(
      (failure) => emit(WalletError(_mapFailureToMessage(failure))),
      (walletSummary) => emit(WalletSummaryLoaded(walletSummary)),
    );
  }

  /// 将Failure映射为用户友好的错误消息
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return '服务器错误，请稍后再试';
      case NetworkFailure:
        return '网络连接失败，请检查网络设置';
      case CacheFailure:
        return '缓存读取失败';
      default:
        return '发生未知错误';
    }
  }
}
