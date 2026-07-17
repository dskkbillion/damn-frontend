import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import '../bloc/connect_account/connect_account_bloc.dart';
import '../bloc/connect_account/connect_account_event.dart';
import '../bloc/connect_account/connect_account_state.dart';

/// 快速绑定收款账户 bottom sheet（#385）
/// 1~2步完成绑定，利用 Stripe deferred onboarding 延迟 KYC。
/// 创建收款账户后，必须完成 Stripe 托管的身份验证并通过审核才能提现。
class QuickConnectSheet extends StatefulWidget {
  const QuickConnectSheet({super.key});

  @override
  State<QuickConnectSheet> createState() => _QuickConnectSheetState();
}

class _QuickConnectSheetState extends State<QuickConnectSheet> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectAccountBloc, ConnectAccountState>(
      listener: (context, state) {
        if (state is ConnectAccountSessionReady ||
            state is ConnectAccountOnboardingReady ||
            state is ConnectAccountPendingVerification ||
            state is ConnectAccountActive) {
          // 账户已创建/绑定，关闭 sheet 并通知成功
          Navigator.of(context).pop(true);
        } else if (state is ConnectAccountError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is ConnectAccountLoading) {
          setState(() => _isLoading = true);
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: AppDimensions.spacingXl,
          right: AppDimensions.spacingXl,
          top: AppDimensions.spacingXl,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppDimensions.spacingXl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题行
            Row(
              children: [
                const Icon(Icons.account_balance_outlined, size: 24),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '绑定收款账户',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '绑定后将进入 Stripe 身份验证。资料审核通过后即可提现。',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Stripe 安全标识
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
                vertical: AppDimensions.spacingSm,
              ),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline, size: 14, color: AppColors.textSecondary),
                  SizedBox(width: 6),
                  Text(
                    '由 Stripe 安全处理，信息加密传输',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 开始绑定按钮（触发 Stripe Connect Onboarding）
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        context.read<ConnectAccountBloc>().add(CreateConnectAccount());
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('开始绑定', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
