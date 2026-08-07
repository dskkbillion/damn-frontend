import 'package:dskk_flutter_refactor/core/dasn/data/dsn_provider_repository.dart';
import 'package:dskk_flutter_refactor/core/dasn/data/dsn_provider_task_repository.dart';
import 'package:dskk_flutter_refactor/core/dasn/domain/dsn_provider_models.dart';
import 'package:dskk_flutter_refactor/core/dasn/domain/dsn_provider_task_models.dart';
import 'package:dskk_flutter_refactor/features/agent/presentation/provider_task_center_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'records ProviderOffer and ProviderAcceptance separately before Commitment',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final tasks = _FakeProviderTaskRepository();
      final provider = _FakeProviderRepository();
      await tester.pumpWidget(_app(
        DsnProviderTaskCenterPage(
          taskRepository: tasks,
          providerRepository: provider,
          artifactSourcePicker: (_) async => const DsnArtifactUploadSource(
            fileName: 'fixture.txt',
            bytes: <int>[1, 2, 3],
            size: 3,
            mimeType: 'text/plain',
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Provider 任务中心'), findsOneWidget);
      expect(find.text('Provider task'), findsOneWidget);
      expect(provider.offerCalls, 0);
      expect(provider.acceptanceCalls, 0);

      expect(find.text('服务器固定目录事实（只读）'), findsOneWidget);
      expect(find.textContaining('translation / standard'), findsOneWidget);
      expect(find.textContaining('120 / CREDITS'), findsOneWidget);
      await _tapText(tester, '提交 ProviderOffer');
      await tester.pumpAndSettle();

      expect(provider.offerCalls, 1);
      expect(provider.lastOffer?.offerVersion, 1);
      expect(provider.lastOffer?.capabilityId, 'translation');
      expect(provider.lastOffer?.variantId, 'standard');
      expect(provider.lastOffer?.quantity, 1);
      expect(provider.lastOffer?.amountMinor, 120);
      expect(provider.lastOffer?.currency, 'CREDITS');
      expect(provider.lastOffer?.quoteHash, _hash('b'));
      expect(provider.lastOffer?.maxRevisions, 2);
      expect(find.textContaining('报价已记录'), findsOneWidget);
      expect(find.text('确认接单'), findsOneWidget);

      await _tapText(tester, '确认接单');
      await tester.pumpAndSettle();
      expect(find.text('确认接单'), findsWidgets);
      expect(provider.acceptanceCalls, 0);

      await tester.tap(find.text('确认').last);
      await tester.pumpAndSettle();
      expect(provider.acceptanceCalls, 1);
      expect(provider.lastAcceptance?.acceptance, DsnProviderAcceptance.accept);
      expect(provider.commitmentCreated, isFalse,
          reason: 'one-sided ProviderAcceptance must not create Commitment');
      expect(find.textContaining('接单状态：ACCEPT'), findsOneWidget);
      expect(find.text('订单 Commitment 尚未建立，当前不能提交交付。'), findsOneWidget);
    },
  );

  testWidgets('renders the current accepted offer as a read-only Provider fact',
      (tester) async {
    final tasks = _FakeProviderTaskRepository()..includeOffer = true;
    final provider = _FakeProviderRepository();
    await tester.pumpWidget(_app(DsnProviderTaskCenterPage(
      taskRepository: tasks,
      providerRepository: provider,
    )));
    await tester.pumpAndSettle();

    expect(find.text('接单状态：ACCEPT · HUMAN'), findsOneWidget);
    expect(find.text('确认接单'), findsNothing);
    expect(find.text('拒单'), findsNothing);
    expect(find.text('请先提交报价，或刷新获取已有报价。'), findsNothing);
    expect(provider.acceptanceCalls, 0);
  });

  testWidgets('blocks a first offer until server fixed facts are available',
      (tester) async {
    final tasks = _FakeProviderTaskRepository()..includeFixedLine = false;
    final provider = _FakeProviderRepository();
    await tester.pumpWidget(_app(DsnProviderTaskCenterPage(
      taskRepository: tasks,
      providerRepository: provider,
    )));
    await tester.pumpAndSettle();

    expect(find.text('服务器尚未提供固定目录事实；请刷新任务后再提交报价。'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '提交 ProviderOffer'),
    );
    expect(button.onPressed, isNull);
    expect(provider.offerCalls, 0);
  });

  testWidgets('rejects a nonpositive server amount before posting',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final tasks = _FakeProviderTaskRepository()..fixedLineAmount = 0;
    final provider = _FakeProviderRepository();
    await tester.pumpWidget(_app(DsnProviderTaskCenterPage(
      taskRepository: tasks,
      providerRepository: provider,
    )));
    await tester.pumpAndSettle();

    await _tapText(tester, '提交 ProviderOffer');
    await tester.pumpAndSettle();
    expect(provider.offerCalls, 0);
    expect(find.text('服务器固定目录事实无效，请刷新任务后再试。'), findsOneWidget);
  });

  testWidgets(
    'requires refreshed Commitment and explicit confirmation before delivery',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final tasks = _FakeProviderTaskRepository();
      final provider = _FakeProviderRepository();
      await tester.pumpWidget(_app(
        DsnProviderTaskCenterPage(
          taskRepository: tasks,
          providerRepository: provider,
          artifactSourcePicker: (_) async => const DsnArtifactUploadSource(
            fileName: 'fixture.txt',
            bytes: <int>[1, 2, 3],
            size: 3,
            mimeType: 'text/plain',
          ),
        ),
      ));
      await tester.pumpAndSettle();

      tasks.includeCommitment = true;
      await _tapText(tester, '刷新服务器事实');
      await tester.pumpAndSettle();
      expect(find.textContaining('Order order-1'), findsOneWidget);
      expect(find.text('提交交付证据'), findsOneWidget);

      await _tapText(tester, '选择交付文件');
      await tester.pumpAndSettle();
      expect(find.textContaining('已选择：fixture.txt'), findsOneWidget);
      await _tapText(tester, '提交交付证据');
      await tester.pumpAndSettle();
      expect(find.text('确认提交交付'), findsOneWidget);
      expect(provider.deliveryCalls, 0);

      await tester.tap(find.text('确认').last);
      await tester.pumpAndSettle();
      expect(provider.deliveryCalls, 1);
      expect(provider.uploadSlotCalls, 1);
      expect(provider.uploadCalls, 1);
      expect(provider.lastDelivery?.submissionNo, 1);
      expect(provider.lastDelivery?.expectedCommitmentHash, _hash('c'));
      expect(provider.lastDelivery?.artifacts.single.uploadRef, 'upl_fixture');
      expect(provider.lastDelivery?.artifacts.single.toJson(),
          isNot(contains('objectRef')));
      expect(find.textContaining('交付已记录：delivery-1'), findsOneWidget);
    },
  );
}

