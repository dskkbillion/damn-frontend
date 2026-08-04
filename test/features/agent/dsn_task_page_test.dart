import 'package:dskk_flutter_refactor/core/dasn/data/dasn_task_repository.dart';
import 'package:dskk_flutter_refactor/core/dasn/data/dsn_delivery_decision_repository.dart';
import 'package:dskk_flutter_refactor/core/dasn/domain/dasn_task_view.dart';
import 'package:dskk_flutter_refactor/core/dasn/domain/dsn_delivery_decision_models.dart';
import 'package:dskk_flutter_refactor/features/agent/presentation/dsn_task_page.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'renders tri-axis projection, one primary action and fallback receipt',
      (tester) async {
    final repository = _FakeDasnTaskRepository(_view(
      waitingOn: 'COUNTERPARTY',
      receipt: {
        'state': 'AWAITING_DELIVERY',
        'source': 'LEGACY_FALLBACK',
        'orderId': 88,
      },
    ));

    await tester.pumpWidget(_app(DsnTaskPage(
      repository: repository,
      taskTraceId: 'ttr_1234567890abcdef',
    )));
    await tester.pumpAndSettle();

    expect(find.text('RUNNING'), findsOneWidget);
    expect(find.text('NONE'), findsOneWidget);
    expect(find.text('SYNCED'), findsOneWidget);
    expect(find.text('COUNTERPARTY'), findsOneWidget);
    expect(find.text('View progress'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('LEGACY_FALLBACK'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('LEGACY_FALLBACK'), findsOneWidget);
    expect(find.textContaining('legacy facts view'), findsOneWidget);
    // The reducer's one chosen action is shown once; the page does not render
    // the server's full action list as a second set of buttons.
    expect(find.text('Primary action'), findsOneWidget);
    expect(find.text('Refresh status'), findsOneWidget);
  });

  testWidgets('offers retry after a read failure and keeps the page read-only',
      (tester) async {
    final repository = _FakeDasnTaskRepository(_view())..failTaskOnce = true;
    await tester.pumpWidget(_app(DsnTaskPage(
      repository: repository,
      taskTraceId: 'ttr_1234567890abcdef',
    )));
    await tester.pumpAndSettle();

    expect(find.text('task read failed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Submit'), findsNothing);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(repository.taskCalls, 2);
    expect(find.text('Task lifecycle'), findsOneWidget);
  });

  testWidgets('loads a missing receipt through the read-only receipt endpoint',
      (tester) async {
    final repository = _FakeDasnTaskRepository(_view())
      ..receiptView = _view(
        receipt: {'state': 'COMPLETED', 'source': 'DSN_APPEND_ONLY'},
      );
    await tester.pumpWidget(_app(DsnTaskPage(
      repository: repository,
      taskTraceId: 'ttr_1234567890abcdef',
    )));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('No receipt is available yet.'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('No receipt is available yet.'), findsOneWidget);
    await tester.tap(find.text('Load receipt'));
    await tester.pumpAndSettle();

    expect(repository.receiptCalls, 1);
    expect(find.text('COMPLETED'), findsOneWidget);
    expect(find.text('DSN_APPEND_ONLY'), findsOneWidget);
  });

  testWidgets('shows explicit buyer delivery decisions from current evidence',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _FakeDasnTaskRepository(_view(
      waitingOn: 'PRINCIPAL',
      receipt: {
        'state': 'AWAITING_ACCEPTANCE',
        'source': 'DSN_APPEND_ONLY',
        'orderId': 88,
        'commitmentVersion': 4,
        'disputeOpen': false,
        'latestEvidence': {
          'deliveryId': 'del-2',
          'commitmentVersion': 4,
          'submissionNo': 2,
          'evidenceHash': _hash('a'),
        },
      },
    ));
    final decisions = _FakeDsnDeliveryDecisionRepository();

    await tester.pumpWidget(_app(DsnTaskPage(
      repository: repository,
      decisionRepository: decisions,
      taskTraceId: 'ttr_1234567890abcdef',
    )));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Accept delivery'));

    expect(find.text('Accept delivery'), findsOneWidget);
    expect(find.text('Request revision'), findsOneWidget);
    expect(find.text('Open dispute'), findsOneWidget);
    expect(decisions.inputs, isEmpty);
    await tester.tap(find.text('Accept delivery'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm acceptance'), findsOneWidget);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(decisions.inputs, hasLength(1));
    final input = decisions.inputs.single;
    expect(input.orderId, 88);
    expect(input.deliveryId, 'del-2');
    expect(input.submissionNo, 2);
    expect(input.commitmentVersion, 4);
    expect(input.expectedSubmissionHash, _hash('a'));
    expect(input.decision, DsnDeliveryDecisionAction.accept);
    expect(decisions.keys.single, 'buyer-decision:88:del-2:ACCEPT:v1');
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

DasnTaskView _view({String waitingOn = 'NONE', Map<String, dynamic>? receipt}) {
  return DasnTaskView.fromJson({
    'taskTraceId': 'ttr_1234567890abcdef',
    'operationTraceId': 'trace-read-1',
    'task': {
      'taskLifecycle': 'RUNNING',
      'responsibilityAction': 'NONE',
      'syncStatus': 'SYNCED',
      'waitingOn': waitingOn,
      'nextActions': [
        {'type': 'VIEW_PROGRESS'},
      ],
    },
    if (receipt != null) 'data': {'receipt': receipt},
  });
}

class _FakeDasnTaskRepository implements DasnTaskRepository {
  _FakeDasnTaskRepository(this.taskView);

  final DasnTaskView taskView;
  DasnTaskView? receiptView;
  bool failTaskOnce = false;
  int taskCalls = 0;
  int receiptCalls = 0;

  @override
  Future<DasnTaskView> getTask(String taskTraceId) async {
    taskCalls++;
    if (failTaskOnce) {
      failTaskOnce = false;
      throw const DasnTaskApiException('task read failed');
    }
    return taskView;
  }

  @override
  Future<DasnTaskView> getReceipt(String taskTraceId) async {
    receiptCalls++;
    return receiptView ?? taskView;
  }
}

class _FakeDsnDeliveryDecisionRepository
    implements DsnDeliveryDecisionRepository {
  final List<DsnDeliveryDecisionInput> inputs = [];
  final List<String> keys = [];

  @override
  Future<DsnDeliveryDecisionResult> submitDecision(
    DsnDeliveryDecisionInput input, {
    required String idempotencyKey,
  }) async {
    inputs.add(input);
    keys.add(idempotencyKey);
    return DsnDeliveryDecisionResult(
      state: input.decision.responseState,
      taskTraceId: 'ttr_1234567890abcdef',
      operationTraceId: 'trace-decision-test',
      decisionId: 'dec-1',
      orderId: input.orderId,
      commitmentId: 'commit-1',
      commitmentVersion: input.commitmentVersion,
      deliveryId: input.deliveryId,
      submissionNo: input.submissionNo,
      action: input.decision,
      actorType: 'PRINCIPAL',
    );
  }
}

String _hash(String letter) => 'sha256:${letter * 64}';
