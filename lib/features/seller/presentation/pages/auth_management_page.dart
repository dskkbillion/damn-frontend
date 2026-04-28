import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_authentication_info.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/auth_management/auth_management_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/widgets/empty_state.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/widgets/loading_state.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

/// 认证管理页面
class AuthManagementPage extends StatefulWidget {
  const AuthManagementPage({super.key});

  @override
  State<AuthManagementPage> createState() => _AuthManagementPageState();
}

class _AuthManagementPageState extends State<AuthManagementPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthManagementBloc>(
      create: (context) {
        final bloc = GetIt.I<AuthManagementBloc>();
        bloc.add(const LoadAuthenticationList());
        return bloc;
      },
      child: Builder(
        builder: (innerContext) => Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(innerContext).seller_auth_management_title ?? 'Authentication Management'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.goNamed('seller_home');
                }
              },
            ),
          ),
          body: BlocBuilder<AuthManagementBloc, AuthManagementState>(
            builder: (blocContext, state) {
              if (state is AuthManagementInitial || state is AuthManagementLoading) {
                return const Center(child: LoadingState());
              } else if (state is AuthManagementError) {
                return _buildErrorState(blocContext, state.message);
              } else if (state is AuthManagementEmpty) {
                return EmptyState(
                  text: AppLocalizations.of(innerContext).seller_auth_management_no_items ?? 'No authentication items',
                  icon: Icons.verified_user_outlined,
                );
              } else if (state is AuthManagementLoaded) {
                return RefreshIndicator(
                  onRefresh: () async {
                    blocContext.read<AuthManagementBloc>()
                      .add(const RefreshAuthenticationList());
                  },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (state.submittedAuthList.isNotEmpty)
                            _buildSubmittedAuthSection(blocContext, state.submittedAuthList),
                          const SizedBox(height: 24),
                          _buildAvailableAuthSection(blocContext, state.availableAuthList),
                        ],
                    ),
                  ),
                ),
              );
              } else {
                return Center(
                  child: Text(AppLocalizations.of(innerContext).seller_auth_management_unknown_status ?? 'Unknown status'),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  /// 构建已提交认证项目列表
  Widget _buildSubmittedAuthSection(
    BuildContext context,
    List<SellerAuthenticationInfo> submittedAuthList,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            AppLocalizations.of(context).seller_auth_management_certified_items ?? 'Certified Items',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...submittedAuthList.map((auth) => _buildAuthItem(context, auth)),
      ],
    );
  }

  /// 构建可申请认证项目列表
  Widget _buildAvailableAuthSection(
    BuildContext context,
    List<SellerAuthenticationInfo> availableAuthList,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            AppLocalizations.of(context).seller_auth_management_open_certification ?? 'Available Certifications',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 20,
            childAspectRatio: 0.8,
          ),
          itemCount: availableAuthList.length,
          itemBuilder: (context, index) => _buildAuthGridItem(
            context,
            availableAuthList[index],
          ),
        ),
      ],
    );
  }

  /// 构建认证项目列表项
  Widget _buildAuthItem(BuildContext context, SellerAuthenticationInfo auth) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        boxShadow: const [
          BoxShadow(
            color: AppColors.borderSecondary,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToAuthDetail(context, auth),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  auth.name,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              _buildStatusTag(context, auth.status),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建认证项目网格项
  Widget _buildAuthGridItem(BuildContext context, SellerAuthenticationInfo auth) {
    return InkWell(
      onTap: () => _navigateToAuthDetail(context, auth),
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _getAuthTypeColor(auth.type),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getAuthTypeIcon(auth.type),
              color: AppColors.onPrimary,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            auth.name,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 构建状态标签
  Widget _buildStatusTag(BuildContext context, AuthenticationStatus status) {
    final l10n = AppLocalizations.of(context);
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case AuthenticationStatus.approved:
        backgroundColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        text = l10n.seller_auth_management_certified ?? 'Certified';
        break;
      case AuthenticationStatus.pending:
        backgroundColor = AppColors.warning.withValues(alpha: 0.1);
        textColor = AppColors.warning;
        text = l10n.seller_auth_management_pending ?? 'Pending';
        break;
      case AuthenticationStatus.rejected:
        backgroundColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        text = l10n.seller_auth_management_rejected ?? 'Rejected';
        break;
      default:
        backgroundColor = AppColors.backgroundSecondary;
        textColor = AppColors.textSecondary;
        text = l10n.seller_auth_management_not_submitted ?? 'Not Submitted';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 获取认证类型图标
  IconData _getAuthTypeIcon(AuthenticationType type) {
    switch (type) {
      case AuthenticationType.idCard:
        return Icons.person;
      case AuthenticationType.education:
        return Icons.school;
      case AuthenticationType.profession:
        return Icons.work;
      case AuthenticationType.company:
        return Icons.business;
      default:
        return Icons.verified_user;
    }
  }

  /// 获取认证类型颜色
  Color _getAuthTypeColor(AuthenticationType type) {
    switch (type) {
      case AuthenticationType.idCard:
        return AppColors.info;
      case AuthenticationType.education:
        return AppColors.success;
      case AuthenticationType.profession:
        return Colors.purple;
      case AuthenticationType.company:
        return AppColors.info;
      default:
        return AppColors.textTertiary;
    }
  }

  /// 构建错误状态组件
  Widget _buildErrorState(BuildContext context, String errorMessage) {
    final l10n = AppLocalizations.of(context);
    // 判断错误类型
    bool isTimeoutError = errorMessage.contains('超时') || 
                         errorMessage.contains('timeout') ||
                         errorMessage.contains('系统请求超时');
    bool isNetworkError = errorMessage.contains('网络') || 
                         errorMessage.contains('network') ||
                         errorMessage.contains('connection');
    
    String title;
    String subtitle;
    List<String> suggestions = [];
    
    if (isTimeoutError) {
      title = l10n.seller_auth_management_server_timeout ?? 'Server Timeout';
      subtitle = l10n.seller_auth_management_server_timeout_desc ?? 'The server is taking too long to respond';
      suggestions = [
        l10n.seller_auth_management_check_network ?? 'Check network connection',
        l10n.seller_auth_management_wait_retry ?? 'Wait and retry',
        l10n.seller_auth_management_contact_support ?? 'Contact support',
      ];
    } else if (isNetworkError) {
      title = l10n.seller_auth_management_network_error ?? 'Network Error';
      subtitle = l10n.seller_auth_management_network_error_desc ?? 'Unable to connect to the network';
      suggestions = [
        l10n.seller_auth_management_check_wifi ?? 'Check WiFi connection',
        l10n.seller_auth_management_switch_network ?? 'Switch network',
        l10n.seller_auth_management_restart_app ?? 'Restart app',
      ];
    } else {
      title = l10n.seller_auth_management_loading_failed ?? 'Loading Failed';
      subtitle = errorMessage.isNotEmpty ? errorMessage : (l10n.seller_auth_management_unknown_error ?? 'Unknown error occurred');
      suggestions = [
        l10n.seller_auth_management_check_connection ?? 'Check connection',
        l10n.seller_auth_management_try_later ?? 'Try again later',
        l10n.seller_auth_management_contact_tech ?? 'Contact technical support',
      ];
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isTimeoutError ? Icons.timer_off : Icons.error_outline,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingLg),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                border: Border.all(color: AppColors.borderPrimary),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.seller_auth_management_troubleshooting ?? 'Troubleshooting Steps',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...suggestions.map((suggestion) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      suggestion,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.read<AuthManagementBloc>()
                    .add(const LoadAuthenticationList()),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.seller_auth_management_reload ?? 'Reload'),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.goNamed('seller_home');
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: Text(l10n.seller_auth_management_back ?? 'Back'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 导航到认证详情页
  void _navigateToAuthDetail(BuildContext context, SellerAuthenticationInfo auth) {
    // 如果认证已经提交过（非未提交状态），且不是被拒绝的状态，应该跳转到状态页
    final shouldShowStatus = auth.status == AuthenticationStatus.pending || 
                           auth.status == AuthenticationStatus.approved;
    
    if (shouldShowStatus) {
      context.pushNamed(
        'sellerAuthenticationDetail',
        pathParameters: {'type': auth.type.value.toLowerCase()},
        extra: auth,
      );
    } else {
      // 只有未提交或被拒绝的认证才能重新申请
      context.pushNamed(
        'sellerAuthenticationApply',
        pathParameters: {'type': auth.type.value.toLowerCase()},
        extra: auth,
      ).then((result) {
        if (result == true && context.mounted) {
          context.read<AuthManagementBloc>().add(const RefreshAuthenticationList());
        }
      });
    }
  }
} 