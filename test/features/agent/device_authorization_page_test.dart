import 'dart:async';

import 'package:dskk_flutter_refactor/features/agent/data/agent_repository.dart';
import 'package:dskk_flutter_refactor/features/agent/domain/agent_models.dart';
import 'package:dskk_flutter_refactor/features/agent/presentation/device_authorization_page.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows requested scopes and approves only selected scopes',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _FakeAgentRepository();
    await tester.pumpWidget(_app(DeviceAuthorizationPage(
      repository: repository,
      initialCode: 'ABCD-EFGH',
    )));
    await tester.pumpAndSettle();

    expect(find.text('Test CLI'), findsOneWidget);
    expect(find.textContaining('Test Mac'), findsOneWidget);
    expect(find.text('Search and view services'), findsOneWidget);
    expect(find.text('Create App-reviewed request drafts'), findsOneWidget);

    await tester.scrollUntilVisible(
        find.text('Create App-reviewed request drafts'), 200,
        scrollable: find.byWidgetPredicate((widget) =>
            widget is Scrollable &&
            widget.axisDirection == AxisDirection.down));
    await tester.tap(find.text('Create App-reviewed request drafts'));
    final allow = find.text('Allow connection');
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(allow);
    await tester.pumpAndSettle();

    expect(repository.approvedCode, 'ABCD-EFGH');
    expect(repository.approvedScopes, {'services:read'});
    expect(find.text('Connection allowed. You can return to the CLI.'),
        findsOneWidget);
  });

  testWidgets('does not show approval controls for an already used request',
      (tester) async {
    final repository = _FakeAgentRepository()..authorizationStatus = 'CONSUMED';
    await tester.pumpWidget(_app(DeviceAuthorizationPage(
      repository: repository,
      initialCode: 'ABCD-EFGH',
    )));
    await tester.pumpAndSettle();

    expect(find.text('This connection code has already been used.'),
        findsOneWidget);
    expect(find.text('Allow connection'), findsNothing);
  });

  testWidgets('rejects malformed user code before calling the API',
      (tester) async {
    final repository = _FakeAgentRepository();
    await tester.pumpWidget(_app(DeviceAuthorizationPage(
      repository: repository,
      initialCode: 'ABC',
    )));

    await tester.tap(find.text('Check connection request'));
    await tester.pump();

    expect(find.text('Enter the 8-character user code'), findsOneWidget);
    expect(repository.inspectCalls, 0);
  });

  testWidgets('binds approval to the latest inspected code', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _OutOfOrderAgentRepository();

    await tester.pumpWidget(_app(DeviceAuthorizationPage(
      repository: repository,
      initialCode: 'AAAA-AAAA',
    )));
    await tester.pump();

    await tester.pumpWidget(_app(DeviceAuthorizationPage(
      repository: repository,
      initialCode: 'BBBB-BBBB',
    )));
    await tester.pump();

    repository.complete('BBBB-BBBB', clientName: 'Client B');
    await tester.pump();
    repository.complete('AAAA-AAAA', clientName: 'Client A');
    await tester.pump();

    expect(find.text('Client B'), findsOneWidget);
    expect(find.text('Client A'), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Allow connection'));
    await tester.pumpAndSettle();

    expect(repository.approvedCode, 'BBBB-BBBB');
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

class _FakeAgentRepository implements AgentRepository {
  int inspectCalls = 0;
  String? approvedCode;
  Set<String>? approvedScopes;
  String authorizationStatus = 'PENDING';

  @override
  Future<AgentAuthorization> inspectAuthorization(String userCode) async {
    inspectCalls++;
    return AgentAuthorization(
      clientName: 'Test CLI',
      clientType: 'CLI',
      deviceName: 'Test Mac',
      platform: 'macOS',
      cliVersion: '0.1.0',
      requestedScopes: const {'services:read', 'requests:create'},
      status: authorizationStatus,
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );
  }

  @override
  Future<void> approveAuthorization(String userCode, Set<String> scopes) async {
    approvedCode = userCode;
    approvedScopes = {...scopes};
  }

  @override
  Future<void> denyAuthorization(String userCode) async {}

  @override
  Future<AgentRequestDraft> abandonRequest(int id) =>
      throw UnimplementedError();
  @override
  Future<AgentRequestDraft> approveRequest(int id) =>
      throw UnimplementedError();
  @override
  Future<AgentRequestDraft> getRequest(int id) => throw UnimplementedError();
  @override
  Future<AgentSessionDetail> getSession(int id) => throw UnimplementedError();
  @override
  Future<List<AgentRequestDraft>> listRequests() => throw UnimplementedError();
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

class _OutOfOrderAgentRepository extends _FakeAgentRepository {
  final Map<String, Completer<AgentAuthorization>> _pending = {};

  @override
  Future<AgentAuthorization> inspectAuthorization(String userCode) {
    inspectCalls++;
    return (_pending[userCode] = Completer<AgentAuthorization>()).future;
  }

  void complete(String userCode, {required String clientName}) {
    _pending[userCode]!.complete(AgentAuthorization(
      clientName: clientName,
      clientType: 'CLI',
      deviceName: 'Test Mac',
      platform: 'macOS',
      cliVersion: '0.1.0',
      requestedScopes: const {'services:read'},
      status: 'PENDING',
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    ));
  }
}
