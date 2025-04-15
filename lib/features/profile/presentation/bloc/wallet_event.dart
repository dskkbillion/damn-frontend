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
