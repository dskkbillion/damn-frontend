import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc

import '../bloc/after_sales_bloc.dart'; // Import Bloc, Event, State
import '../../domain/entities/after_sales_application.dart'; // Import Entity
// Correct import path for DI container if using getIt directly (less common in UI)
import '../../../../app/di/injection_container.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dskk_flutter_refactor/core/widgets/app_network_image.dart';
import 'package:dskk_flutter_refactor/core/widgets/skeleton/shimmer_effect.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_action_button_builder.dart';


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
          title: Text(AppLocalizations.of(context).after_sales_detail_title),
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
                    Text(AppLocalizations.of(context).after_sales_detail_load_failed(state.errorMessage ?? '')), // Use errorMessage
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
                      child: Text(AppLocalizations.of(context).retry),
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
            return Center(child: Text(AppLocalizations.of(context).after_sales_detail_initializing));
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
    final s = AppLocalizations.of(context);
    switch (status) {
      case 'wait_audit':
        return s.after_sales_status_wait_audit;
      case 'audit_pass':
        return s.after_sales_status_audit_pass;
      case 'audit_reject':
        return s.after_sales_status_audit_reject;
      case 'refund_success':
        return s.after_sales_status_refund_success;
      case 'canceled':
        return s.after_sales_status_canceled;
      default:
        return s.after_sales_status_processing;
    }
  }

  String? _getStatusSubtitle(String status) {
    final s = AppLocalizations.of(context);
    switch (status) {
      case 'wait_audit':
        return s.after_sales_subtitle_wait_audit;
      case 'audit_pass':
        return s.after_sales_subtitle_audit_pass;
      case 'audit_reject':
        return s.after_sales_subtitle_audit_reject;
      case 'refund_success':
        return s.after_sales_subtitle_refund_success;
      case 'canceled':
        return s.after_sales_subtitle_canceled;
      default:
        return s.after_sales_subtitle_default;
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
            AppLocalizations.of(context).after_sales_info_title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(AppLocalizations.of(context).after_sales_info_order_number, application.refundSn ?? '-', textTheme, colorScheme),
          _buildDetailRow(AppLocalizations.of(context).after_sales_info_apply_time, _formatDateTime(application.createTime), textTheme, colorScheme),
          // #217 AS-08 + #356: 币种符号走 RegionConfig,不再写死 ¥
          _buildDetailRow(AppLocalizations.of(context).after_sales_info_refund_amount, RegionConfig.formatPrice(application.refundPrice ?? 0), textTheme, colorScheme),
          _buildDetailRow(AppLocalizations.of(context).after_sales_info_reason, application.refundReason ?? '-', textTheme, colorScheme),
          if (application.refundExplain?.isNotEmpty == true)
            _buildDetailRow(AppLocalizations.of(context).after_sales_info_description, application.refundExplain!, textTheme, colorScheme),
          if (application.refundImage?.isNotEmpty == true) ...[
            const Divider(height: 24),
            Text(
              AppLocalizations.of(context).after_sales_info_evidence,
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: application.refundImage!.map((url) =>
                GestureDetector(
                  onTap: () => _showFullImage(context, url),
                  child: AppNetworkImage(
                    imageUrl: url,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ).toList(),
            ),
          ],
          if (application.auditRemark?.isNotEmpty == true) ...[
            const Divider(height: 24),
            _buildDetailRow(AppLocalizations.of(context).after_sales_info_audit_remark, application.auditRemark!, textTheme, colorScheme),
          ],
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: InteractiveViewer(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              placeholder: (ctx, url) => const Center(
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: ShimmerEffect(child: CircleAvatar()),
                ),
              ),
              errorWidget: (ctx, url, error) => const Center(
                child: Icon(Icons.broken_image, color: Colors.white, size: 64),
              ),
            ),
          ),
        ),
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
        return colorScheme.tertiary;
      case 'audit_reject':
        return colorScheme.error;
      case 'refund_success':
        return colorScheme.tertiary;
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
            AppLocalizations.of(context).after_sales_product_info,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              AppNetworkImage(
                imageUrl: application.productImage ?? '',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 12.0),
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.productName ?? AppLocalizations.of(context).after_sales_product_unknown,
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6.0),
                    if (application.variantName != null && application.variantName!.isNotEmpty) ...[
                      Text(
                        AppLocalizations.of(context).after_sales_spec(application.variantName!),
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4.0),
                    ],
                    Text(
                      AppLocalizations.of(context).after_sales_quantity(application.refundNumber ?? 1),
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

  // Bottom Action Bar - uses OrderActionButtonBuilder for consistent styling across the app
  Widget _buildBottomActionBar(BuildContext context, ColorScheme colorScheme, AfterSalesApplication application) {
    final l10n = AppLocalizations.of(context);
    final List<Widget> actionButtons = [];

    // 撤销申请：待审核或审核通过时可撤销
    if (application.refundState == 'wait_audit' || application.refundState == 'audit_pass') {
      actionButtons.add(
        OrderActionButtonBuilder.buildButton(
          context,
          l10n.after_sales_revoke,
          () { /* TODO: Implement cancel */ print('Cancel clicked'); },
          isPrimary: false,
        ),
      );
    }

    // 主操作按钮：待审核时可修改（主要按钮），非终态的其他状态显示平台介入（次要按钮）
    // 终态（audit_pass / audit_refused / cancel）不显示任何操作按钮
    const terminalStates = {'audit_pass', 'audit_refused', 'cancel'};
    if (application.refundState == 'wait_audit') {
      actionButtons.add(
        OrderActionButtonBuilder.buildButton(
          context,
          l10n.after_sales_modify,
          () { /* TODO: Implement modify */ print('Modify clicked'); },
          isPrimary: true,
        ),
      );
    } else if (!terminalStates.contains(application.refundState)) {
      actionButtons.add(
        OrderActionButtonBuilder.buildButton(
          context,
          l10n.after_sales_platform_intervention,
          () { /* TODO: Implement platform intervention */ print('Platform clicked'); },
          isPrimary: false,
        ),
      );
    }

    if (actionButtons.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(top: BorderSide(color: AppColors.borderPrimary, width: 0.5)),
      ),
      child: OrderActionButtonBuilder.buildResponsiveButtonLayout(actionButtons),
    );
  }

} 