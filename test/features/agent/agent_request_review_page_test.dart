import 'package:dskk_flutter_refactor/features/agent/data/agent_repository.dart';
import 'package:dskk_flutter_refactor/features/agent/domain/agent_models.dart';
import 'package:dskk_flutter_refactor/features/agent/presentation/agent_request_review_page.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows read-only task status link after the draft boundary',
      (tester) async {
    await tester.pumpWidget(_app(AgentRequestReviewPage(
      repository: _FakeRequestRepository(_request(status: 'SUBMITTED')),
      requestId: 9,
    )));
    await tester.pumpAndSettle();

    expect(find.text('View task status'), findsOneWidget);
    expect(find.text('Submit to provider'), findsNothing);
  });

  testWidgets('does not show task status link while App review is pending',
      (tester) async {
    await tester.pumpWidget(_app(AgentRequestReviewPage(
      repository:
          _FakeRequestRepository(_request(status: 'AWAITING_APP_REVIEW')),
      requestId: 9,
    )));
    await tester.pumpAndSettle();

    expect(find.text('View task status'), findsNothing);
    expect(find.text('Submit to provider'), findsOneWidget);
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

AgentRequestDraft _request({required String status}) => AgentRequestDraft(
      id: 9,
      taskTraceId: 'ttr_1234567890abcdef',
      version: 2,
      serviceId: 42,
      title: 'Need a logo',
      brief: 'Minimal blue identity',
      status: status,
      appReviewUrl: '/requests/9/review',
      createdAt: DateTime(2026, 7, 21, 10),
      updatedAt: DateTime(2026, 7, 21, 10),
    );

class _FakeRequestRepository implements AgentRepository {
  _FakeRequestRepository(this.request);

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
  Future<AgentSessionPage> listSessions({int? beforeId, int limit = 20}) =>
      throw UnimplementedError();

  @override
  Future<AgentSession> reduceScopes(int id, Set<String> scopes) =>
      throw UnimplementedError();

  @override
  Future<int> revokeAllSessions() => throw UnimplementedError();

  @override
  Future<void> revokeSession(int id) => throw UnimplementedError();
}
