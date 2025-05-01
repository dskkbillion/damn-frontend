import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_authentication_info.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/auth_management/auth_management_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/routes/seller_routes.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/widgets/empty_state.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/widgets/loading_state.dart';

/// 认证管理页面
class AuthManagementPage extends StatelessWidget {
  const AuthManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthManagementBloc>(
      create: (context) {
        final bloc = GetIt.I<AuthManagementBloc>();
        bloc.add(const LoadAuthenticationList());
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('认证管理'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<AuthManagementBloc, AuthManagementState>(
          builder: (innerContext, state) {
            if (state is AuthManagementInitial || state is AuthManagementLoading) {
              return const Center(child: LoadingState());
            } else if (state is AuthManagementError) {
              return EmptyState.error(
                text: '加载失败',
                subText: state.message,
                onRetryPressed: () => innerContext.read<AuthManagementBloc>()
                  .add(const LoadAuthenticationList()),
              );
            } else if (state is AuthManagementEmpty) {
              return const EmptyState(
                text: '暂无认证项目',
                icon: Icons.verified_user_outlined,
              );
            } else if (state is AuthManagementLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  innerContext.read<AuthManagementBloc>()
                    .add(RefreshAuthenticationList());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.submittedAuthList.isNotEmpty)
                          _buildSubmittedAuthSection(innerContext, state.submittedAuthList),
                        const SizedBox(height: 24),
                        _buildAvailableAuthSection(innerContext, state.availableAuthList),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const Center(
                child: Text('未知状态'),
              );
            }
          },
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
            '已认证项目',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...submittedAuthList.map((auth) => _buildAuthItem(context, auth)).toList(),
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
            '开放认证',
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToAuthDetail(context, auth),
        borderRadius: BorderRadius.circular(8),
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
              _buildStatusTag(auth.status),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Colors.grey[400],
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
              color: Colors.white,
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
  Widget _buildStatusTag(AuthenticationStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case AuthenticationStatus.approved:
        backgroundColor = Colors.green[50]!;
        textColor = Colors.green[800]!;
        text = '已认证';
        break;
      case AuthenticationStatus.pending:
        backgroundColor = Colors.orange[50]!;
        textColor = Colors.orange[800]!;
        text = '审核中';
        break;
      case AuthenticationStatus.rejected:
        backgroundColor = Colors.red[50]!;
        textColor = Colors.red[800]!;
        text = '未通过';
        break;
      default:
        backgroundColor = Colors.grey[50]!;
        textColor = Colors.grey[800]!;
        text = '未提交';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
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
        return Colors.blue;
      case AuthenticationType.education:
        return Colors.green;
      case AuthenticationType.profession:
        return Colors.purple;
      case AuthenticationType.company:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// 导航到认证详情页
  void _navigateToAuthDetail(BuildContext context, SellerAuthenticationInfo auth) {
    if (auth.status != AuthenticationStatus.notSubmitted && 
        auth.status != AuthenticationStatus.rejected) {
      context.pushNamed(
        'seller_authentication_detail',
        extra: auth,
      );
    } else {
      context.pushNamed(
        'seller_authentication_apply',
        pathParameters: {'type': auth.type.value.toLowerCase()},
        extra: auth,
      );
    }
  }
} 