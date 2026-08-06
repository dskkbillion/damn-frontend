import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/dasn/data/dsn_provider_repository.dart';
import '../../../core/dasn/data/dsn_provider_task_repository.dart';
import '../../../core/dasn/domain/dsn_provider_models.dart';
import '../../../core/dasn/domain/dsn_provider_task_models.dart';

typedef DsnArtifactSourcePicker = Future<DsnArtifactUploadSource?> Function(
    BuildContext context);

/// Minimal human Provider Task Center for DS 0.1.
///
/// The page owns only interaction state and retry keys.  Server facts remain
/// authoritative: task assignment is read from the Provider projection and
/// every write goes through the canonical Provider adapter with If-Match and
/// Idempotency-Key.  It never accepts a member id, role, grant or task
/// selector from a form and never falls back to the buyer request list.
class DsnProviderTaskCenterPage extends StatefulWidget {
  const DsnProviderTaskCenterPage({
    super.key,
    required this.taskRepository,
    required this.providerRepository,
    this.artifactSourcePicker,
  });

  final DsnProviderTaskRepository taskRepository;
  final DsnProviderRepository providerRepository;
  final DsnArtifactSourcePicker? artifactSourcePicker;

  @override
  State<DsnProviderTaskCenterPage> createState() =>
      _DsnProviderTaskCenterPageState();
}

class _DsnProviderTaskCenterPageState extends State<DsnProviderTaskCenterPage> {
  List<DsnProviderTask>? _tasks;
  DsnProviderTask? _selected;
  String? _error;
  bool _loading = false;
  bool _busy = false;

  final Map<int, DsnProviderOfferInput> _offerInputs = {};
  final Map<int, DsnProviderOfferResult> _offerResults = {};
  final Map<int, DsnProviderAcceptanceResult> _acceptanceResults = {};
  final Map<String, DsnDeliveryResult> _deliveryResults = {};
  final Map<String, DsnArtifactUploadResult> _uploadResults = {};

