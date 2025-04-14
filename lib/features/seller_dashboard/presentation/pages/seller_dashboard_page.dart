import 'package:dskk_flutter_refactor/features/seller_dashboard/presentation/providers/seller_dashboard_notifier.dart';
import 'package:dskk_flutter_refactor/features/seller_dashboard/presentation/providers/seller_dashboard_state.dart';
import 'package:dskk_flutter_refactor/features/seller_dashboard/presentation/widgets/indicators_widget.dart';
import 'package:dskk_flutter_refactor/features/seller_dashboard/presentation/widgets/pending_tasks_widget.dart';
import 'package:dskk_flutter_refactor/features/seller_dashboard/presentation/widgets/performance_metrics_widget.dart';
import 'package:dskk_flutter_refactor/features/seller_dashboard/presentation/widgets/upgrade_progress_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import the file where the provider is defined
import '../providers/dashboard_providers.dart';

// Changed to ConsumerStatefulWidget to easily call fetch on init
class SellerDashboardPage extends ConsumerStatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  ConsumerState<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends ConsumerState<SellerDashboardPage> {

  @override
  void initState() {
    super.initState();
    // Fetch data when the page initializes
    // Use addPostFrameCallback to ensure the provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
         ref.read(sellerDashboardNotifierProvider.notifier).fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the state provided by the notifier
    final state = ref.watch(sellerDashboardNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2), // Set background color
      appBar: AppBar(
        // AppBar might need its own background color or elevation adjustment
        // depending on the desired final look.
        backgroundColor: Colors.white, // Example: Set AppBar background to white
        elevation: 0, // Example: Remove AppBar shadow if needed
        title: Text(
          '卖家主页',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.black87 // Ensure title text is visible on white bg
          ),
        ),
      ),
      // Use RefreshIndicator for pull-to-refresh functionality
      body: RefreshIndicator(
         onRefresh: () async {
           await ref.read(sellerDashboardNotifierProvider.notifier).refreshDashboardData();
         },
         child: _buildBody(context, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SellerDashboardState state) {
    switch (state.status) {
      case SellerDashboardStatus.initial:
      case SellerDashboardStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case SellerDashboardStatus.failure:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('加载失败: ${state.failure?.message ?? '未知错误'}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(sellerDashboardNotifierProvider.notifier).fetchDashboardData();
                },
                child: const Text('重试'),
              ),
            ],
          ),
        );
      case SellerDashboardStatus.success:
        if (state.data == null) {
          // Should not happen if status is success, but handle defensively
          return const Center(child: Text('数据为空'));
        }
        final data = state.data!;
        // Use ListView to ensure content scrolls if it overflows
        return ListView(
           padding: const EdgeInsets.all(16.0), // Add overall padding
           children: [
             PerformanceMetricsWidget(
               heatPercent: data.heatPercent,
               recoverPercent: data.recoverPercent,
               completePercent: data.completePercent,
               goodPercent: data.goodPercent,
             ),
             const SizedBox(height: 32), // Increased spacing from 24 to 32
             _buildSectionTitle('升到下一级'),
             UpgradeProgressWidget(
               targetDays: data.days,
               targetOrderNum: data.orderNum,
               targetOrderPrice: data.orderPrice,
               progressDays: data.totalDays,
               progressOrderCount: data.upgradeProgressOrderCount,
               progressOrderPrice: data.totalOrderPrice,
             ),
              const SizedBox(height: 24),
             _buildSectionTitle('指标'),
             IndicatorsWidget(
               totalEarnings: data.totalEarnings,
               thisMonthTotalEarnings: data.thisMonthTotalEarnings,
               overallTotalOrderCount: data.overallTotalOrderCount,
               activeOrderNum: data.activeOrderNum,
             ),
             const SizedBox(height: 24),
              _buildSectionTitle('待处理'),
             PendingTasksWidget(
               pendingOrderNum: data.pendingOrderNum,
               receiptOrderNum: data.receiptOrderNum,
               earlyTime: data.earlyTime,
               latenessTime: data.latenessTime,
             ),
              const SizedBox(height: 24), // Bottom padding
           ],
        );

    }
  }

   // Helper to build section titles consistently
   Widget _buildSectionTitle(String title) {
     return Padding(
       padding: const EdgeInsets.only(bottom: 8.0),
       child: Text(
         title,
         style: Theme.of(context).textTheme.titleMedium?.copyWith(
           fontWeight: FontWeight.bold, // Make title bold
         ),
       ),
     );
   }
} 