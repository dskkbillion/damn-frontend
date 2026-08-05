import 'package:dskk_flutter_refactor/core/dasn/data/dsn_order_repository.dart';
import 'package:dskk_flutter_refactor/core/dasn/data/dasn_task_repository.dart';
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
  @override
  Future<AgentRequestDraft> getRequest(int id) async => AgentRequestDraft(
        id: id,
        taskTraceId: 'ttr_1234567890abcdef',
        version: 3,
        specHash: 'sha256:${'a' * 64}',
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
  });

  final bool reconcilingPayment;
  final DsnOrderApiException? createPreviewError;
  final DsnOrderApiException? issueConfirmationError;
  final DsnOrderApiException? createOrderError;
  bool previewCreated = false;
  bool confirmationIssued = false;
  bool orderCreated = false;
  bool paymentCreated = false;
  bool paymentReconciled = false;

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
    return DsnConfirmationRef(
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
      offerId: offer.offerId,
    );
  }

  @override
  Future<DsnPaymentAttempt> createPaymentAttempt(DsnOrder order,
      {required DsnOrderPreview preview,
      required DsnConfirmationRef confirmation,
      required String idempotencyKey}) async {
    paymentCreated = true;
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
        nextAction: 'RECONCILE_PAYMENT_ATTEMPT',
      );
}

class _FakeTaskRepository implements DasnTaskRepository {
  _FakeTaskRepository({this.includePayment = false});

  final bool includePayment;
  @override
  Future<DasnTaskView> getTask(String taskTraceId) async => _view();

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
          'commitment': {
            'id': 'commit-1',
            'orderId': 1001,
            'previewId': 'preview-1',
            'confirmationRef': 'cr_test-1',
            'offerVersion': 2,
            'specHash': 'a' * 64,
            'quoteHash': 'b' * 64,
            'amountCredits': 120,
            'currency': 'CREDITS',
          },
          'order': {
            'id': 1001,
            'state': 'awaitingPayment',
          },
          'paymentAttempt': includePayment
              ? {
                  'id': 'payment-1',
                  'fundsDisposition': 'RECONCILING',
                }
              : null,
        },
      });
}
