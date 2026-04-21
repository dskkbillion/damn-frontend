import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/i_wallet_repository.dart';
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
  final IWalletRepository? walletRepository;

  WalletBloc({
    required this.getWalletSummary,
    required this.getWalletTransactions,
    this.walletRepository,
  }) : super(const WalletInitial()) {
    on<FetchWalletSummary>(_onFetchWalletSummary);
    on<RefreshWalletSummary>(_onRefreshWalletSummary);
    on<FetchWalletTransactions>(_onFetchWalletTransactions);
    on<LoadMoreWalletTransactions>(_onLoadMoreWalletTransactions);
    on<SubmitWithdrawal>(_onSubmitWithdrawal);
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
    if (state is WalletSummaryLoaded) {
      final walletSummary = (state as WalletSummaryLoaded).walletSummary;
      emit(WalletTransactionsLoading(walletSummary, const []));

      final result = await getWalletTransactions(TransactionsParams(
        page: 1,
      pageSize: event.pageSize,
        transactionType: event.transactionType,
      startDate: event.startDate,
      endDate: event.endDate,
      ));

    result.fold(
      (failure) {
          // 当交易记录API返回失败时，仍然保留钱包摘要信息
          AppLogger.d('获取交易记录失败: ${failure.toString()}');
          emit(WalletLoaded(
            walletSummary,
            const [], // 空交易记录列表
            1,
            false,
            loadMoreError: failure.toString(),
          ));
      },
      (transactions) {
          emit(WalletLoaded(
            walletSummary,
            transactions,
            1,
            transactions.length < event.pageSize,
          ));
        },
      );
        } else {
      // 如果摘要未加载，先尝试获取摘要
      emit(const WalletLoading());
      
      final summaryResult = await getWalletSummary(NoParams());
      
      await summaryResult.fold(
        (failure) async {
          // 如果获取摘要失败，尝试只获取交易记录
          AppLogger.d('获取钱包摘要失败，尝试只获取交易记录: ${failure.toString()}');
          
          final transactionsResult = await getWalletTransactions(TransactionsParams(
            page: 1,
            pageSize: event.pageSize,
            transactionType: event.transactionType,
            startDate: event.startDate,
            endDate: event.endDate,
          ));
          
          transactionsResult.fold(
            (transactionsFailure) {
              emit(WalletError(transactionsFailure.toString()));
            },
            (transactions) {
          emit(WalletTransactionsOnly(
            transactions,
                1,
            transactions.length < event.pageSize,
          ));
            },
          );
        },
        (walletSummary) async {
          // 如果获取摘要成功，再获取交易记录
          emit(WalletTransactionsLoading(walletSummary, const []));
          
          final transactionsResult = await getWalletTransactions(TransactionsParams(
            page: 1,
            pageSize: event.pageSize,
            transactionType: event.transactionType,
            startDate: event.startDate,
            endDate: event.endDate,
          ));
          
          transactionsResult.fold(
            (failure) {
              // 即使获取交易记录失败，也保留钱包摘要
              AppLogger.d('获取交易记录失败: ${failure.toString()}');
              emit(WalletLoaded(
                walletSummary,
                const [], // 空交易记录列表
                1,
                false,
                loadMoreError: failure.toString(),
              ));
            },
            (transactions) {
              emit(WalletLoaded(
                walletSummary,
                transactions,
                1,
                transactions.length < event.pageSize,
              ));
            },
          );
        },
      );
    }
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

  /// 处理提交提款事件
  Future<void> _onSubmitWithdrawal(
    SubmitWithdrawal event,
    Emitter<WalletState> emit,
  ) async {
    if (walletRepository == null) {
      emit(const WithdrawalFailed('提款服务不可用'));
      return;
    }
    emit(const WithdrawalSubmitting());
    final result = await walletRepository!.submitWithdrawal(amount: event.amount);
    result.fold(
      (failure) => emit(WithdrawalFailed(_mapFailureToMessage(failure))),
      (_) => emit(const WithdrawalSuccess()),
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
