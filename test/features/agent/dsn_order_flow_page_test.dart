import 'package:dskk_flutter_refactor/core/dasn/data/dsn_order_repository.dart';
import 'package:dskk_flutter_refactor/core/dasn/data/dasn_task_repository.dart';
import 'package:dskk_flutter_refactor/core/dasn/domain/dsn_buyer_agent_models.dart';
import 'package:dskk_flutter_refactor/core/dasn/domain/dasn_task_view.dart';
import 'package:dskk_flutter_refactor/core/dasn/domain/dsn_order_models.dart';
import 'package:dskk_flutter_refactor/features/agent/data/agent_repository.dart';
import 'package:dskk_flutter_refactor/features/agent/domain/agent_models.dart';
import 'package:dskk_flutter_refactor/features/agent/presentation/dsn_order_flow_page.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('keeps order and payment behind separate explicit confirmations',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final orders = _FakeOrderRepository();
    await tester.pumpWidget(_app(DsnOrderFlowPage(
      requestRepository: _FakeRequestRepository(),
      orderRepository: orders,
      requestId: 9,
    )));
    await tester.pumpAndSettle();

    expect(find.text('服务方报价'), findsOneWidget);
    expect(orders.previewCreated, isFalse);
    expect(orders.confirmationIssued, isFalse);

    await tester.tap(find.text('查看报价并创建预览'));
    await tester.pumpAndSettle();
    expect(find.text('服务器订单预览'), findsOneWidget);
    expect(orders.previewCreated, isTrue);
    expect(orders.confirmationIssued, isFalse);

    final issueButton = find.widgetWithText(FilledButton, '生成确认引用');
    await tester.tap(issueButton);
    await tester.pumpAndSettle();
    expect(find.text('确认冻结报价'), findsOneWidget);
    expect(orders.confirmationIssued, isFalse);
    await tester.tap(find.text('生成确认引用').last);
    await tester.pumpAndSettle();
    expect(find.text('确认引用已生成'), findsOneWidget);
    expect(orders.confirmationIssued, isTrue);
    expect(orders.orderCreated, isFalse);

    final orderButton = find.widgetWithText(FilledButton, '创建未支付订单');
    await tester.tap(orderButton);
    await tester.pumpAndSettle();
    expect(find.text('确认创建订单'), findsOneWidget);
    expect(orders.orderCreated, isFalse);
    await tester.tap(find.text('创建未支付订单').last);
    await tester.pumpAndSettle();
    expect(find.text('未支付订单已创建'), findsOneWidget);
    expect(orders.orderCreated, isTrue);
    expect(orders.paymentCreated, isFalse);

    final payButton = find.widgetWithText(FilledButton, '使用积分支付');
    await tester.tap(payButton);
    await tester.pumpAndSettle();
    expect(find.text('确认支付'), findsNWidgets(2));
    expect(orders.paymentCreated, isFalse);
    await tester.tap(find.text('确认支付').last);
    await tester.pumpAndSettle();
    expect(find.text('支付已完成'), findsOneWidget);
    expect(orders.paymentCreated, isTrue);
    expect(orders.paymentIfMatchVersion, 2);
  });

  testWidgets('fails closed when requester actor type is missing',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final orders = _FakeOrderRepository();
    await tester.pumpWidget(_app(DsnOrderFlowPage(
      requestRepository: _FakeRequestRepository(requesterActorType: null),
      orderRepository: orders,
      requestId: 9,
    )));
    await tester.pumpAndSettle();

    expect(find.text('买方身份类型缺失或不受支持'), findsOneWidget);
    expect(find.text('创建未支付订单'), findsNothing);
    expect(orders.previewCreated, isFalse);
  });

  testWidgets(
      'fails closed before confirmation when Agent principalRef is missing',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final orders = _FakeOrderRepository();
    await tester.pumpWidget(_app(DsnOrderFlowPage(
      requestRepository: _FakeRequestRepository(
        requesterActorType: 'AGENT',
        principalRef: null,
      ),
      orderRepository: orders,
      requestId: 9,
    )));
    await tester.pumpAndSettle();

    await tester.tap(find.text('查看报价并创建预览'));
    await tester.pumpAndSettle();

    expect(find.text('Buyer Agent handoff 暂不可用'), findsOneWidget);
    expect(find.text('生成确认引用'), findsNothing);
    expect(orders.confirmationIssued, isFalse);
  });

  testWidgets('clears confirmation state when handoff facts mismatch',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final orders = _FakeOrderRepository(
      confirmationResponse: DsnConfirmationRef(
        confirmationRef: 'cr_test-1',
        requestId: 9,
        taskTraceId: 'ttr_1234567890abcdef',
        previewId: 'preview-1',
        specHash: 'sha256:${'c' * 64}',
        quoteHash: 'sha256:${'b' * 64}',
        amountMinor: 120,
        currency: 'CREDITS',
        paymentMethodType: 'CREDITS',
        allowedActions: const ['CREATE_ORDER', 'CREATE_PAYMENT_ATTEMPT'],
      ),
    );
    await tester.pumpWidget(_app(DsnOrderFlowPage(
      requestRepository: _FakeRequestRepository(
        requesterActorType: 'AGENT',
        principalRef: 'member:buyer',
      ),
      orderRepository: orders,
      requestId: 9,
    )));
    await tester.pumpAndSettle();

    await tester.tap(find.text('查看报价并创建预览'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '生成确认引用'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('生成确认引用').last);
    await tester.pumpAndSettle();

    expect(find.text('确认引用与当前报价事实不匹配，请刷新后重试'), findsOneWidget);
    expect(find.text('服务器订单预览'), findsNothing);
    expect(find.text('确认引用已生成'), findsNothing);
    expect(find.text('等待 Buyer Agent 创建 Commitment'), findsNothing);
    expect(orders.confirmationIssued, isTrue);
  });

  testWidgets('blocks payment surface when restored task facts mismatch offer',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_app(DsnOrderFlowPage(
      requestRepository: _FakeRequestRepository(),
      orderRepository: _FakeOrderRepository(),
      taskRepository: _FakeTaskRepository(
        commitmentOverrides: {'specHash': 'c' * 64},
      ),
      requestId: 9,
    )));
    await tester.pumpAndSettle();

    expect(find.text('订单事实未安全恢复'), findsOneWidget);
    expect(find.text('使用积分支付'), findsNothing);
    expect(find.text('未支付订单已创建'), findsNothing);
  });

  testWidgets('blocks recovery when the server omits the Commitment version',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_app(DsnOrderFlowPage(
      requestRepository: _FakeRequestRepository(),
      orderRepository: _FakeOrderRepository(),
      taskRepository: _FakeTaskRepository(
        commitmentOverrides: {'commitmentVersion': null},
      ),
      requestId: 9,
    )));
    await tester.pumpAndSettle();

    expect(find.text('订单事实未安全恢复'), findsOneWidget);
    expect(find.text('使用积分支付'), findsNothing);
    expect(find.text('未支付订单已创建'), findsNothing);
  });

  testWidgets('blocks recovery when order and Commitment versions differ',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_app(DsnOrderFlowPage(
      requestRepository: _FakeRequestRepository(),
      orderRepository: _FakeOrderRepository(),
      taskRepository: _FakeTaskRepository(orderCommitmentVersion: 3),
      requestId: 9,
    )));
    await tester.pumpAndSettle();

    expect(find.text('订单事实未安全恢复'), findsOneWidget);
    expect(find.text('使用积分支付'), findsNothing);
    expect(find.text('未支付订单已创建'), findsNothing);
  });

  testWidgets('blocks recovery when a persisted payment has another version',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_app(DsnOrderFlowPage(
      requestRepository: _FakeRequestRepository(),
      orderRepository: _FakeOrderRepository(),
      taskRepository: _FakeTaskRepository(
        includePayment: true,
        paymentCommitmentVersion: 3,
      ),
      requestId: 9,
    )));
    await tester.pumpAndSettle();

    expect(find.text('订单事实未安全恢复'), findsOneWidget);
    expect(find.text('使用积分支付'), findsNothing);
    expect(find.text('恢复支付状态'), findsNothing);
  });

  testWidgets('restores a committed task without creating another order',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final orders = _FakeOrderRepository();
    await tester.pumpWidget(_app(DsnOrderFlowPage(
      requestRepository: _FakeRequestRepository(),
      orderRepository: orders,
      taskRepository: _FakeTaskRepository(),
      requestId: 9,
    )));
    await tester.pumpAndSettle();

    expect(find.text('服务方报价'), findsOneWidget);
    expect(find.text('未支付订单已创建'), findsOneWidget);
    expect(orders.previewCreated, isFalse);
    expect(orders.confirmationIssued, isFalse);
    expect(orders.orderCreated, isFalse);
    expect(orders.paymentCreated, isFalse);
  });

  testWidgets(
      'fails closed instead of crashing when restored Agent task lacks principalRef',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_app(DsnOrderFlowPage(
      requestRepository: _FakeRequestRepository(
        requesterActorType: 'AGENT',
        principalRef: null,
      ),
      orderRepository: _FakeOrderRepository(),
      taskRepository: _FakeTaskRepository(),
      requestId: 9,
    )));
    await tester.pumpAndSettle();

    expect(find.text('订单事实未安全恢复'), findsOneWidget);
    expect(find.textContaining('principalRef'), findsOneWidget);
    expect(find.text('创建未支付订单'), findsNothing);
    expect(find.text('使用积分支付'), findsNothing);
  });

  testWidgets(
      'buyer Agent stops at a credential-free handoff and never creates an App order',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final orders = _FakeOrderRepository();
    DsnBuyerAgentHandoff? handoff;
    await tester.pumpWidget(_app(DsnOrderFlowPage(
      requestRepository: _FakeRequestRepository(
        requesterActorType: 'AGENT',
        principalRef: 'member:buyer',
      ),
      orderRepository: orders,
      requestId: 9,
      onBuyerAgentHandoffReady: (value) => handoff = value,
    )));
    await tester.pumpAndSettle();

    await tester.tap(find.text('查看报价并创建预览'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '生成确认引用'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('生成确认引用').last);
    await tester.pumpAndSettle();

    expect(find.text('等待 Buyer Agent 创建 Commitment'), findsOneWidget);
    expect(
        find.text('handoff 状态：HANDOFF_PENDING_EXTERNAL_AGENT'), findsOneWidget);
    expect(find.text('创建未支付订单'), findsNothing);
    expect(orders.orderCreated, isFalse);
    expect(handoff, isNotNull);
    expect(handoff!.status, DsnBuyerAgentHandoffStatus.readyForBuyerAgent);
    expect(handoff!.status.wireName, 'READY_FOR_BUYER_AGENT');
    expect(handoff!.toSafeJson(), containsPair('requestId', 9));
    expect(
        handoff!.toSafeJson().keys,
        containsAll(<String>[
          'previewId',
          'providerAcceptanceId',
          'offerVersion',
          'expectedSpecHash',
          'expectedQuoteHash',
          'confirmationRef',
        ]));
    final safeHandoff = handoff!.toSafeJson();
    expect(safeHandoff, isNot(contains('accessToken')));
    expect(safeHandoff, isNot(contains('grant')));
    expect(safeHandoff, isNot(contains('sessionToken')));
  });

  testWidgets(
      'buyer Agent resumes the shared payment surface after external Commitment',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final orders = _FakeOrderRepository();
    await tester.pumpWidget(_app(DsnOrderFlowPage(
      requestRepository: _FakeRequestRepository(
        requesterActorType: 'AGENT',
        principalRef: 'member:buyer',
      ),
      orderRepository: orders,
      taskRepository: _FakeTaskRepository(),
      requestId: 9,
    )));
    await tester.pumpAndSettle();

    expect(find.text('未支付订单已创建'), findsOneWidget);
    expect(find.text('handoff 状态：COMMITMENT_CREATED'), findsOneWidget);
    expect(find.text('支付阶段：AWAITING_APP_PAYMENT'), findsOneWidget);
    expect(find.text('等待 Buyer Agent 创建 Commitment'), findsNothing);
    expect(find.text('使用积分支付'), findsOneWidget);
    expect(orders.orderCreated, isFalse);
    expect(orders.paymentCreated, isFalse);
  });

  testWidgets(
      'buyer Agent payment after Commitment uses the shared App payment route',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final orders = _FakeOrderRepository();
    await tester.pumpWidget(_app(DsnOrderFlowPage(
      requestRepository: _FakeRequestRepository(
        requesterActorType: 'AGENT',
        principalRef: 'member:buyer',
      ),
      orderRepository: orders,
      taskRepository: _FakeTaskRepository(),
      requestId: 9,
    )));
    await tester.pumpAndSettle();

    // The external Buyer Agent has already created the Commitment. The
    // Trusted App now owns the explicit payment confirmation and must use the
    // same App/member payment adapter as a human buyer.
    await tester.tap(find.widgetWithText(FilledButton, '使用积分支付'));
    await tester.pumpAndSettle();
    expect(find.text('确认支付'), findsNWidgets(2));
    expect(orders.paymentCreated, isFalse);
    await tester.tap(find.text('确认支付').last);
    await tester.pumpAndSettle();

    expect(orders.paymentCreated, isTrue);
    expect(orders.paymentIfMatchVersion, 2);
    expect(find.text('支付已完成'), findsOneWidget);
  });

  testWidgets(
      'keeps Agent handoff fail-closed when the task projection cannot be read',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final orders = _FakeOrderRepository();
    await tester.pumpWidget(_app(DsnOrderFlowPage(
      requestRepository: _FakeRequestRepository(
        requesterActorType: 'AGENT',
        principalRef: 'member:buyer',
      ),
      orderRepository: orders,
      taskRepository: _FakeTaskRepository(
        error: StateError('Agent task projection unavailable'),
      ),
      requestId: 9,
    )));
    await tester.pumpAndSettle();

    expect(find.text('订单事实未安全恢复'), findsOneWidget);
    expect(find.text('使用积分支付'), findsNothing);
    expect(find.text('创建未支付订单'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, '刷新任务'), findsOneWidget);
    expect(orders.orderCreated, isFalse);
  });

  testWidgets(
      'keeps Agent handoff fail-closed when the confirmation has expired',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final orders = _FakeOrderRepository(
      issueConfirmationError: const DsnOrderApiException(
        'confirmation expired',
        code: 'PREVIEW_EXPIRED',
      ),
    );
    await tester.pumpWidget(_app(DsnOrderFlowPage(
      requestRepository: _FakeRequestRepository(
        requesterActorType: 'AGENT',
        principalRef: 'member:buyer',
      ),
      orderRepository: orders,
      requestId: 9,
    )));
    await tester.pumpAndSettle();

    await tester.tap(find.text('查看报价并创建预览'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '生成确认引用'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('生成确认引用').last);
    await tester.pumpAndSettle();

    expect(find.text('报价预览已过期，请重新创建预览'), findsOneWidget);
    expect(find.text('创建未支付订单'), findsNothing);
    expect(find.text('使用积分支付'), findsNothing);
    expect(orders.orderCreated, isFalse);
  });

  testWidgets('uses explicit reconcile when the server marks payment uncertain',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final orders = _FakeOrderRepository(reconcilingPayment: true);
    await tester.pumpWidget(_app(DsnOrderFlowPage(
      requestRepository: _FakeRequestRepository(),
      orderRepository: orders,
      taskRepository: _FakeTaskRepository(includePayment: true),
      requestId: 9,
    )));
    await tester.pumpAndSettle();

    expect(find.text('支付处理中'), findsOneWidget);
    await tester.tap(find.text('刷新支付状态'));
    await tester.pumpAndSettle();

    expect(orders.paymentReconciled, isTrue);
    expect(find.text('支付已完成'), findsOneWidget);
  });

  testWidgets('clears stale preview before an order side effect',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final orders = _FakeOrderRepository(
      issueConfirmationError: const DsnOrderApiException(
        'server quote changed',
        code: 'PREVIEW_CONFLICT',
      ),
    );
    await tester.pumpWidget(_app(DsnOrderFlowPage(
      requestRepository: _FakeRequestRepository(),
      orderRepository: orders,
      requestId: 9,
    )));
    await tester.pumpAndSettle();

    await tester.tap(find.text('查看报价并创建预览'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '生成确认引用'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('生成确认引用').last);
    await tester.pumpAndSettle();

    expect(find.text('报价已变化，请刷新后重新创建预览'), findsOneWidget);
    expect(find.text('服务器订单预览'), findsNothing);
    expect(find.text('确认引用已生成'), findsNothing);
    expect(find.text('创建未支付订单'), findsNothing);
    expect(orders.orderCreated, isFalse);
  });

  testWidgets(
      'clears stale preview when order creation sees a version conflict',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final orders = _FakeOrderRepository(
      createOrderError: const DsnOrderApiException(
        'server quote changed',
        code: 'OFFER_VERSION_CONFLICT',
      ),
    );
    await tester.pumpWidget(_app(DsnOrderFlowPage(
      requestRepository: _FakeRequestRepository(),
      orderRepository: orders,
      requestId: 9,
    )));
    await tester.pumpAndSettle();

    await tester.tap(find.text('查看报价并创建预览'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '生成确认引用'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('生成确认引用').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '创建未支付订单'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('创建未支付订单').last);
    await tester.pumpAndSettle();

    expect(find.text('报价已变化，请刷新后重新创建预览'), findsOneWidget);
    expect(find.text('服务器订单预览'), findsNothing);
    expect(find.text('确认引用已生成'), findsNothing);
    expect(find.text('使用积分支付'), findsNothing);
    expect(orders.orderCreated, isFalse);
  });

  testWidgets('fails closed when preview facts no longer match the offer',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final orders = _FakeOrderRepository(
      createPreviewError: const DsnOrderApiException(
        'server quote changed',
        code: 'PREVIEW_CONFLICT',
      ),
    );
    await tester.pumpWidget(_app(DsnOrderFlowPage(
      requestRepository: _FakeRequestRepository(),
      orderRepository: orders,
      requestId: 9,
    )));
    await tester.pumpAndSettle();

    await tester.tap(find.text('查看报价并创建预览'));
    await tester.pumpAndSettle();

    expect(find.text('报价已变化，请刷新后重新创建预览'), findsOneWidget);
    expect(find.text('服务方报价'), findsNothing);
    expect(find.text('服务器订单预览'), findsNothing);
    expect(find.text('生成确认引用'), findsNothing);
    expect(orders.previewCreated, isFalse);
  });
}

