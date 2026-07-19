import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import '../data/agent_repository.dart';
import '../domain/agent_models.dart';
import 'agent_ui_helpers.dart';
import 'connected_agents_page.dart';

class DeviceAuthorizationPage extends StatefulWidget {
  final AgentRepository repository;
  final String? initialCode;
  const DeviceAuthorizationPage({
    super.key,
    required this.repository,
    this.initialCode,
  });

  @override
  State<DeviceAuthorizationPage> createState() =>
      _DeviceAuthorizationPageState();
}

class _DeviceAuthorizationPageState extends State<DeviceAuthorizationPage> {
  late final TextEditingController _code;
  AgentAuthorization? _authorization;
  Set<String> _selectedScopes = {};
  String? _authorizationCode;
  int _requestGeneration = 0;
  bool _loading = false;
  String? _error;
  String? _terminalMessage;

  @override
  void initState() {
    super.initState();
    _code = TextEditingController(
        text: normalizeAgentCode(widget.initialCode ?? ''));
    if (_code.text.replaceAll('-', '').length == 8) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _inspect();
      });
    }
  }

  @override
  void didUpdateWidget(covariant DeviceAuthorizationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previousCode = normalizeAgentCode(oldWidget.initialCode ?? '');
    final nextCode = normalizeAgentCode(widget.initialCode ?? '');
    if (previousCode == nextCode) return;

    _requestGeneration++;
    _code.text = nextCode;
    _authorization = null;
    _authorizationCode = null;
    _selectedScopes = {};
    _loading = false;
    _error = null;
    _terminalMessage = null;
    if (nextCode.replaceAll('-', '').length == 8) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _inspect();
      });
    }
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _inspect() async {
    final normalized = normalizeAgentCode(_code.text);
    if (normalized.replaceAll('-', '').length != 8) {
      setState(() => _error = AppLocalizations.of(context).agentInvalidCode);
      return;
    }
    final generation = ++_requestGeneration;
    setState(() {
      _loading = true;
      _error = null;
      _terminalMessage = null;
      _authorization = null;
      _authorizationCode = null;
      _selectedScopes = {};
    });
    try {
      final authorization =
          await widget.repository.inspectAuthorization(normalized);
      if (!mounted ||
          generation != _requestGeneration ||
          normalized != normalizeAgentCode(_code.text)) {
        return;
      }
      if (authorization.status != 'PENDING') {
        setState(() {
          _authorization = null;
          _authorizationCode = null;
          _terminalMessage =
              agentAuthorizationStatusMessage(context, authorization.status);
        });
        return;
      }
      setState(() {
        _authorization = authorization;
        _authorizationCode = normalized;
        _selectedScopes = {...authorization.requestedScopes};
      });
    } catch (error) {
      if (mounted && generation == _requestGeneration) {
        setState(() => _error = agentErrorMessage(context, error));
      }
    } finally {
      if (mounted && generation == _requestGeneration) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _approve() async {
    final authorizationCode = _authorizationCode;
    if (_authorization == null || authorizationCode == null) return;
    if (_selectedScopes.isEmpty) {
      setState(
          () => _error = AppLocalizations.of(context).agentChoosePermission);
      return;
    }
    await _operate(
        () => widget.repository.approveAuthorization(
            authorizationCode, {..._selectedScopes}),
        authorizationCode,
        AppLocalizations.of(context).agentAuthorizationApproved);
  }

  Future<void> _deny() async {
    final authorizationCode = _authorizationCode;
    if (_authorization == null || authorizationCode == null) return;
    await _operate(
        () => widget.repository.denyAuthorization(authorizationCode),
        authorizationCode,
        AppLocalizations.of(context).agentAuthorizationDenied);
  }

  Future<void> _operate(
      Future<void> Function() operation, String authorizationCode,
      String message) async {
    final generation = _requestGeneration;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await operation();
      if (mounted &&
          generation == _requestGeneration &&
          authorizationCode == normalizeAgentCode(_code.text)) {
        setState(() {
          _terminalMessage = message;
          _authorization = null;
          _authorizationCode = null;
        });
      }
    } catch (error) {
      if (mounted && generation == _requestGeneration) {
        setState(() => _error = agentErrorMessage(context, error));
      }
    } finally {
      if (mounted && generation == _requestGeneration) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.agentConnectTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Icon(Icons.smart_toy_outlined,
                size: 54, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(l10n.agentConnectDescription, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            TextField(
              controller: _code,
              readOnly: _loading,
              textCapitalization: TextCapitalization.characters,
              maxLength: 9,
              decoration: InputDecoration(
                labelText: l10n.agentUserCode,
                hintText: 'ABCD-EFGH',
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                final normalized = normalizeAgentCode(value);
                if (normalized != value) {
                  _code.value = TextEditingValue(
                      text: normalized,
                      selection:
                          TextSelection.collapsed(offset: normalized.length));
                }
                if (_authorizationCode != normalized) {
                  setState(() {
                    _requestGeneration++;
                    _authorization = null;
                    _authorizationCode = null;
                    _selectedScopes = {};
                    _loading = false;
                    _error = null;
                    _terminalMessage = null;
                  });
                }
              },
            ),
            FilledButton(
              onPressed: _loading ? null : _inspect,
              child: Text(l10n.agentCheckRequest),
            ),
            if (_loading)
              const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator())),
            if (_error != null) _MessageCard(message: _error!, error: true),
            if (_terminalMessage != null)
              _MessageCard(message: _terminalMessage!),
            TextButton.icon(
              onPressed: _loading
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConnectedAgentsPage(
                              repository: widget.repository),
                        ),
                      ),
              icon: const Icon(Icons.devices_other),
              label: Text(l10n.agentManageConnectedAgents),
            ),
            if (_authorization != null) ...[
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_authorization!.clientName,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text([
                        _authorization!.clientType,
                        _authorization!.deviceName,
                        _authorization!.platform,
                        _authorization!.cliVersion == null
                            ? null
                            : 'CLI ${_authorization!.cliVersion}',
                      ].whereType<String>().join(' · ').isEmpty
                          ? l10n.agentUnknownPlatform
                          : [
                              _authorization!.clientType,
                              _authorization!.deviceName,
                              _authorization!.platform,
                              _authorization!.cliVersion == null
                                  ? null
                                  : 'CLI ${_authorization!.cliVersion}',
                            ].whereType<String>().join(' · ')),
                      const SizedBox(height: 8),
                      Text(l10n.agentClientMetadataNotice,
                          style: Theme.of(context).textTheme.bodySmall),
                      Text(
                          '${l10n.agentAuthorizationRequestExpiresAt}: ${agentDate(_authorization!.expiresAt)}',
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 12),
                      Text(l10n.agentRequestedPermissions,
                          style: Theme.of(context).textTheme.titleMedium),
                      ..._authorization!.requestedScopes
                          .map((scope) => CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                value: _selectedScopes.contains(scope),
                                title: Text(agentScopeLabel(context, scope)),
                                onChanged: _loading
                                    ? null
                                    : (selected) => setState(() {
                                          if (selected == true) {
                                            _selectedScopes.add(scope);
                                          } else {
                                            _selectedScopes.remove(scope);
                                          }
                                        }),
                              )),
                      const Divider(),
                      Text(l10n.agentNeverIncludes,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                            child: OutlinedButton(
                          onPressed: _loading ? null : _deny,
                          child: Text(l10n.agentDeny),
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: FilledButton(
                          onPressed: _loading ? null : _approve,
                          child: Text(l10n.agentAllow),
                        )),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String message;
  final bool error;
  const _MessageCard({required this.message, this.error = false});
  @override
  Widget build(BuildContext context) => Card(
        color: error
            ? Theme.of(context).colorScheme.errorContainer
            : Theme.of(context).colorScheme.primaryContainer,
        child: Padding(padding: const EdgeInsets.all(14), child: Text(message)),
      );
}
