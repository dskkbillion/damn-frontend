import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:dskk_flutter_refactor/core/widgets/loading_indicator.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/order_refund.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/enums/order_refund_state.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/enums/refund_type.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/blocs/after_sales_review/after_sales_review_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/widgets/empty_state.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/widgets/status_tag.dart';

/// 售后审核列表页面
class AfterSalesReviewPage extends StatefulWidget {
  /// 路由名称
  static const routeName = '/seller/after-sales';

  /// 构造函数
  const AfterSalesReviewPage({Key? key}) : super(key: key);
  
  @override
  State<AfterSalesReviewPage> createState() => _AfterSalesReviewPageState();
}

class _AfterSalesReviewPageState extends State<AfterSalesReviewPage> {
  @override
  void initState() {
    super.initState();
    // 在 initState 中触发加载事件
    context.read<AfterSalesReviewBloc>().add(LoadAfterSalesList());
  }
  
  @override
  Widget build(BuildContext context) {
    // return BlocProvider( // 移除 BlocProvider
    //   create: (_) => GetIt.instance<AfterSalesReviewBloc>()..add(LoadAfterSalesList()),
    //   child: Scaffold(
    return Scaffold(
        appBar: AppBar(
          title: const Text('售后审核'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<AfterSalesReviewBloc>().add(ReloadAfterSalesList());
              },
              tooltip: '刷新',
            ),
          ],
        ),
        body: const _AfterSalesReviewBody(),
    //   ),
    );
  }
}

/// 售后审核列表主体
class _AfterSalesReviewBody extends StatefulWidget {
  const _AfterSalesReviewBody({Key? key}) : super(key: key);

  @override
  _AfterSalesReviewBodyState createState() => _AfterSalesReviewBodyState();
}

class _AfterSalesReviewBodyState extends State<_AfterSalesReviewBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    // 滚动到底部时加载更多
    if (maxScroll - currentScroll <= 200) {
      final bloc = context.read<AfterSalesReviewBloc>();
      final state = bloc.state;
      if (state is AfterSalesReviewLoaded && !state.hasMore) {
        return;
      }
      
      bloc.add(LoadMoreAfterSalesList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AfterSalesReviewBloc, AfterSalesReviewState>(
      listener: (context, state) {
        if (state is AfterSalesReviewError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is AfterSalesReviewInitial || state is AfterSalesReviewLoading) {
          return const Center(child: LoadingIndicator());
        }
        
        if (state is AfterSalesReviewEmpty) {
          return const EmptyState(
            icon: Icons.assignment_returned,
            text: '暂无待审核的售后申请',
          );
        }
        
        if (state is AfterSalesReviewLoaded) {
          return _buildRefundList(context, state);
        }
        
        return const Center(child: Text('加载失败，请重试'));
      },
    );
  }

  Widget _buildRefundList(BuildContext context, AfterSalesReviewLoaded state) {
    final isAuditing = state is AfterSalesReviewAuditing;
    final isLoadingMore = state is AfterSalesReviewLoadingMore;
    
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AfterSalesReviewBloc>().add(ReloadAfterSalesList());
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        itemCount: state.refunds.length + (isLoadingMore || state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.refunds.length) {
            // 最后一项显示加载更多指示器
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          
          final refund = state.refunds[index];
          return _RefundCard(
            refund: refund,
            isProcessing: isAuditing && (state as AfterSalesReviewAuditing).auditingId == refund.id,
          );
        },
      ),
    );
  }
}

/// 售后申请卡片
class _RefundCard extends StatelessWidget {
  /// 售后申请数据
  final OrderRefund refund;
  
  /// 是否处理中
  final bool isProcessing;
  
  /// 构造函数
  const _RefundCard({
    Key? key,
    required this.refund,
    this.isProcessing = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头部信息
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
            
            // 退款信息
            _buildInfoRow(context, '申请类型', _getRefundTypeLabel(refund.type)),
            const SizedBox(height: 8),
            _buildInfoRow(context, '申请时间', dateFormat.format(refund.applyTime ?? DateTime.now())),
            const SizedBox(height: 8),
            _buildInfoRow(context, '退款金额', '¥${refund.formattedRefundPrice.toStringAsFixed(2)}'),
            
            // 退款原因
            if (refund.reason != null && refund.reason!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('申请原因:', style: textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(refund.reason ?? '无', style: textTheme.bodyMedium),
            ],
            
            // 图片证据
            if (refund.credentials.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('图片证据:', style: textTheme.titleSmall),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: refund.credentials.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () => _showImageDialog(context, refund.credentials[index]),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: Image.network(
                            refund.credentials[index],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            
            const Divider(height: 24),
            
            // 操作按钮
            if (refund.state == OrderRefundState.waitAudit && !isProcessing)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _showRejectDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                    ),
                    child: const Text('拒绝'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => _showConfirmDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('同意'),
                  ),
                ],
              )
            else if (isProcessing)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // 构建信息行
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
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
  void _showConfirmDialog(BuildContext context) {
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
                  refundId: refund.id!,
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
  void _showRejectDialog(BuildContext context) {
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
                    refundId: refund.id!,
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