  final _expiryHoursController = TextEditingController(text: '24');
  final _commitmentHashController = TextEditingController();
  DsnArtifactUploadSource? _selectedArtifact;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final controller in <TextEditingController>[
      _expiryHoursController,
      _commitmentHashController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    if (_loading || _busy) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await widget.taskRepository.listAssignedTasks();
      if (!mounted) return;
      setState(() {
        _tasks = page.tasks;
        _selected = _selected == null
            ? (page.tasks.isEmpty ? null : page.tasks.first)
            : page.tasks
                .where((task) => task.requestId == _selected!.requestId)
                .firstOrNull;
      });
      _syncDeliveryFields(_selected);
    } catch (error) {
      if (mounted) setState(() => _error = _errorText(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refreshTask(DsnProviderTask task) async {
    if (_busy) return;
    try {
      final fresh =
          await widget.taskRepository.getAssignedTask(task.taskTraceId);
      if (!mounted) return;
      setState(() {
        _tasks = [
          for (final item in _tasks ?? const <DsnProviderTask>[])
            item.requestId == fresh.requestId ? fresh : item,
        ];
        _selected = fresh;
        _error = null;
      });
      _syncDeliveryFields(fresh);
    } catch (error) {
      if (mounted) setState(() => _error = _errorText(error));
    }
  }

  String _errorText(Object error) {
    if (error is DsnProviderTaskApiException) {
      if (error.code == 'PROVIDER_TASK_READ_NOT_AVAILABLE') {
        return 'Provider 任务读取接口尚未启用；未回退到买方需求列表。';
      }
      return error.message;
    }
    if (error is DsnProviderApiException) {
      if (error.code == 'STORAGE_ADAPTER_UNAVAILABLE' ||
          error.code == 'STORAGE_UPLOAD_FAILED' ||
          error.statusCode == 503) {
        return '服务端私有存储适配器尚未启用，文件上传已安全停止；不会回退到 objectRef。';
      }
      return error.message;
    }
    return 'Provider 任务暂时无法加载，请稍后重试。';
  }

  void _select(DsnProviderTask task) {
    setState(() {
      _selected = task;
      // A file selected for one Commitment must never silently follow the
      // Provider to another task/order.
      _selectedArtifact = null;
    });
    _syncDeliveryFields(task);
  }

  void _syncDeliveryFields(DsnProviderTask? task) {
    final commitment = task?.commitment;
    if (commitment == null) {
      _commitmentHashController.clear();
      return;
    }
    _commitmentHashController.text = commitment.commitmentHash;
  }

  Future<void> _submitOffer(DsnProviderTask task) async {
    final fixedLine = task.fixedLine;
    final expiryHours = int.tryParse(_expiryHoursController.text.trim());
    if (fixedLine == null) {
      setState(() => _error = '服务器尚未返回固定目录事实，请刷新任务后再提交报价。');
      return;
    }
    if (fixedLine.amountMinor < 1 ||
        fixedLine.quantity < 1 ||
        fixedLine.capacity != null ||
        fixedLine.currency != 'CREDITS' ||
        !_isHash(fixedLine.quoteHash) ||
        !_isHash(fixedLine.fixedLineHash)) {
      setState(() => _error = '服务器固定目录事实无效，请刷新任务后再试。');
      return;
    }
    if (expiryHours == null || expiryHours < 1) {
      setState(() => _error = '请填写有效的报价有效期。');
      return;
    }
    final offerVersion = (_offerResults[task.requestId]?.offerVersion ??
            task.offer?.offerVersion ??
            0) +
        1;
    final expiresAt = DateTime.now().toUtc().add(
          Duration(hours: expiryHours),
        );
    final input = DsnProviderOfferInput(
      offerVersion: offerVersion,
      specHash: task.specHash,
      quoteHash: fixedLine.quoteHash,
      capabilityId: fixedLine.capabilityId,
      variantId: fixedLine.variantId,
      quantity: fixedLine.quantity,
      capacity: fixedLine.capacity,
      amountMinor: fixedLine.amountMinor,
      currency: fixedLine.currency,
      expiresAt: expiresAt,
      maxRevisions: fixedLine.maxRevisions,
    );
    await _runBusy(() async {
      final result = await widget.providerRepository.submitOffer(
        task.requestId,
        offer: input,
        ifMatchVersion: task.version,
        idempotencyKey: 'provider-offer:${task.requestId}:$offerVersion:v1',
      );
      if (!mounted) return;
      setState(() {
        _offerInputs[task.requestId] = input;
        _offerResults[task.requestId] = result;
        _tasks = [
          for (final item in _tasks ?? const <DsnProviderTask>[])
            item.requestId == task.requestId
                ? item.copyWith(
                    version: result.metadata.resourceVersion ?? item.version,
                  )
                : item,
        ];
        _selected = task.copyWith(
          version: result.metadata.resourceVersion ?? task.version,
        );
        _error = null;
      });
    });
  }

  Future<void> _submitAcceptance(
    DsnProviderTask task,
    DsnProviderAcceptance acceptance,
  ) async {
    final confirmed = await _confirm(
      title: acceptance == DsnProviderAcceptance.accept ? '确认接单' : '确认拒单',
      message: acceptance == DsnProviderAcceptance.accept
          ? '确认按当前报价接单？这只记录服务方事实，不会单方面生成生效订单。'
          : '确认拒绝当前报价？',
    );
    if (confirmed != true) return;

    final input = _offerInputs[task.requestId];
    final snapshot = task.offer;
    final result = _offerResults[task.requestId];
    final offerVersion =
        result?.offerVersion ?? input?.offerVersion ?? snapshot?.offerVersion;
    final specHash = result?.specHash ?? input?.specHash ?? snapshot?.specHash;
    final quoteHash =
        result?.quoteHash ?? input?.quoteHash ?? snapshot?.quoteHash;
    if (offerVersion == null || specHash == null || quoteHash == null) {
      setState(() => _error = '当前任务没有可确认的 ProviderOffer。');
      return;
    }
    await _runBusy(() async {
      final expectedVersion =
          _offerResults[task.requestId]?.metadata.resourceVersion ??
              task.version;
      final acceptanceResult = await widget.providerRepository.submitAcceptance(
        task.requestId,
        acceptance: DsnProviderAcceptanceInput(
          offerVersion: offerVersion,
          specHash: specHash,
          quoteHash: quoteHash,
          acceptance: acceptance,
          reason: acceptance == DsnProviderAcceptance.reject
              ? 'Provider declined'
              : null,
        ),
        ifMatchVersion: expectedVersion,
        idempotencyKey:
            'provider-acceptance:${task.requestId}:$offerVersion:${acceptance.wireValue.toLowerCase()}:v1',
      );
      if (!mounted) return;
      setState(() {
        _acceptanceResults[task.requestId] = acceptanceResult;
        _error = null;
      });
    });
  }

  Future<void> _submitDelivery(DsnProviderTask task) async {
    final commitment = task.commitment;
    if (commitment == null) {
      setState(() => _error = '只有服务端已建立 Commitment 后才能提交交付。');
      return;
    }
    final source = _selectedArtifact;
    final expectedHash = _commitmentHashController.text.trim();
    if (source == null || source.size < 1 || !_isHash(expectedHash)) {
      setState(() => _error = '请先选择有效的交付文件，并确认 Commitment 哈希。');
      return;
    }
    final confirmed = await _confirm(
      title: '确认提交交付',
      message: '文件会先上传到服务端签发的 uploadRef，再作为追加式事实提交；如需修改，请创建新的 submission。',
    );
    if (confirmed != true) return;

    await _runBusy(() async {
      final slotResult =
          await widget.providerRepository.issueArtifactUploadSlots(
        commitment.orderId,
        input: DsnArtifactUploadSlotInput(
          expectedCommitmentHash: expectedHash,
          submissionNo: commitment.nextSubmissionNo,
          artifacts: [
            DsnArtifactUploadMetadata(
              size: source.size,
              mimeType: source.mimeType,
            ),
          ],
        ),
        ifMatchVersion: commitment.commitmentVersion,
        idempotencyKey:
            'provider-upload-slots:${commitment.orderId}:${commitment.nextSubmissionNo}:v1',
      );
      if (slotResult.items.isEmpty) {
        throw const DsnProviderApiException(
          '服务端没有返回可用的 uploadRef',
          code: 'INVALID_UPLOAD_SLOT_RESPONSE',
        );
      }
      final slot = slotResult.items.first;
      final upload = await widget.providerRepository.uploadArtifact(
        commitment.orderId,
        uploadRef: slot.uploadRef,
        source: source,
        commitmentHash: expectedHash,
        submissionNo: commitment.nextSubmissionNo,
        ifMatchVersion: commitment.commitmentVersion,
      );
      final result = await widget.providerRepository.submitDelivery(
        commitment.orderId,
        delivery: DsnDeliveryInput(
          expectedCommitmentHash: expectedHash,
          submissionNo: commitment.nextSubmissionNo,
          artifacts: [
            DsnDeliveryArtifactInput(
              uploadRef: upload.uploadRef,
              size: upload.size,
              mimeType: upload.mimeType,
              sha256: upload.sha256,
            ),
          ],
        ),
        ifMatchVersion: commitment.commitmentVersion,
        idempotencyKey:
            'provider-delivery:${commitment.orderId}:${commitment.nextSubmissionNo}:v1',
      );
      if (!mounted) return;
      setState(() {
        _uploadResults[commitment.orderId] = upload;
        _deliveryResults[commitment.orderId] = result;
        _error = null;
      });
    });
  }

  Future<void> _chooseArtifact() async {
    final picker = widget.artifactSourcePicker ?? _pickWithFilePicker;
    try {
      final source = await picker(context);
      if (!mounted || source == null) return;
      if (source.size < 1) {
        setState(() => _error = '交付文件不能为空。');
        return;
      }
      setState(() {
        _selectedArtifact = source;
        _error = null;
      });
    } catch (error) {
      if (mounted) setState(() => _error = _errorText(error));
    }
  }

  Future<DsnArtifactUploadSource?> _pickWithFilePicker(
    BuildContext context,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.any,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.single;
    final declaredMimeType = _mimeTypeFor(file.name);
    final bytes = file.bytes;
    if (bytes != null) {
      return DsnArtifactUploadSource(
        fileName: file.name,
        bytes: bytes,
        size: bytes.length,
        mimeType: canonicalDsnArtifactMimeType(
          bytes: bytes,
          declaredMimeType: declaredMimeType,
        ),
      );
    }
    if (file.path == null || file.path!.trim().isEmpty) {
      throw const DsnProviderApiException(
        '文件读取失败；当前平台没有返回文件内容。',
        code: 'ARTIFACT_FILE_UNAVAILABLE',
      );
    }
    return DsnArtifactUploadSource(
      fileName: file.name,
      path: file.path,
      size: file.size,
      mimeType: canonicalDsnArtifactMimeType(
        bytes: null,
        declaredMimeType: declaredMimeType,
      ),
    );
  }

  Future<void> _runBusy(Future<void> Function() operation) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await operation();
    } catch (error) {
      if (mounted) setState(() => _error = _errorText(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool?> _confirm({required String title, required String message}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider 任务中心'),
        actions: [
          IconButton(
            tooltip: '刷新任务',
            onPressed: _loading || _busy ? null : _load,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _tasks == null && _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  if (_error != null) _buildErrorCard(),
                  if (_tasks != null && _tasks!.isEmpty) _buildEmptyCard(),
                  for (final task in _tasks ?? const <DsnProviderTask>[])
                    _buildTaskCard(task),
                  if (selected != null) ...[
                    const SizedBox(height: 12),
                    _buildActionCard(selected),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_error!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer)),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _loading || _busy ? null : _load,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.assignment_outlined, size: 42),
            SizedBox(height: 10),
            Text('暂无分配给你的 Provider 任务'),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(DsnProviderTask task) {
    final selected = _selected?.requestId == task.requestId;
    return Card(
      color: selected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: () => _select(task),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(task.title,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  Chip(label: Text(task.status)),
                ],
              ),
              const SizedBox(height: 6),
              Text(task.brief, maxLines: 3, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Text('Request #${task.requestId} · v${task.version}',
                  style: Theme.of(context).textTheme.bodySmall),
              if (task.offer != null) ...[
                const SizedBox(height: 8),
                Text(
                    'Offer ${task.offer!.offerVersion} · ${task.offer!.status}'),
              ],
              if (task.commitment != null) ...[
                const SizedBox(height: 4),
                Text(
                    'Order ${task.commitment!.orderId} · submission ${task.commitment!.nextSubmissionNo}'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(DsnProviderTask task) {
    final offerResult = _offerResults[task.requestId];
    final acceptanceResult = _acceptanceResults[task.requestId];
    final existingAcceptance = task.offer?.acceptance;
    final fixedLine = task.fixedLine;
    final canAccept = offerResult != null || task.offer != null;
    final delivery = task.commitment == null
        ? null
        : _deliveryResults[task.commitment!.orderId];
    final upload = task.commitment == null
        ? null
        : _uploadResults[task.commitment!.orderId];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('处理任务', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('服务方身份、任务归属和额度均由服务器判定。'),
            const Divider(height: 24),
            Text('提交报价', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            if (fixedLine == null)
              const Text('服务器尚未提供固定目录事实；请刷新任务后再提交报价。')
            else ...[
              _fixedLineFacts(fixedLine),
              const SizedBox(height: 6),
            ],
            _field(_expiryHoursController, '报价有效期（小时）', numeric: true),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _busy || fixedLine == null
                    ? null
                    : () => _submitOffer(task),
                icon: const Icon(Icons.request_quote_outlined),
                label:
                    Text(offerResult == null ? '提交 ProviderOffer' : '提交新版本报价'),
              ),
            ),
            if (offerResult != null) ...[
              const SizedBox(height: 8),
              Text('报价已记录：${offerResult.offerId} · ${offerResult.status}'),
            ],
            const Divider(height: 24),
            Text('接单事实', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            if (!canAccept)
              const Text('请先提交报价，或刷新获取已有报价。')
            else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => _submitAcceptance(
                              task, DsnProviderAcceptance.reject),
                      child: const Text('拒单'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: _busy
                          ? null
                          : () => _submitAcceptance(
                              task, DsnProviderAcceptance.accept),
                      child: const Text('确认接单'),
                    ),
                  ),
                ],
              ),
              if (acceptanceResult != null) ...[
                const SizedBox(height: 8),
                Text(
                    '接单状态：${acceptanceResult.acceptance.wireValue} · ${acceptanceResult.actorType}'),
              ] else if (existingAcceptance != null) ...[
                const SizedBox(height: 8),
                Text('接单状态：${existingAcceptance.wireValue} · HUMAN'),
              ],
            ],
            const Divider(height: 24),
            Text('提交交付', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            if (task.commitment == null)
              const Text('订单 Commitment 尚未建立，当前不能提交交付。')
            else ...[
              const Text(
                'DS 0.2 只接受服务端签发的 uploadRef。不要填写 objectRef、URL 或对象存储路径。',
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _busy ? null : _chooseArtifact,
                icon: const Icon(Icons.attach_file),
                label: Text(_selectedArtifact == null ? '选择交付文件' : '更换交付文件'),
              ),
              if (_selectedArtifact != null) ...[
                const SizedBox(height: 8),
                Text(
                  '已选择：${_selectedArtifact!.fileName} · ${_selectedArtifact!.size} bytes · ${_selectedArtifact!.mimeType}',
                ),
              ],
              _field(
                _commitmentHashController,
                'Expected Commitment hash (server fact)',
                readOnly: true,
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _busy ? null : () => _submitDelivery(task),
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('提交交付证据'),
                ),
              ),
              if (delivery != null) ...[
                const SizedBox(height: 8),
                Text(
                    '交付已记录：${delivery.deliveryId} · submission ${delivery.submissionNo}'),
              ] else if (upload != null) ...[
                const SizedBox(height: 8),
                Text('文件已上传：${upload.uploadRef} · ${upload.sha256}'),
              ],
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _busy ? null : () => _refreshTask(task),
                icon: const Icon(Icons.sync),
                label: const Text('刷新服务器事实'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label,
      {bool numeric = false, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _fixedLineFacts(DsnProviderFixedCatalogLine line) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('服务器固定目录事实（只读）'),
        const SizedBox(height: 4),
        _fact('能力 / 变体', '${line.capabilityId} / ${line.variantId}'),
        _fact('价格 / 币种', '${line.amountMinor} / ${line.currency}'),
        _fact('数量 / 容量', '${line.quantity} / ${line.capacity ?? '无'}'),
        _fact('最大修改次数', '${line.maxRevisions}'),
        _fact('交付窗口', '${line.deliverySeconds} 秒'),
        _fact('目录版本', line.catalogRevision),
        _fact('固定行哈希', line.fixedLineHash),
      ],
    );
  }

  Widget _fact(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text('$label：$value'),
    );
  }

  bool _isHash(String value) =>
      RegExp(r'^sha256:[a-f0-9]{64}$').hasMatch(value);

  String _mimeTypeFor(String fileName) {
    final extension =
        fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
    const known = <String, String>{
      'csv': 'text/plain',
      'gif': 'image/gif',
      'jpeg': 'image/jpeg',
      'jpg': 'image/jpeg',
      'json': 'application/json',
      'pdf': 'application/pdf',
      'png': 'image/png',
      'txt': 'text/plain',
      'webp': 'image/webp',
      'zip': 'application/zip',
    };
    return known[extension] ?? 'application/octet-stream';
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
