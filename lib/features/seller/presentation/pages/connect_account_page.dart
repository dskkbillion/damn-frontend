import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/widgets/seller_page_skeleton.dart';

import '../bloc/connect_account/connect_account_bloc.dart';
import '../bloc/connect_account/connect_account_event.dart';
import '../bloc/connect_account/connect_account_state.dart';
import 'stripe_connect_webview_page.dart';
import 'stripe_connect_embedded_page.dart';

/// 卖家收款账户绑定页面
class ConnectAccountPage extends StatefulWidget {
  const ConnectAccountPage({super.key});

  @override
  State<ConnectAccountPage> createState() => _ConnectAccountPageState();
}

class _ConnectAccountPageState extends State<ConnectAccountPage> {
  @override
  void initState() {
    super.initState();
    context.read<ConnectAccountBloc>().add(CheckConnectAccountStatus());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('收款账户'),
      ),
      body: BlocConsumer<ConnectAccountBloc, ConnectAccountState>(
        listener: (context, state) {
          if (state is ConnectAccountSessionReady) {
            _openEmbeddedOnboarding(context, state.clientSecret);
          } else if (state is ConnectAccountOnboardingReady) {
            // fallback: 跳转式 Onboarding
            _openOnboardingWebView(context, state.onboardingUrl);
          }
          if (state is ConnectAccountError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ConnectAccountLoading) {
            return const SellerPageSkeleton(variant: SellerSkeletonVariant.detail);
          }
          if (state is ConnectAccountActive) {
            return _buildActiveState(context, state);
          }
          if (state is ConnectAccountPendingVerification) {
            return _buildPendingState(context, state);
          }
          if (state is ConnectAccountError) {
            return _buildErrorState(context, state);
          }
          // ConnectAccountUnlinked or Initial
          return _buildUnlinkedState(context);
        },
      ),
    );
  }

  /// 未绑定状态 — 引导用户绑定
  Widget _buildUnlinkedState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.backgroundSecondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_outlined,
              size: 40,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '绑定收款账户',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '绑定银行账号，通常只需 1-2 分钟。买家付款会自动结算到您的账户，整个过程由 Stripe 安全处理。',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                context.read<ConnectAccountBloc>().add(CreateConnectAccount());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
              child: const Text(
                '开始绑定',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 审核中状态
  Widget _buildPendingState(BuildContext context, ConnectAccountPendingVerification state) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hourglass_top_rounded,
              size: 40,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '银行账号已绑定',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '银行账号已绑定成功。首次提现时需完成身份验证，通常只需几分钟。',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () {
              context.read<ConnectAccountBloc>().add(RefreshConnectAccountStatus());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('刷新状态'),
          ),
        ],
      ),
    );
  }

  /// 已激活状态
  Widget _buildActiveState(BuildContext context, ConnectAccountActive state) {
    final status = state.accountStatus;
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingXl),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 40,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '收款账户已激活',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 32),
          // 账户摘要卡片
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: AppColors.borderPrimary),
            ),
            child: Column(
              children: [
                _buildStatusRow('收款功能', status.chargesEnabled),
                const Divider(height: 24),
                _buildStatusRow('提款功能', status.payoutsEnabled),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool enabled) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
        ),
        Row(
          children: [
            Icon(
              enabled ? Icons.check_circle : Icons.cancel,
              size: 18,
              color: enabled ? AppColors.success : AppColors.textTertiary,
            ),
            const SizedBox(width: 6),
            Text(
              enabled ? '已开通' : '未开通',
              style: TextStyle(
                fontSize: 14,
                color: enabled ? AppColors.success : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 错误状态
  Widget _buildErrorState(BuildContext context, ConnectAccountError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<ConnectAccountBloc>().add(CheckConnectAccountStatus());
              },
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  /// 打开嵌入式 Onboarding WebView
  Future<void> _openEmbeddedOnboarding(BuildContext context, String clientSecret) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => StripeConnectEmbeddedPage(clientSecret: clientSecret),
      ),
    );

    if (!context.mounted) return;

    // 无论用户是完成还是中途退出，都刷新状态（refresh: true 会查 Stripe API）
    if (result == true) {
      context.read<ConnectAccountBloc>().add(RefreshConnectAccountStatus());
    }
    // result == false 或 null — 用户主动关闭，不刷新
  }

  /// 打开 Onboarding WebView（fallback 跳转式）
  Future<void> _openOnboardingWebView(BuildContext context, String url) async {
    final result = await Navigator.of(context).push<ConnectWebViewResult>(
      MaterialPageRoute(
        builder: (_) => StripeConnectWebViewPage(onboardingUrl: url),
      ),
    );

    if (!context.mounted) return;

    if (result == ConnectWebViewResult.success) {
      // Onboarding 完成，刷新状态
      context.read<ConnectAccountBloc>().add(RefreshConnectAccountStatus());
    } else if (result == ConnectWebViewResult.refresh) {
      // 链接过期，重新获取
      context.read<ConnectAccountBloc>().add(FetchOnboardingLink());
    }
    // cancelled — 不做任何操作，保持当前状态
  }
}