Widget _app(Widget child) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

class _FakeRequestRepository implements AgentRepository {
  _FakeRequestRepository(
      {this.requesterActorType = 'HUMAN', this.principalRef});

  final String? requesterActorType;
  final String? principalRef;

  @override
  Future<AgentRequestDraft> getRequest(int id) async => AgentRequestDraft(
        id: id,
        taskTraceId: 'ttr_1234567890abcdef',
        version: 3,
        specHash: 'sha256:${'a' * 64}',
        requesterActorType: requesterActorType,
        principalRef: principalRef,
        serviceId: 42,
        title: 'Need a logo',
        brief: 'Minimal blue identity',
        status: 'PROVIDER_RESPONDED',
        appReviewUrl: '/requests/$id/review',
        createdAt: DateTime(2026, 7, 21, 10),
        updatedAt: DateTime(2026, 7, 21, 10),
      );

  @override
  Future<AgentRequestDraft> abandonRequest(int id) =>
      throw UnimplementedError();
  @override
  Future<void> approveAuthorization(String userCode, Set<String> scopes) =>
      throw UnimplementedError();
  @override
  Future<AgentRequestDraft> approveRequest(int id) =>
      throw UnimplementedError();
  @override
  Future<void> denyAuthorization(String userCode) => throw UnimplementedError();
  @override
  Future<AgentAuthorization> inspectAuthorization(String userCode) =>
      throw UnimplementedError();
  @override
  Future<AgentSessionDetail> getSession(int id) => throw UnimplementedError();
  @override
  Future<List<AgentRequestDraft>> listRequests() => throw UnimplementedError();
  @override
  Future<AgentRequestDraft> createHumanRequest(
          {required int serviceId,
          required String capabilityRevision,
          required String title,
          required String brief,
          int? budgetMaxMinor}) =>
      throw UnimplementedError();
  @override
  Future<AgentSessionPage> listSessions({int? beforeId, int limit = 20}) =>
      throw UnimplementedError();
  @override
  Future<AgentSession> reduceScopes(int id, Set<String> scopes) =>
      throw UnimplementedError();
  @override
  Future<int> revokeAllSessions() => throw UnimplementedError();
  @override
  Future<void> revokeSession(int id) => throw UnimplementedError();
  @override
  Future<void> submitRequest(int id,
          {required int version, required String specHash}) =>
      throw UnimplementedError();
}

