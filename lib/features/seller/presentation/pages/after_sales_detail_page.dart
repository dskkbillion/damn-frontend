import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final int id;

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
      child: Scaffold(
        appBar: AppBar(
          title: const Text('售后详情'),
        ),
        body: BlocBuilder<AfterSalesReviewBloc, AfterSalesReviewState>(
          builder: (context, state) {
            if (state is AfterSalesReviewInitial || state is AfterSalesReviewLoading) {
              return const Center(child: LoadingIndicator());
            }
            
            if (state is AfterSalesReviewLoaded) {
              // 从列表中查找对应ID的售后
              final refund = state.refunds.firstWhere(
                (r) => r.id == id,
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
                return const Center(
                  child: Text('找不到对应的售后申请'),
                );
              }
              
              // 显示详情
              return _buildRefundDetail(context, refund, state);
            }
            
            return const Center(child: Text('加载失败，请重试'));
          },
        ),
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
                          '订单编号: ${refund.orderSn}',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      StatusTag(
                        text: refund.state.displayName,
                        type: _getStateType(refund.state),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 24),
                  
                  // 售后基本信息
                  _buildInfoItem(context, '申请类型', _getRefundTypeLabel(refund.type)),
                  const SizedBox(height: 12),
                  _buildInfoItem(context, '申请时间', dateFormat.format(refund.applyTime ?? DateTime.now())),
                  const SizedBox(height: 12),
                  _buildInfoItem(context, '退款金额', '¥${refund.formattedRefundPrice.toStringAsFixed(2)}'),
                  const SizedBox(height: 12),
                  _buildInfoItem(context, '退款类型', _getRefundTypeLabel(refund.type)),
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
                    Text('申请原因', style: textTheme.titleMedium),
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
                    Text('图片证据', style: textTheme.titleMedium),
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
                    child: const Text('拒绝申请'),
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
                    child: const Text('同意申请'),
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
  String _getRefundTypeLabel(RefundType type) {
    switch (type) {
      case RefundType.onlyMoney:
        return '仅退款';
      case RefundType.moneyAndProduct:
        return '退货退款';
      case RefundType.unknown:
      default:
        return '未知类型';
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认'),
        content: const Text('确定同意此售后申请吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AfterSalesReviewBloc>().add(
                AuditAfterSalesRequest(
                  refundId: refundId,
                  approved: true,
                ),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  // 显示拒绝对话框
  void _showRejectDialog(BuildContext context, int refundId) {
    final TextEditingController reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('拒绝原因'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: '请输入拒绝原因',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                context.read<AfterSalesReviewBloc>().add(
                  AuditAfterSalesRequest(
                    refundId: refundId,
                    approved: false,
                    refusalReason: reasonController.text.trim(),
                  ),
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  // 显示图片对话框
  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('图片查看'),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
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
                      children: const [
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