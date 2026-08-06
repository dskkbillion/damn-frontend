import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/dasn/data/dsn_mandate_repository.dart';
import 'package:dskk_flutter_refactor/core/dasn/domain/dsn_mandate_models.dart';
import 'package:dskk_flutter_refactor/core/dasn/data/dsn_provider_task_repository.dart';
import 'package:dskk_flutter_refactor/core/dasn/domain/dsn_provider_task_models.dart';
import 'package:dskk_flutter_refactor/features/agent/data/agent_repository.dart';
import 'package:dskk_flutter_refactor/features/agent/domain/agent_models.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:uuid/uuid.dart';

/// Principal-side, App-only Mandate management.
///
/// This surface intentionally contains just the P0 lifecycle: preview,
/// explicit confirmation, list/detail and revoke. There is no mutation that
/// could silently expand a Mandate or turn the App into an Agent session UI.
class DsnMandatesPage extends StatefulWidget {
  const DsnMandatesPage({
    super.key,
    required this.repository,
    required this.agentRepository,
    required this.providerTaskRepository,
  });

  final DsnMandateRepository repository;
  final AgentRepository agentRepository;
  final DsnProviderTaskRepository providerTaskRepository;

  @override
  State<DsnMandatesPage> createState() => _DsnMandatesPageState();
}

class _DsnMandatesPageState extends State<DsnMandatesPage> {
  List<DsnMandate>? _items;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final items = await widget.repository.list();
      if (mounted) setState(() => _items = items);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  Future<void> _create() async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => DsnMandateCreatePage(
        repository: widget.repository,
        agentRepository: widget.agentRepository,
        providerTaskRepository: widget.providerTaskRepository,
      ),
    ));
    if (mounted) await _load();
  }

  Future<void> _open(DsnMandate item) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => DsnMandateDetailPage(
        repository: widget.repository,
        mandateId: item.mandateId,
      ),
    ));
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.agentMandates)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _items == null ? null : _create,
        icon: const Icon(Icons.verified_user_outlined),
        label: Text(l10n.agentCreateMandate),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _items == null && _error == null
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(children: [
                    const SizedBox(height: 120),
                    Icon(Icons.cloud_off,
                        size: 48, color: Theme.of(context).colorScheme.error),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(_error!, textAlign: TextAlign.center),
                    ),
                    Center(
                      child: FilledButton(
                        onPressed: _load,
                        child: Text(l10n.agentRetry),
                      ),
                    ),
                  ])
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    children: [
                      Card(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(l10n.agentMandatesHint),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_items!.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 88),
                          child: Text(l10n.agentMandateNoItems,
                              textAlign: TextAlign.center),
                        )
                      else
                        ..._items!.map((item) => Card(
                              child: ListTile(
                                leading: Icon(_stateIcon(item.state)),
                                title: Text(
                                    _templateLabel(l10n, item.templateCode)),
                                subtitle: Text(
                                  '${item.subjectRole.wireValue} · ${item.agentClientId ?? '—'}\n'
                                  '${item.state.wireValue} · v${item.mandateVersion}',
                                ),
                                isThreeLine: true,
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _open(item),
                              ),
                            )),
                    ],
                  ),
      ),
    );
  }
}

class DsnMandateCreatePage extends StatefulWidget {
  const DsnMandateCreatePage({
    super.key,
    required this.repository,
    required this.agentRepository,
    required this.providerTaskRepository,
  });

  final DsnMandateRepository repository;
  final AgentRepository agentRepository;
  final DsnProviderTaskRepository providerTaskRepository;

  @override
  State<DsnMandateCreatePage> createState() => _DsnMandateCreatePageState();
}

