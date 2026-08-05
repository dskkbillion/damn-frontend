import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

import '../../../core/dasn/data/dsn_order_repository.dart';
import '../../../core/dasn/data/dasn_task_repository.dart';
import '../../../core/dasn/domain/dasn_task_view.dart';
import '../../../core/dasn/domain/dsn_buyer_agent_models.dart';
import '../../../core/dasn/domain/dsn_order_models.dart';
import '../data/agent_repository.dart';
import '../domain/agent_models.dart';

enum _DsnBuyerActorType { human, agent, unknown }

/// Trusted App surface for the DS 0.1 buyer P0 flow.
///
/// Every economic step remains explicit: reading an accepted offer, creating
/// a server preview, issuing the short-lived confirmation reference, creating
/// an unpaid order, and finally starting the internal-credits payment.  A
/// network retry reuses the same idempotency key; the page never edits server
/// facts or silently advances to the next side effect.
///
/// When the requester is an Agent, the page intentionally stops after the
/// App-issued confirmation reference.  The external Buyer Agent adapter owns
/// `/agent/v1/requests/{id}/commitment`; this page exposes a credential-free
/// handoff and later restores the resulting order from the App task
/// projection.
class DsnOrderFlowPage extends StatefulWidget {
  const DsnOrderFlowPage({
    super.key,
    required this.requestRepository,
    required this.orderRepository,
    required this.requestId,
    this.taskRepository,
    this.onBuyerAgentHandoffReady,
  });

  final AgentRepository requestRepository;
  final DsnOrderRepository orderRepository;
  final int requestId;
  final DasnTaskRepository? taskRepository;
  final ValueChanged<DsnBuyerAgentHandoff>? onBuyerAgentHandoffReady;

  @override
  State<DsnOrderFlowPage> createState() => _DsnOrderFlowPageState();
}

class _DsnOrderFlowPageState extends State<DsnOrderFlowPage> {
  static const _quoteInvalidatingErrorCodes = <String>{
    'OFFER_NOT_ACTIVE',
    'OFFER_PREVIEW_MISMATCH',
    'OFFER_VERSION_CONFLICT',
    'PREVIEW_CONFLICT',
    'PREVIEW_INVALID',
    'REQUEST_SPEC_CONFLICT',
    'REQUEST_VERSION_CONFLICT',
  };

  AgentRequestDraft? _request;
  DsnProviderOffer? _offer;
  DsnOrderPreview? _preview;
  DsnConfirmationRef? _confirmation;
  DsnOrder? _order;
  DsnPaymentAttempt? _payment;
  DsnBuyerAgentHandoff? _buyerAgentHandoff;
  String? _paymentAttemptRecoveryId;
  String? _error;
  bool _loading = false;
  bool _busy = false;
  bool _recoveryBlocked = false;
  int _previewKeyGeneration = 0;

  _DsnBuyerActorType _buyerActorType(AgentRequestDraft request) {
    return switch (request.requesterActorType) {
      'HUMAN' => _DsnBuyerActorType.human,
      'AGENT' => _DsnBuyerActorType.agent,
      _ => _DsnBuyerActorType.unknown,
    };
  }

  bool _isBuyerAgentRequest(AgentRequestDraft request) =>
      _buyerActorType(request) == _DsnBuyerActorType.agent;

