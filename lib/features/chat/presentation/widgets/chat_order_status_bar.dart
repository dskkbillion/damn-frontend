import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/constants/participant_type.dart';
import 'package:go_router/go_router.dart';

import 'package:dskk_flutter_refactor/app/di/injection_container.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dskk_flutter_refactor/core/utils/price_formatter.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_room.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/repositories/i_order_repository.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/utils/order_status_mapper.dart';

class ChatOrderStatusBar extends StatefulWidget {
  final ChatRoom chatRoom;

  const ChatOrderStatusBar({
    super.key,
    required this.chatRoom,
  });

  @override
  State<ChatOrderStatusBar> createState() => _ChatOrderStatusBarState();
}

class _ChatOrderStatusBarState extends State<ChatOrderStatusBar> {
  bool _isLoading = true;
  bool _isExpanded = false;
  List<Order> _orders = const [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void didUpdateWidget(covariant ChatOrderStatusBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chatRoom.id != widget.chatRoom.id ||
        oldWidget.chatRoom.productId != widget.chatRoom.productId) {
      _loadOrders();
    }
  }

  Future<void> _loadOrders() async {
    final productId = int.tryParse(widget.chatRoom.productId ?? '');
    if (productId == null) {
      setState(() {
        _isLoading = false;
        _orders = const [];
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repository = getIt<IOrderRepository>();
    final isSellerView = widget.chatRoom.participant1.type == ParticipantType.doctor;
    final result = await repository.getOrderList(
      productId: productId,
      page: 1,
      limit: 50,
      userRole: isSellerView ? 'seller' : 'buyer',
      forceRefresh: true,
    );

    if (!mounted) {
      return;
    }

    result.fold(
      (failure) {
        AppLogger.d('[ChatOrderStatusBar] Failed to load orders: $failure');
        setState(() {
          _isLoading = false;
          _orders = const [];
          _errorMessage = _failureMessage(failure);
        });
      },
      (orders) {
        final sortedOrders = [...orders]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final exactMatches =
            sortedOrders.where(_matchesCurrentConversation).toList();

        setState(() {
          _isLoading = false;
          _orders = exactMatches.isNotEmpty ? exactMatches : sortedOrders;
          _errorMessage = null;
          _isExpanded = false;
        });
      },
    );
  }

  bool _matchesCurrentConversation(Order order) {
    final productId = int.tryParse(widget.chatRoom.productId ?? '');
    final buyerReferId = _buyerReferId;
    final sellerReferId = _sellerReferId;

    if (productId == null || buyerReferId == null || sellerReferId == null) {
      return false;
    }

    final hasMatchedProduct =
        order.items.any((item) => item.productId == productId);
    final hasMatchedBuyer = order.buyer?.id == buyerReferId;
    final hasMatchedSeller = order.tenant?.id == sellerReferId;

    return hasMatchedProduct && hasMatchedBuyer && hasMatchedSeller;
  }

  int? get _buyerReferId {
    if (widget.chatRoom.participant1.id == widget.chatRoom.memberId) {
      return widget.chatRoom.participant1.referId;
    }
    if (widget.chatRoom.participant2.id == widget.chatRoom.memberId) {
      return widget.chatRoom.participant2.referId;
    }
    return null;
  }

  int? get _sellerReferId {
    if (widget.chatRoom.participant1.id == widget.chatRoom.doctorId) {
      return widget.chatRoom.participant1.referId;
    }
    if (widget.chatRoom.participant2.id == widget.chatRoom.doctorId) {
      return widget.chatRoom.participant2.referId;
    }
    return null;
  }

  String _failureMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return '订单状态加载失败';
  }

  void _openOrder(Order order) {
    final isSellerView = widget.chatRoom.participant1.type == ParticipantType.doctor;
    final route = _resolveTargetRoute(order, isSellerView: isSellerView);
    context.push(route);
  }

  String _resolveTargetRoute(Order order, {required bool isSellerView}) {
    if (_shouldOpenAfterSalesDetail(order)) {
      if (!isSellerView) {
        if (order.refundId != null) {
          return '/afterSalesDetail/${order.refundId}?mode=refund';
        }
        return '/afterSalesDetail/${order.id}?mode=order';
      }

      if (order.refundId != null) {
        return '/seller/after-sales/${order.refundId}';
      }
    }

    return isSellerView
        ? '/seller/orders/${order.id}'
        : '/orderDetail/${order.id}';
  }

  bool _shouldOpenAfterSalesDetail(Order order) {
    switch (order.state) {
      case OrderStatus.afterSale:
      case OrderStatus.AfterSaleRejection:
      case OrderStatus.applyingForMediation:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildShell(
        context,
        child: const SizedBox(
          height: 24,
          child: Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildShell(
        context,
        child: Row(
          children: [
            const Icon(Icons.error_outline, size: 16, color: AppColors.warning),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.warning,
                ),
              ),
            ),
            TextButton(
              onPressed: _loadOrders,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return const SizedBox.shrink();
    }

    final latestOrder = _orders.first;
    final multipleOrders = _orders.length > 1;
    final isSellerView = widget.chatRoom.participant1.type == ParticipantType.doctor;
    final statusText = OrderStatusMapper.getSimplifiedStatusText(
      latestOrder.state,
      isSellerView: isSellerView,
    );
    final statusColor = OrderStatusMapper.getSimplifiedStatusColor(
      latestOrder.state,
      context,
    );

    return _buildShell(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: multipleOrders
                ? () => setState(() => _isExpanded = !_isExpanded)
                : () => _openOrder(latestOrder),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        Icon(Icons.receipt_long, size: 18, color: statusColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              multipleOrders
                                  ? '共${_orders.length}笔相关订单'
                                  : '当前关联订单',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '最新订单 ${latestOrder.orderSn} · ${PriceFormatter.format(latestOrder.priceSummary.payPrice)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (multipleOrders)
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.textSecondary,
                    )
                  else
                    const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Column(
                children: _orders
                    .map(
                      (order) => _OrderListTile(
                        order: order,
                        isSellerView: isSellerView,
                        onTap: () => _openOrder(order),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShell(BuildContext context, {required Widget child}) {
    return GlassCard(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      tintOpacity: 0.62,
      child: child,
    );
  }
}

class _OrderListTile extends StatelessWidget {
  final Order order;
  final bool isSellerView;
  final VoidCallback onTap;

  const _OrderListTile({
    required this.order,
    required this.isSellerView,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = OrderStatusMapper.getSimplifiedStatusText(
      order.state,
      isSellerView: isSellerView,
    );
    final statusColor =
        OrderStatusMapper.getSimplifiedStatusColor(order.state, context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.orderSn,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${PriceFormatter.format(order.priceSummary.payPrice)} · ${order.createdAt.month.toString().padLeft(2, '0')}-${order.createdAt.day.toString().padLeft(2, '0')} ${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
