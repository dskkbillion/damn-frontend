import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_statistics.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/seller_statistics/seller_statistics_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/seller_statistics/seller_statistics_event.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/seller_statistics/seller_statistics_state.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/widgets/empty_state.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/widgets/loading_state.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

// 导入国际化
import '../../../../generated/app_localizations.dart';

/// 卖家数据统计页面
class SellerStatisticsPage extends ConsumerWidget {
  const SellerStatisticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (context) => GetIt.I<SellerStatisticsBloc>()..add(const LoadSellerStatistics()),
      child: Scaffold(
        body: BlocBuilder<SellerStatisticsBloc, SellerStatisticsState>(
          builder: (context, state) {
            if (state is SellerStatisticsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SellerStatisticsLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<SellerStatisticsBloc>().add(const RefreshSellerStatistics());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.seller_statistics_title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildPercentSection(context, state.percentStats),
                          const SizedBox(height: 24),
                          _buildUpgradeSection(context, state.upgradeStats),
                          const SizedBox(height: 24),
                          _buildIndicatorsSection(context, state.indexStats),
                          const SizedBox(height: 24),
                          _buildPendingSection(context, state.indexStats),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else if (state is SellerStatisticsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: AppDimensions.spacingLg),
                    Text(AppLocalizations.of(context)!.seller_statistics_loading_failed(state.failure.message)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<SellerStatisticsBloc>().add(const LoadSellerStatistics());
                      },
                      child: Text(AppLocalizations.of(context)!.seller_statistics_retry),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
  
  /// 构建百分比部分（热度值、回复率、完成率、好评率）
  Widget _buildPercentSection(BuildContext context, SellerPercentStatistics stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.seller_statistics_seller_homepage,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPercentCircle(AppLocalizations.of(context)!.seller_statistics_heat_value, stats.heatPercent, AppColors.warning),
            _buildPercentCircle(AppLocalizations.of(context)!.seller_statistics_reply_rate, stats.recoverPercent, AppColors.warning),
            _buildPercentCircle(AppLocalizations.of(context)!.seller_statistics_completion_rate, stats.completePercent, AppColors.textSecondary),
            _buildPercentCircle(AppLocalizations.of(context)!.seller_statistics_positive_rate, stats.goodPercent, AppColors.textSecondary),
          ],
        ),
      ],
    );
  }
  
  /// 构建百分比圆形指标
  Widget _buildPercentCircle(String label, double percent, Color color) {
    return Column(
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  width: 65,
                  height: 65,
                  child: CircularProgressIndicator(
                    value: percent / 100,
                    strokeWidth: 6,
                    backgroundColor: AppColors.borderPrimary,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              Center(
                child: Text(
                  '${percent.toInt()}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
  
  /// 构建升级指标部分（成为三级会员卖家、完成订单、盈利）
  Widget _buildUpgradeSection(BuildContext context, SellerUpgradeStatistics stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.seller_statistics_upgrade_to_next_level,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            boxShadow: [
              BoxShadow(
                color: AppColors.borderSecondary,
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingLg, horizontal: AppDimensions.spacingXl),
            child: Column(
              children: [
                _buildUpgradeItem(
                  AppLocalizations.of(context)!.seller_statistics_become_level3_seller(stats.days.toString()),
                  '${stats.totalDays}/${stats.days}',
                ),
                const Divider(height: 24, thickness: 0.5),
                _buildUpgradeItem(
                  AppLocalizations.of(context)!.seller_statistics_complete_orders(stats.orderNum.toString()),
                  '${stats.totalOrderNum}/${stats.orderNum}',
                ),
                const Divider(height: 24, thickness: 0.5),
                _buildUpgradeItem(
                  AppLocalizations.of(context)!.seller_statistics_profit_amount(stats.orderPrice.toStringAsFixed(2)),
                  '${stats.totalOrderPrice.toStringAsFixed(2)}/${stats.orderPrice.toStringAsFixed(2)}',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  /// 构建升级项目
  Widget _buildUpgradeItem(String title, String progress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        Text(
          progress,
          style: const TextStyle(
            color: AppColors.warning,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
  
  /// 构建指标部分（总盈利、本月盈利、总订单数、活跃订单数）
  Widget _buildIndicatorsSection(BuildContext context, SellerIndexStatistics stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.seller_statistics_indicators,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            boxShadow: [
              BoxShadow(
                color: AppColors.borderSecondary,
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingXl),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildIndicatorItem(AppLocalizations.of(context)!.seller_statistics_total_earnings, stats.totalEarnings.toInt().toString()),
                    ),
                    Expanded(
                      child: _buildIndicatorItem(AppLocalizations.of(context)!.seller_statistics_monthly_earnings, stats.thisMonthTotalEarnings.toInt().toString()),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: _buildIndicatorItem(AppLocalizations.of(context)!.seller_statistics_total_orders, stats.totalOrderNum.toString()),
                    ),
                    Expanded(
                      child: _buildIndicatorItem(AppLocalizations.of(context)!.seller_statistics_active_orders, stats.activeOrderNum.toString()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  /// 构建指标项目
  Widget _buildIndicatorItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
  
  /// 构建待处理部分（未完成订单数、距离下次邀交日）
  Widget _buildPendingSection(BuildContext context, SellerIndexStatistics stats) {
    String earlyTimeText = stats.earlyTime > 0 
        ? '${stats.earlyTime} (${AppLocalizations.of(context)!.seller_statistics_earliest})' 
        : 'N/A';
    
    String latenessTimeText = stats.latenessTime > 0 
        ? '${stats.latenessTime}' 
        : 'N/A';
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.seller_statistics_pending,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            boxShadow: [
              BoxShadow(
                color: AppColors.borderSecondary,
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingXl),
            child: Column(
              children: [
                _buildPendingItem(
                  AppLocalizations.of(context)!.seller_statistics_incomplete_orders,
                  '${stats.pendingOrderNum} (${AppLocalizations.of(context)!.seller_statistics_pending_completion}) / ${stats.receiptOrderNum} (${AppLocalizations.of(context)!.seller_statistics_receipt})',
                ),
                const Divider(height: 30, thickness: 0.5),
                _buildPendingItem(
                  AppLocalizations.of(context)!.seller_statistics_next_delivery_date,
                  '$earlyTimeText / $latenessTimeText',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  /// 构建待处理项目
  Widget _buildPendingItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
} 