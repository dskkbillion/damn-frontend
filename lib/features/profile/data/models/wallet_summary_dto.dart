import '../../domain/entities/wallet_summary.dart';

/// 钱包摘要数据传输对象
class WalletSummaryDto {
  final double balance;
  final double? pendingAmount;
  final double? totalIncome;
  final bool hasBankCard;
  final bool hasPaymentPassword;
  final int recentTransactionsCount;

  /// 是否已绑定并激活 Stripe 收款账户（来自卖家余额接口）。默认 true 兼容旧来源。
  final bool bound;

  const WalletSummaryDto({
    required this.balance,
    this.pendingAmount,
    this.totalIncome,
    this.hasBankCard = false,
    this.hasPaymentPassword = false,
    this.recentTransactionsCount = 0,
    this.bound = true,
  });

  /// 从已映射好的 WalletSummary 实体构造（卖家余额接口走此路径，单位换算已在上游完成）。
  factory WalletSummaryDto.fromWalletSummary(WalletSummary summary) {
    return WalletSummaryDto(
      balance: summary.balance,
      pendingAmount: summary.pendingAmount,
      totalIncome: summary.totalIncome,
      hasBankCard: summary.hasBankCard,
      hasPaymentPassword: summary.hasPaymentPassword,
      recentTransactionsCount: summary.recentTransactionsCount,
      bound: summary.bound,
    );
  }

  /// 从 JSON 映射创建 WalletSummaryDto 实例
  factory WalletSummaryDto.fromJson(Map<String, dynamic> json) {
    return WalletSummaryDto(
      balance: _parseDouble(json['balance'] ?? json['useableAmount'] ?? json['useable_amount']) ?? 0.0,
      pendingAmount: _parseDouble(json['pendingAmount'] ?? json['pending_amount'] ?? json['freezeAmount'] ?? json['freeze_amount']),
      totalIncome: _parseDouble(json['totalIncome'] ?? json['total_income'] ?? json['incomeTotal'] ?? json['income_total']),
      hasBankCard: json['hasBankCard'] ?? json['has_bank_card'] ?? false,
      hasPaymentPassword: json['hasPaymentPassword'] ?? json['has_payment_password'] ?? false,
      recentTransactionsCount: json['recentTransactionsCount'] ?? json['recent_transactions_count'] ?? 0,
    );
  }

  /// 转换为 WalletSummary 实体
  WalletSummary toEntity() {
    return WalletSummary(
      balance: balance,
      pendingAmount: pendingAmount,
      totalIncome: totalIncome,
      hasBankCard: hasBankCard,
      hasPaymentPassword: hasPaymentPassword,
      recentTransactionsCount: recentTransactionsCount,
      bound: bound,
    );
  }

  /// 将 WalletSummaryDto 转换为 JSON 映射
  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      if (pendingAmount != null) 'pendingAmount': pendingAmount,
      if (totalIncome != null) 'totalIncome': totalIncome,
      'hasBankCard': hasBankCard,
      'hasPaymentPassword': hasPaymentPassword,
      'recentTransactionsCount': recentTransactionsCount,
    };
  }

  /// 解析数字类型值，处理字符串和数字类型
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
