import 'package:dskk_flutter_refactor/features/seller/presentation/widgets/seller_page_skeleton.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/enums/order_refund_state.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/enums/refund_type.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/order_refund.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/widgets/status_tag.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dskk_flutter_refactor/core/widgets/app_network_image.dart';
import 'package:dskk_flutter_refactor/core/widgets/skeleton/shimmer_effect.dart';

class AfterSalesDetailPage extends StatefulWidget {
  static const routeName = '/seller/after-sales/:id';

  final String id;

  const AfterSalesDetailPage({super.key, required this.id});

  @override
  State<AfterSalesDetailPage> createState() => _AfterSalesDetailPageState();
}

class _AfterSalesDetailPageState extends State<AfterSalesDetailPage> {
  late Future<OrderRefund> _refundFuture;
  bool _isAuditing = false;

  @override
  void initState() {
    super.initState();
    _refundFuture = _loadRefund();
  }

  Future<OrderRefund> _loadRefund() async {
    final refundId = int.tryParse(widget.id);
    if (refundId == null) {
      throw Exception('Invalid after-sales id: ${widget.id}');
    }

    final repository = GetIt.instance<ISellerRepository>();
    final result = await repository.getRefundDetail(refundId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (refund) => refund,
    );
  }

  Future<void> _reloadRefund() async {
    setState(() {
      _refundFuture = _loadRefund();
    });
  }

