import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/dasn/data/dasn_task_repository.dart';
import 'package:dskk_flutter_refactor/core/dasn/domain/dasn_domain.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

/// Read-only DS 0.1 task projection surface.
///
/// This page deliberately has no order, payment, delivery or dispute write
/// controls.  It can only refresh the server projection (or open the
/// read-only receipt endpoint), so a stale client cannot change business
/// facts while displaying a task.
class DsnTaskPage extends StatefulWidget {
  const DsnTaskPage({
    super.key,
    required this.repository,
    required this.taskTraceId,
  });

  final DasnTaskRepository repository;
  final String taskTraceId;

  @override
  State<DsnTaskPage> createState() => _DsnTaskPageState();
}

class _DsnTaskPageState extends State<DsnTaskPage> {
  DasnTaskView? _view;
  String? _error;
  bool _loading = false;
  bool _loadingReceipt = false;
  String? _receiptError;

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
      final view = await widget.repository.getTask(widget.taskTraceId);
      if (mounted) {
        setState(() {
          _view = view;
          _receiptError = null;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = _errorText(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadReceipt() async {
    if (_loadingReceipt) return;
    setState(() {
      _loadingReceipt = true;
      _receiptError = null;
    });
    try {
      final view = await widget.repository.getReceipt(widget.taskTraceId);
      if (mounted) setState(() => _view = view);
    } catch (error) {
      if (mounted) setState(() => _receiptError = _errorText(error));
    } finally {
      if (mounted) setState(() => _loadingReceipt = false);
    }
  }

  String _errorText(Object error) {
    if (error is DasnTaskApiException && error.message.trim().isNotEmpty) {
      return error.message;
    }
    if (error is DasnProjectionFormatException &&
        error.message.trim().isNotEmpty) {
      return error.message;
    }
    return AppLocalizations.of(context).agentErrorGeneric;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final view = _view;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dsnTaskStatusTitle)),
      body: view == null
          ? _buildInitialState(l10n)
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  if (_error != null) _buildInlineError(l10n, _error!),
                  _buildIdentityCard(context, l10n, view),
                  const SizedBox(height: 12),
                  _buildAxesCard(context, l10n, view.projection),
                  const SizedBox(height: 12),
                  _buildPrimaryActionCard(context, l10n, view.projection),
                  const SizedBox(height: 12),
                  _buildReceiptCard(context, l10n, view),
                ],
              ),
            ),
    );
  }

  Widget _buildInitialState(AppLocalizations l10n) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final error = _error;
    if (error == null) return const SizedBox.shrink();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loading ? null : _load,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.agentRetry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineError(AppLocalizations l10n, String error) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_outlined,
                color: Theme.of(context).colorScheme.onErrorContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(error,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer)),
            ),
            TextButton(
              onPressed: _loading ? null : _load,
              child: Text(l10n.agentRetry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityCard(
      BuildContext context, AppLocalizations l10n, DasnTaskView view) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.dsnTaskIdentity,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            _factRow(l10n.dsnTaskTraceId, view.taskTraceId),
            _factRow(l10n.dsnTaskOperationTraceId, view.operationTraceId),
          ],
        ),
      ),
    );
  }

  Widget _buildAxesCard(
      BuildContext context, AppLocalizations l10n, TaskProjection projection) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.dsnTaskAxes,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            _factRow(l10n.dsnTaskLifecycle, projection.taskLifecycle.wireValue),
            _factRow(l10n.dsnTaskResponsibility,
                projection.responsibilityAction.wireValue),
            _factRow(l10n.dsnTaskSyncStatus, projection.syncStatus.wireValue),
            _factRow(l10n.dsnTaskWaitingOn, projection.waitingOn.wireValue),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryActionCard(
      BuildContext context, AppLocalizations l10n, TaskProjection projection) {
    final action = reduceDasnNextAction(projection);
    final canRefresh = action.kind == NextActionKind.recoverOperation ||
        action.kind == NextActionKind.recoverTask ||
        action.kind == NextActionKind.recoveryInProgress ||
        action.kind == NextActionKind.viewProgress ||
        action.kind == NextActionKind.viewSystemStatus ||
        action.kind == NextActionKind.viewRecord;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.dsnTaskPrimaryAction,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(_actionIcon(action.kind)),
              title: Text(_actionLabel(l10n, action)),
              subtitle: Text(action.type),
            ),
            if (canRefresh)
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : _load,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.dsnTaskRefreshProjection),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptCard(
      BuildContext context, AppLocalizations l10n, DasnTaskView view) {
    final receipt = view.receipt;
    if (receipt == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.dsnTaskReceipt,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(l10n.dsnTaskNoReceipt),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _loadingReceipt ? null : _loadReceipt,
                icon: _loadingReceipt
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.receipt_long_outlined),
                label: Text(l10n.dsnTaskLoadReceipt),
              ),
              if (_receiptError != null) ...[
                const SizedBox(height: 8),
                Text(_receiptError!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ],
          ),
        ),
      );
    }
    final source = receipt['source']?.toString();
    final isLegacyFallback = source == 'LEGACY_FALLBACK';
    final fields = <MapEntry<String, dynamic>>[
      if (receipt['state'] != null)
        MapEntry(l10n.dsnTaskReceiptState, receipt['state']),
      if (receipt['orderId'] != null)
        MapEntry(l10n.dsnTaskReceiptOrder, receipt['orderId']),
      if (receipt['deliveryCount'] != null)
        MapEntry(l10n.dsnTaskReceiptDeliveries, receipt['deliveryCount']),
      if (receipt['generatedAt'] != null)
        MapEntry(l10n.dsnTaskReceiptGeneratedAt, receipt['generatedAt']),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(l10n.dsnTaskReceipt,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                IconButton(
                  tooltip: l10n.dsnTaskRefreshReceipt,
                  onPressed: _loadingReceipt ? null : _loadReceipt,
                  icon: _loadingReceipt
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                ),
              ],
            ),
            for (final field in fields) _factRow(field.key, field.value),
            if (source != null) _factRow(l10n.dsnTaskReceiptSource, source),
            if (isLegacyFallback)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(10),
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: Text(l10n.dsnTaskLegacyFallback),
              ),
            if (_receiptError != null) ...[
              const SizedBox(height: 8),
              Text(_receiptError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _factRow(String label, Object? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 148,
            child: Text(label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
          ),
          Expanded(child: SelectableText(value?.toString() ?? '—')),
        ],
      ),
    );
  }

  String _actionLabel(AppLocalizations l10n, NextAction action) {
    switch (action.kind) {
      case NextActionKind.recoverOperation:
        return l10n.dsnTaskActionRecoverOperation;
      case NextActionKind.recoverTask:
        return l10n.dsnTaskActionRecoverTask;
      case NextActionKind.reviewResponsibility:
        return l10n.dsnTaskActionReviewResponsibility;
      case NextActionKind.recoveryInProgress:
        return l10n.dsnTaskActionRecoveryInProgress;
      case NextActionKind.viewProgress:
        return l10n.dsnTaskActionViewProgress;
      case NextActionKind.viewSystemStatus:
        return l10n.dsnTaskActionViewSystemStatus;
      case NextActionKind.viewRecord:
        return l10n.dsnTaskActionViewRecord;
      case NextActionKind.domain:
        return l10n.dsnTaskActionDomain;
      case NextActionKind.unknown:
        return l10n.dsnTaskActionUnknown;
    }
  }

  IconData _actionIcon(NextActionKind kind) {
    switch (kind) {
      case NextActionKind.recoverOperation:
      case NextActionKind.recoverTask:
        return Icons.sync_problem_outlined;
      case NextActionKind.recoveryInProgress:
        return Icons.sync_outlined;
      case NextActionKind.reviewResponsibility:
        return Icons.person_outline;
      case NextActionKind.viewProgress:
        return Icons.timelapse_outlined;
      case NextActionKind.viewSystemStatus:
        return Icons.cloud_outlined;
      case NextActionKind.viewRecord:
        return Icons.fact_check_outlined;
      case NextActionKind.domain:
        return Icons.arrow_forward_outlined;
      case NextActionKind.unknown:
        return Icons.help_outline;
    }
  }
}