Widget _app(Widget child) => MaterialApp(home: child);

Future<void> _tapText(WidgetTester tester, String label) async {
  final finder = find.text(label);
  expect(finder, findsOneWidget);
  await tester.ensureVisible(finder);
  final button = find.ancestor(
    of: finder,
    matching: find.byWidgetPredicate(
      (widget) => widget is ButtonStyleButton || widget is TextButton,
    ),
  );
  expect(button, findsOneWidget);
  await tester.ensureVisible(button);
  await tester.tap(button);
}

class _FakeProviderTaskRepository implements DsnProviderTaskRepository {
  bool includeCommitment = false;
  bool includeOffer = false;
  bool includeFixedLine = true;
  int fixedLineAmount = 120;

  @override
  Future<DsnProviderTaskPage> listAssignedTasks({
    String? cursor,
    int limit = 20,
  }) async {
    return DsnProviderTaskPage(tasks: <DsnProviderTask>[_task()]);
  }

  @override
  Future<DsnProviderTask> getAssignedTask(String taskTraceId) async {
    includeOffer = true;
    return _task();
  }

  DsnProviderTask _task() => DsnProviderTask(
        requestId: 33,
        version: includeCommitment ? 2 : 0,
        taskTraceId: 'ttr_1234567890abcdef',
        specHash: _hash('a'),
        title: 'Provider task',
        brief: 'A fixed brief',
        status: includeCommitment ? 'COMMITTED' : 'SUBMITTED',
        fixedLine: includeFixedLine
            ? DsnProviderFixedCatalogLine(
                fixedLineHash: _hash('d'),
                capabilityId: 'translation',
                providerId: 'provider-1',
                buyerId: 'buyer-1',
                variantId: 'standard',
                quantity: 1,
                capacity: null,
                currency: 'CREDITS',
                amountMinor: fixedLineAmount,
                quoteHash: _hash('b'),
                deliverySeconds: 3600,
                maxRevisions: 2,
                outputTypes: const <String>['FILE'],
                slaHash: _hash('e'),
                catalogRevision: _hash('f'),
              )
            : null,
        offer: includeOffer
            ? DsnProviderOfferSnapshot(
                offerId: 'offer-1',
                offerVersion: 1,
                specHash: _hash('a'),
                quoteHash: _hash('b'),
                capabilityId: 'translation',
                variantId: 'standard',
                quantity: 1,
                amountMinor: 120,
                currency: 'CREDITS',
                status: 'ACTIVE',
                acceptance: DsnProviderAcceptance.accept,
              )
            : null,
        commitment: includeCommitment
            ? DsnProviderCommitmentSnapshot(
                orderId: 'order-1',
                commitmentId: 'commit-1',
                commitmentVersion: 1,
                commitmentHash: _hash('c'),
                nextSubmissionNo: 1,
              )
            : null,
      );
}

