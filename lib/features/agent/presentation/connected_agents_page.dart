import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import '../data/agent_repository.dart';
import '../domain/agent_models.dart';
import 'agent_ui_helpers.dart';
import 'agent_session_detail_page.dart';

class ConnectedAgentsPage extends StatefulWidget {
  final AgentRepository repository;
  const ConnectedAgentsPage({super.key, required this.repository});
  @override
  State<ConnectedAgentsPage> createState() => _ConnectedAgentsPageState();
}

class _ConnectedAgentsPageState extends State<ConnectedAgentsPage> {
  List<AgentSession>? _sessions;
  String? _error;
  bool _loading = false;
  bool _loadingMore = false;
  bool _mutationBusy = false;
  bool _hasMore = false;
  int? _nextCursor;
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final generation = ++_loadGeneration;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await widget.repository.listSessions();
      if (mounted && generation == _loadGeneration) {
        setState(() {
          _sessions = page.items;
          _hasMore = page.hasMore;
          _nextCursor = page.nextCursor;
        });
      }
    } catch (error) {
      if (mounted && generation == _loadGeneration) {
        setState(() => _error = agentErrorMessage(context, error));
      }
    } finally {
      if (mounted && generation == _loadGeneration) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore || _nextCursor == null) return;
    setState(() => _loadingMore = true);
    try {
      final page = await widget.repository.listSessions(beforeId: _nextCursor);
      if (mounted) {
        setState(() {
          _sessions = [...?_sessions, ...page.items];
          _hasMore = page.hasMore;
          _nextCursor = page.nextCursor;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(agentErrorMessage(context, error))));
      }
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _revokeAll() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(l10n.agentRevokeAll),
              content: Text(l10n.agentRevokeAllConfirmation),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(l10n.profile_cancel)),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(l10n.agentRevoke)),
              ],
            ));
    if (confirmed != true || _mutationBusy) return;
    setState(() => _mutationBusy = true);
    try {
      await widget.repository.revokeAllSessions();
      await _load();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(agentErrorMessage(context, error))));
      }
    } finally {
      if (mounted) setState(() => _mutationBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final active =
        _sessions?.where((session) => session.status == 'ACTIVE').length ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.agentConnectedAgents),
        actions: [
          if (active > 0)
            TextButton(
                onPressed: _mutationBusy ? null : _revokeAll,
                child: Text(l10n.agentRevokeAll))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading && _sessions == null
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(children: [
                    const SizedBox(height: 120),
                    Icon(Icons.cloud_off,
                        size: 48, color: Theme.of(context).colorScheme.error),
                    Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(_error!, textAlign: TextAlign.center)),
                    Center(
                        child: FilledButton(
                            onPressed: _load, child: Text(l10n.agentRetry))),
                  ])
                : (_sessions?.isEmpty ?? true)
                    ? ListView(children: [
                        const SizedBox(height: 120),
                        const Icon(Icons.devices_other, size: 56),
                        const SizedBox(height: 16),
                        Text(l10n.agentNoConnectedAgents,
                            textAlign: TextAlign.center),
                        Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(l10n.agentNoConnectedAgentsHint,
                                textAlign: TextAlign.center)),
                      ])
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _sessions!.length + 1 + (_hasMore ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Card(
                                child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.agentNoPaymentNotice),
                                  const SizedBox(height: 8),
                                  Text(l10n.agentClientMetadataNotice,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                ],
                              ),
                            ));
                          }
                          if (_hasMore && index == _sessions!.length + 1) {
                            return Center(
                              child: TextButton(
                                onPressed: _loadingMore ? null : _loadMore,
                                child: Text(_loadingMore
                                    ? l10n.home_loading_more
                                    : l10n.product_detail_more),
                              ),
                            );
                          }
                          final session = _sessions![index - 1];
                          return Card(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => AgentSessionDetailPage(
                                            repository: widget.repository,
                                            sessionId: session.id)));
                                await _load();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const CircleAvatar(
                                        child: Icon(Icons.smart_toy_outlined)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(session.clientName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium),
                                          const SizedBox(height: 4),
                                          Text([
                                            if (session.clientType != null)
                                              session.clientType!,
                                            '${l10n.agentClientId}: #${session.clientId}',
                                            if (session.deviceName != null)
                                              session.deviceName!,
                                            session.platform ??
                                                l10n.agentUnknownPlatform,
                                            if (session.cliVersion != null)
                                              'CLI ${session.cliVersion}',
                                          ].join(' · ')),
                                          const SizedBox(height: 8),
                                          Text(
                                              '${l10n.agentStatus}: ${agentStatusLabel(context, session.status)}'),
                                          Text(
                                              '${l10n.agentConnectedAt}: ${agentDate(session.createdAt)}'),
                                          Text(l10n.agentLastUsed(
                                              agentDate(session.lastUsedAt))),
                                          Text(
                                              '${l10n.agentAccessExpiresAt}: ${agentDate(session.accessExpiresAt)}'),
                                          Text(
                                              '${l10n.agentAuthorizationExpiresAt}: ${agentDate(session.refreshExpiresAt)}'),
                                          const SizedBox(height: 8),
                                          Text(session.scopes
                                              .map((scope) => agentScopeLabel(
                                                  context, scope))
                                              .join(' · ')),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
