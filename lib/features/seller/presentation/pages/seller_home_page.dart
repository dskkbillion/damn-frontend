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

import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/core/network/core_dio_client.dart';

import '../bloc/seller_home/seller_home_bloc.dart';
import '../bloc/seller_home/seller_home_event.dart';
import '../bloc/seller_home/seller_home_state.dart';
import '../../domain/entities/seller_dashboard_data.dart';
import '../../data/datasources/stripe_connect_remote_data_source.dart';
import '../routes/seller_routes.dart';
import '../widgets/empty_state.dart';
import '../widgets/seller_home_skeleton.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';


/// 卖家中心首页
class SellerHomePage extends ConsumerStatefulWidget {
  const SellerHomePage({super.key});

  @override
  ConsumerState<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends ConsumerState<SellerHomePage> {
  // null = 还没查完；true = 未绑定；false = 已绑定或查询失败
  bool? _stripeUnlinked;

  @override
  void initState() {
    super.initState();
    AppLogger.d('[SellerHomePage] initState called');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<SellerHomeBloc>();
      final currentState = bloc.state;

      AppLogger.d('[SellerHomePage] Current state: ${currentState.runtimeType}');

      if (currentState.dashboardData == null && !currentState.isLoading) {
        AppLogger.d('[SellerHomePage] No data found, dispatching LoadDashboardData');
        bloc.add(const LoadDashboardData());
      } else {
        AppLogger.d('[SellerHomePage] Data already exists or loading, skipping LoadDashboardData');
      }

      _checkStripeAccountStatus();
    });
  }

  Future<void> _checkStripeAccountStatus() async {
    try {
      final dio = GetIt.I<CoreDioClient>().dio;
      final dataSource = StripeConnectRemoteDataSourceImpl(dio);
      final status = await dataSource.getAccountStatus();
      if (mounted) {
        setState(() {
          _stripeUnlinked = status.status == ConnectStatus.notCreated;
        });
      }
    } catch (_) {
      // 查询失败不影响主页展示，静默忽略
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.d('[SellerHomePage] Build method called');
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: GlassBackdrop(
        child: SafeArea(
          top: true,
          bottom: false,
          child: RefreshIndicator(
          onRefresh: () async {
            AppLogger.d('[SellerHomePage] Refresh triggered: Dispatching RefreshDashboardData');
            context.read<SellerHomeBloc>().add(const RefreshDashboardData());
            return Future.delayed(const Duration(milliseconds: 500));
          },
          child: BlocBuilder<SellerHomeBloc, SellerHomeState>(
            builder: (context, state) {
              AppLogger.d('[SellerHomePage] BlocBuilder received state: ${state.runtimeType}');
              if (state.isLoading) {
                return const SellerHomeSkeleton();
              }
              
              if (state.hasError) {
                return EmptyState.error(
                  text: AppLocalizations.of(context).seller_home_loading_failed,
                  subText: state.errorMessage,
                  onRetryPressed: () {
                    context.read<SellerHomeBloc>().add(const LoadDashboardData(forceRefresh: true));
                  },
                );
              }
              
              if (state.dashboardData == null) {
                return EmptyState.error(
                  text: AppLocalizations.of(context).seller_home_no_data,
                  onRetryPressed: () {
                    context.read<SellerHomeBloc>().add(const LoadDashboardData(forceRefresh: true));
                  },
                );
              }
              
              final dashboardData = state.dashboardData!;
              
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  left: AppDimensions.spacingLg,
                  right: AppDimensions.spacingLg,
                  bottom: GlassNavigationMetrics.contentBottomInset(context) +
                      AppDimensions.spacingXl,
                ),
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
                    
                    // 未绑定收款账户提示
                    if (_stripeUnlinked == true) ...[
                      _buildStripeUnlinkedBanner(context),
                      const SizedBox(height: 16),
                    ],

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
      ),
    );
  }
  
  // 店铺信息卡片
  Widget _buildStoreProfileCard(BuildContext context, SellerHomeState state) {
    if (state.storeProfile == null) {
      return GlassCard(
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          child: Center(
            child: Text(AppLocalizations.of(context).seller_home_no_store_info),
          ),
        ),
      );
    }

    final profile = state.storeProfile!;

    return GlassCard(
      margin: const EdgeInsets.only(top: AppDimensions.spacingMd),
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      tintColor: Theme.of(context).primaryColor,
      tintOpacity: 0.76,
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
                        radius: 35,
                        backgroundColor: AppColors.backgroundCard,
                        backgroundImage: profile.logoUrl != null && profile.logoUrl!.isNotEmpty
                            ? NetworkImage(profile.logoUrl!)
                            : null,
                        child: profile.logoUrl == null || profile.logoUrl!.isEmpty
                            ? Icon(
                                Icons.store_rounded,
                                size: 35,
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
                          Text(
                            profile.storeName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Builder(builder: (context) {
                            final isOnline = profile.onlineFlag ?? false;
                            return Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isOnline
                                        ? AppColors.success
                                        : AppColors.textTertiary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isOnline
                                      ? AppLocalizations.of(context)
                                          .seller_home_online
                                      : AppLocalizations.of(context)
                                          .seller_home_offline,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.onPrimary
                                        .withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            );
                          }),
                          const SizedBox(height: 8),
                          
                          // 评分和完成率
                          Row(
                            children: [
                              if (profile.averageRating != null) ...[
                                const Icon(Icons.star, color: AppColors.warning, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  profile.averageRating!.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: AppColors.onPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],

                              if (profile.completionRate != null) ...[
                                const Icon(Icons.check_circle_outline, color: AppColors.onPrimary, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  AppLocalizations.of(context).seller_home_completion_rate(profile.completionRate!.toStringAsFixed(1)),
                                  style: const TextStyle(
                                    color: AppColors.onPrimary,
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
                    label: Text(AppLocalizations.of(context).seller_home_switch_to_buyer),
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
                      backgroundColor: AppColors.onPrimary.withValues(alpha: 0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
      ),
    );
  }
  
  // 收入信息卡片
  Widget _buildIncomeCard(BuildContext context, dynamic dashboardData) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).seller_home_income,
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
                      Text(AppLocalizations.of(context).seller_home_view_details),
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
                _buildIncomeItem(AppLocalizations.of(context).seller_home_total_income, PriceFormatter.format(dashboardData.income.total)),
                _buildIncomeItem(AppLocalizations.of(context).seller_home_today_income, PriceFormatter.format(dashboardData.income.today)),
                _buildIncomeItem(AppLocalizations.of(context).seller_home_pending_settlement, PriceFormatter.format(dashboardData.income.pending)),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // 订单概览卡片
  Widget _buildOrdersCard(BuildContext context, dynamic dashboardData) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).seller_home_orders,
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
                      Text(AppLocalizations.of(context).seller_home_view_all),
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
                  label: AppLocalizations.of(context).seller_home_orders_all,
                  count: dashboardData.orders.total.toString(),
                  onTap: () => context.push('/seller/orders'),
                ),
                _buildOrderStatusItem(
                  context,
                  icon: Icons.access_time,
                  label: AppLocalizations.of(context).seller_home_orders_pending,
                  count: dashboardData.orders.pending.toString(),
                  // 卖家"待处理"= 待接单（映射到 awaitingStart tab）
                  onTap: () => context.push('/seller/orders?status=awaitingStart'),
                ),
                _buildOrderStatusItem(
                  context,
                  icon: Icons.check_circle_outline,
                  label: AppLocalizations.of(context).seller_home_orders_completed,
                  count: dashboardData.orders.completed.toString(),
                  onTap: () => context.push('/seller/orders?status=orderCompleted'),
                ),
                _buildOrderStatusItem(
                  context,
                  icon: Icons.cancel_outlined,
                  label: AppLocalizations.of(context).seller_home_orders_canceled,
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
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).seller_home_functions,
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
                  label: AppLocalizations.of(context).seller_home_wallet,
                  onTap: () => context.goNamed('seller_wallet'),
                ),
                _buildFunctionItem(
                  context,
                  icon: Icons.account_balance_outlined,
                  label: '收款账户',
                  onTap: () => context.push('/seller/connect-account'),
                ),
                // TODO(#306): 认证功能暂未完善，隐藏入口
                // _buildFunctionItem(
                //   context,
                //   icon: Icons.verified_user,
                //   label: AppLocalizations.of(context)!.seller_home_auth_management,
                //   onTap: () => context.push(SellerRoutes.authentication),
                // ),
                _buildFunctionItem(
                  context,
                  icon: Icons.access_time,
                  label: AppLocalizations.of(context).seller_home_time_management,
                  onTap: () => context.push(SellerRoutes.timeManagement),
                ),
                _buildFunctionItem(
                  context,
                  icon: Icons.reply_all,
                  label: AppLocalizations.of(context).seller_home_auto_reply,
                  onTap: () => context.push(SellerRoutes.autoReply),
                ),
                _buildFunctionItem(
                  context,
                  icon: Icons.assignment_return_outlined,
                  label: '售后审核',
                  onTap: () => context.push(SellerRoutes.afterSalesReview),
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
      return GlassCard(
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          child: Center(child: Text(AppLocalizations.of(context).seller_home_no_recent_income)), 
        ),
      );
    }
    
    // 获取最大收入值以计算柱状图高度比例
    final maxAmount = weeklyIncome.fold<double>(
      0.0, 
      (max, item) => (item.amount ?? 0.0) > max ? (item.amount ?? 0.0) : max,
    );
    
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).seller_home_recent_income,
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
                      child: Text(AppLocalizations.of(context).seller_home_no_income_data),
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

  // 未绑定收款账户提示 banner（#385 延迟绑定：发布商品不强制，首次提现前提示）
  Widget _buildStripeUnlinkedBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(SellerRoutes.connectAccount),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(Icons.account_balance_outlined, color: AppColors.warning, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '绑定收款账户后才能接收买家付款，点击立即绑定',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.warning,
                  height: 1.4,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.warning, size: 18),
          ],
        ),
      ),
    );
  }
}
