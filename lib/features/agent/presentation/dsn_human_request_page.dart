import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/agent_repository.dart';

/// DS 0.2 HUMAN buyer ingress.
///
/// This page only creates the canonical request draft. Submission, provider
/// facts, payment and final acceptance remain on the existing review/order
/// boundaries; no App callback writes an order directly.
class DsnHumanRequestPage extends StatefulWidget {
  final AgentRepository repository;

  const DsnHumanRequestPage({super.key, required this.repository});

  @override
  State<DsnHumanRequestPage> createState() => _DsnHumanRequestPageState();
}

class _DsnHumanRequestPageState extends State<DsnHumanRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _serviceController = TextEditingController(text: '581');
  final _revisionController = TextEditingController(text: 'sha256:${'0' * 64}');
  final _titleController = TextEditingController();
  final _briefController = TextEditingController();
  final _budgetController = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _serviceController.dispose();
    _revisionController.dispose();
    _titleController.dispose();
    _briefController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final draft = await widget.repository.createHumanRequest(
        serviceId: int.parse(_serviceController.text.trim()),
        capabilityRevision: _revisionController.text.trim(),
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
              validator: (value) {
                final error = _required(value, 'Service ID');
                if (error != null) return error;
                return int.tryParse(value!.trim()) == null
                    ? 'Use a numeric service ID'
                    : null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _revisionController,
              decoration: const InputDecoration(
                labelText: 'Capability revision (sha256)',
              ),
              validator: (value) => value != null &&
                      RegExp(r'^sha256:[a-f0-9]{64}$').hasMatch(value.trim())
                  ? null
                  : 'Use sha256:<64 lowercase hex>',
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
              onPressed: _busy ? null : _create,
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
