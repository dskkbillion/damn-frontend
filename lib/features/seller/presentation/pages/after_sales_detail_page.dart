import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/generated/l10n.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import 'package:dskk_flutter_refactor/core/widgets/loading_indicator.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/order_refund.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/enums/order_refund_state.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/enums/refund_type.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/blocs/after_sales_review/after_sales_review_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/widgets/status_tag.dart';

/// 售后审核详情页面
class AfterSalesDetailPage extends StatelessWidget {
  /// 路由名称
  static const routeName = '/seller/after-sales/:id';

  /// 售后ID
  final String id;

  /// 构造函数
  const AfterSalesDetailPage({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 这里应该从传入的id获取详情数据
    // 由于我们现在没有单独的售后详情获取接口，这里暂时使用列表接口获取所有数据并过滤
    return BlocProvider(
      create: (_) => GetIt.instance<AfterSalesReviewBloc>()..add(LoadAfterSalesList()),
      child: Builder(
        builder: (context) {
          final l10n = S.of(context);
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n?.after_sales_detail_title ?? 'After-sales Details'),
            ),
            body: BlocBuilder<AfterSalesReviewBloc, AfterSalesReviewState>(
              builder: (context, state) {
                if (state is AfterSalesReviewInitial || state is AfterSalesReviewLoading) {
                  return const Center(child: LoadingIndicator());
                }
                
                if (state is AfterSalesReviewLoaded) {
                  // 从列表中查找对应ID的售后
                  final idInt = int.tryParse(id) ?? -1;
                  final refund = state.refunds.firstWhere(
                    (r) => r.id == idInt,
                    orElse: () => OrderRefund(
                      id: -1,
                      orderId: 0,
                      orderSn: '未找到',
                      refundSn: 'not-found',
                      refundPrice: 0,
                      reason: '',
                      credentials: [],
                      state: OrderRefundState.unknown,
                      type: RefundType.unknown,
                      applyTime: DateTime.now(),
                    ),
                  );
                  
                  // 如果找不到对应ID的售后
                  if (refund.id == -1) {
                    return Center(
                      child: Text(l10n?.after_sales_not_found ?? 'After-sales request not found'),
                    );
                  }
                  
                  // 显示详情
                  return _buildRefundDetail(context, refund, state);
                }
                
                return Center(child: Text(l10n?.after_sales_load_failed ?? 'Load failed, please try again'));
              },
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildRefundDetail(BuildContext context, OrderRefund refund, AfterSalesReviewState state) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isAuditing = state is AfterSalesReviewAuditing && 
                       state.auditingId == refund.id;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部卡片
          Card(
            elevation: 2,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 订单信息
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${S.of(context)?.after_sales_order_number ?? "Order Number"}: ${refund.orderSn}',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      StatusTag(
                        text: refund.state.displayName(context),
                        type: _getStateType(refund.state),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 24),
                  
                  // 售后基本信息
                  _buildInfoItem(context, S.of(context)?.after_sales_apply_type ?? 'Request Type', _getRefundTypeLabel(context, refund.type)),
                  const SizedBox(height: 12),
                  _buildInfoItem(context, S.of(context)?.after_sales_apply_time ?? 'Request Time', dateFormat.format(refund.applyTime ?? DateTime.now())),
                  const SizedBox(height: 12),
                  _buildInfoItem(context, S.of(context)?.after_sales_refund_amount ?? 'Refund Amount', '¥${refund.formattedRefundPrice.toStringAsFixed(2)}'),
                  const SizedBox(height: 12),
                  _buildInfoItem(context, S.of(context)?.after_sales_refund_type ?? 'Refund Type', _getRefundTypeLabel(context, refund.type)),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 退款原因
          if (refund.reason != null && refund.reason!.isNotEmpty)
            Card(
              elevation: 2,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.of(context)?.after_sales_apply_reason ?? 'Request Reason', style: textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      refund.reason ?? '',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // 图片证据
          if (refund.credentials.isNotEmpty)
            Card(
              elevation: 2,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.of(context)?.after_sales_image_evidence ?? 'Image Evidence', style: textTheme.titleMedium),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: refund.credentials.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _showImageDialog(context, refund.credentials[index]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4.0),
                            child: Image.network(
                              refund.credentials[index],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 24),
          
          // 操作按钮
          if (refund.state == OrderRefundState.waitAudit && !isAuditing)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRejectDialog(context, refund.id!),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(S.of(context)?.after_sales_reject_application ?? 'Reject Request'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showConfirmDialog(context, refund.id!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(S.of(context)?.after_sales_agree_application ?? 'Approve Request'),
                  ),
                ),
              ],
            )
          else if (isAuditing)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildInfoItem(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
  
  // 获取退款类型标签
  String _getRefundTypeLabel(BuildContext context, RefundType type) {
    final l10n = S.of(context);
    switch (type) {
      case RefundType.onlyMoney:
        return l10n?.after_sales_type_refund_only ?? 'Refund Only';
      case RefundType.moneyAndProduct:
        return l10n?.after_sales_type_refund_return ?? 'Return & Refund';
      case RefundType.unknown:
      default:
        return l10n?.after_sales_type_unknown ?? 'Unknown Type';
    }
  }
  
  // 获取状态颜色
  Color _getStateColor(OrderRefundState state) {
    switch (state) {
      case OrderRefundState.waitAudit:
        return Colors.amber;
      case OrderRefundState.auditPass:
        return Colors.green;
      case OrderRefundState.refused:
        return Colors.red;
      case OrderRefundState.buyerShip:
      case OrderRefundState.sellerReceived:
        return Colors.blue;
      case OrderRefundState.finished:
        return Colors.teal;
      case OrderRefundState.canceled:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
  
  /// 根据售后状态获取标签类型
  StatusTagType _getStateType(OrderRefundState state) {
    switch (state) {
      case OrderRefundState.waitAudit:
        return StatusTagType.warning;
      case OrderRefundState.auditPass:
        return StatusTagType.success;
      case OrderRefundState.refused:
        return StatusTagType.danger;
      case OrderRefundState.buyerShip:
      case OrderRefundState.sellerReceived:
        return StatusTagType.primary;
      case OrderRefundState.finished:
        return StatusTagType.success;
      case OrderRefundState.canceled:
        return StatusTagType.defaultTag;
      default:
        return StatusTagType.defaultTag;
    }
  }
  
  // 显示确认对话框
  void _showConfirmDialog(BuildContext context, int refundId) {
    final l10n = S.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n?.after_sales_confirm_title ?? 'Confirm'),
        content: Text(l10n?.after_sales_confirm_message ?? 'Are you sure you want to approve this after-sales request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n?.after_sales_cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AfterSalesReviewBloc>().add(
                AuditAfterSalesRequest(
                  refundId: refundId,
                  approved: true,
                ),
              );
            },
            child: Text(l10n?.after_sales_confirm ?? 'Confirm'),
          ),
        ],
      ),
    );
  }
  
