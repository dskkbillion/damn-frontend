import 'dart:async';

import 'package:dskk_flutter_refactor/features/agent/data/agent_repository.dart';
import 'package:dskk_flutter_refactor/features/agent/domain/agent_models.dart';
import 'package:dskk_flutter_refactor/features/agent/presentation/connected_agents_page.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows complete client metadata without a fixed ListTile height',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _ConnectedAgentsRepository();

    await tester.pumpWidget(_app(ConnectedAgentsPage(repository: repository)));
    await tester.pumpAndSettle();

    expect(find.text('Codex'), findsOneWidget);
    expect(find.textContaining('CLI · Client identifier: #9'), findsOneWidget);
    expect(find.textContaining('Access expires:'), findsOneWidget);
    expect(find.textContaining('Authorization expires:'), findsOneWidget);
    expect(find.textContaining('declared by the connecting program'),
        findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('revoke all is single-flight and refreshes the active state',
      (tester) async {
    final repository = _ConnectedAgentsRepository();
    await tester.pumpWidget(_app(ConnectedAgentsPage(repository: repository)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Revoke all'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Revoke'));
    await tester.pump();

    expect(repository.revokeAllCalls, 1);
    final action = tester
        .widget<TextButton>(find.widgetWithText(TextButton, 'Revoke all'));
    expect(action.onPressed, isNull);

    repository.revokeCompleter.complete(1);
    await tester.pumpAndSettle();

    expect(find.text('Revoke all'), findsNothing);
    expect(repository.revokeAllCalls, 1);
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

class _ConnectedAgentsRepository implements AgentRepository {
  final Completer<int> revokeCompleter = Completer<int>();
  int revokeAllCalls = 0;
  bool revoked = false;

  AgentSession get _session => AgentSession(
        id: 22,
        clientId: 9,
        clientName: 'Codex',
        clientType: 'CLI',
        deviceName: 'Studio Mac',
        platform: 'macOS',
        cliVersion: '0.1.0',
        scopes: const {'services:read', 'requests:read'},
        status: revoked ? 'REVOKED' : 'ACTIVE',
        accessExpiresAt: DateTime(2026, 7, 20, 12),
        refreshExpiresAt: DateTime(2026, 8, 20, 12),
        lastUsedAt: DateTime(2026, 7, 19, 12),
        createdAt: DateTime(2026, 7, 18, 12),
      );

  @override
  Future<List<AgentSession>> listSessions() async => [_session];

  @override
  Future<int> revokeAllSessions() async {
    revokeAllCalls++;
    final result = await revokeCompleter.future;
    revoked = true;
    return result;
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
  Future<AgentSessionDetail> getSession(int id) => throw UnimplementedError();
  @override
  Future<List<AgentRequestDraft>> listRequests() => throw UnimplementedError();
  @override
  Future<AgentSession> reduceScopes(int id, Set<String> scopes) =>
      throw UnimplementedError();
  @override
  Future<void> revokeSession(int id) => throw UnimplementedError();
}