class _FakeOrderRepository implements DsnOrderRepository {
  _FakeOrderRepository({
    this.reconcilingPayment = false,
    this.createPreviewError,
    this.issueConfirmationError,
    this.createOrderError,
    this.confirmationResponse,
  });

  final bool reconcilingPayment;
  final DsnOrderApiException? createPreviewError;
  final DsnOrderApiException? issueConfirmationError;
  final DsnOrderApiException? createOrderError;
  final DsnConfirmationRef? confirmationResponse;
  bool previewCreated = false;
  bool confirmationIssued = false;
  bool orderCreated = false;
  bool paymentCreated = false;
  bool paymentReconciled = false;
  int? paymentIfMatchVersion;

  final offer = DsnProviderOffer(
    requestId: 9,
    taskTraceId: 'ttr_1234567890abcdef',
    offerId: 'offer-1',
    acceptanceId: 'accept-1',
    providerId: '77',
    capabilityId: 'service:42',
    variantId: 'standard',
    offerVersion: 2,
    specHash: 'sha256:${'a' * 64}',
    quoteHash: 'sha256:${'b' * 64}',
    quantity: 1,
    amountMinor: 120,
    currency: 'CREDITS',
  );

  @override
  Future<DsnProviderOffer> getProviderOffer(int requestId) async => offer;

