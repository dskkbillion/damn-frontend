import 'package:equatable/equatable.dart';

/// 钱包摘要信息实体类
class WalletSummary extends Equatable {
  /// 钱包余额
  final double balance;

  /// 待结算金额
  final double? pendingAmount;

  /// 累计收入
  final double? totalIncome;

  /// 是否绑定银行卡
  final bool hasBankCard;

  /// 支付密码是否已设置
  final bool hasPaymentPassword;

  /// 最近交易记录数量
  final int recentTransactionsCount;

  /// 是否已绑定并激活 Stripe 收款账户。false → UI 引导绑定。
  /// 默认 true 以兼容旧 member 钱包来源（无此概念）。
  final bool bound;

  const WalletSummary({
    required this.balance,
    this.pendingAmount,
    this.totalIncome,
    this.hasBankCard = false,
    this.hasPaymentPassword = false,
    this.recentTransactionsCount = 0,
    this.bound = true,
  });

  @override
  List<Object?> get props => [
        balance,
        pendingAmount,
        totalIncome,
        hasBankCard,
        hasPaymentPassword,
        recentTransactionsCount,
        bound,
      ];
}
