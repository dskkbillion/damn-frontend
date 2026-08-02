/// 产品阶段开关。
///
/// 旧现金提现和 Stripe Connect 代码暂时保留，便于未来在独立 cash_earnings
/// 账本与合规能力就绪后恢复；积分 MVP 期间不得向用户展示或开放入口。
abstract final class AppFeatureFlags {
  static const bool sellerCashPayoutsEnabled = false;

  static String? sellerCashRouteRedirect({required String creditsWalletPath}) {
    return sellerCashPayoutsEnabled ? null : creditsWalletPath;
  }
}
