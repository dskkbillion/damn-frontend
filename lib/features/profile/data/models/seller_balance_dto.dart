import '../../domain/entities/wallet_summary.dart';

/// 卖家余额 DTO —— 对接 `GET /api/wallet/seller/balance`（Stripe 真相源）。
///
/// 后端响应 `data` 形状（详见 docs/dev/wallet_seller_api_contract.md）：
/// ```json
/// { "bound": true, "available": 12345, "pending": 6789, "currency": "usd" }
/// ```
/// ⚠️ `available` / `pending` 单位是 **cents（分）**，展示需 ÷100。
class SellerBalanceDto {
  /// 是否已绑定并激活 Stripe 收款账户。false → 引导绑定，余额恒为 0。
  final bool bound;

  /// 可提现余额（cents）。
  final int availableCents;

  /// 结算中余额（cents）。
  final int pendingCents;

  /// 货币代码（小写，如 "usd"）。
  final String currency;

  const SellerBalanceDto({
    required this.bound,
    required this.availableCents,
    required this.pendingCents,
    required this.currency,
  });

  factory SellerBalanceDto.fromJson(Map<String, dynamic> json) {
    return SellerBalanceDto(
      bound: json['bound'] as bool? ?? false,
      availableCents: _parseInt(json['available']),
      pendingCents: _parseInt(json['pending']),
      currency: (json['currency'] as String?) ?? 'usd',
    );
  }

  /// 映射到通用钱包摘要实体：cents ÷100 转元。
  /// totalIncome 无对应字段（Stripe balance 不含累计收入），保持 null。
  WalletSummary toWalletSummary() {
    return WalletSummary(
      balance: availableCents / 100.0,
      pendingAmount: pendingCents / 100.0,
      totalIncome: null,
      bound: bound,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
