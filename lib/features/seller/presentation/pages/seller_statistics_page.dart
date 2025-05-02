import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_statistics.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/seller_statistics/seller_statistics_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/seller_statistics/seller_statistics_event.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/seller_statistics/seller_statistics_state.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/widgets/empty_state.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/widgets/loading_state.dart';

/// 卖家数据统计页面
class SellerStatisticsPage extends StatelessWidget {
  const SellerStatisticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                          const Text(
                            '卖家数据',
                            style: TextStyle(
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
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('加载失败: ${state.failure.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<SellerStatisticsBloc>().add(const LoadSellerStatistics());
                      },
                      child: const Text('重试'),
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
        const Text(
          '卖家主页',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPercentCircle('热度值', stats.heatPercent, const Color(0xFFFFB74D)),
            _buildPercentCircle('回复率', stats.recoverPercent, const Color(0xFFFFB74D)),
            _buildPercentCircle('完成率', stats.completePercent, Colors.grey.shade500),
            _buildPercentCircle('好评率', stats.goodPercent, Colors.grey.shade500),
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
                    backgroundColor: Colors.grey.shade200,
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
          style: TextStyle(
            color: Colors.grey.shade700,
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
        const Text(
          '升到下一级',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            child: Column(
              children: [
                _buildUpgradeItem(
                  '成为三级会员卖家${stats.days}天',
                  '${stats.totalDays}/${stats.days}',
                ),
                const Divider(height: 24, thickness: 0.5),
                _buildUpgradeItem(
                  '完成订单${stats.orderNum}笔',
                  '${stats.totalOrderNum}/${stats.orderNum}',
                ),
                const Divider(height: 24, thickness: 0.5),
                _buildUpgradeItem(
                  '盈利${stats.orderPrice.toStringAsFixed(2)}元',
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
          style: TextStyle(
            color: Colors.brown.shade500,
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
        const Text(
          '指标',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildIndicatorItem('总盈利', stats.totalEarnings.toInt().toString()),
                    ),
                    Expanded(
                      child: _buildIndicatorItem('本月盈利', stats.thisMonthTotalEarnings.toInt().toString()),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: _buildIndicatorItem('总订单数', stats.totalOrderNum.toString()),
                    ),
                    Expanded(
                      child: _buildIndicatorItem('活跃订单数', stats.activeOrderNum.toString()),
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
            color: Colors.brown.shade500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
  
  /// 构建待处理部分（未完成订单数、距离下次邀交日）
  Widget _buildPendingSection(BuildContext context, SellerIndexStatistics stats) {
    String earlyTimeText = stats.earlyTime > 0 
        ? '${stats.earlyTime} (最早)' 
        : 'N/A';
    
    String latenessTimeText = stats.latenessTime > 0 
        ? '${stats.latenessTime}' 
        : 'N/A';
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '待处理',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildPendingItem(
                  '未完成订单数',
                  '${stats.pendingOrderNum} (待完成) / ${stats.receiptOrderNum} (回单)',
                ),
                const Divider(height: 30, thickness: 0.5),
                _buildPendingItem(
                  '距离下次邀交日',
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
} 