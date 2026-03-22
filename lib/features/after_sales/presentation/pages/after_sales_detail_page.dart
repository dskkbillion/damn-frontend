import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc
import 'package:go_router/go_router.dart';

import '../bloc/after_sales_bloc.dart'; // Import Bloc, Event, State
import '../../domain/entities/after_sales_application.dart'; // Import Entity
// Correct import path for DI container if using getIt directly (less common in UI)
import '../../../../app/di/injection_container.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/repositories/i_chat_repository.dart';

/// 售后详情页面
class AfterSalesDetailPage extends StatefulWidget {
  // Changed to StatefulWidget
  /// 预期接收售后申请 ID 或订单 ID
  final String id;
  final bool resolveByOrderId;

  const AfterSalesDetailPage({
    super.key,
    required this.id, // 接收 ID
    this.resolveByOrderId = false,
  });

  @override
  State<AfterSalesDetailPage> createState() => _AfterSalesDetailPageState();
}

class _AfterSalesDetailPageState extends State<AfterSalesDetailPage> {
  AfterSalesApplication? _loadedApplication;
  bool _mediationRequested = false;
  bool _isOpeningChat = false;
  late final IChatRepository _chatRepository = getIt<IChatRepository>();

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
    AppLogger.d(
        '[AfterSalesDetailPage] initState: Triggering LoadAfterSalesDetail for id: ${widget.id}');
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
        if (widget.resolveByOrderId) {
          final orderId = int.tryParse(widget.id);
          if (orderId != null) {
            bloc.add(LoadAfterSalesDetailByOrderId(orderId: orderId));
          } else {
            bloc.add(LoadAfterSalesDetail(id: widget.id));
          }
        } else {
          bloc.add(LoadAfterSalesDetail(id: widget.id));
        }
        return bloc;
      },
      child: BlocConsumer<AfterSalesBloc, AfterSalesState>(
        listener: (context, state) {
          if (state is AfterSalesDetailLoaded) {
            final normalizedStatus =
                _normalizeStatus(state.application.refundState);
            final normalizedFinalState =
                _normalizeStatus(state.application.finalState ?? '');
            final normalizedOrderState =
                _normalizeStatus(state.application.orderState ?? '');
            setState(() {
              _loadedApplication = state.application;
              if (normalizedStatus == 'applyingformediation' ||
                  normalizedFinalState == 'applyingformediation' ||
                  normalizedOrderState == 'applyingformediation') {
                _mediationRequested = true;
              } else if (!_mediationRequested) {
                _mediationRequested = false;
              }
            });
          } else if (state is AfterSalesActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.actionSuccessMessage ?? '操作成功')),
            );
            final isMediationSuccess =
                state.actionSuccessMessage?.contains('平台介入') == true;
            if (_loadedApplication != null) {
              if (isMediationSuccess) {
                setState(() {
                  _mediationRequested = true;
                });
              }
              _reloadDetail(context);
            }
          } else if (state is AfterSalesActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? '操作失败')),
            );
          }
        },
        builder: (context, state) {
          AppLogger.d(
              '[AfterSalesDetailPage] BlocBuilder received state: ${state.runtimeType}');

          final application = _currentApplication(state);
          if (state is AfterSalesDetailLoading &&
              state.loadingId == widget.id &&
              application == null) {
            return Scaffold(
              appBar: AppBar(
                title: Text('售后详情'),
              ),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is AfterSalesDetailError &&
              state.id == widget.id &&
              application == null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('售后详情'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('加载失败: ${state.errorMessage}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _reloadDetail(context),
                      child: const Text('重试'),
                    )
                  ],
                ),
              ),
            );
          }

          if (application == null) {
            return Scaffold(
              appBar: AppBar(
                title: Text('售后详情'),
              ),
              body: Center(child: Text('正在初始化...')),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('售后详情'),
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatusHeader(context, application),
                  const SizedBox(height: 8),
                  _buildRefundInfoCard(
                      context, colorScheme, textTheme, application),
                  const SizedBox(height: 8),
                  _buildRefundDetailsCard(context, application),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            bottomNavigationBar:
                _buildBottomActionBar(context, colorScheme, application, state),
          );
        },
      ),
    );
  }

  AfterSalesApplication? _currentApplication(AfterSalesState state) {
    if (state is AfterSalesDetailLoaded) {
      return state.application;
    }
    return _loadedApplication;
  }

  void _reloadDetail(BuildContext context) {
    if (widget.resolveByOrderId) {
      final orderId = int.tryParse(widget.id);
      if (orderId != null) {
        context
            .read<AfterSalesBloc>()
            .add(LoadAfterSalesDetailByOrderId(orderId: orderId));
        return;
      }
    }
    context.read<AfterSalesBloc>().add(LoadAfterSalesDetail(id: widget.id));
  }

  Future<void> _openChat(
      BuildContext context, AfterSalesApplication application) async {
    if (application.chatRoomId != null) {
      GoRouter.of(context).go('/chat/refactored/${application.chatRoomId}');
      return;
    }
    if (_isOpeningChat) return;
    final tenantId = application.tenantId;
    if (tenantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法获取卖家信息')),
      );
      return;
    }

    setState(() {
      _isOpeningChat = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await _chatRepository.createRoom(
        tenantId,
        productId: application.productId,
      );

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      result.fold(
        (failure) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('创建聊天失败: ${failure.message}')),
          );
        },
        (chatId) {
          if (!mounted) return;
          GoRouter.of(context).go('/chat/refactored/$chatId');
        },
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('打开聊天室失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningChat = false;
        });
      }
    }
  }

  // Status Header - matching order detail page style
  Widget _buildStatusHeader(
      BuildContext context, AfterSalesApplication application) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    String statusTitle = _getStatusTitle(application);
    String? statusSubtitle = _getStatusSubtitle(application);
    IconData statusIcon = _getStatusIcon(application.refundState);
    Color statusColor = _getStatusColor(application, colorScheme);

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

  String _getStatusTitle(AfterSalesApplication application) {
    final normalized = _normalizeStatus(application.refundState);
    final normalizedOrderState = _normalizeStatus(application.orderState ?? '');
    if (_mediationRequested ||
        normalized == 'applyingformediation' ||
        normalizedOrderState == 'applyingformediation') {
      return '平台介入中';
    }
    switch (normalized) {
      case 'waitaudit':
        return '等待卖家处理';
      case 'auditpass':
        return '售后处理中';
      case 'auditrefused':
        return '卖家已拒绝';
      case 'refundsuccess':
        return '已退款';
      case 'cancel':
        return '已关闭';
      default:
        return '售后处理中';
    }
  }

  String? _getStatusSubtitle(AfterSalesApplication application) {
    final normalized = _normalizeStatus(application.refundState);
    final normalizedOrderState = _normalizeStatus(application.orderState ?? '');
    if (_mediationRequested ||
        normalized == 'applyingformediation' ||
        normalizedOrderState == 'applyingformediation') {
      return '卖家已收到平台介入申请，请耐心等待处理';
    }
    switch (normalized) {
      case 'waitaudit':
        return '请等待卖家确认处理方案';
      case 'auditpass':
        return '如需补充说明或继续协商，请前往聊天室沟通';
      case 'auditrefused':
        return '如有异议，可申请平台介入';
      case 'refundsuccess':
        return '退款已完成，请查收';
      case 'cancel':
        return '该售后流程已结束';
      default:
        return '请耐心等待处理结果';
    }
  }

  // 退款详情卡片
  Widget _buildRefundDetailsCard(
      BuildContext context, AfterSalesApplication application) {
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
          _buildDetailRow(
              '申请单号', application.refundSn ?? '-', textTheme, colorScheme),
          _buildDetailRow('申请时间', _formatDateTime(application.createTime),
              textTheme, colorScheme),
          _buildDetailRow(
              '退款金额',
              '¥${application.refundPrice?.toStringAsFixed(2) ?? '0.00'}',
              textTheme,
              colorScheme),
          _buildDetailRow(
              '申请原因', application.refundReason ?? '-', textTheme, colorScheme),
          if (application.refundExplain?.isNotEmpty == true)
            _buildDetailRow(
                '详细说明', application.refundExplain!, textTheme, colorScheme),
          if (application.chatRoomId != null)
            _buildDetailRow(
                '关联聊天室', '#${application.chatRoomId}', textTheme, colorScheme),
          if (application.auditRemark?.isNotEmpty == true) ...[
            const Divider(height: 24),
            _buildDetailRow(
                '审核备注', application.auditRemark!, textTheme, colorScheme),
          ],
          if (application.timeline?.isNotEmpty == true) ...[
            const Divider(height: 24),
            Text(
              '处理时间线',
              style:
                  textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...application.timeline!.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.remark?.isNotEmpty == true
                                ? item.remark!
                                : '状态更新',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (item.reason?.isNotEmpty == true) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.reason!,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          const SizedBox(height: 2),
                          Text(
                            _formatDateTime(item.createTime),
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, TextTheme textTheme,
      ColorScheme colorScheme) {
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
    final normalized = _normalizeStatus(status);
    if (_mediationRequested || normalized == 'applyingformediation') {
      return Icons.gavel_outlined;
    }
    switch (normalized) {
      case 'waitaudit':
        return Icons.pending_outlined;
      case 'auditpass':
        return Icons.check_circle_outline;
      case 'auditrefused':
        return Icons.cancel_outlined;
      case 'refundsuccess':
        return Icons.done_all;
      default:
        return Icons.info_outline;
    }
  }

  Color _getStatusColor(
      AfterSalesApplication application, ColorScheme colorScheme) {
    final normalized = _normalizeStatus(application.refundState);
    final normalizedOrderState = _normalizeStatus(application.orderState ?? '');
    if (_mediationRequested ||
        normalized == 'applyingformediation' ||
        normalizedOrderState == 'applyingformediation') {
      return colorScheme.secondary;
    }
    switch (normalized) {
      case 'waitaudit':
        return colorScheme.primary;
      case 'auditpass':
        return Colors.green;
      case 'auditrefused':
        return colorScheme.error;
      case 'refundsuccess':
        return Colors.green;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  String _normalizeStatus(String status) =>
      status.toLowerCase().replaceAll('_', '');

  bool _canApplyMediation(AfterSalesApplication application) {
    if (application.mediationEligible != null) {
      return application.mediationEligible!;
    }
    final status = application.refundState.toLowerCase();
    final finalState = (application.finalState ?? '').toLowerCase();
    final orderState = _normalizeStatus(application.orderState ?? '');
    if (orderState == 'applyingformediation') {
      return false;
    }
    return _normalizeStatus(status) == 'auditrefused' ||
        _normalizeStatus(finalState) == 'refused';
  }

  bool _canCancelApplication(AfterSalesApplication application) {
    final status = _normalizeStatus(application.refundState);
    return status == 'waitaudit' || status == 'auditpass';
  }

  // Product Information Card - matching order detail page style
  Widget _buildRefundInfoCard(BuildContext context, ColorScheme colorScheme,
      TextTheme textTheme, AfterSalesApplication application) {
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
                  child: application.productImage != null &&
                          application.productImage!.isNotEmpty
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
                      style: textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6.0),
                    if (application.variantName != null &&
                        application.variantName!.isNotEmpty) ...[
                      Text(
                        '规格：${application.variantName}',
                        style: textTheme.bodySmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4.0),
                    ],
                    Text(
                      '数量：${application.refundNumber ?? 1}',
                      style: textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
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
  Widget _buildBottomActionBar(BuildContext context, ColorScheme colorScheme,
      AfterSalesApplication application, AfterSalesState state) {
    final actionButtons = <Widget>[];
    final isActionLoading = state is AfterSalesActionLoading;

    if (application.tenantId != null) {
      actionButtons.add(
        OutlinedButton(
          onPressed: isActionLoading || _isOpeningChat
              ? null
              : () => _openChat(context, application),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colorScheme.primary),
            foregroundColor: colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: Theme.of(context).textTheme.labelMedium,
          ),
          child: Text(_isOpeningChat ? '打开中...' : '去聊天室沟通'),
        ),
      );
    }

    if (_canCancelApplication(application)) {
      if (actionButtons.isNotEmpty) {
        actionButtons.add(const SizedBox(width: 8));
      }
      actionButtons.add(
        OutlinedButton(
          onPressed: isActionLoading
              ? null
              : () {
                  context
                      .read<AfterSalesBloc>()
                      .add(CancelAfterSalesRequested(application.id));
                },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colorScheme.outline),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: Theme.of(context).textTheme.labelMedium,
          ),
          child: const Text('撤销申请'),
        ),
      );
      actionButtons.add(const SizedBox(width: 8));
    }

    if (_canApplyMediation(application) && !_mediationRequested) {
      if (actionButtons.isNotEmpty) {
        actionButtons.add(const SizedBox(width: 8));
      }
      actionButtons.add(
        OutlinedButton(
          onPressed: isActionLoading
              ? null
              : () {
                  context
                      .read<AfterSalesBloc>()
                      .add(ApplyMediationRequested(application.id));
                },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colorScheme.secondary),
            foregroundColor: colorScheme.secondary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: Theme.of(context).textTheme.labelMedium,
          ),
          child: Text(isActionLoading ? '处理中...' : '申请平台介入'),
        ),
      );
    }

    if (actionButtons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 0.5)),
      ),
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 8,
        runSpacing: 8,
        children: actionButtons, // Use the dynamically generated list
      ),
    );
  }
}
