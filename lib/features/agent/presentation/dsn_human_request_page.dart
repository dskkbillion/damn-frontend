import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dasn/data/dsn_service_capability_repository.dart';
import '../../../core/dasn/domain/dsn_service_capability_models.dart';
import '../data/agent_repository.dart';

/// DS 0.2 HUMAN buyer ingress.
///
/// This page only creates the canonical request draft. Submission, provider
/// facts, payment and final acceptance remain on the existing review/order
/// boundaries; no App callback writes an order directly.
class DsnHumanRequestPage extends StatefulWidget {
  final AgentRepository repository;
  final DsnServiceCapabilityRepository capabilityRepository;
  final int initialServiceId;

  const DsnHumanRequestPage({
    super.key,
    required this.repository,
    required this.capabilityRepository,
    this.initialServiceId =
        DioDsnServiceCapabilityRepository.defaultStagingServiceId,
  });

  @override
  State<DsnHumanRequestPage> createState() => _DsnHumanRequestPageState();
}

class _DsnHumanRequestPageState extends State<DsnHumanRequestPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _serviceController;
  final _titleController = TextEditingController();
  final _briefController = TextEditingController();
  final _budgetController = TextEditingController();
  bool _busy = false;
  bool _loadingCapability = false;
  DsnServiceCapability? _capability;
  int _capabilityLoadGeneration = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _serviceController =
        TextEditingController(text: widget.initialServiceId.toString());
    // Resolve the initial catalog entry as soon as the page is mounted. The
    // request button remains fail-closed until the server returns a complete
    // capability and its revision.
    Future<void>.microtask(_loadCapability);
  }

  @override
  void dispose() {
    _serviceController.dispose();
    _titleController.dispose();
    _briefController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  int? _serviceId() {
    final value = int.tryParse(_serviceController.text.trim());
    return value != null && value > 0 ? value : null;
  }

  Future<void> _loadCapability() async {
    final serviceId = _serviceId();
    if (serviceId == null) {
      if (mounted) {
        setState(() {
          _capability = null;
          _error = 'Use a positive numeric service ID';
        });
      }
      return;
    }
    final generation = ++_capabilityLoadGeneration;
    setState(() {
      _loadingCapability = true;
      _capability = null;
      _error = null;
    });
    try {
      final capability =
          await widget.capabilityRepository.getServiceCapability(serviceId);
      if (!mounted || generation != _capabilityLoadGeneration) return;
      if (capability.serviceId != serviceId) {
        throw const DsnServiceCapabilityFormatException(
          'Capability response does not match the requested service',
          code: 'CAPABILITY_ID_MISMATCH',
        );
      }
      setState(() => _capability = capability);
    } catch (error) {
      if (mounted && generation == _capabilityLoadGeneration) {
        setState(() {
          _capability = null;
          _error = error.toString();
        });
      }
    } finally {
      if (mounted && generation == _capabilityLoadGeneration) {
        setState(() => _loadingCapability = false);
      }
    }
  }

  Future<DsnServiceCapability?> _ensureCapability() async {
    final serviceId = _serviceId();
    if (serviceId == null) return null;
    if (_capability?.serviceId == serviceId) return _capability;
    await _loadCapability();
    return _capability?.serviceId == serviceId ? _capability : null;
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final capability = await _ensureCapability();
      if (capability == null) {
        throw const DsnServiceCapabilityFormatException(
          'Load the server capability before creating a request',
          code: 'CAPABILITY_REQUIRED',
        );
      }
      final draft = await widget.repository.createHumanRequest(
        serviceId: capability.serviceId,
        capabilityRevision: capability.revision,
        title: _titleController.text,
        brief: _briefController.text,
        budgetMaxMinor: int.tryParse(_budgetController.text.trim()),
      );
      if (!mounted) return;
      context.push('/requests/${draft.id}/review');
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create a human request')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'DS 0.2: this creates a HUMAN request draft. The server binds your Member identity; it does not accept buyer, provider, session or payment fields from this form.',
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _serviceController,
              decoration: const InputDecoration(labelText: 'Service ID'),
              keyboardType: TextInputType.number,
              onChanged: (_) {
                setState(() {
                  ++_capabilityLoadGeneration;
                  _loadingCapability = false;
                  _capability = null;
                  _error = null;
                });
              },
              onFieldSubmitted: (_) => _loadCapability(),
              validator: (value) {
                final error = _required(value, 'Service ID');
                if (error != null) return error;
                final serviceId = int.tryParse(value!.trim());
                return serviceId == null || serviceId <= 0
                    ? 'Use a positive numeric service ID'
                    : null;
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _busy || _loadingCapability ? null : _loadCapability,
                icon: const Icon(Icons.refresh),
                label: const Text('Load server capability'),
              ),
            ),
            const SizedBox(height: 12),
            if (_loadingCapability)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(),
              ),
            if (_capability != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Server capability',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(_capability!.title),
                      const SizedBox(height: 4),
                      Text(
                        '${_capability!.amountMinor} ${_capability!.currency} · '
                        '${_capability!.deliveryHours}h delivery · '
                        '${_capability!.maxRevisions} revisions',
                      ),
                      const SizedBox(height: 4),
                      SelectableText('Revision: ${_capability!.revision}'),
                    ],
                  ),
                ),
              )
            else
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'A current server capability is required. The request will not use a local or placeholder revision.',
                  ),
                ),
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Request title'),
              validator: (value) => _required(value, 'Request title'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _briefController,
              decoration: const InputDecoration(
                labelText: 'Goal, deliverables and acceptance criteria',
              ),
              minLines: 4,
              maxLines: 8,
              validator: (value) => _required(value, 'Request brief'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _budgetController,
              decoration: const InputDecoration(
                labelText: 'Budget ceiling (credits, optional)',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                final amount = int.tryParse(value.trim());
                return amount == null || amount < 0
                    ? 'Use a non-negative integer'
                    : null;
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              key: const ValueKey<String>('create-human-request'),
              onPressed: _busy || _loadingCapability || _capability == null
                  ? null
                  : _create,
              child: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create request draft'),
            ),
          ],
        ),
      ),
    );
  }
}
