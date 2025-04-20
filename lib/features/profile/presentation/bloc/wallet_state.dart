import 'package:equatable/equatable.dart';

import '../../domain/entities/wallet_summary.dart';

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