  @override
  Future<DsnOrderPreview> createPreview(int requestId,
      {required String expectedSpecHash,
      required String quoteHash,
      required String idempotencyKey}) async {
    if (createPreviewError != null) throw createPreviewError!;
    previewCreated = true;
    return DsnOrderPreview(
      requestId: requestId,
      taskTraceId: offer.taskTraceId,
      previewId: 'preview-1',
      providerId: offer.providerId,
      providerOfferId: offer.offerId,
      providerAcceptanceId: offer.acceptanceId,
      offerVersion: offer.offerVersion,
      specHash: offer.specHash,
      quoteHash: offer.quoteHash,
      amountMinor: offer.amountMinor,
      currency: offer.currency,
      quantity: 1,
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );
  }

  @override
  Future<DsnConfirmationRef> issueConfirmationRef(int requestId,
      {required String previewId,
      required List<String> allowedActions,
      required String idempotencyKey}) async {
    if (issueConfirmationError != null) throw issueConfirmationError!;
    confirmationIssued = true;
    return confirmationResponse ??
        DsnConfirmationRef(
          confirmationRef: 'cr_test-1',
          requestId: requestId,
          taskTraceId: offer.taskTraceId,
          previewId: previewId,
          specHash: offer.specHash,
          quoteHash: offer.quoteHash,
          amountMinor: offer.amountMinor,
          currency: offer.currency,
          paymentMethodType: 'CREDITS',
          allowedActions: allowedActions,
        );
  }

