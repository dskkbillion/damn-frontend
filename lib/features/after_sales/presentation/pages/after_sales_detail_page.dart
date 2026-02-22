import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
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
     AppLogger.d('[AfterSalesDetailPage] initState: Triggering LoadAfterSalesDetail for id: ${widget.id}');
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
      create: (context) {
        final bloc = getIt<AfterSalesBloc>();
        // Try to parse the ID as an integer (order ID)
        final orderId = int.tryParse(widget.id);
        if (orderId != null) {
          // Use the new event that handles order ID to refund ID conversion
          bloc.add(LoadAfterSalesDetailByOrderId(orderId: orderId));
        } else {
          // Fall back to the original event if it's not a valid integer
          bloc.add(LoadAfterSalesDetail(id: widget.id));
        }
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('售后详情'),
        ),
        body: BlocBuilder<AfterSalesBloc, AfterSalesState>(
          builder: (context, state) {
            AppLogger.d('[AfterSalesDetailPage] BlocBuilder received state: ${state.runtimeType}');

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
                        final orderId = int.tryParse(widget.id);
                        if (orderId != null) {
                          context.read<AfterSalesBloc>().add(LoadAfterSalesDetailByOrderId(orderId: orderId));
                        } else {
                          context.read<AfterSalesBloc>().add(LoadAfterSalesDetail(id: widget.id));
                        }
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStatusHeader(context, application),
                    const SizedBox(height: 8),
                    _buildRefundInfoCard(context, colorScheme, textTheme, application),
                    const SizedBox(height: 8),
                    _buildRefundDetailsCard(context, application),
                    const SizedBox(height: 100), // 为底部按钮留出空间
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

  // Status Header - matching order detail page style
  Widget _buildStatusHeader(BuildContext context, AfterSalesApplication application) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    String statusTitle = _getStatusTitle(application.refundState);
    String? statusSubtitle = _getStatusSubtitle(application.refundState);
    IconData statusIcon = _getStatusIcon(application.refundState);
    Color statusColor = _getStatusColor(application.refundState, colorScheme);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(top: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              size: 24,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusTitle,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
                if (statusSubtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    statusSubtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusTitle(String status) {
    switch (status) {
      case 'wait_audit':
        return '等待卖家审核';
      case 'audit_pass':
        return '售后申请已通过';
      case 'audit_reject':
        return '售后申请已拒绝';
      case 'refund_success':
        return '退款成功';
      case 'canceled':
        return '售后已取消';
      default:
        return '售后处理中';
    }
  }

  String? _getStatusSubtitle(String status) {
    switch (status) {
      case 'wait_audit':
        return '卖家会在48小时内处理您的申请';
      case 'audit_pass':
        return '退款将在1-3个工作日内到账';
      case 'audit_reject':
        return '如有异议，可申请平台介入';
      case 'refund_success':
        return '退款已完成，请查收';
      case 'canceled':
        return '您已取消售后申请';
      default:
        return '请耐心等待处理结果';
    }
  }

  // 退款详情卡片
  Widget _buildRefundDetailsCard(BuildContext context, AfterSalesApplication application) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '售后信息',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('申请单号', application.refundSn ?? '-', textTheme, colorScheme),
          _buildDetailRow('申请时间', _formatDateTime(application.createTime), textTheme, colorScheme),
          _buildDetailRow('退款金额', '¥${application.refundPrice?.toStringAsFixed(2) ?? '0.00'}', textTheme, colorScheme),
          _buildDetailRow('申请原因', application.refundReason ?? '-', textTheme, colorScheme),
          if (application.refundExplain?.isNotEmpty == true)
            _buildDetailRow('详细说明', application.refundExplain!, textTheme, colorScheme),
          if (application.auditRemark?.isNotEmpty == true) ...[
            const Divider(height: 24),
            _buildDetailRow('审核备注', application.auditRemark!, textTheme, colorScheme),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'wait_audit':
        return Icons.pending_outlined;
      case 'audit_pass':
        return Icons.check_circle_outline;
      case 'audit_reject':
        return Icons.cancel_outlined;
      case 'refund_success':
        return Icons.done_all;
      default:
        return Icons.info_outline;
    }
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status) {
      case 'wait_audit':
        return colorScheme.primary;
      case 'audit_pass':
        return Colors.green;
      case 'audit_reject':
        return colorScheme.error;
      case 'refund_success':
        return Colors.green;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  // Product Information Card - matching order detail page style
  Widget _buildRefundInfoCard(BuildContext context, ColorScheme colorScheme, TextTheme textTheme, AfterSalesApplication application) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '商品信息', 
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80, 
                  height: 80,
                  color: Colors.grey[200],
                  child: application.productImage != null && application.productImage!.isNotEmpty
                    ? Image.network(
                        application.productImage!, 
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image_not_supported, 
                          color: Colors.grey[400], 
                          size: 32,
                        ),
                      )
                    : Icon(Icons.image, color: Colors.grey[400], size: 32),
                ),
              ),
              const SizedBox(width: 12.0),
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.productName ?? '商品名称未知',
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6.0),
                    if (application.variantName != null && application.variantName!.isNotEmpty) ...[
                      Text(
                        '规格：${application.variantName}',
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4.0),
                    ],
                    Text(
                      '数量：${application.refundNumber ?? 1}',
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
               onPressed: () { /* TODO: Implement cancel */ AppLogger.d('Cancel clicked'); },
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
               onPressed: () { /* TODO: Implement modify */ AppLogger.d('Modify clicked'); },
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
               onPressed: () { /* TODO: Implement platform intervention */ AppLogger.d('Platform clicked'); },
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