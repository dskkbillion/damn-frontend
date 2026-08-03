import 'package:dskk_flutter_refactor/features/agent/data/agent_repository.dart';
import 'package:dskk_flutter_refactor/features/agent/domain/agent_models.dart';
import 'package:dskk_flutter_refactor/features/agent/presentation/agent_session_detail_page.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('scope update can only remove an existing permission',
      (tester) async {
    final repository = _SessionRepository();
    await tester.pumpWidget(_app(AgentSessionDetailPage(
      repository: repository,
      sessionId: 22,
    )));
    await tester.pumpAndSettle();

    final listView = tester.widget<ListView>(find.byType(ListView));
    final padding = listView.padding! as EdgeInsets;
    expect(padding.bottom, greaterThanOrEqualTo(96));

    expect(find.text('Studio Mac'), findsOneWidget);
    expect(find.text('Client type: CLI'), findsOneWidget);
    expect(find.text('Client identifier: #11'), findsOneWidget);
    expect(find.textContaining('Access expires:'), findsOneWidget);
    expect(find.textContaining('Authorization expires:'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Request draft created'), 250,
        scrollable: find.byWidgetPredicate((widget) =>
            widget is Scrollable &&
            widget.axisDirection == AxisDirection.down));
    expect(find.text('Request draft created'), findsOneWidget);
    await tester.scrollUntilVisible(
        find.text('Create App-reviewed request drafts'), -200,
        scrollable: find.byWidgetPredicate((widget) =>
            widget is Scrollable &&
            widget.axisDirection == AxisDirection.down));
    await tester.tap(find.text('Create App-reviewed request drafts'));
    await tester.drag(find.byType(ListView), const Offset(0, -350));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save permissions'));
    await tester.pumpAndSettle();

    expect(repository.savedScopes, {'services:read'});
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

class _SessionRepository implements AgentRepository {
  Set<String>? savedScopes;

  AgentSession get _session => AgentSession(
        id: 22,
        clientId: 11,
        clientName: 'Test CLI',
        clientType: 'CLI',
        deviceName: 'Studio Mac',
        platform: 'darwin-arm64',
        cliVersion: '0.1.0',
        scopes: savedScopes ?? const {'services:read', 'requests:create'},
        status: 'ACTIVE',
        accessExpiresAt: DateTime.now().add(const Duration(minutes: 20)),
        refreshExpiresAt: DateTime.now().add(const Duration(days: 30)),
        lastUsedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

  @override
  Future<AgentSessionDetail> getSession(int id) async =>
      AgentSessionDetail(_session, [
        AgentAuditEvent(
            'REQUEST_DRAFT_CREATE', 'SUCCESS', null, DateTime(2026, 7, 19, 12))
      ]);
  @override
  Future<AgentSession> reduceScopes(int id, Set<String> scopes) async {
    savedScopes = {...scopes};
    return _session;
  }

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
  Future<AgentRequestDraft> getRequest(int id) => throw UnimplementedError();
  @override
  Future<List<AgentRequestDraft>> listRequests() => throw UnimplementedError();
  @override
  Future<AgentSessionPage> listSessions({int? beforeId, int limit = 20}) =>
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