  @override
  Future<DsnOrder> createOrder(int requestId,
      {required DsnOrderPreview preview,
      required DsnConfirmationRef confirmation,
      required int ifMatchVersion,
      required String idempotencyKey}) async {
    if (createOrderError != null) throw createOrderError!;
    orderCreated = true;
    return DsnOrder(
      orderId: '1001',
      taskTraceId: offer.taskTraceId,
      commitmentId: 'commit-1',
      confirmationRef: confirmation.confirmationRef,
      amountMinor: preview.amountMinor,
      currency: preview.currency,
      orderState: 'awaitingPayment',
      commitmentVersion: 2,
      offerId: offer.offerId,
    );
  }

  @override
  Future<DsnPaymentAttempt> createPaymentAttempt(DsnOrder order,
      {required DsnOrderPreview preview,
      required DsnConfirmationRef confirmation,
      required int ifMatchVersion,
      required String idempotencyKey}) async {
    paymentCreated = true;
    paymentIfMatchVersion = ifMatchVersion;
    return DsnPaymentAttempt(
      paymentAttemptId: 'payment-1',
      orderId: order.orderId,
      taskTraceId: offer.taskTraceId,
      state: 'PAYMENT_CAPTURED',
      fundsDisposition: 'CAPTURED',
      effectiveCommitment: true,
      amountMinor: preview.amountMinor,
      currency: 'CREDITS',
      confirmationRef: confirmation.confirmationRef,
      commitmentVersion: 2,
    );
  }