class _FakeProviderRepository implements DsnProviderRepository {
  int offerCalls = 0;
  int acceptanceCalls = 0;
  int deliveryCalls = 0;
  int uploadSlotCalls = 0;
  int uploadCalls = 0;
  bool commitmentCreated = false;
  DsnProviderOfferInput? lastOffer;
  DsnProviderAcceptanceInput? lastAcceptance;
  DsnDeliveryInput? lastDelivery;

  @override
  Future<DsnProviderOfferResult> submitOffer(
    int requestId, {
    required DsnProviderOfferInput offer,
    required int ifMatchVersion,
    required String idempotencyKey,
  }) async {
    offerCalls += 1;
    lastOffer = offer;
    return DsnProviderOfferResult(
      metadata: _metadata('PROVIDER_OFFERED', version: ifMatchVersion + 1),
      offerId: 'offer-1',
      providerId: 'provider-1',
      offerVersion: offer.offerVersion,
      specHash: offer.specHash,
      quoteHash: offer.quoteHash,
      expiresAt: offer.expiresAt,
      status: 'OFFERED',
    );
  }

  @override
  Future<DsnProviderAcceptanceResult> submitAcceptance(
    int requestId, {
    required DsnProviderAcceptanceInput acceptance,
    required int ifMatchVersion,
    required String idempotencyKey,
  }) async {
    acceptanceCalls += 1;
    lastAcceptance = acceptance;
    return DsnProviderAcceptanceResult(
      metadata: _metadata('PROVIDER_ACCEPTED', version: ifMatchVersion + 1),
      acceptanceId: 'accept-1',
      offerId: 'offer-1',
      offerVersion: acceptance.offerVersion,
      specHash: acceptance.specHash,
      quoteHash: acceptance.quoteHash,
      acceptance: acceptance.acceptance,
      actorType: 'HUMAN',
    );
  }

  @override
  Future<DsnDeliveryResult> submitDelivery(
    String orderId, {
    required DsnDeliveryInput delivery,
    required int ifMatchVersion,
    required String idempotencyKey,
  }) async {
    deliveryCalls += 1;
    lastDelivery = delivery;
    return DsnDeliveryResult(
      metadata: _metadata('DELIVERY_SUBMITTED', version: ifMatchVersion + 1),
      deliveryId: 'delivery-1',
      orderId: orderId,
      commitmentId: 'commit-1',
      commitmentVersion: ifMatchVersion,
      submissionNo: delivery.submissionNo,
      evidenceHash: _hash('d'),
      actorType: 'HUMAN',
    );
  }

  @override
  Future<DsnArtifactUploadSlotResult> issueArtifactUploadSlots(
    String orderId, {
    required DsnArtifactUploadSlotInput input,
    required int ifMatchVersion,
    required String idempotencyKey,
  }) async {
    uploadSlotCalls += 1;
    return DsnArtifactUploadSlotResult(
      metadata:
          _metadata('ARTIFACT_UPLOAD_SLOTS_ISSUED', version: ifMatchVersion),
      submissionNo: input.submissionNo,
      items: <DsnArtifactUploadSlot>[
        DsnArtifactUploadSlot(
          uploadRef: 'upl_fixture',
          expiresAt: DateTime.utc(2026, 8, 7),
          maxBytes: 25 * 1024 * 1024,
        ),
      ],
    );
  }

  @override
  Future<DsnArtifactUploadResult> uploadArtifact(
    String orderId, {
    required String uploadRef,
    required DsnArtifactUploadSource source,
    required String commitmentHash,
    required int submissionNo,
    required int ifMatchVersion,
  }) async {
    uploadCalls += 1;
    return DsnArtifactUploadResult(
      metadata: _metadata('ARTIFACT_UPLOADED', version: ifMatchVersion),
      uploadRef: uploadRef,
      status: 'UPLOADED',
      sha256: _hash('e'),
      size: source.size,
      mimeType: source.mimeType,
    );
  }
}

DsnProviderMachineMetadata _metadata(String state, {required int version}) =>
    DsnProviderMachineMetadata(
      schemaVersion: '0.1',
      state: state,
      taskTraceId: 'ttr_1234567890abcdef',
      operationTraceId: 'trace-provider-test',
      resourceId: 'resource-1',
      resourceVersion: version,
      resourceHash: _hash('z'),
      nextActions: const <dynamic>[],
    );

String _hash(String letter) => 'sha256:${letter * 64}';
