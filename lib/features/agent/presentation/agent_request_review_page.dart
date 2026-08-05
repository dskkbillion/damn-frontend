import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../core/dasn/data/dsn_order_repository.dart';
import '../data/agent_repository.dart';
import '../domain/agent_models.dart';
import 'agent_ui_helpers.dart';

class AgentRequestReviewPage extends StatefulWidget {
  final AgentRepository repository;
  final DsnOrderRepository? orderRepository;
  final int requestId;
  const AgentRequestReviewPage(
      {super.key,
      required this.repository,
      this.orderRepository,
      required this.requestId});
  @override
  State<AgentRequestReviewPage> createState() => _AgentRequestReviewPageState();
}

class _AgentRequestReviewPageState extends State<AgentRequestReviewPage> {
  AgentRequestDraft? _request;
  String? _error;
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final request = await widget.repository.getRequest(widget.requestId);
      if (mounted) setState(() => _request = request);
    } catch (error) {
      if (mounted) setState(() => _error = agentErrorMessage(context, error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _review(bool approve) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(approve
                  ? l10n.agentApproveRequest
                  : l10n.agentAbandonRequest),
              content: Text(approve
                  ? l10n.agentApproveRequestConfirmation
                  : l10n.agentAbandonRequestConfirmation),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(l10n.profile_cancel)),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child:
                        Text(approve ? l10n.agentApprove : l10n.agentAbandon)),
              ],
            ));
    if (confirmed != true) return;
    setState(() => _busy = true);
    try {
      if (approve) {
        final current = _request;
        final version = current?.version;
        final specHash = current?.specHash;
        if (version == null || specHash == null || specHash.trim().isEmpty) {
          throw const AgentApiException(
              'Request submission facts are unavailable; refresh the task first');
        }
        await widget.repository.submitRequest(widget.requestId,
            version: version, specHash: specHash);
      } else {
        await widget.repository.abandonRequest(widget.requestId);
      }
      await _load();
    } catch (error) {
      if (mounted) setState(() => _error = agentErrorMessage(context, error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final request = _request;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.agentReviewRequest)),
      body: _busy && request == null
          ? const Center(child: CircularProgressIndicator())
          : _error != null && request == null
              ? Center(child: Text(_error!))
              : request == null
                  ? const SizedBox.shrink()
                  : ListView(
                      // This page is opened inside the app shell, whose
                      // floating tab bar overlays the bottom of the route.
                      // Keep the final task-status/action controls above that
                      // bar so they remain reachable on short screens.
                      padding: EdgeInsets.fromLTRB(
                          20,
                          20,
                          20,
                          20 +
                              GlassNavigationMetrics.contentBottomInset(
                                  context)),
                      children: [
                          Card(
                              child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(request.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall),
                                      const SizedBox(height: 8),
                                      Chip(
                                          label: Text(agentStatusLabel(
                                              context, request.status))),
                                      const SizedBox(height: 16),
                                      Text(l10n.agentRequestBrief,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                      const SizedBox(height: 6),
                                      Text(request.brief),
                                      if (request.serviceId != null) ...[
                                        const SizedBox(height: 14),
                                        Text(
                                            '${l10n.agentServiceId}: ${request.serviceId}'),
                                      ],
                                      const SizedBox(height: 14),
                                      Text(
                                          '${l10n.agentCreatedAt}: ${agentDate(request.createdAt)}'),
                                      if (request.submittedAt != null) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                            '${l10n.agentSubmittedAt}: ${agentDate(request.submittedAt)}'),
                                      ],
                                      if (request.providerRespondedAt !=
                                          null) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                            '${l10n.agentProviderRespondedAt}: ${agentDate(request.providerRespondedAt)}'),
                                      ],
                                      if (request.chatId != null) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                            '${l10n.agentChatId}: ${request.chatId}'),
                                      ],
                                    ],
                                  ))),
                          const SizedBox(height: 12),
                          Card(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(l10n.agentReviewSafetyNotice))),
                          if (_error != null)
                            Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(_error!,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error))),
                          if (request.status == 'AWAITING_APP_REVIEW') ...[
                            const SizedBox(height: 24),
                            FilledButton(
                                onPressed: _busy ? null : () => _review(true),
                                child: Text(l10n.agentApproveRequest)),
                            TextButton(
                                onPressed: _busy ? null : () => _review(false),
                                child: Text(l10n.agentAbandonRequest)),
                          ] else if (request.chatId != null) ...[
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: () => context
                                  .go('/chat/refactored/${request.chatId}'),
                              icon: const Icon(Icons.forum_outlined),
                              label: Text(l10n.agentOpenChat),
                            ),
                          ],
                          // The provider response timestamp is the durable
                          // server fact. Some task projections use a more
                          // specific status after ProviderAcceptance, so
                          // gating this handoff on one presentation status
                          // would strand a valid accepted offer in the App.
                          if (_providerResponseAvailable(request) &&
                              widget.orderRepository != null) ...[
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: _busy
                                  ? null
                                  : () => context
                                      .push('/requests/${request.id}/order'),
                              icon: const Icon(Icons.receipt_long_outlined),
                              label: const Text('查看报价并继续下单'),
                            ),
                          ],
                          if (_hasTaskStatus(request)) ...[
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () => context.go(
                                  '/agent/tasks/${Uri.encodeComponent(request.taskTraceId!)}'),
                              icon: const Icon(Icons.timeline_outlined),
                              label: Text(l10n.agentViewTaskStatus),
                            ),
                          ],
                        ]),
    );
  }

  bool _hasTaskStatus(AgentRequestDraft request) {
    final taskTraceId = request.taskTraceId;
    if (taskTraceId == null || taskTraceId.trim().isEmpty) return false;
    // The App review controls are the mutable draft boundary.  Once a draft
    // has been submitted (or otherwise leaves the draft state), only the
    // read-only task projection is exposed from this page.
    return request.status != 'AWAITING_APP_REVIEW' && request.status != 'DRAFT';
  }

  bool _providerResponseAvailable(AgentRequestDraft request) =>
      request.status == 'PROVIDER_RESPONDED' ||
      request.providerRespondedAt != null;
}