  // 显示拒绝对话框
  void _showRejectDialog(BuildContext context, int refundId) {
    final TextEditingController reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final l10n = S.of(context);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n?.after_sales_reject_reason ?? 'Rejection Reason'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: reasonController,
            decoration: InputDecoration(
              hintText: l10n?.after_sales_reject_reason_hint ?? 'Please enter rejection reason',
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n?.after_sales_reject_reason_required ?? 'Please enter rejection reason';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n?.after_sales_cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop();
                context.read<AfterSalesReviewBloc>().add(
                  AuditAfterSalesRequest(
                    refundId: refundId,
                    approved: false,
                    refusalReason: reasonController.text.trim(),
                  ),
                );
              }
            },
            child: Text(l10n?.after_sales_confirm ?? 'Confirm'),
          ),
        ],
      ),
    );
  }
  
  // 显示图片对话框
  void _showImageDialog(BuildContext context, String imageUrl) {
    final l10n = S.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(l10n?.after_sales_image_view ?? 'Image View'),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              elevation: 0,
            ),
            Flexible(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    width: double.infinity,
                    height: 300,
                    color: Colors.grey[300],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.broken_image, size: 60),
                        const SizedBox(height: 8),
                        Text(l10n?.after_sales_image_load_failed ?? 'Image load failed'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 