  String? _principalRef(AgentRequestDraft request) {
    final value = request.principalRef?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  bool get _requiresBuyerAgentHandoff =>
      _request != null && _isBuyerAgentRequest(_request!);

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
      setState(() {
        _request = request;
        _recoveryBlocked = false;
      });
      if (_providerResponseAvailable(request)) {
        final offer =
            await widget.orderRepository.getProviderOffer(widget.requestId);
        if (mounted) {
          setState(() => _offer = offer);
          await _restoreExistingTask(request, offer);
        }
      }
    } catch (error) {
      if (mounted) setState(() => _error = _errorText(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Rehydrates an existing DS Commitment/PaymentAttempt after the page is
  /// recreated.  The task projection is read-only truth; this method never
  /// creates a new order or confirmation reference during recovery.
  Future<void> _restoreExistingTask(
    AgentRequestDraft request,
    DsnProviderOffer offer,
  ) async {
    _recoveryBlocked = false;
    final repository = widget.taskRepository;
    if (repository == null) return;
    final taskTraceId = request.taskTraceId;
    if (taskTraceId == null || taskTraceId.trim().isEmpty) return;
    DasnTaskView task;
    try {
      task = await repository.getTask(taskTraceId);
    } catch (_) {
      // A task trace is an existing-lineage hint. If its projection cannot be
      // read, do not expose a fresh payment/order surface that could race a
      // previously persisted commitment.
      _blockTaskRecovery('任务状态暂不可用，请刷新任务后重试');
      return;
    }
    if (task.taskTraceId != taskTraceId) {
      _blockTaskRecovery('任务引用不匹配，请刷新任务后重试');
      return;
    }
    final requestFact = _mapFact(task.data['request']);
    final commitment = _mapFact(task.data['commitment']);
    final order = _mapFact(task.data['order']);
    final hasCommitmentFact = task.data['commitment'] != null;
    final hasOrderFact = task.data['order'] != null;
    if (commitment == null || order == null) {
      if (hasCommitmentFact || hasOrderFact) {
        _blockTaskRecovery('任务事实不完整，请刷新任务后重试');
      }
      return;
    }

    final projectedRequestId = _intFact(requestFact?['id']);
    final previewId = _stringFact(commitment, 'previewId');
    final confirmationRef = _stringFact(commitment, 'confirmationRef');
    final specHash = _wireHash(commitment['specHash']);
    final quoteHash = _wireHash(commitment['quoteHash']);
    final amount = _intFact(commitment['amountCredits']);
    final offerVersion = _intFact(commitment['offerVersion']);
    final currency = _stringFact(commitment, 'currency');
    final acceptanceId = _stringFact(commitment, 'acceptanceId');
    final commitmentOrderId = _stringFact(commitment, 'orderId');
    final orderId = _stringFact(order, 'id');
    final orderState = _stringFact(order, 'state');
    final commitmentVersion = _intFact(commitment['commitmentVersion']);
    final orderCommitmentVersion = _intFact(order['commitmentVersion']);
    final commitmentId = _stringFact(commitment, 'id');
    if (projectedRequestId != request.id ||
        previewId == null ||
        confirmationRef == null ||
        specHash == null ||
        quoteHash == null ||
        amount == null ||
        amount <= 0 ||
        offerVersion == null ||
        offerVersion <= 0 ||
        currency == null ||
        acceptanceId == null ||
        commitmentOrderId == null ||
        orderId == null ||
        orderState == null ||
        commitmentVersion == null ||
        commitmentVersion <= 0 ||
        orderCommitmentVersion != commitmentVersion ||
        commitmentId == null ||
        offerVersion != offer.offerVersion ||
        specHash != offer.specHash ||
        quoteHash != offer.quoteHash ||
        acceptanceId != offer.acceptanceId ||
        amount != offer.amountMinor ||
        currency != offer.currency ||
        commitmentOrderId != orderId) {
      _blockTaskRecovery('任务报价或订单事实已变化，请刷新任务后重试');
      return;
    }
    if (_isBuyerAgentRequest(request) && _principalRef(request) == null) {
      _blockTaskRecovery('买方 principalRef 缺失，已停止恢复订单，请刷新任务');
      return;
    }

    final restoredPreview = DsnOrderPreview(
      requestId: request.id,
      taskTraceId: taskTraceId,
      previewId: previewId,
      providerId: offer.providerId,
      providerOfferId: offer.offerId,
      providerAcceptanceId: offer.acceptanceId,
      offerVersion: offerVersion,
      specHash: specHash,
      quoteHash: quoteHash,
      amountMinor: amount,
      currency: currency,
      quantity: offer.quantity,
      // The original preview expiry is deliberately not reconstructed as a
      // live authorization fact. Payment recovery is bound to the persisted
      // Commitment/confirmationRef and server If-Match checks.
      expiresAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
    final restoredConfirmation = DsnConfirmationRef(
      confirmationRef: confirmationRef,
      requestId: request.id,
      taskTraceId: taskTraceId,
      previewId: previewId,
      specHash: specHash,
      quoteHash: quoteHash,
      amountMinor: amount,
      currency: currency,
      paymentMethodType: 'CREDITS',
      allowedActions: const ['CREATE_ORDER', 'CREATE_PAYMENT_ATTEMPT'],
    );
    final restoredOrder = DsnOrder(
      orderId: orderId,
      taskTraceId: taskTraceId,
      commitmentId: commitmentId,
      confirmationRef: confirmationRef,
      amountMinor: amount,
      currency: currency,
      orderState: orderState,
      commitmentVersion: commitmentVersion,
      offerId: offer.offerId,
      replayed: true,
    );
    DsnPaymentAttempt? restoredPayment;
    final paymentId = _stringFact(task.data['paymentAttempt'], 'id');
    final paymentFact = _mapFact(task.data['paymentAttempt']);
    if (task.data['paymentAttempt'] != null &&
        (paymentFact == null || paymentId == null)) {
      _blockTaskRecovery('支付事实不完整，请刷新任务后重试');
      return;
    }
    final projectedPaymentConfirmation =
        _stringFact(paymentFact, 'confirmationRef');
    if (projectedPaymentConfirmation != null &&
        projectedPaymentConfirmation != confirmationRef) {
      _blockTaskRecovery('支付确认引用不匹配，请刷新任务后重试');
      return;
    }
    final projectedPaymentVersion =
        _intFact(paymentFact?['commitmentVersion']);
    if (paymentFact != null &&
        (projectedPaymentVersion == null ||
            projectedPaymentVersion != commitmentVersion)) {
      _blockTaskRecovery('支付承诺版本不匹配，请刷新任务后重试');
      return;
    }
    String? paymentRecoveryId = paymentId;
    if (paymentId != null) {
      try {
        restoredPayment =
            await widget.orderRepository.getPaymentAttempt(paymentId);
        if (restoredPayment.orderId != orderId ||
            restoredPayment.taskTraceId != taskTraceId ||
            restoredPayment.confirmationRef != confirmationRef ||
            restoredPayment.amountMinor != amount ||
            restoredPayment.currency != currency) {
          _blockTaskRecovery('支付状态与订单事实不匹配，请刷新任务后重试');
          return;
        }
        paymentRecoveryId = null;
      } catch (_) {
        // Keep the recovered order visible, but fail closed: a projection
        // that already contains a PaymentAttempt must never fall back to a
        // second debit button merely because its status lookup was flaky.
      }
    }
    if (!mounted) return;
    DsnBuyerAgentHandoff? restoredHandoff;
    if (_isBuyerAgentRequest(request)) {
      try {
        restoredHandoff = DsnBuyerAgentHandoff(
          requestId: request.id,
          taskTraceId: taskTraceId,
          commitment: buyerAgentCommitmentInputFromFacts(
            preview: restoredPreview,
            confirmation: restoredConfirmation,
          ),
          status: DsnBuyerAgentHandoffStatus.commitmentCreated,
          principalRef: _principalRef(request)!,
        );
      } on ArgumentError {
        _blockTaskRecovery('Buyer Agent handoff 事实不匹配，请刷新任务后重试');
        return;
      }
    }
    setState(() {
      _preview = restoredPreview;
      _confirmation = restoredConfirmation;
      _order = restoredOrder;
      _payment = restoredPayment;
      _paymentAttemptRecoveryId = paymentRecoveryId;
      _buyerAgentHandoff = restoredHandoff;
    });
  }

  void _blockTaskRecovery(String message) {
    if (!mounted) return;
    setState(() {
      _recoveryBlocked = true;
      _error = message;
      _preview = null;
      _confirmation = null;
      _order = null;
      _payment = null;
      _paymentAttemptRecoveryId = null;
      _buyerAgentHandoff = null;
    });
  }

  Map<String, dynamic>? _mapFact(dynamic value) {
    if (value is! Map) return null;
    try {
      return Map<String, dynamic>.from(value);
    } catch (_) {
      return null;
    }
  }

  String? _stringFact(dynamic value, String field) {
    final map = _mapFact(value);
    final fact = map?[field];
    if (fact == null || fact.toString().trim().isEmpty) return null;
    return fact.toString().trim();
  }

  int? _intFact(dynamic value) {
    if (value is num && value == value.truncateToDouble()) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  String? _wireHash(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    final wire = text.startsWith('sha256:') ? text : 'sha256:$text';
    return RegExp(r'^sha256:[a-f0-9]{64}$').hasMatch(wire) ? wire : null;
  }

  Future<void> _createPreview() async {
    final request = _request;
    if (request == null ||
        _buyerActorType(request) != _DsnBuyerActorType.human &&
            _buyerActorType(request) != _DsnBuyerActorType.agent) {
      setState(() => _error = '买方身份类型缺失，已停止创建订单预览');
      return;
    }
    final offer = _offer;
    if (offer == null) return;
    await _runBusy(() async {
      try {
        _preview = await _createPreviewWithKey(offer);
      } on DsnOrderApiException catch (error) {
        if (error.code == 'PREVIEW_EXPIRED_RETRY') {
          // An expired preview is a new logical operation. Reusing its old
          // idempotency key would correctly replay the old fact forever, so a
          // new generation is required before asking the server for a fresh
          // offer-bound preview.
          _previewKeyGeneration += 1;
          _preview = await _createPreviewWithKey(offer);
        } else {
          if (!_quoteNeedsRefresh(error)) rethrow;
          _clearQuoteState();
          throw const DsnOrderApiException(
            '报价已变化，请刷新后重新创建预览',
            code: 'STALE_QUOTE_RETRY',
          );
        }
      }
    });
  }

  Future<DsnOrderPreview> _createPreviewWithKey(DsnProviderOffer offer) {
    return widget.orderRepository.createPreview(
      widget.requestId,
      expectedSpecHash: offer.specHash,
      quoteHash: offer.quoteHash,
      idempotencyKey:
          'app-preview:${widget.requestId}:${offer.offerVersion}:$_previewKeyGeneration',
    );
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
      try {
        final request = _request;
        if (request != null &&
            _isBuyerAgentRequest(request) &&
            _principalRef(request) == null) {
          throw const DsnOrderApiException(
            '买方 principalRef 缺失，无法安全交给 Buyer Agent',
            code: 'BUYER_PRINCIPAL_REF_REQUIRED',
          );
        }
        final confirmation = await widget.orderRepository.issueConfirmationRef(
          widget.requestId,
          previewId: preview.previewId,
          allowedActions: const ['CREATE_ORDER', 'CREATE_PAYMENT_ATTEMPT'],
          idempotencyKey:
              'app-confirmation:${widget.requestId}:${preview.previewId}',
        );
        final requestForHandoff = _request;
        if (requestForHandoff != null &&
            _isBuyerAgentRequest(requestForHandoff)) {
          final handoff = DsnBuyerAgentHandoff(
              requestId: requestForHandoff.id,
              taskTraceId: preview.taskTraceId,
              commitment: buyerAgentCommitmentInputFromFacts(
                preview: preview,
                confirmation: confirmation,
              ),
              status: DsnBuyerAgentHandoffStatus.readyForBuyerAgent,
              principalRef: _principalRef(requestForHandoff)!);
          _confirmation = confirmation;
          _buyerAgentHandoff = handoff;
          widget.onBuyerAgentHandoffReady?.call(handoff);
        } else {
          _confirmation = confirmation;
        }
      } on ArgumentError catch (_) {
        _clearQuoteState(clearOffer: false);
        throw const DsnOrderApiException(
          '确认引用与当前报价事实不匹配，请刷新后重试',
          code: 'HANDOFF_FACT_MISMATCH',
        );
      } on DsnOrderApiException catch (error) {
        if (error.code == 'PREVIEW_EXPIRED') {
          _clearQuoteState(clearOffer: false);
          throw const DsnOrderApiException(
            '报价预览已过期，请重新创建预览',
            code: 'PREVIEW_EXPIRED_RETRY',
          );
        }
        if (_quoteNeedsRefresh(error)) {
          _clearQuoteState();
          throw const DsnOrderApiException(
            '报价已变化，请刷新后重新创建预览',
            code: 'STALE_QUOTE_RETRY',
          );
        }
        rethrow;
      }
    });
  }

  Future<void> _createOrder() async {
    final request = _request;
    final preview = _preview;
    final confirmation = _confirmation;
    if (request == null || preview == null || confirmation == null) return;
    if (_buyerActorType(request) != _DsnBuyerActorType.human) {
      // This is an invariant guard in addition to the hidden button.  App
      // JWTs must never be used to call the Agent commitment route, and an
      // unknown actor type must never silently become a human buyer.
      setState(() => _error = '买方身份类型不受支持，已停止创建订单');
      return;
    }
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
      try {
        _order = await widget.orderRepository.createOrder(
          widget.requestId,
          preview: preview,
          confirmation: confirmation,
          ifMatchVersion: version,
          idempotencyKey: 'app-order:${widget.requestId}:${preview.previewId}',
        );
      } on DsnOrderApiException catch (error) {
        if (!_quoteNeedsRefresh(error)) rethrow;
        _clearQuoteState();
        throw const DsnOrderApiException(
          '报价已变化，请刷新后重新创建预览',
          code: 'STALE_QUOTE_RETRY',
        );
      }
    });
  }

  bool _quoteNeedsRefresh(DsnOrderApiException error) =>
      error.code != null && _quoteInvalidatingErrorCodes.contains(error.code);

  void _clearQuoteState({bool clearOffer = true}) {
    if (clearOffer) _offer = null;
    _preview = null;
    _confirmation = null;
    _order = null;
    _payment = null;
    _paymentAttemptRecoveryId = null;
    _buyerAgentHandoff = null;
    _previewKeyGeneration += 1;
  }

  Future<void> _pay() async {
    final order = _order;
    final preview = _preview;
    final confirmation = _confirmation;
    if (order == null || preview == null || confirmation == null) return;
    final commitmentVersion = order.commitmentVersion;
    if (commitmentVersion == null || commitmentVersion < 1) {
      setState(() => _error = '订单承诺版本缺失，已停止支付，请刷新任务');
      return;
    }
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
        ifMatchVersion: commitmentVersion,
        idempotencyKey:
            'app-payment:${order.orderId}:${confirmation.confirmationRef}',
      );
    });
  }

  Future<void> _refreshPayment() async {
    final payment = _payment;
    if (payment == null) return;
    await _runBusy(() async {
      _payment = payment.nextAction == 'RECONCILE_PAYMENT_ATTEMPT'
          ? await widget.orderRepository.reconcilePaymentAttempt(
              payment.paymentAttemptId,
            )
          : await widget.orderRepository.getPaymentAttempt(
              payment.paymentAttemptId,
            );
    });
  }

  Future<void> _recoverPaymentAttempt() async {
    final paymentAttemptId = _paymentAttemptRecoveryId;
    if (paymentAttemptId == null) return;
    await _runBusy(() async {
      _payment =
          await widget.orderRepository.getPaymentAttempt(paymentAttemptId);
      _paymentAttemptRecoveryId = null;
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

  bool _providerResponseAvailable(AgentRequestDraft request) =>
      request.status == 'PROVIDER_RESPONDED' ||
      request.providerRespondedAt != null;

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
                      !_providerResponseAvailable(request))
                    _notReadyCard(request)
                  else if (request != null &&
                      _buyerActorType(request) == _DsnBuyerActorType.unknown)
                    _actorTypeBlockedCard(request)
                  else if (_recoveryBlocked)
                    _recoveryBlockedCard()
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
                        _requiresBuyerAgentHandoff &&
                                _principalRef(_request!) == null
                            ? _principalRefBlockedCard()
                            : _actionCard(
                                title: '需要你的确认',
                                message: '确认引用只允许当前这份预览继续创建订单和支付尝试。',
                                label: '生成确认引用',
                                onPressed: _busy ? null : _issueConfirmationRef,
                              )
                      else ...[
                        _confirmationCard(_confirmation!),
                        const SizedBox(height: 12),
                        if (_order == null)
                          _requiresBuyerAgentHandoff
                              ? _buyerAgentHandoffCard()
                              : _actionCard(
                                  title: '订单尚未创建',
                                  message: '创建订单不会扣积分；扣积分只发生在下一步明确支付。',
                                  label: '创建未支付订单',
                                  onPressed: _busy ? null : _createOrder,
                                )
                        else ...[
                          _orderCard(_order!),
                          const SizedBox(height: 12),
                          if (_payment == null &&
                              _paymentAttemptRecoveryId != null)
                            _actionCard(
                              title: '支付状态待恢复',
                              message: '服务器已经记录过支付尝试。先恢复其最终状态，不会重复扣除积分。',
                              label: '恢复支付状态',
                              onPressed: _busy ? null : _recoverPaymentAttempt,
                            )
                          else if (_payment == null)
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

  Widget _actorTypeBlockedCard(AgentRequestDraft request) => Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('买方身份类型缺失或不受支持',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('请求 ${request.id} 未明确标记为 HUMAN 或 AGENT，已停止订单操作。'),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _loading ? null : _load,
                icon: const Icon(Icons.refresh),
                label: const Text('刷新任务'),
              ),
            ],
          ),
        ),
      );

  Widget _recoveryBlockedCard() => Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('订单事实未安全恢复', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text('服务器返回的任务、报价或支付事实不一致，当前不会显示支付操作。'),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _loading ? null : _load,
                icon: const Icon(Icons.refresh),
                label: const Text('刷新任务'),
              ),
            ],
          ),
        ),
      );

  Widget _principalRefBlockedCard() => Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Buyer Agent handoff 暂不可用',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const Text('缺少同一买方 App/Agent 使用的 principalRef，已停止签发确认引用。'),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _loading ? null : _load,
                icon: const Icon(Icons.refresh),
                label: const Text('刷新任务'),
              ),
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
              if (_buyerAgentHandoff != null)
                _fact('handoff 状态', _buyerAgentHandoff!.status.wireName),
              _fact('订单 ID', order.orderId),
              _fact('承诺 ID', order.commitmentId),
              _fact('状态', order.orderState),
              _fact('金额', '${order.amountMinor} ${order.currency}'),
            ],
          ),
        ),
      );

  Widget _buyerAgentHandoffCard() {
    final handoff = _buyerAgentHandoff;
    if (handoff == null) {
      // This should only be reachable if a server projection is incomplete;
      // fail closed rather than offering a direct App order button.
      return _actionCard(
        title: 'Buyer Agent handoff 不完整',
        message: '缺少可验证的预览或确认引用，请刷新任务后重试。',
        label: '刷新 Commitment 状态',
        onPressed: _busy ? null : _load,
      );
    }
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('等待 Buyer Agent 创建 Commitment',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Trusted App 已读取 accepted offer、预览和确认引用。接下来由外部 Buyer Agent adapter 在自己的 Grant/session 下提交；App 不会携带或伪造 Agent token。',
            ),
            const SizedBox(height: 12),
            _fact('handoff 状态', handoff.status.wireName),
            _fact('请求 ID', '${handoff.requestId}'),
            _fact('任务', handoff.taskTraceId),
            _fact('预览 ID', handoff.commitment.previewId),
            _fact('服务方接单 ID', handoff.commitment.providerAcceptanceId),
            _fact('报价版本', '${handoff.commitment.offerVersion}'),
            _fact('规格哈希', handoff.commitment.specHash),
            _fact('报价哈希', handoff.commitment.quoteHash),
            _fact('确认引用', handoff.commitment.confirmationRef),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _busy ? null : _load,
              icon: const Icon(Icons.refresh),
              label: const Text('刷新 Commitment 状态'),
            ),
          ],
        ),
      ),
    );
  }

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