  @override
  Future<DsnPaymentAttempt> getPaymentAttempt(String paymentAttemptId) =>
      reconcilingPayment
          ? Future.value(_reconcilingPayment(paymentAttemptId))
          : throw UnimplementedError();

  @override
  Future<DsnPaymentAttempt> reconcilePaymentAttempt(
      String paymentAttemptId) async {
    paymentReconciled = true;
    return DsnPaymentAttempt(
      paymentAttemptId: paymentAttemptId,
      orderId: '1001',
      taskTraceId: offer.taskTraceId,
      state: 'PAYMENT_CAPTURED',
      fundsDisposition: 'CAPTURED',
      effectiveCommitment: true,
      amountMinor: offer.amountMinor,
      currency: 'CREDITS',
      confirmationRef: 'cr_test-1',
      commitmentVersion: 2,
    );
  }

  DsnPaymentAttempt _reconcilingPayment(String paymentAttemptId) =>
      DsnPaymentAttempt(
        paymentAttemptId: paymentAttemptId,
        orderId: '1001',
        taskTraceId: offer.taskTraceId,
        state: 'PAYMENT_RECONCILING',
        fundsDisposition: 'RECONCILING',
        effectiveCommitment: false,
        amountMinor: offer.amountMinor,
        currency: 'CREDITS',
        confirmationRef: 'cr_test-1',
        commitmentVersion: 2,
        nextAction: 'RECONCILE_PAYMENT_ATTEMPT',
      );
}

