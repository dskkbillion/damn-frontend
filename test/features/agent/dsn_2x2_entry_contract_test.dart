import 'package:dskk_flutter_refactor/core/dasn/data/dasn_task_repository.dart';
import 'package:dskk_flutter_refactor/core/dasn/data/dsn_order_repository.dart';
import 'package:dskk_flutter_refactor/core/dasn/domain/dasn_task_view.dart';
import 'package:dskk_flutter_refactor/core/dasn/domain/dsn_order_models.dart';
import 'package:dskk_flutter_refactor/features/agent/data/agent_repository.dart';
import 'package:dskk_flutter_refactor/features/agent/domain/agent_models.dart';
import 'package:dskk_flutter_refactor/features/agent/presentation/agent_request_review_page.dart';
import 'package:dskk_flutter_refactor/features/agent/presentation/agent_requests_page.dart';
import 'package:dskk_flutter_refactor/features/agent/presentation/agent_routes.dart';
import 'package:dskk_flutter_refactor/features/agent/presentation/dsn_order_flow_page.dart';
import 'package:dskk_flutter_refactor/features/agent/presentation/dsn_task_page.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// The DS 0.2 actor matrix is an identity/ingress matrix, not four business
/// implementations.  This test intentionally drives the same App pages for
/// every pairing and asserts the same order/payment/receipt facts are used.
enum _ActorPairing {
  h2h('H2H', 'HUMAN', 'HUMAN'),
  h2a('H2A', 'HUMAN', 'AGENT'),
  a2h('A2H', 'AGENT', 'HUMAN'),
  a2a('A2A', 'AGENT', 'AGENT');

  const _ActorPairing(this.label, this.buyerActor, this.providerActor);

  final String label;
  final String buyerActor;
  final String providerActor;
}

