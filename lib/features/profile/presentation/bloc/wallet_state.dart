import 'package:equatable/equatable.dart';

import '../../domain/entities/wallet_summary.dart';
import '../../data/models/transaction_dto.dart';

/// 钱包状态抽象基类
abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

/// 钱包初始状态
class WalletInitial extends WalletState {
  const WalletInitial();
}

/// 钱包加载中状态
class WalletLoading extends WalletState {
  const WalletLoading();
}

/// 钱包错误状态
class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}

/// 钱包摘要加载完成状态
class WalletSummaryLoaded extends WalletState {
  final WalletSummary walletSummary;

  const WalletSummaryLoaded(this.walletSummary);

  @override
  List<Object?> get props => [walletSummary];
}

/// 钱包交易记录加载中状态
class WalletTransactionsLoading extends WalletState {
  final WalletSummary walletSummary;
  final List<TransactionDto> currentTransactions;

  const WalletTransactionsLoading(this.walletSummary, this.currentTransactions);

  @override
  List<Object?> get props => [walletSummary, currentTransactions];
}

/// 钱包交易记录错误状态
class WalletTransactionsError extends WalletState {
  final WalletSummary walletSummary;
  final List<TransactionDto> transactions;
  final String message;

  const WalletTransactionsError(
    this.walletSummary,
    this.transactions,
    this.message,
  );

  @override
  List<Object?> get props => [walletSummary, transactions, message];
}

/// 钱包加载完成状态（包含摘要和交易记录）
class WalletLoaded extends WalletState {
  final WalletSummary walletSummary;
  final List<TransactionDto> transactions;
  final int currentPage;
  final bool isNoMoreData;
  final String? loadMoreError;

  const WalletLoaded(
    this.walletSummary,
    this.transactions,
    this.currentPage,
    this.isNoMoreData, {
    this.loadMoreError,
  });

  @override
  List<Object?> get props => [
        walletSummary,
        transactions,
        currentPage,
        isNoMoreData,
        loadMoreError,
      ];
}

/// 仅加载了交易记录的状态
class WalletTransactionsOnly extends WalletState {
  final List<TransactionDto> transactions;
  final int currentPage;
  final bool isNoMoreData;
  final String? loadMoreError;

  const WalletTransactionsOnly(
    this.transactions,
    this.currentPage,
    this.isNoMoreData, {
    this.loadMoreError,
  });

  @override
  List<Object?> get props => [
        transactions,
        currentPage,
        isNoMoreData,
        loadMoreError,
      ];
}

/// 钱包加载更多中状态
class WalletLoadingMore extends WalletState {
  final WalletSummary walletSummary;
  final List<TransactionDto> transactions;
  final int currentPage;

  const WalletLoadingMore(
    this.walletSummary,
    this.transactions,
    this.currentPage,
  );

  @override
  List<Object?> get props => [
        walletSummary,
        transactions,
        currentPage,
      ];
}

/// 仅交易记录加载更多中状态
class WalletTransactionsLoadingMore extends WalletState {
  final List<TransactionDto> transactions;
  final int currentPage;

  const WalletTransactionsLoadingMore(
    this.transactions,
    this.currentPage,
  );

  @override
  List<Object?> get props => [
        transactions,
        currentPage,
      ];
}
