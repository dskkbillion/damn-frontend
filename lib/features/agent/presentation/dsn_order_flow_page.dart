import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

import '../../../core/dasn/data/dsn_order_repository.dart';
import '../../../core/dasn/domain/dsn_order_models.dart';
import '../data/agent_repository.dart';
import '../domain/agent_models.dart';

/// Trusted App surface for the DS 0.1 buyer P0 flow.
///
/// Every economic step remains explicit: reading an accepted offer, creating
/// a server preview, issuing the short-lived confirmation reference, creating
/// an unpaid order, and finally starting the internal-credits payment.  A
/// network retry reuses the same idempotency key; the page never edits server
/// facts or silently advances to the next side effect.
class DsnOrderFlowPage extends StatefulWidget {
  const DsnOrderFlowPage({
    super.key,
    required this.requestRepository,
    required this.orderRepository,
    required this.requestId,
  });

  final AgentRepository requestRepository;
  final DsnOrderRepository orderRepository;
  final int requestId;

  @override
  State<DsnOrderFlowPage> createState() => _DsnOrderFlowPageState();
}

class _DsnOrderFlowPageState extends State<DsnOrderFlowPage> {
  AgentRequestDraft? _request;
  DsnProviderOffer? _offer;
  DsnOrderPreview? _preview;
  DsnConfirmationRef? _confirmation;
  DsnOrder? _order;
  DsnPaymentAttempt? _payment;
  String? _error;
  bool _loading = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final request =
          await widget.requestRepository.getRequest(widget.requestId);
      if (!mounted) return;
      setState(() => _request = request);
      if (request.status == 'PROVIDER_RESPONDED') {
        final offer =
            await widget.orderRepository.getProviderOffer(widget.requestId);
        if (mounted) setState(() => _offer = offer);
      }
    } catch (error) {
      if (mounted) setState(() => _error = _errorText(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createPreview() async {
    final offer = _offer;
    if (offer == null) return;
    await _runBusy(() async {
      _preview = await widget.orderRepository.createPreview(
        widget.requestId,
        expectedSpecHash: offer.specHash,
        quoteHash: offer.quoteHash,
        idempotencyKey: 'app-preview:${widget.requestId}:${offer.offerVersion}',
      );
    });
  }

  Future<void> _issueConfirmationRef() async {
    final preview = _preview;
    if (preview == null) return;
    final accepted = await _confirm(
      title: '确认冻结报价',
      message: '这会为当前报价生成一次性确认引用。金额、服务方、数量和积分单位均来自服务器，尚未创建订单，也不会扣除积分。',
      confirmLabel: '生成确认引用',
    );
    if (accepted != true) return;
    await _runBusy(() async {
      _confirmation = await widget.orderRepository.issueConfirmationRef(
        widget.requestId,
        previewId: preview.previewId,
        allowedActions: const ['CREATE_ORDER', 'CREATE_PAYMENT_ATTEMPT'],
      );
    });
  }

  Future<void> _createOrder() async {
    final request = _request;
    final preview = _preview;
    final confirmation = _confirmation;
    if (request == null || preview == null || confirmation == null) return;
    final version = request.version;
    if (version == null || version < 0) {
      setState(() => _error = '请求版本缺失，已停止创建订单，请刷新任务');
      return;
    }
    final accepted = await _confirm(
      title: '确认创建订单',
      message:
          '订单将按 ${preview.amountMinor} ${preview.currency} 创建，但此步骤只建立未支付订单，不会扣除积分。',
      confirmLabel: '创建未支付订单',
    );
    if (accepted != true) return;
    await _runBusy(() async {
      _order = await widget.orderRepository.createOrder(
        widget.requestId,
        preview: preview,
        confirmation: confirmation,
        ifMatchVersion: version,
        idempotencyKey: 'app-order:${widget.requestId}:${preview.previewId}',
      );
    });
  }

  Future<void> _pay() async {
    final order = _order;
    final preview = _preview;
    final confirmation = _confirmation;
    if (order == null || preview == null || confirmation == null) return;
    final accepted = await _confirm(
      title: '确认支付',
      message:
          '将从你的平台积分扣除 ${preview.amountMinor} ${preview.currency}。支付结果以服务器返回为准。',
      confirmLabel: '确认支付',
    );
    if (accepted != true) return;
    await _runBusy(() async {
      _payment = await widget.orderRepository.createPaymentAttempt(
        order,
        preview: preview,
        confirmation: confirmation,
        idempotencyKey:
            'app-payment:${order.orderId}:${confirmation.confirmationRef}',
      );
    });
  }

  Future<void> _refreshPayment() async {
    final payment = _payment;
    if (payment == null) return;
    await _runBusy(() async {
      _payment = await widget.orderRepository.getPaymentAttempt(
        payment.paymentAttemptId,
      );
    });
  }

  Future<void> _runBusy(Future<void> Function() operation) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await operation();
      if (mounted) setState(() {});
    } catch (error) {
      if (mounted) setState(() => _error = _errorText(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool?> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  String _errorText(Object error) {
    if (error is DsnOrderApiException && error.message.trim().isNotEmpty) {
      return error.message;
    }
    if (error is AgentApiException && error.message.trim().isNotEmpty) {
      return error.message;
    }
    return AppLocalizations.of(context).agentErrorGeneric;
  }

  @override
  Widget build(BuildContext context) {
    final request = _request;
    return Scaffold(
      appBar: AppBar(title: const Text('确认服务订单')),
      body: _loading && request == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  if (_error != null) _errorCard(_error!),
                  if (request == null && !_loading)
                    const Center(child: Text('未找到请求'))
                  else if (request != null &&
                      request.status != 'PROVIDER_RESPONDED')
                    _notReadyCard(request)
                  else if (_offer != null) ...[
                    _offerCard(_offer!),
                    const SizedBox(height: 12),
                    if (_preview == null)
                      _actionCard(
                        title: '服务方已接单',
                        message: '先创建一份由服务器冻结的订单预览，再进入确认。',
                        label: '查看报价并创建预览',
                        onPressed: _busy ? null : _createPreview,
                      )
                    else ...[
                      _previewCard(_preview!),
                      const SizedBox(height: 12),
                      if (_confirmation == null)
                        _actionCard(
                          title: '需要你的确认',
                          message: '确认引用只允许当前这份预览继续创建订单和支付尝试。',
                          label: '生成确认引用',
                          onPressed: _busy ? null : _issueConfirmationRef,
                        )
                      else ...[
                        _confirmationCard(_confirmation!),
                        const SizedBox(height: 12),
                        if (_order == null)
                          _actionCard(
                            title: '订单尚未创建',
                            message: '创建订单不会扣积分；扣积分只发生在下一步明确支付。',
                            label: '创建未支付订单',
                            onPressed: _busy ? null : _createOrder,
                          )
                        else ...[
                          _orderCard(_order!),
                          const SizedBox(height: 12),
                          if (_payment == null)
                            _actionCard(
                              title: '订单已创建，等待支付',
                              message: '这是最后一个资金动作，必须由你明确确认。',
                              label: '使用积分支付',
                              onPressed: _busy ? null : _pay,
                            )
                          else
                            _paymentCard(_payment!),
                        ],
                      ],
                    ],
                  ] else if (_loading)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
    );
  }

  Widget _errorCard(String error) => Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_outlined,
                  color: Theme.of(context).colorScheme.onErrorContainer),
              const SizedBox(width: 10),
              Expanded(child: Text(error)),
              IconButton(
                onPressed: _loading ? null : _load,
                icon: const Icon(Icons.refresh),
                tooltip: '刷新',
              ),
            ],
          ),
        ),
      );

  Widget _notReadyCard(AgentRequestDraft request) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(request.title,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('当前状态：${request.status}'),
              const SizedBox(height: 8),
              const Text('服务方尚未形成可确认的固定报价。状态变化后再进入此页面。'),
            ],
          ),
        ),
      );

  Widget _offerCard(DsnProviderOffer offer) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('服务方报价', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _fact('服务方', offer.providerId),
              _fact('能力 / 变体', '${offer.capabilityId} / ${offer.variantId}'),
              _fact('数量', '${offer.quantity}'),
              _fact('金额', '${offer.amountMinor} ${offer.currency}'),
              _fact('报价版本', '${offer.offerVersion}'),
              _fact('报价哈希', offer.quoteHash),
            ],
          ),
        ),
      );

  Widget _previewCard(DsnOrderPreview preview) => Card(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('服务器订单预览', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _fact('预览 ID', preview.previewId),
              _fact('金额', '${preview.amountMinor} ${preview.currency}'),
              _fact('数量', '${preview.quantity}'),
              _fact('规格哈希', preview.specHash),
              _fact('报价哈希', preview.quoteHash),
            ],
          ),
        ),
      );

  Widget _confirmationCard(DsnConfirmationRef confirmation) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('确认引用已生成', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text('它只绑定当前预览和当前账户，不能替换服务方或修改金额。'),
              const SizedBox(height: 10),
              _fact('确认引用', confirmation.confirmationRef),
              _fact('允许动作', confirmation.allowedActions.join(', ')),
            ],
          ),
        ),
      );

  Widget _orderCard(DsnOrder order) => Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('未支付订单已创建', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              _fact('订单 ID', order.orderId),
              _fact('承诺 ID', order.commitmentId),
              _fact('状态', order.orderState),
              _fact('金额', '${order.amountMinor} ${order.currency}'),
            ],
          ),
        ),
      );

  Widget _paymentCard(DsnPaymentAttempt payment) {
    final captured = payment.captured;
    return Card(
      color: captured
          ? Theme.of(context).colorScheme.tertiaryContainer
          : Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(captured ? '支付已完成' : '支付处理中',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            _fact('支付尝试', payment.paymentAttemptId),
            _fact('资金状态', payment.fundsDisposition),
            _fact('状态', payment.state),
            if (!captured)
              OutlinedButton.icon(
                onPressed: _busy ? null : _refreshPayment,
                icon: const Icon(Icons.refresh),
                label: const Text('刷新支付状态'),
              ),
            if (captured)
              FilledButton.icon(
                onPressed: () => context.go(
                    '/agent/tasks/${Uri.encodeComponent(payment.taskTraceId)}'),
                icon: const Icon(Icons.timeline_outlined),
                label: const Text('查看任务状态'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard({
    required String title,
    required String message,
    required String label,
    required VoidCallback? onPressed,
  }) =>
      Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(message),
              const SizedBox(height: 14),
              FilledButton(onPressed: onPressed, child: Text(label)),
            ],
          ),
        ),
      );

  Widget _fact(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: SelectableText('$label：$value'),
      );
}
