import 'package:equatable/equatable.dart';

/// 钱包事件抽象基类
abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

/// 获取钱包摘要信息事件
class FetchWalletSummary extends WalletEvent {
  const FetchWalletSummary();
}

/// 刷新钱包摘要信息事件
class RefreshWalletSummary extends WalletEvent {
  const RefreshWalletSummary();
}

/// 获取钱包交易记录事件
class FetchWalletTransactions extends WalletEvent {
  /// 页码
  final int page;

  /// 每页记录数
  final int pageSize;

  /// 开始日期，格式为YYYY-MM-DD
  final String? startDate;

  /// 结束日期，格式为YYYY-MM-DD
  final String? endDate;

  /// 交易类型，可选值：'income', 'outcome', 'all'(默认)
  final String transactionType;

  const FetchWalletTransactions({
    this.page = 1,
    this.pageSize = 20,
    this.startDate,
    this.endDate,
    this.transactionType = 'all',
  });

  @override
  List<Object?> get props => [page, pageSize, startDate, endDate, transactionType];
}

/// 加载更多钱包交易记录事件
class LoadMoreWalletTransactions extends WalletEvent {
  /// 每页记录数
  final int pageSize;

  /// 开始日期，格式为YYYY-MM-DD
  final String? startDate;

  /// 结束日期，格式为YYYY-MM-DD
  final String? endDate;

  /// 交易类型，可选值：'income', 'outcome', 'all'(默认)
  final String transactionType;

  const LoadMoreWalletTransactions({
    this.pageSize = 20,
    this.startDate,
    this.endDate,
    this.transactionType = 'all',
  });

  @override
  List<Object?> get props => [pageSize, startDate, endDate, transactionType];
}

/// 提交提款申请事件
class SubmitWithdrawal extends WalletEvent {
  final double amount;

  const SubmitWithdrawal({required this.amount});

  @override
  List<Object?> get props => [amount];
}
