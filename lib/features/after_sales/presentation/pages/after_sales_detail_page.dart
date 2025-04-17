import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc

import '../bloc/after_sales_bloc.dart'; // Import Bloc, Event, State
import '../../domain/entities/after_sales_application.dart'; // Import Entity
// Correct import path for DI container if using getIt directly (less common in UI)
import '../../../../app/di/injection_container.dart';


/// 售后详情页面
class AfterSalesDetailPage extends StatefulWidget { // Changed to StatefulWidget
  /// 预期接收售后申请 ID 或订单 ID
  final String id;

  const AfterSalesDetailPage({
    super.key,
    required this.id, // 接收 ID
  });

  @override
  State<AfterSalesDetailPage> createState() => _AfterSalesDetailPageState();
}

class _AfterSalesDetailPageState extends State<AfterSalesDetailPage> {

  @override
  void initState() {
    super.initState();
    // Trigger loading the details when the page initializes
    // Assuming AfterSalesBloc is provided higher up in the widget tree or via routing arguments
    // Option 1: If provided via BlocProvider ancestor
    // context.read<AfterSalesBloc>().add(LoadAfterSalesDetail(id: widget.id));

    // Option 2: If needing to get it directly (less ideal, assumes Bloc is registered)
    // getIt<AfterSalesBloc>().add(LoadAfterSalesDetail(id: widget.id));

    // We need to ensure the Bloc is actually available. For now, let's assume it is.
    // Let's use context.read for now, assuming a BlocProvider exists above.
     // IMPORTANT: This requires a BlocProvider<AfterSalesBloc> wrapping the route
     //            or this widget itself.
     // We will need to adjust the navigation in OrderListPage to include this.
    // BlocProvider.of<AfterSalesBloc>(context, listen: false).add(LoadAfterSalesDetail(id: widget.id));
     print('[AfterSalesDetailPage] initState: Triggering LoadAfterSalesDetail for id: ${widget.id}');
     // Deferring the add event slightly to ensure context is fully available might be safer in some cases
     // WidgetsBinding.instance.addPostFrameCallback((_) {
     //   if (mounted) {
          // context.read<AfterSalesBloc>().add(LoadAfterSalesDetail(id: widget.id));
     //   }
     // });
      // Let's try adding it directly for now. If issues arise, reconsider.
      // We still need to PROVIDE the Bloc instance first.

  }


  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    // --- Move BlocProvider to wrap the Scaffold ---
    return BlocProvider<AfterSalesBloc>(
      create: (context) => getIt<AfterSalesBloc>()..add(LoadAfterSalesDetail(id: widget.id)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('售后详情'),
        ),
        body: BlocBuilder<AfterSalesBloc, AfterSalesState>(
          builder: (context, state) {
            print('[AfterSalesDetailPage] BlocBuilder received state: ${state.runtimeType}');

            // Show loading indicator only if loading this specific ID
            if (state is AfterSalesDetailLoading && state.loadingId == widget.id) {
              return const Center(child: CircularProgressIndicator());
            }
            // Show error specific to this ID if loading failed
            if (state is AfterSalesDetailError && state.id == widget.id) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('加载失败: ${state.errorMessage}'), // Use errorMessage
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                         context.read<AfterSalesBloc>().add(LoadAfterSalesDetail(id: widget.id));
                      },
                      child: const Text('重试'),
                    )
                  ],
                ),
              );
            }

            // Handle Loaded state
            if (state is AfterSalesDetailLoaded) {
              final application = state.application;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStatusTimeline(context, application),
                    const SizedBox(height: 16.0),
                    _buildRefundInfoCard(context, colorScheme, textTheme, application),
                    const SizedBox(height: 24.0),
                  ],
                ),
              );
            }

            // Default/Initial state or unexpected state
            return const Center(child: Text('正在初始化...'));
          },
        ),
        bottomNavigationBar: BlocBuilder<AfterSalesBloc, AfterSalesState>(
          builder: (context, state) {
            if (state is AfterSalesDetailLoaded) {
              return _buildBottomActionBar(context, colorScheme, state.application);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // Placeholder for Status Timeline - Modify to accept data
  Widget _buildStatusTimeline(BuildContext context, AfterSalesApplication application) {
    // ... (implementation using application data)
    return Card(
      // ... (rest of the card structure)
       child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                 // Use real data
                 application.refundStateText ?? application.refundState, // Example
                 style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
               ),
              // TODO: Add countdown logic based on state and time
               const SizedBox(height: 4),
               Text(
                 '还剩1天11时58分', // Placeholder countdown
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.secondary),
               ),
               const SizedBox(height: 8),
               Text(
                 application.auditRemark ?? '请耐心等待处理...', // Example using audit remark
                 style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.secondary),
               ),
               const SizedBox(height: 16),
               Container(
                  height: 50,
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: const Text('状态时间轴占位符'),
               ),
            ],
          ),
        ),
    );
  }

  // Placeholder for Refund Information Card - Modify to accept data
  Widget _buildRefundInfoCard(BuildContext context, ColorScheme colorScheme, TextTheme textTheme, AfterSalesApplication application) {
      // ... (implementation using application data)
      return Card(
      // ... (rest of the card structure)
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text('退款信息', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), // Section title
             const SizedBox(height: 16.0),
             Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Image
                  Container(
                     width: 60, height: 60,
                     color: Colors.grey[200],
                     child: application.productImage != null && application.productImage!.isNotEmpty
                       ? Image.network(application.productImage!, fit: BoxFit.cover)
                       : Icon(Icons.image, color: Colors.grey[400]),
                  ),
                  const SizedBox(width: 12.0),
                  // Item Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.productName ?? '商品名称未知',
                          style: textTheme.bodyLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          application.variantName ?? '默认规格',
                          style: textTheme.bodySmall?.copyWith(color: colorScheme.secondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
               const SizedBox(height: 16.0),
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                 children: [
                    TextButton.icon(
                      icon: Icon(Icons.chat_bubble_outline, size: 18, color: colorScheme.secondary),
                      label: Text('联系卖家', style: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary)),
                      onPressed: () { /* TODO: Implement contact seller */ },
                    ),
                    TextButton.icon(
                      icon: Icon(Icons.support_agent_outlined, size: 18, color: colorScheme.secondary),
                      label: Text('官方客服', style: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary)),
                       onPressed: () { /* TODO: Implement contact support */ },
                    ),
                 ],
               )
           ],
        ),
      ),
    );
  }

   // Placeholder for Bottom Action Bar - Modify to accept data
  Widget _buildBottomActionBar(BuildContext context, ColorScheme colorScheme, AfterSalesApplication application) {
     // ... (implementation using application data to show/hide buttons)
      List<Widget> actionButtons = [];

      // Example logic: Determine buttons based on state
      // This needs refinement based on actual state strings and business logic
      if (application.refundState == 'WAIT_AUDIT' || application.refundState == 'AUDIT_PASS') {
         actionButtons.add(
            OutlinedButton(
               onPressed: () { /* TODO: Implement cancel */ print('Cancel clicked'); },
               child: const Text('撤销申请'),
                style: OutlinedButton.styleFrom(
                 side: BorderSide(color: colorScheme.outline),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                 textStyle: Theme.of(context).textTheme.labelMedium,
               ),
            ),
         );
         actionButtons.add(const SizedBox(width: 8));
      }
       if (application.refundState == 'WAIT_AUDIT') { // Can modify only when waiting?
          actionButtons.add(
             ElevatedButton(
               onPressed: () { /* TODO: Implement modify */ print('Modify clicked'); },
               child: const Text('修改申请'),
               style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: Theme.of(context).textTheme.labelMedium,
               ),
            ),
          );
       } else {
           // Maybe always show platform intervention?
           actionButtons.add(
             OutlinedButton(
               onPressed: () { /* TODO: Implement platform intervention */ print('Platform clicked'); },
               child: const Text('平台介入'),
               style: OutlinedButton.styleFrom(
                 side: BorderSide(color: colorScheme.outline),
                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                 textStyle: Theme.of(context).textTheme.labelMedium,
               ),
             ),
           );
       }


     return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
           color: Theme.of(context).scaffoldBackgroundColor,
           border: Border(top: BorderSide(color: Colors.grey[300]!, width: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: actionButtons, // Use the dynamically generated list
        ),
     );
  }

} 