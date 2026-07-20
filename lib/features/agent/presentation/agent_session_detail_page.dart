import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import '../data/agent_repository.dart';
import '../domain/agent_models.dart';
import 'agent_ui_helpers.dart';

class AgentSessionDetailPage extends StatefulWidget {
  final AgentRepository repository;
  final int sessionId;
  const AgentSessionDetailPage(
      {super.key, required this.repository, required this.sessionId});
  @override
  State<AgentSessionDetailPage> createState() => _AgentSessionDetailPageState();
}

class _AgentSessionDetailPageState extends State<AgentSessionDetailPage> {
  AgentSessionDetail? _detail;
  Set<String> _scopes = {};
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
      final detail = await widget.repository.getSession(widget.sessionId);
      if (mounted) {
        setState(() {
          _detail = detail;
          _scopes = {...detail.session.scopes};
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = agentErrorMessage(context, error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveScopes() async {
    if (_scopes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(AppLocalizations.of(context).agentAtLeastOnePermission)));
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.repository.reduceScopes(widget.sessionId, _scopes);
      await _load();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(agentErrorMessage(context, error))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _revoke() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(l10n.agentRevokeAgent),
              content: Text(l10n.agentRevokeConfirmation),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(l10n.profile_cancel)),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(l10n.agentRevoke)),
              ],
            ));
    if (confirmed != true) return;
    setState(() => _busy = true);
    try {
      await widget.repository.revokeSession(widget.sessionId);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(agentErrorMessage(context, error))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = _detail?.session;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.agentDetails)),
      body: _busy && _detail == null
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(_error!),
                    const SizedBox(height: 12),
                    FilledButton(
                        onPressed: _load, child: Text(l10n.agentRetry)),
                  ]),
                )
              : session == null
                  ? const SizedBox.shrink()
                  : ListView(
                      padding: EdgeInsets.fromLTRB(
                          16,
                          16,
                          16,
                          MediaQuery.paddingOf(context).bottom + 96),
                      children: [
                      Card(
                          child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(session.clientName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge),
                                  if (session.clientType != null)
                                    Text(
                                        '${l10n.agentClientType}: ${session.clientType}'),
                                  Text(
                                      '${l10n.agentClientId}: #${session.clientId}'),
                                  Text(session.platform ??
                                      l10n.agentUnknownPlatform),
                                  if (session.deviceName != null)
                                    Text(session.deviceName!),
                                  if (session.cliVersion != null)
                                    Text('CLI ${session.cliVersion}'),
                                  const SizedBox(height: 12),
                                  Text(
                                      '${l10n.agentSessionId}: …${session.id.toString().padLeft(6, '0').substring(session.id.toString().padLeft(6, '0').length - 6)}'),
                                  Text(
                                      '${l10n.agentStatus}: ${agentStatusLabel(context, session.status)}'),
                                  Text(
                                      '${l10n.agentConnectedAt}: ${agentDate(session.createdAt)}'),
                                  Text(
                                      '${l10n.agentLastUsedLabel}: ${agentDate(session.lastUsedAt)}'),
                                  Text(
                                      '${l10n.agentAccessExpiresAt}: ${agentDate(session.accessExpiresAt)}'),
                                  Text(
                                      '${l10n.agentAuthorizationExpiresAt}: ${agentDate(session.refreshExpiresAt)}'),
                                  const SizedBox(height: 12),
                                  Text(l10n.agentClientMetadataNotice,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                ],
                              ))),
                      const SizedBox(height: 12),
                      Card(
                          child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.agentPermissions,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  ...session.scopes.map((scope) =>
                                      CheckboxListTile(
                                        contentPadding: EdgeInsets.zero,
                                        value: _scopes.contains(scope),
                                        title: Text(
                                            agentScopeLabel(context, scope)),
                                        onChanged:
                                            session.status != 'ACTIVE' || _busy
                                                ? null
                                                : (value) => setState(() {
                                                      if (value == true) {
                                                        _scopes.add(scope);
                                                      } else {
                                                        _scopes.remove(scope);
                                                      }
                                                    }),
                                      )),
                                  if (session.status == 'ACTIVE')
                                    SizedBox(
                                        width: double.infinity,
                                        child: FilledButton(
                                            onPressed:
                                                _busy ? null : _saveScopes,
                                            child: Text(
                                                l10n.agentSavePermissions))),
                                  Text(l10n.agentCannotAddPermissions),
                                ],
                              ))),
                      const SizedBox(height: 12),
                      Text(l10n.agentRecentSecurityEvents,
                          style: Theme.of(context).textTheme.titleMedium),
                      ..._detail!.events.map((event) => ListTile(
                            leading: const Icon(Icons.shield_outlined),
                            title: Text(
                                agentAuditActionLabel(context, event.action)),
                            subtitle: Text(
                                '${agentAuditResultLabel(context, event.result)} · ${agentDate(event.createdAt)}'),
                          )),
                      if (session.status == 'ACTIVE')
                        Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: OutlinedButton(
                                onPressed: _busy ? null : _revoke,
                                style: OutlinedButton.styleFrom(
                                    foregroundColor:
                                        Theme.of(context).colorScheme.error),
                                child: Text(l10n.agentRevokeAgent))),
                    ]),
    );
  }
}