class _DsnMandateCreatePageState extends State<DsnMandateCreatePage> {
  final _uuid = const Uuid();
  DsnMandateTemplateCode _template =
      DsnMandateTemplateCode.buyerFixedCommitmentV1;
  List<AgentSession>? _agents;
  AgentSession? _agent;
  List<AgentRequestDraft>? _buyerRequests;
  AgentRequestDraft? _buyerRequest;
  List<DsnProviderTask>? _providerTasks;
  DsnProviderTask? _providerTask;
  bool _loadingAgents = true;
  bool _loadingContexts = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAgents();
    _loadContexts();
  }

  Future<void> _loadAgents() async {
    setState(() {
      _loadingAgents = true;
      _error = null;
    });
    try {
      final page = await widget.agentRepository.listSessions();
      final active = page.items
          .where((session) => session.status == 'ACTIVE')
          .toList(growable: false);
      if (mounted) {
        setState(() {
          _agents = active;
          _agent = active.isEmpty ? null : active.first;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loadingAgents = false);
    }
  }

  Future<void> _loadContexts() async {
    setState(() => _loadingContexts = true);
    List<AgentRequestDraft> buyerRequests = const <AgentRequestDraft>[];
    List<DsnProviderTask> providerTasks = const <DsnProviderTask>[];
    Object? loadError;
    try {
      buyerRequests = await widget.agentRepository.listRequests();
    } catch (error) {
      loadError ??= error;
    }
    try {
      providerTasks =
          (await widget.providerTaskRepository.listAssignedTasks()).tasks;
    } catch (error) {
      loadError ??= error;
    }
    if (mounted) {
      setState(() {
        _buyerRequests = buyerRequests;
        _buyerRequest = buyerRequests.isEmpty ? null : buyerRequests.first;
        _providerTasks = providerTasks;
        _providerTask = providerTasks.isEmpty ? null : providerTasks.first;
        if (loadError != null) _error = loadError.toString();
      });
    }
    if (mounted) setState(() => _loadingContexts = false);
  }

  bool get _isBuyerTemplate =>
      _template == DsnMandateTemplateCode.buyerFixedCommitmentV1;

  bool get _hasSelectedContext =>
      _isBuyerTemplate ? _buyerRequest != null : _providerTask != null;

  Future<void> _preview() async {
    if (_agent == null || !_hasSelectedContext || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final binding = _isBuyerTemplate
          ? await widget.repository.bindBuyerRequest(
              _buyerRequest!.id,
              agentSessionId: _agent!.id.toString(),
              idempotencyKey: 'app-mandate-buyer-binding-${_uuid.v4()}',
            )
          : await widget.repository.bindProviderTask(
              _providerTask!.taskTraceId,
              agentSessionId: _agent!.id.toString(),
              idempotencyKey: 'app-mandate-provider-binding-${_uuid.v4()}',
            );
      if (!binding.allowedTemplateCodes.contains(_template)) {
        throw const DsnMandateApiException(
          'Selected context cannot create this Mandate template',
          code: 'MANDATE_RESOURCE_BINDING_TEMPLATE_INVALID',
        );
      }
      final preview = await widget.repository.createPreview(
        DsnMandatePreviewInput(
          templateCode: _template,
          resourceRef: binding.resourceRef,
        ),
        idempotencyKey: 'app-mandate-preview-${_uuid.v4()}',
      );
      if (!mounted) return;
      final created = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => DsnMandatePreviewPage(
            repository: widget.repository,
            preview: preview,
          ),
        ),
      );
      if (mounted && created == true) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.agentCreateMandate)),
      body: _loadingAgents || _loadingContexts
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                Text(l10n.agentMandatesHint),
                const SizedBox(height: 16),
                DropdownButtonFormField<DsnMandateTemplateCode>(
                  initialValue: _template,
                  decoration:
                      InputDecoration(labelText: l10n.agentMandateTemplate),
                  items: DsnMandateTemplateCode.values
                      .map((template) => DropdownMenuItem(
                            value: template,
                            child: Text(_templateLabel(l10n, template)),
                          ))
                      .toList(growable: false),
                  onChanged: _busy
                      ? null
                      : (template) {
                          if (template != null) {
                            setState(() => _template = template);
                          }
                        },
                ),
                const SizedBox(height: 12),
                if (_agents!.isEmpty)
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(l10n.agentMandateNoAgents),
                    ),
                  )
                else
                  DropdownButtonFormField<AgentSession>(
                    initialValue: _agent,
                    decoration:
                        InputDecoration(labelText: l10n.agentMandateAgent),
                    items: _agents!
                        .map((agent) => DropdownMenuItem(
                              value: agent,
                              child: Text(
                                  '${agent.clientName} (#${agent.clientId})'),
                            ))
                        .toList(growable: false),
                    onChanged: _busy
                        ? null
                        : (agent) => setState(() => _agent = agent),
                  ),
                const SizedBox(height: 12),
                if (_isBuyerTemplate) ...[
                  Text(l10n.agentMandateBuyerContext,
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  if (_buyerRequests!.isEmpty)
                    _missingContextCard(
                        context, l10n.agentMandateNoBuyerContexts)
                  else
                    DropdownButtonFormField<AgentRequestDraft>(
                      initialValue: _buyerRequest,
                      decoration: InputDecoration(
                          labelText: l10n.agentMandateBuyerContext),
                      items: _buyerRequests!
                          .map((request) => DropdownMenuItem(
                                value: request,
                                child: Text(
                                    '#${request.id} · ${request.title} (${request.status})'),
                              ))
                          .toList(growable: false),
                      onChanged: _busy
                          ? null
                          : (request) =>
                              setState(() => _buyerRequest = request),
                    ),
                ] else ...[
                  Text(l10n.agentMandateProviderContext,
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  if (_providerTasks!.isEmpty)
                    _missingContextCard(
                        context, l10n.agentMandateNoProviderContexts)
                  else
                    DropdownButtonFormField<DsnProviderTask>(
                      initialValue: _providerTask,
                      decoration: InputDecoration(
                          labelText: l10n.agentMandateProviderContext),
                      items: _providerTasks!
                          .map((task) => DropdownMenuItem(
                                value: task,
                                child: Text('${task.title} (${task.status})'),
                              ))
                          .toList(growable: false),
                      onChanged: _busy
                          ? null
                          : (task) => setState(() => _providerTask = task),
                    ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _agents!.isEmpty || !_hasSelectedContext || _busy
                      ? null
                      : _preview,
                  child: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.agentMandatePreview),
                ),
              ],
            ),
    );
  }
}

