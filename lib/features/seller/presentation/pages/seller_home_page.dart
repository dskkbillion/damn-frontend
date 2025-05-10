import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dskk_flutter_refactor/app/app_mode.dart';

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
    print('[SellerHomePage] initState: Dispatching LoadDashboardData');
    context.read<SellerHomeBloc>().add(const LoadDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    print('[SellerHomePage] Build method called');
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        top: true,
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            print('[SellerHomePage] Refresh triggered: Dispatching RefreshDashboardData');
            context.read<SellerHomeBloc>().add(RefreshDashboardData());
            return Future.delayed(const Duration(milliseconds: 500));
          },
          child: BlocBuilder<SellerHomeBloc, SellerHomeState>(
            builder: (context, state) {
              print('[SellerHomePage] BlocBuilder received state: ${state.runtimeType}');
              if (state.isLoading) {
                return LoadingState.list();
              }
              
              if (state.hasError) {
                return EmptyState.error(
                  text: '加载失败',
                  subText: state.errorMessage,
                  onRetryPressed: () {
                    context.read<SellerHomeBloc>().add(const LoadDashboardData(forceRefresh: true));
                  },
                );
              }
              
              if (state.dashboardData == null) {
                return EmptyState.error(
                  text: '暂无数据',
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
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('暂无店铺信息'),
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
                    // 店铺logo
                    CircleAvatar(
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
                              if (profile.onlineFlag != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                  decoration: BoxDecoration(
                                    color: profile.onlineFlag! ? Colors.green : Colors.grey,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        profile.onlineFlag! ? Icons.circle : Icons.circle_outlined,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        profile.onlineFlag! ? '在线' : '离线',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                                  '完成率 ${profile.completionRate!.toStringAsFixed(1)}%',
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
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(4.0),
                                        ),
                                        child: Text(
                                          cert,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Theme.of(context).primaryColor,
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
                    label: const Text('切换到买家模式'),
                    onPressed: () {
                      // 更新状态
                      ref.read(appModeProvider.notifier).state = AppMode.buyer;
                      // 执行导航
                      try {
                        context.go('/profile');
                      } catch (e) {
                        print('Error navigating to /profile: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('无法切换到买家模式: $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      // 样式参考 ProfileHeader 的按钮，可以调整
                      foregroundColor: Theme.of(context).primaryColorDark, 
                      backgroundColor: Colors.white.withOpacity(0.9), 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 设置按钮
          Positioned(
            top: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.go(SellerRoutes.storeSettings),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
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
                const Text(
                  '收入',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: 导航到收入明细页面
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Row(
                    children: [
                      Text('查看明细'),
                      Icon(Icons.arrow_forward_ios, size: 12),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildIncomeItem('总收入', '¥${dashboardData.income.total.toStringAsFixed(2)}'),
                _buildIncomeItem('今日收入', '¥${dashboardData.income.today.toStringAsFixed(2)}'),
                _buildIncomeItem('待结算', '¥${dashboardData.income.pending.toStringAsFixed(2)}'),
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
                const Text(
                  '订单',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // 导航到订单列表
                    context.read<SellerHomeBloc>().add(const NavigateToOrders());
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Row(
                    children: [
                      Text('查看全部'),
                      Icon(Icons.arrow_forward_ios, size: 12),
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
                  label: '全部',
                  count: dashboardData.orders.total.toString(),
                  onTap: () => context.read<SellerHomeBloc>().add(const NavigateToOrders()),
                ),
                _buildOrderStatusItem(
                  context,
                  icon: Icons.access_time,
                  label: '待处理',
                  count: dashboardData.orders.pending.toString(),
                  onTap: () => context.read<SellerHomeBloc>().add(const NavigateToOrders(orderType: 'pending')),
                ),
                _buildOrderStatusItem(
                  context,
                  icon: Icons.check_circle,
                  label: '已完成',
                  count: dashboardData.orders.completed.toString(),
                  onTap: () => context.read<SellerHomeBloc>().add(const NavigateToOrders(orderType: 'completed')),
                ),
                _buildOrderStatusItem(
                  context,
                  icon: Icons.cancel,
                  label: '已取消',
                  count: dashboardData.orders.canceled.toString(),
                  onTap: () => context.read<SellerHomeBloc>().add(const NavigateToOrders(orderType: 'canceled')),
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
            const Text(
              '功能',
              style: TextStyle(
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
                  label: '钱包',
                  onTap: () => context.go('/seller/wallet'),
                ),
                _buildFunctionItem(
                  context,
                  icon: Icons.verified_user,
                  label: '认证管理',
                  onTap: () => context.go(SellerRoutes.authentication),
                ),
                _buildFunctionItem(
                  context,
                  icon: Icons.access_time,
                  label: '时间管理',
                  onTap: () => context.go(SellerRoutes.timeManagement),
                ),
                _buildFunctionItem(
                  context,
                  icon: Icons.reply_all,
                  label: '自动回复',
                  onTap: () => context.go(SellerRoutes.autoReply),
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
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('暂无近期收入数据')), 
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
            const Text(
              '近期收入',
              style: TextStyle(
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
                                      message: '¥${(item.amount ?? 0.0).toStringAsFixed(2)}',
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                        width: double.infinity,
                                        height: (maxAmount > 0 ? (150 * ((item.amount ?? 0.0) / maxAmount)) : 0).toDouble(),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor.withOpacity(0.7),
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(4.0),
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
                  : const Center(
                      child: Text('暂无收入数据'),
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
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
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
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
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
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
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