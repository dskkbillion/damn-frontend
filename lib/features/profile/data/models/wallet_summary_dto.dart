import '../../domain/entities/wallet_summary.dart';

/// 钱包摘要数据传输对象
class WalletSummaryDto {
  final double balance;
  final double? pendingAmount;
  final double? totalIncome;
  final bool hasBankCard;
  final bool hasPaymentPassword;
  final int recentTransactionsCount;

  const WalletSummaryDto({
    required this.balance,
    this.pendingAmount,
    this.totalIncome,
    this.hasBankCard = false,
    this.hasPaymentPassword = false,
    this.recentTransactionsCount = 0,
  });

  /// 从 JSON 映射创建 WalletSummaryDto 实例
  factory WalletSummaryDto.fromJson(Map<String, dynamic> json) {
    return WalletSummaryDto(
      balance: _parseDouble(json['balance']) ?? 0.0,
      pendingAmount: _parseDouble(json['pendingAmount'] ?? json['pending_amount']),
      totalIncome: _parseDouble(json['totalIncome'] ?? json['total_income']),
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
