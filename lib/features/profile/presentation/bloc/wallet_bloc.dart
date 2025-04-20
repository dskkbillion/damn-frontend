import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/wallet_summary.dart';
import '../../domain/usecases/get_wallet_summary.dart';
import '../../domain/usecases/get_wallet_transactions.dart';
import '../../data/models/transaction_dto.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

/// 钱包Bloc类，用于处理钱包相关的状态管理
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletSummary getWalletSummary;
  final GetWalletTransactions getWalletTransactions;

  WalletBloc({
    required this.getWalletSummary,
    required this.getWalletTransactions,
  }) : super(const WalletInitial()) {
    on<FetchWalletSummary>(_onFetchWalletSummary);
    on<RefreshWalletSummary>(_onRefreshWalletSummary);
    on<FetchWalletTransactions>(_onFetchWalletTransactions);
    on<LoadMoreWalletTransactions>(_onLoadMoreWalletTransactions);
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

  /// 处理获取钱包交易记录事件
  Future<void> _onFetchWalletTransactions(
    FetchWalletTransactions event,
    Emitter<WalletState> emit,
  ) async {
    // 保存当前状态的钱包摘要信息（如果有）
    WalletSummary? currentSummary;
    if (state is WalletSummaryLoaded) {
      currentSummary = (state as WalletSummaryLoaded).walletSummary;
    }

    // 如果没有加载摘要，先显示加载中
    if (currentSummary == null) {
      emit(const WalletLoading());
    } else {
      emit(WalletTransactionsLoading(currentSummary, const []));
    }

    // 构建请求参数
    final params = TransactionsParams(
      page: event.page,
      pageSize: event.pageSize,
      startDate: event.startDate,
      endDate: event.endDate,
      transactionType: event.transactionType,
    );

    // 执行请求
    final result = await getWalletTransactions(params);

    result.fold(
      (failure) {
        // 如果有摘要信息，保留摘要但显示交易记录错误
        if (currentSummary != null) {
          emit(WalletTransactionsError(
            currentSummary,
            const [],
            _mapFailureToMessage(failure),
          ));
        } else {
          // 否则显示普通错误
          emit(WalletError(_mapFailureToMessage(failure)));
        }
      },
      (transactions) {
        if (currentSummary != null) {
          // 如果有摘要信息，同时展示摘要和交易记录
          emit(WalletLoaded(
            currentSummary,
            transactions,
            event.page,
            transactions.length < event.pageSize, // 如果返回数量小于请求数量，表示没有更多数据
          ));
        } else {
          // 如果只获取了交易记录但没有摘要，也展示交易记录
          emit(WalletTransactionsOnly(
            transactions,
            event.page,
            transactions.length < event.pageSize,
          ));
        }
      },
    );
  }

  /// 处理加载更多钱包交易记录事件
  Future<void> _onLoadMoreWalletTransactions(
    LoadMoreWalletTransactions event,
    Emitter<WalletState> emit,
  ) async {
    // 获取当前状态的信息
    WalletSummary? currentSummary;
    List<TransactionDto> currentTransactions = [];
    int currentPage = 1;

    if (state is WalletLoaded) {
      final loadedState = state as WalletLoaded;
      currentSummary = loadedState.walletSummary;
      currentTransactions = loadedState.transactions;
      currentPage = loadedState.currentPage;
    } else if (state is WalletTransactionsOnly) {
      final transactionsState = state as WalletTransactionsOnly;
      currentTransactions = transactionsState.transactions;
      currentPage = transactionsState.currentPage;
    } else {
      // 如果当前状态不是已加载状态，不处理加载更多
      return;
    }

    // 显示加载更多中的状态
    if (currentSummary != null) {
      emit(WalletLoadingMore(
        currentSummary,
        currentTransactions,
        currentPage,
      ));
    } else {
      emit(WalletTransactionsLoadingMore(
        currentTransactions,
        currentPage,
      ));
    }

    // 构建请求参数
    final nextPage = currentPage + 1;
    final params = TransactionsParams(
      page: nextPage,
      pageSize: event.pageSize,
      startDate: event.startDate,
      endDate: event.endDate,
      transactionType: event.transactionType,
    );

    // 执行请求
    final result = await getWalletTransactions(params);

    result.fold(
      (failure) {
        // 保留当前数据，但显示加载更多失败
        if (currentSummary != null) {
          emit(WalletLoaded(
            currentSummary,
            currentTransactions,
            currentPage,
            false, // 由于加载失败，不确定是否没有更多数据
            loadMoreError: _mapFailureToMessage(failure),
          ));
        } else {
          emit(WalletTransactionsOnly(
            currentTransactions,
            currentPage,
            false,
            loadMoreError: _mapFailureToMessage(failure),
          ));
        }
      },
      (newTransactions) {
        // 合并新旧交易记录
        final allTransactions = [...currentTransactions, ...newTransactions];
        final isNoMoreData = newTransactions.length < event.pageSize;

        if (currentSummary != null) {
          emit(WalletLoaded(
            currentSummary,
            allTransactions,
            nextPage,
            isNoMoreData,
          ));
        } else {
          emit(WalletTransactionsOnly(
            allTransactions,
            nextPage,
            isNoMoreData,
          ));
        }
      },
    );
  }

  /// 将Failure映射为用户友好的错误消息
  String _mapFailureToMessage(Failure failure) {
    switch (failure) {
      case ServerFailure _:
        return '服务器错误，请稍后再试';
      case NetworkFailure _:
        return '网络连接失败，请检查网络设置';
      case CacheFailure _:
        return '缓存读取失败';
      default:
        return '发生未知错误';
    }
  }
}