class DsnMandatePreviewPage extends StatefulWidget {
  const DsnMandatePreviewPage({
    super.key,
    required this.repository,
    required this.preview,
  });

  final DsnMandateRepository repository;
  final DsnMandatePreview preview;

  @override
  State<DsnMandatePreviewPage> createState() => _DsnMandatePreviewPageState();
}

class _DsnMandatePreviewPageState extends State<DsnMandatePreviewPage> {
  final _uuid = const Uuid();
  bool _busy = false;
  String? _error;

  Future<void> _confirm() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.agentMandateConfirm),
        content: Text(l10n.agentMandateConfirmMessage),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.profile_cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.agentMandateConfirm)),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.repository.confirmPreview(
        widget.preview.previewId,
        approvalRef: widget.preview.approvalRef,
        expectedPreviewHash: widget.preview.previewHash,
        expectedReviewHash: widget.preview.reviewHash,
        idempotencyKey: 'app-mandate-confirm-${_uuid.v4()}',
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final preview = widget.preview;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.agentMandateReviewTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_templateLabel(l10n, preview.templateCode),
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                        '${l10n.agentMandateAgent}: ${preview.agentClientId ?? '—'}'),
                    Text(
                      '${l10n.agentMandateAllowedActions}:\n'
                      '${preview.allowedActionClasses.map((action) => _actionLabel(l10n, action)).join('\n')}',
                    ),
                    const SizedBox(height: 12),
                    Text(l10n.agentMandateReviewFacts,
                        style: Theme.of(context).textTheme.titleSmall),
                    _reviewFact(l10n.agentMandateReviewCapability,
                        preview.review.capability),
                    _reviewFact(l10n.agentMandateReviewProvider,
                        preview.review.provider),
                    _reviewFact(
                        l10n.agentMandateReviewBuyer, preview.review.buyer),
                    _reviewFact(
                        l10n.agentMandateReviewVariant, preview.review.variant),
                    _reviewFact(l10n.agentMandateReviewQuantity,
                        preview.review.quantity.toString()),
                    _reviewFact(l10n.agentMandateReviewCapacity,
                        preview.review.capacity.toString()),
                    _reviewFact(
                      l10n.agentMandateReviewPrice,
                      '${preview.review.amountMinor} ${preview.review.currency}',
                    ),
                    _reviewFact(l10n.agentMandateReviewSla,
                        preview.review.sla.toString()),
                    _reviewFact(l10n.agentMandateReviewMaxDelivery,
                        '${preview.review.maxDeliverySeconds}s'),
                    Text(
                        '${l10n.agentMandateExpiresAt}: ${preview.expiresAt.toLocal()}'),
                    const SizedBox(height: 8),
                    Text(preview.reviewHash,
                        style: Theme.of(context).textTheme.bodySmall),
                  ]),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy ? null : _confirm,
            child: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.agentMandateConfirm),
          ),
        ],
      ),
    );
  }
}

