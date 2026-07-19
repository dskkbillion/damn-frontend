import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import '../data/agent_repository.dart';
import '../domain/agent_models.dart';
import 'agent_request_review_page.dart';
import 'agent_ui_helpers.dart';

class AgentRequestsPage extends StatefulWidget {
  final AgentRepository repository;
  const AgentRequestsPage({super.key, required this.repository});
  @override
  State<AgentRequestsPage> createState() => _AgentRequestsPageState();
}

class _AgentRequestsPageState extends State<AgentRequestsPage> {
  List<AgentRequestDraft>? _requests;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final requests = await widget.repository.listRequests();
      if (mounted) {
        setState(() {
          _requests = requests;
          _error = null;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = agentErrorMessage(context, error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.agentRequestDrafts)),
      body: RefreshIndicator(
          onRefresh: _load,
          child: _error != null
              ? ListView(children: [
                  const SizedBox(height: 120),
                  Center(child: Text(_error!))
                ])
              : _requests == null
                  ? const Center(child: CircularProgressIndicator())
                  : _requests!.isEmpty
                      ? ListView(children: [
                          const SizedBox(height: 120),
                          const Icon(Icons.inbox_outlined, size: 56),
                          const SizedBox(height: 16),
                          Text(l10n.agentNoRequestDrafts,
                              textAlign: TextAlign.center),
                        ])
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _requests!.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final request = _requests![index];
                            return Card(
                                child: ListTile(
                              title: Text(request.title),
                              subtitle: Text(
                                  '${agentStatusLabel(context, request.status)}\n${agentDate(request.createdAt)}'),
                              isThreeLine: true,
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => AgentRequestReviewPage(
                                            repository: widget.repository,
                                            requestId: request.id)));
                                _load();
                              },
                            ));
                          },
                        )),
    );
  }
}
