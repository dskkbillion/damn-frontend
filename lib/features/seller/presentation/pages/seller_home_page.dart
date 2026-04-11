import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dskk_flutter_refactor/app/app_mode.dart';
import 'package:dskk_flutter_refactor/core/services/mode_transition_service.dart';
import 'package:dskk_flutter_refactor/core/utils/price_formatter.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

// 导入国际化
import '../../../../generated/app_localizations.dart';

import '../bloc/seller_home/seller_home_bloc.dart';
import '../bloc/seller_home/seller_home_event.dart';
import '../bloc/seller_home/seller_home_state.dart';
import '../../domain/entities/seller_dashboard_data.dart';
import '../routes/seller_routes.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_state.dart';


/// 卖家中心首页
class SellerHomePage extends ConsumerStatefulWidget {
  const SellerHomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends ConsumerState<SellerHomePage> {
  @override
  void initState() {
    super.initState();
    AppLogger.d('[SellerHomePage] initState called');
    
    // 延迟检查状态，避免在build之前访问context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<SellerHomeBloc>();
      final currentState = bloc.state;
      
      AppLogger.d('[SellerHomePage] Current state: ${currentState.runtimeType}');
      
      // 只有在没有数据时才加载
      if (currentState.dashboardData == null && !currentState.isLoading) {
        AppLogger.d('[SellerHomePage] No data found, dispatching LoadDashboardData');
        bloc.add(const LoadDashboardData());
      } else {
        AppLogger.d('[SellerHomePage] Data already exists or loading, skipping LoadDashboardData');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.d('[SellerHomePage] Build method called');
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        top: true,
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            AppLogger.d('[SellerHomePage] Refresh triggered: Dispatching RefreshDashboardData');
            context.read<SellerHomeBloc>().add(RefreshDashboardData());
            return Future.delayed(const Duration(milliseconds: 500));
          },
          child: BlocBuilder<SellerHomeBloc, SellerHomeState>(
            builder: (context, state) {
              AppLogger.d('[SellerHomePage] BlocBuilder received state: ${state.runtimeType}');
              if (state.isLoading) {
                return LoadingState.list();
              }
              
              if (state.hasError) {
                return EmptyState.error(
                  text: AppLocalizations.of(context)!.seller_home_loading_failed,
                  subText: state.errorMessage,
                  onRetryPressed: () {
                    context.read<SellerHomeBloc>().add(const LoadDashboardData(forceRefresh: true));
                  },
                );
              }
              
              if (state.dashboardData == null) {
                return EmptyState.error(
                  text: AppLocalizations.of(context)!.seller_home_no_data,
                  onRetryPressed: () {
                    context.read<SellerHomeBloc>().add(const LoadDashboardData(forceRefresh: true));
                  },
                );
              }
              
              final dashboardData = state.dashboardData!;
              
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 店铺信息卡片
                    _buildStoreProfileCard(context, state),
                    
                    const SizedBox(height: 16),
                    
                    // 收入信息卡片
                    _buildIncomeCard(context, dashboardData),
                    
                    const SizedBox(height: 16),
                    
                    // 订单概览卡片
                    _buildOrdersCard(context, dashboardData),
                    
                    const SizedBox(height: 16),
                    
                    // 功能列表卡片
                    _buildFunctionsCard(context),
                    
                    const SizedBox(height: 16),
                    
                    // 统计信息卡片
                    if (dashboardData.statistics.weeklyIncome.isNotEmpty)
                      _buildStatisticsCard(context, dashboardData),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  
  // 店铺信息卡片
  Widget _buildStoreProfileCard(BuildContext context, SellerHomeState state) {
    if (state.storeProfile == null) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(AppLocalizations.of(context)!.seller_home_no_store_info),
          ),
        ),
      );
    }

    final profile = state.storeProfile!;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.7),
                  Theme.of(context).primaryColor.withOpacity(0.4),
                ],
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 店铺logo - 点击跳转到店铺公开页面
                    GestureDetector(
                      onTap: () {
                        AppLogger.d('[SellerHomePage] Store logo tapped');
                        AppLogger.d('[SellerHomePage] storeId: ${profile.storeId}');
                        // 使用 storeId 作为 sellerId 跳转
                        context.push('/seller-profile/${profile.storeId}');
                      },
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
                        backgroundImage: profile.logoUrl != null && profile.logoUrl!.isNotEmpty
                            ? NetworkImage(profile.logoUrl!)
                            : null,
                        child: profile.logoUrl == null || profile.logoUrl!.isEmpty
                            ? Icon(
                                Icons.store_rounded,
                                size: 36,
                                color: Theme.of(context).primaryColor,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // 店铺信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  profile.storeName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // #266: 不再用 null 守卫遮盖徽章 —— null 默认按"离线"显示
                              Builder(builder: (context) {
                                final isOnline = profile.onlineFlag ?? false;
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingSm, vertical: 2.0),
                                  decoration: BoxDecoration(
                                    color: isOnline ? AppColors.success : AppColors.textTertiary,
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isOnline ? Icons.circle : Icons.circle_outlined,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isOnline ? AppLocalizations.of(context)!.seller_home_online : AppLocalizations.of(context)!.seller_home_offline,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // 评分和完成率
                          Row(
                            children: [
                              if (profile.averageRating != null) ...[
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${profile.averageRating!.toStringAsFixed(1)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              
                              if (profile.completionRate != null) ...[
                                const Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  AppLocalizations.of(context)!.seller_home_completion_rate(profile.completionRate!.toStringAsFixed(1)),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // 资质标签
                          if (profile.certifications != null && profile.certifications!.isNotEmpty)
                            Wrap(
                              spacing: 4.0,
                              runSpacing: 4.0,
                              children: profile.certifications!
                                  .map((cert) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6.0,
                                          vertical: 2.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.backgroundCard,
                                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                                        ),
                                        child: Text(
                                          cert,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.switch_account_outlined, size: 18),
                    label: Text(AppLocalizations.of(context)!.seller_home_switch_to_buyer),
                    onPressed: () {
                      // 使用模式切换服务触发翻转动画
                      final modeTransitionService = ref.read(modeTransitionServiceProvider);
                      final appModeNotifier = ref.read(appModeProvider.notifier);
                      
                      modeTransitionService.triggerTransition(
                        targetMode: AppMode.buyer,
                        onAnimationComplete: () {
                          // 动画完成后切换模式
                          appModeNotifier.state = AppMode.buyer;
                          // DualModeNavigationShell 会自动处理页面切换
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      // 样式参考 ProfileHeader 的按钮，可以调整
                      foregroundColor: Theme.of(context).primaryColorDark, 
                      backgroundColor: Colors.white.withOpacity(0.9), 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingMd),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 收入信息卡片
  Widget _buildIncomeCard(BuildContext context, dynamic dashboardData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.seller_home_income,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // 导航到数据tab页面
                    context.push('/seller/dashboard');
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    children: [
                      Text(AppLocalizations.of(context)!.seller_home_view_details),
                      const Icon(Icons.arrow_forward_ios, size: 12),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildIncomeItem(AppLocalizations.of(context)!.seller_home_total_income, PriceFormatter.format(dashboardData.income.total)),
                _buildIncomeItem(AppLocalizations.of(context)!.seller_home_today_income, PriceFormatter.format(dashboardData.income.today)),
                _buildIncomeItem(AppLocalizations.of(context)!.seller_home_pending_settlement, PriceFormatter.format(dashboardData.income.pending)),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // 订单概览卡片
  Widget _buildOrdersCard(BuildContext context, dynamic dashboardData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.seller_home_orders,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // 导航到卖家订单列表页面（全部订单）
                    context.push('/seller/orders');
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    children: [
                      Text(AppLocalizations.of(context)!.seller_home_view_all),
                      const Icon(Icons.arrow_forward_ios, size: 12),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOrderStatusItem(
                  context,
                  icon: Icons.receipt_long,
                  label: AppLocalizations.of(context)!.seller_home_orders_all,
                  count: dashboardData.orders.total.toString(),
                  onTap: () => context.push('/seller/orders'),
                ),
                _buildOrderStatusItem(
                  context,
                  icon: Icons.access_time,
                  label: AppLocalizations.of(context)!.seller_home_orders_pending,
                  count: dashboardData.orders.pending.toString(),
                  // 卖家"待处理"= 待交付（映射到 awaitingConfirmation tab）
                  onTap: () => context.push('/seller/orders?status=awaitingConfirmation'),
                ),
                _buildOrderStatusItem(
                  context,
                  icon: Icons.check_circle_outline,
                  label: AppLocalizations.of(context)!.seller_home_orders_completed,
                  count: dashboardData.orders.completed.toString(),
                  onTap: () => context.push('/seller/orders?status=orderCompleted'),
                ),
                _buildOrderStatusItem(
                  context,
                  icon: Icons.cancel_outlined,
                  label: AppLocalizations.of(context)!.seller_home_orders_canceled,
                  count: dashboardData.orders.canceled.toString(),
                  onTap: () => context.push('/seller/orders?status=canceled'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // 功能列表卡片
  Widget _buildFunctionsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.seller_home_functions,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              children: [
                _buildFunctionItem(
                  context,
                  icon: Icons.account_balance_wallet_outlined,
                  label: AppLocalizations.of(context)!.seller_home_wallet,
                  onTap: () => context.goNamed('seller_wallet'),
                ),
                _buildFunctionItem(
                  context,
                  icon: Icons.verified_user,
                  label: AppLocalizations.of(context)!.seller_home_auth_management,
                  onTap: () => context.push(SellerRoutes.authentication),
                ),
                _buildFunctionItem(
                  context,
                  icon: Icons.access_time,
                  label: AppLocalizations.of(context)!.seller_home_time_management,
                  onTap: () => context.push(SellerRoutes.timeManagement),
                ),
                _buildFunctionItem(
                  context,
                  icon: Icons.reply_all,
                  label: AppLocalizations.of(context)!.seller_home_auto_reply,
                  onTap: () => context.push(SellerRoutes.autoReply),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // 统计信息卡片
  Widget _buildStatisticsCard(BuildContext context, dynamic dashboardData) {
    // 提取每周收入数据
    final List<WeeklyIncomeItem> weeklyIncome = 
        List<WeeklyIncomeItem>.from(dashboardData.statistics.weeklyIncome ?? []);
    
    if (weeklyIncome.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text(AppLocalizations.of(context)!.seller_home_no_recent_income)), 
        ),
      );
    }
    
    // 获取最大收入值以计算柱状图高度比例
    final maxAmount = weeklyIncome.fold<double>(
      0.0, 
      (max, item) => (item.amount ?? 0.0) > max ? (item.amount ?? 0.0) : max,
    );
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.seller_home_recent_income,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: maxAmount > 0
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: weeklyIncome
                          .map((item) => Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Tooltip(
                                      message: PriceFormatter.format(item.amount ?? 0.0),
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                        width: double.infinity,
                                        height: (maxAmount > 0 ? (150 * ((item.amount ?? 0.0) / maxAmount)) : 0).toDouble(),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(AppDimensions.radiusSm),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDateLabel(item.date),
                                      style: const TextStyle(fontSize: 10),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    )
                  : Center(
                      child: Text(AppLocalizations.of(context)!.seller_home_no_income_data),
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 收入项目组件
  Widget _buildIncomeItem(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  // 订单状态项组件
  Widget _buildOrderStatusItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingSm),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              count,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 功能项组件
  Widget _buildFunctionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingSm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Text(
                label,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 格式化日期标签
  String _formatDateLabel(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.month}/${date.day}';
    } catch (e) {
      return dateStr;
    }
  }
} 