class DsnMandateDetailPage extends StatefulWidget {
  const DsnMandateDetailPage(
      {super.key, required this.repository, required this.mandateId});

  final DsnMandateRepository repository;
  final String mandateId;

  @override
  State<DsnMandateDetailPage> createState() => _DsnMandateDetailPageState();
}

class _DsnMandateDetailPageState extends State<DsnMandateDetailPage> {
  final _uuid = const Uuid();
  DsnMandate? _mandate;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final mandate = await widget.repository.get(widget.mandateId);
      if (mounted) setState(() => _mandate = mandate);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  Future<void> _revoke() async {
    final mandate = _mandate;
    if (mandate == null || mandate.state != DsnMandateState.active || _busy) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.agentMandateRevoke),
        content: Text(l10n.agentMandateRevokeConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.profile_cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.agentMandateRevoke)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final revoked = await widget.repository.revoke(
        mandate,
        idempotencyKey: 'app-mandate-revoke-${_uuid.v4()}',
      );
      if (mounted) setState(() => _mandate = revoked);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mandate = _mandate;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.agentMandates)),
      body: mandate == null
          ? _error != null
              ? Center(child: Text(_error!))
              : const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(_templateLabel(l10n, mandate.templateCode),
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                _fact(
                    context, l10n.agentMandateStatus, mandate.state.wireValue),
                _fact(context, l10n.agentMandateAgent,
                    mandate.agentClientId ?? '—'),
                _fact(context, l10n.agentMandateVersion,
                    mandate.mandateVersion.toString()),
                _fact(context, l10n.agentMandateHash, mandate.mandateHash),
                if (mandate.revokedAt != null)
                  _fact(context, l10n.agentMandateRevokedAt,
                      mandate.revokedAt!.toLocal().toString()),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 24),
                if (mandate.state == DsnMandateState.active)
                  FilledButton.tonalIcon(
                    onPressed: _busy ? null : _revoke,
                    icon: const Icon(Icons.block_outlined),
                    label: Text(l10n.agentMandateRevoke),
                  ),
              ],
            ),
    );
  }
}

Widget _fact(BuildContext context, String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 3),
        SelectableText(value),
      ]),
    );

Widget _reviewFact(String label, String value) => Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text('$label: $value'),
    );

Widget _missingContextCard(BuildContext context, String message) => Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message),
      ),
    );

IconData _stateIcon(DsnMandateState state) => switch (state) {
      DsnMandateState.active => Icons.verified_user_outlined,
      DsnMandateState.revoked => Icons.block_outlined,
      DsnMandateState.expired => Icons.schedule_outlined,
      DsnMandateState.exhausted => Icons.hourglass_empty_outlined,
    };

String _templateLabel(AppLocalizations l10n, DsnMandateTemplateCode template) =>
    switch (template) {
      DsnMandateTemplateCode.buyerFixedCommitmentV1 =>
        l10n.agentMandateBuyerTemplate,
      DsnMandateTemplateCode.providerFixedTaskV1 =>
        l10n.agentMandateProviderTaskTemplate,
    };

/// The server remains authoritative for this exact action set. The App only
/// turns known fixed codes into reviewable text; unknown server actions remain
/// visible as their wire code rather than being silently permitted or hidden.
String _actionLabel(AppLocalizations l10n, String action) => switch (action) {
      'BUYER_CONFIRM_COMMITMENT' => l10n.agentMandateActionBuyerCommitment,
      'PROVIDER_SUBMIT_FIXED_OFFER' => l10n.agentMandateActionProviderOffer,
      'PROVIDER_ACCEPT_FIXED_REQUEST' => l10n.agentMandateActionProviderAccept,
      'PROVIDER_SUBMIT_DELIVERY' => l10n.agentMandateActionProviderDelivery,
      _ => action,
    };