class _FakeTaskRepository implements DasnTaskRepository {
  _FakeTaskRepository({
    this.includePayment = false,
    this.commitmentOverrides = const <String, dynamic>{},
    this.orderCommitmentVersion = 2,
    this.paymentCommitmentVersion = 2,
    this.error,
  });

  final bool includePayment;
  final Map<String, dynamic> commitmentOverrides;
  final int? orderCommitmentVersion;
  final int? paymentCommitmentVersion;
  final Object? error;
  @override
  Future<DasnTaskView> getTask(String taskTraceId) async {
    if (error != null) throw error!;
    return _view();
  }

  @override
  Future<DasnTaskView> getReceipt(String taskTraceId) async => _view();

  DasnTaskView _view() => DasnTaskView.fromJson({
        'taskTraceId': 'ttr_1234567890abcdef',
        'operationTraceId': 'trace_restore',
        'task': {
          'taskLifecycle': 'READY',
          'responsibilityAction': 'PENDING',
          'syncStatus': 'SYNCED',
          'waitingOn': 'PRINCIPAL',
          'nextActions': <dynamic>[],
        },
        'data': {
          'request': {'id': 9},
          'commitment': {
            'id': 'commit-1',
            'orderId': 1001,
            'acceptanceId': 'accept-1',
            'previewId': 'preview-1',
            'confirmationRef': 'cr_test-1',
            'offerVersion': 2,
            'commitmentVersion': 2,
            'specHash': 'a' * 64,
            'quoteHash': 'b' * 64,
            'amountCredits': 120,
            'currency': 'CREDITS',
            ...commitmentOverrides,
          },
          'order': {
            'id': 1001,
            'state': 'awaitingPayment',
            'commitmentVersion': orderCommitmentVersion,
          },
          'paymentAttempt': includePayment
              ? {
                  'id': 'payment-1',
                  'fundsDisposition': 'RECONCILING',
                  'commitmentVersion': paymentCommitmentVersion,
                }
              : null,
        },
      });
}