void main() {
  test('exposes one canonical App entry set for all DS 0.2 pairings', () {
    final paths = AgentRoutes.routes
        .whereType<GoRoute>()
        .map((route) => route.path)
        .toList();

    expect(
      paths,
      containsAll(<String>[
        '/requests/new',
        '/requests/:id/review',
        '/requests/:id/order',
        '/agent/tasks/:taskTraceId',
        '/provider/tasks',
      ]),
    );
    // No actor pairing is allowed to introduce a legacy order/payment entry.
    expect(paths, everyElement(isNot(contains('/api/'))));
  });

  testWidgets(
      'all four pairings share review and receipt surfaces; Agent buyers hand off Commitment',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final pairing in _ActorPairing.values) {
      final requestRepository = _MatrixRequestRepository(pairing);
      final orderRepository = _MatrixOrderRepository(pairing);

      // The provider response is the only fact needed to unlock the shared
      // buyer order surface.  It does not matter whether the response came
      // from the human Provider App or the Provider Agent adapter.
      await tester.pumpWidget(_app(AgentRequestReviewPage(
        repository: requestRepository,
        orderRepository: orderRepository,
        requestId: requestRepository.request.id,
      )));
      await tester.pumpAndSettle();
      expect(find.text('查看报价并继续下单'), findsOneWidget,
          reason: '${pairing.label} lost the shared order handoff');

      await tester.pumpWidget(_app(DsnOrderFlowPage(
        requestRepository: requestRepository,
        orderRepository: orderRepository,
        requestId: requestRepository.request.id,
      )));
      await tester.pumpAndSettle();
      expect(find.text('服务方报价'), findsOneWidget,
          reason: '${pairing.label} did not reach the shared offer surface');

      await tester.tap(find.text('查看报价并创建预览'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, '生成确认引用'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('生成确认引用').last);
      await tester.pumpAndSettle();
      if (pairing.buyerActor == 'AGENT') {
        // The App has no Agent credential and must not POST the Agent
        // commitment route.  This is a local handoff contract only; the
        // external runner/Grant and its runtime HTTP path are tested outside
        // this Flutter fixture.
        expect(find.text('等待 Buyer Agent 创建 Commitment'), findsOneWidget,
            reason: '${pairing.label} did not stop at the Agent handoff');
        expect(find.text('创建未支付订单'), findsNothing);
        expect(
          orderRepository.steps,
          <String>[
            'getProviderOffer',
            'createPreview',
            'issueConfirmationRef',
          ],
          reason: '${pairing.label} used an App order side effect',
        );
      } else {
        await tester.tap(find.widgetWithText(FilledButton, '创建未支付订单'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('创建未支付订单').last);
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilledButton, '使用积分支付'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('确认支付').last);
        await tester.pumpAndSettle();

        expect(
            orderRepository.steps,
            <String>[
              'getProviderOffer',
              'createPreview',
              'issueConfirmationRef',
              'createOrder',
              'createPaymentAttempt',
            ],
            reason: '${pairing.label} selected a different economic flow');
        expect(find.text('支付已完成'), findsOneWidget);
      }
      expect(requestRepository.request.requesterActorType, pairing.buyerActor);
      expect(orderRepository.providerActor, pairing.providerActor);

      // Delivery is an append-only server fact; the App reads the same task
      // projection and receipt after either Provider adapter has written it.
      // For Agent buyers, the fixture starts after the external commitment;
      // no App-side Agent token or Grant is fabricated here.
      await tester.pumpWidget(_app(DsnTaskPage(
        repository: _MatrixTaskRepository(pairing),
        taskTraceId: requestRepository.request.taskTraceId!,
      )));
      await tester.pumpAndSettle();
      expect(find.text('COMPLETED'), findsWidgets,
          reason: '${pairing.label} did not render the canonical receipt');
      expect(find.text('DSN_APPEND_ONLY'), findsOneWidget);
      expect(find.text('Accept delivery'), findsNothing,
          reason: '${pairing.label} exposed a second final-accept action');
      expect(find.text('Request revision'), findsNothing);
      expect(find.text('Open dispute'), findsNothing);
    }
  });

  testWidgets('request list forwards the same order facade into review',
      (tester) async {
    const pairing = _ActorPairing.a2a;
    final requestRepository = _MatrixRequestRepository(pairing);
    final orderRepository = _MatrixOrderRepository(pairing);

    await tester.pumpWidget(_app(AgentRequestsPage(
      repository: requestRepository,
      orderRepository: orderRepository,
    )));
    await tester.pumpAndSettle();

    await tester.tap(find.text('${pairing.label} DS request'));
    await tester.pumpAndSettle();

    expect(find.text('查看报价并继续下单'), findsOneWidget);
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

class _MatrixRequestRepository implements AgentRepository {
  _MatrixRequestRepository(this.pairing)
      : request = AgentRequestDraft(
            id: 29,
            taskTraceId: 'ttr_2x2_${pairing.label.toLowerCase()}_123456',
            version: 3,
            specHash: _hash('a'),
            requesterActorType: pairing.buyerActor,
            serviceId: 581,
            title: '${pairing.label} DS request',
            brief: 'Shared DS 0.2 request',
            status: 'PROVIDER_RESPONDED',
            providerMemberId: pairing.providerActor == 'HUMAN' ? 10589 : null,
            appReviewUrl: '/requests/29/review',
            providerRespondedAt: DateTime(2026, 8, 5, 23),
            createdAt: DateTime(2026, 8, 5, 22),
            updatedAt: DateTime(2026, 8, 5, 23));

  final _ActorPairing pairing;
  final AgentRequestDraft request;

  @override
  Future<AgentRequestDraft> getRequest(int id) async => request;

  @override
  Future<AgentRequestDraft> abandonRequest(int id) =>
      throw UnimplementedError();

  @override
  Future<void> approveAuthorization(String userCode, Set<String> scopes) =>
      throw UnimplementedError();

  @override
  Future<void> denyAuthorization(String userCode) => throw UnimplementedError();

  @override
  Future<AgentAuthorization> inspectAuthorization(String userCode) =>
      throw UnimplementedError();

  @override
  Future<AgentSessionDetail> getSession(int id) => throw UnimplementedError();

  @override
  Future<List<AgentRequestDraft>> listRequests() async => <AgentRequestDraft>[
        request,
      ];

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
  Future<AgentRequestDraft> approveRequest(int id) =>
      throw UnimplementedError();

  @override
  Future<void> submitRequest(int id,
          {required int version, required String specHash}) =>
      throw UnimplementedError();
}

class _MatrixOrderRepository implements DsnOrderRepository {
  _MatrixOrderRepository(this.pairing)
      : offer = DsnProviderOffer(
            requestId: 29,
            taskTraceId: 'ttr_2x2_${pairing.label.toLowerCase()}_123456',
            offerId: 'offer-2x2',
            acceptanceId: 'accept-2x2',
            providerId: 'provider-${pairing.providerActor.toLowerCase()}',
            capabilityId: 'service:581',
            variantId: 'standard',
            offerVersion: 2,
            specHash: _hash('a'),
            quoteHash: _hash('b'),
            quantity: 1,
            amountMinor: 120,
            currency: 'CREDITS');

  final _ActorPairing pairing;
  final List<String> steps = <String>[];
  final DsnProviderOffer offer;

  String get providerActor => pairing.providerActor;

  @override
  Future<DsnProviderOffer> getProviderOffer(int requestId) async {
    steps.add('getProviderOffer');
    return DsnProviderOffer(
      requestId: offer.requestId,
      taskTraceId: 'ttr_2x2_${pairing.label.toLowerCase()}_123456',
      offerId: offer.offerId,
      acceptanceId: offer.acceptanceId,
      providerId: offer.providerId,
      capabilityId: offer.capabilityId,
      variantId: offer.variantId,
      offerVersion: offer.offerVersion,
      specHash: offer.specHash,
      quoteHash: offer.quoteHash,
      quantity: offer.quantity,
      amountMinor: offer.amountMinor,
      currency: offer.currency,
    );
  }

  @override
  Future<DsnOrderPreview> createPreview(int requestId,
      {required String expectedSpecHash,
      required String quoteHash,
      required String idempotencyKey}) async {
    steps.add('createPreview');
    return DsnOrderPreview(
      requestId: requestId,
      taskTraceId: offer.taskTraceId,
      previewId: 'preview-2x2',
      providerId: offer.providerId,
      providerOfferId: offer.offerId,
      providerAcceptanceId: offer.acceptanceId,
      offerVersion: offer.offerVersion,
      specHash: offer.specHash,
      quoteHash: offer.quoteHash,
      amountMinor: offer.amountMinor,
      currency: offer.currency,
      quantity: 1,
      expiresAt: DateTime(2026, 8, 5, 23, 30),
    );
  }

  @override
  Future<DsnConfirmationRef> issueConfirmationRef(int requestId,
      {required String previewId,
      required List<String> allowedActions,
      required String idempotencyKey}) async {
    steps.add('issueConfirmationRef');
    return DsnConfirmationRef(
      confirmationRef: 'cr-2x2',
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
    steps.add('createOrder');
    return DsnOrder(
      orderId: 'order-2x2',
      taskTraceId: offer.taskTraceId,
      commitmentId: 'commit-2x2',
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
    steps.add('createPaymentAttempt');
    return DsnPaymentAttempt(
      paymentAttemptId: 'payment-2x2',
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
      throw UnimplementedError();

  @override
  Future<DsnPaymentAttempt> reconcilePaymentAttempt(String paymentAttemptId) =>
      throw UnimplementedError();
}

class _MatrixTaskRepository implements DasnTaskRepository {
  _MatrixTaskRepository(this.pairing);

  final _ActorPairing pairing;

  @override
  Future<DasnTaskView> getTask(String taskTraceId) async => _view();

  @override
  Future<DasnTaskView> getReceipt(String taskTraceId) async => _view();

  DasnTaskView _view() => DasnTaskView.fromJson({
        'taskTraceId': 'ttr_2x2_${pairing.label.toLowerCase()}_123456',
        'operationTraceId': 'trace-${pairing.label.toLowerCase()}',
        'task': {
          'taskLifecycle': 'COMPLETED',
          'responsibilityAction': 'NONE',
          'syncStatus': 'SYNCED',
          'waitingOn': 'NONE',
          'nextActions': <dynamic>[],
        },
        'data': {
          'receipt': {
            'state': 'COMPLETED',
            'source': 'DSN_APPEND_ONLY',
            'orderId': 202,
            'commitmentVersion': 1,
            'fundsDisposition': 'CAPTURED',
            'disputeOpen': false,
            'finalDecision': {'action': 'ACCEPT'},
            'latestEvidence': {
              'deliveryId': 'delivery-2x2',
              'commitmentVersion': 1,
              'submissionNo': 1,
              'evidenceHash': _hash('c'),
            },
          },
        },
      });
}

String _hash(String letter) => 'sha256:${letter * 64}';