  Future<void> _auditRefund(
      {required bool approved, String? refusalReason}) async {
    final refundId = int.tryParse(widget.id);
    if (refundId == null) {
      throw Exception('Invalid after-sales id: ${widget.id}');
    }

    final repository = GetIt.instance<ISellerRepository>();
    final result = await repository.auditRefund(
      id: refundId,
      refundState: approved ? 'PASS' : 'REJECT',
      auditRemark: refusalReason,
    );

    result.fold(
      (failure) => throw Exception(failure.message),
      (_) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.after_sales_detail_title)),
      bottomNavigationBar: FutureBuilder<OrderRefund>(
        future: _refundFuture,
        builder: (context, snapshot) {
          final refund = snapshot.data;
          if (snapshot.connectionState != ConnectionState.done ||
              refund == null) {
            return const SizedBox.shrink();
          }
          return _buildBottomActions(context, refund);
        },
      ),
      body: FutureBuilder<OrderRefund>(
        future: _refundFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SellerPageSkeleton(variant: SellerSkeletonVariant.detail);
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(snapshot.error.toString()),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _reloadRefund,
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            );
          }

          final refund = snapshot.data;
          if (refund == null) {
            return Center(child: Text(l10n.after_sales_not_found));
          }

          return _buildRefundDetail(context, refund);
        },
      ),
    );
  }

  Widget _buildRefundDetail(BuildContext context, OrderRefund refund) {
    final logisticsCard = _buildLogisticsCard(context, refund);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusHeader(context, refund),
          const SizedBox(height: 16),
          _buildCommunicationHint(context),
          const SizedBox(height: 16),
          _buildSummaryCard(context, refund),
          const SizedBox(height: 16),
          _buildReasonCard(context, refund),
          if (refund.credentials.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildEvidenceCard(context, refund),
          ],
          if (logisticsCard != null) ...[
            const SizedBox(height: 16),
            logisticsCard,
          ],
        ],
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context, OrderRefund refund) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColor = _statusColor(refund.state, colorScheme);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon(refund.state), color: statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getProcessStatusLabel(refund.state),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _statusSubtitle(refund),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunicationHint(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.forum_outlined, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '交付与协商统一在聊天室处理',
                  style: textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  '当前页面只保留售后流程与审核动作。如需继续沟通、补充说明或交换凭证，请回到卖家聊天列表。',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, OrderRefund refund) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '售后信息',
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              StatusTag(
                text: _getProcessStatusLabel(refund.state),
                type: _getStateType(refund.state),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoItem(context, '申请单号',
              refund.refundSn.isNotEmpty ? refund.refundSn : '#${refund.id}'),
          const SizedBox(height: 12),
          _buildInfoItem(
              context,
              '订单编号',
              refund.orderSn.isNotEmpty
                  ? refund.orderSn
                  : '#${refund.orderId}'),
          const SizedBox(height: 12),
          _buildInfoItem(context, '申请时间', _formatDateTime(refund.applyTime)),
          const SizedBox(height: 12),
          _buildInfoItem(context, '退款金额',
              '¥${refund.formattedRefundPrice.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _buildInfoItem(
              context, '申请类型', _getRefundTypeLabel(context, refund.type)),
          if (refund.auditTime != null) ...[
            const SizedBox(height: 12),
            _buildInfoItem(context, '审核时间', _formatDateTime(refund.auditTime)),
          ],
          if (refund.finishTime != null) ...[
            const SizedBox(height: 12),
            _buildInfoItem(context, '完成时间', _formatDateTime(refund.finishTime)),
          ],
        ],
      ),
    );
  }

  Widget _buildReasonCard(BuildContext context, OrderRefund refund) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '申请原因',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(refund.reason.isNotEmpty ? refund.reason : '-',
              style: textTheme.bodyMedium),
          if ((refund.refuseReason ?? '').isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Text(
              '拒绝原因',
              style:
                  textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              refund.refuseReason!,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEvidenceCard(BuildContext context, OrderRefund refund) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '凭证图片',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
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
                onTap: () =>
                    _showImageDialog(context, refund.credentials[index]),
                child: AppNetworkImage(
                  imageUrl: refund.credentials[index],
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget? _buildLogisticsCard(BuildContext context, OrderRefund refund) {
    final rows = <MapEntry<String, String>>[];

    if ((refund.receiveContact ?? '').isNotEmpty) {
      rows.add(MapEntry('收件人', refund.receiveContact!));
    }
    if ((refund.receivePhone ?? '').isNotEmpty) {
      rows.add(MapEntry('联系电话', refund.receivePhone!));
    }
    if ((refund.receiveAddress ?? '').isNotEmpty) {
      rows.add(MapEntry('退货地址', refund.receiveAddress!));
    }
    if ((refund.buyerLogistics ?? '').isNotEmpty ||
        (refund.buyerLogisticsNo ?? '').isNotEmpty) {
      rows.add(MapEntry(
        '买家物流',
        [refund.buyerLogistics, refund.buyerLogisticsNo]
            .whereType<String>()
            .where((value) => value.isNotEmpty)
            .join(' / '),
      ));
    }
    if ((refund.sellerLogistics ?? '').isNotEmpty ||
        (refund.sellerLogisticsNo ?? '').isNotEmpty) {
      rows.add(MapEntry(
        '卖家物流',
        [refund.sellerLogistics, refund.sellerLogisticsNo]
            .whereType<String>()
            .where((value) => value.isNotEmpty)
            .join(' / '),
      ));
    }

    if (rows.isEmpty) {
      return null;
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '物流信息',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < rows.length; i++) ...[
            _buildInfoItem(context, rows[i].key, rows[i].value),
            if (i != rows.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, OrderRefund refund) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
              top: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.16))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed:
                    _isAuditing ? null : () => _openSellerChat(context, refund),
                icon: const Icon(Icons.forum_outlined, size: 18),
                label: const Text('去聊天室沟通'),
              ),
            ),
            if (refund.state == OrderRefundState.waitAudit) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isAuditing ? null : () => _showRejectDialog(context),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.error),
                      child: const Text('拒绝售后'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed:
                          _isAuditing ? null : () => _showConfirmDialog(context),
                      child: _isAuditing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.onPrimary),
                            )
                          : const Text('同意退款'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openSellerChat(BuildContext context, OrderRefund refund) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('请在卖家聊天列表中继续处理订单 ${refund.orderSn} 的售后沟通。'),
        duration: const Duration(seconds: 3),
      ),
    );
    context.push('/seller/chat');
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(value, style: textTheme.bodyMedium)),
      ],
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  String _getRefundTypeLabel(BuildContext context, RefundType type) {
    switch (type) {
      case RefundType.onlyMoney:
        return '仅退款';
      case RefundType.moneyAndProduct:
        return '退货退款';
      case RefundType.unknown:
        return '未知类型';
    }
  }

  String _getProcessStatusLabel(OrderRefundState state) {
    switch (state) {
      case OrderRefundState.waitAudit:
        return '等待卖家处理';
      case OrderRefundState.refused:
        return '卖家已拒绝';
      case OrderRefundState.finished:
        return '已退款';
      case OrderRefundState.canceled:
        return '已关闭';
      case OrderRefundState.auditPass:
      case OrderRefundState.buyerShip:
      case OrderRefundState.sellerReceived:
      case OrderRefundState.unknown:
        return '售后处理中';
    }
  }

  String _statusSubtitle(OrderRefund refund) {
    switch (refund.state) {
      case OrderRefundState.waitAudit:
        return '请尽快审核申请，并在聊天室与买家确认处理方案。';
      case OrderRefundState.refused:
        return '该申请已被拒绝，如需继续说明，请回到聊天室沟通。';
      case OrderRefundState.finished:
        return '退款流程已完成，可在此页查看处理记录。';
      case OrderRefundState.canceled:
        return '该售后流程已结束。';
      case OrderRefundState.auditPass:
      case OrderRefundState.buyerShip:
      case OrderRefundState.sellerReceived:
      case OrderRefundState.unknown:
        return '当前页面保留流程状态与审核信息，持续沟通请在聊天室完成。';
    }
  }

  IconData _statusIcon(OrderRefundState state) {
    switch (state) {
      case OrderRefundState.waitAudit:
        return Icons.pending_outlined;
      case OrderRefundState.refused:
        return Icons.cancel_outlined;
      case OrderRefundState.finished:
        return Icons.task_alt_outlined;
      case OrderRefundState.canceled:
        return Icons.remove_circle_outline;
      case OrderRefundState.auditPass:
      case OrderRefundState.buyerShip:
      case OrderRefundState.sellerReceived:
      case OrderRefundState.unknown:
        return Icons.support_agent_outlined;
    }
  }

  Color _statusColor(OrderRefundState state, ColorScheme colorScheme) {
    switch (state) {
      case OrderRefundState.waitAudit:
        return colorScheme.primary;
      case OrderRefundState.refused:
        return colorScheme.error;
      case OrderRefundState.finished:
        return AppColors.success;
      case OrderRefundState.canceled:
        return colorScheme.onSurfaceVariant;
      case OrderRefundState.auditPass:
      case OrderRefundState.buyerShip:
      case OrderRefundState.sellerReceived:
      case OrderRefundState.unknown:
        return AppColors.warning;
    }
  }

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
      case OrderRefundState.unknown:
        return StatusTagType.defaultTag;
    }
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('同意退款'),
        content: const Text('确认同意该售后申请，并进入退款流程吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _runAudit(context, approved: true);
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('拒绝售后'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: reasonController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: '请输入拒绝原因',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '请输入拒绝原因';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.of(dialogContext).pop();
              await _runAudit(
                context,
                approved: false,
                refusalReason: reasonController.text.trim(),
              );
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  Future<void> _runAudit(BuildContext context,
      {required bool approved, String? refusalReason}) async {
    setState(() {
      _isAuditing = true;
    });

    try {
      await _auditRefund(approved: approved, refusalReason: refusalReason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approved ? '已同意退款' : '已拒绝售后'),
          backgroundColor: AppColors.success,
        ),
      );
      await _reloadRefund();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isAuditing = false;
        });
      }
    }
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('凭证预览'),
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
                  errorWidget: (_, __, ___) => Container(
                    width: double.infinity,
                    height: 300,
                    color: AppColors.borderInput,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 60),
                        SizedBox(height: 8),
                        Text('图片加载失败'),
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
