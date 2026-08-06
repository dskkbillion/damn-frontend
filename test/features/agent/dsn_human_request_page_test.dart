import 'package:dskk_flutter_refactor/core/dasn/data/dsn_service_capability_repository.dart';
import 'package:dskk_flutter_refactor/core/dasn/domain/dsn_service_capability_models.dart';
import 'package:dskk_flutter_refactor/features/agent/data/agent_repository.dart';
import 'package:dskk_flutter_refactor/features/agent/domain/agent_models.dart';
import 'package:dskk_flutter_refactor/features/agent/presentation/dsn_human_request_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('loads the default staging capability and displays its revision',
      (tester) async {
    final capabilityRepository = _FakeCapabilityRepository(_capability());
    await tester.pumpWidget(_app(DsnHumanRequestPage(
      repository: _FakeAgentRepository(),
      capabilityRepository: capabilityRepository,
    )));
    await tester.pumpAndSettle();

    expect(capabilityRepository.requestedServiceIds, [582]);
    expect(find.text('DS 0.2 Staging Capability'), findsOneWidget);
    expect(find.text('Revision: ${_hash('a')}'), findsOneWidget);
    expect(find.textContaining('000000000000000000000000'), findsNothing);
    final button = find.byKey(const ValueKey<String>('create-human-request'));
    await tester.scrollUntilVisible(button, 500,
        scrollable: find.byType(Scrollable).first);
    expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
  });

  testWidgets('fails closed when the server capability cannot be loaded',
      (tester) async {
    await tester.pumpWidget(_app(DsnHumanRequestPage(
      repository: _FakeAgentRepository(),
      capabilityRepository: _FakeCapabilityRepository(
        null,
        error: const DsnServiceCapabilityFormatException(
          'Capability is unavailable',
          code: 'CAPABILITY_NOT_FOUND',
        ),
      ),
    )));
    await tester.pumpAndSettle();

    expect(find.textContaining('placeholder revision'), findsOneWidget);
    final button = find.byKey(const ValueKey<String>('create-human-request'));
    await tester.scrollUntilVisible(button, 500,
        scrollable: find.byType(Scrollable).first);
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    expect(find.textContaining('Capability is unavailable'), findsOneWidget);
  });
}

Widget _app(Widget child) => MaterialApp(home: child);

DsnServiceCapability _capability() => DsnServiceCapability(
      serviceId: 582,
      capabilityId: 'service:582',
      revision: _hash('a'),
      title: 'DS 0.2 Staging Capability',
      description: 'staging',
      amountMinor: 100,
      currency: 'CREDITS',
      deliveryHours: 24,
      maxRevisions: 1,
      outputTypes: const ['TEXT'],
    );

String _hash(String letter) => 'sha256:${letter * 64}';

class _FakeCapabilityRepository implements DsnServiceCapabilityRepository {
  _FakeCapabilityRepository(this.capability, {this.error});

  final DsnServiceCapability? capability;
  final Object? error;
  final requestedServiceIds = <int>[];

  @override
  Future<DsnServiceCapability> getServiceCapability(int serviceId) async {
    requestedServiceIds.add(serviceId);
    if (error != null) throw error!;
    return capability!;
  }
}

class _FakeAgentRepository implements AgentRepository {
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
  Future<AgentRequestDraft> createHumanRequest({
    required int serviceId,
    required String capabilityRevision,
    required String title,
    required String brief,
    int? budgetMaxMinor,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> denyAuthorization(String userCode) => throw UnimplementedError();

  @override
  Future<AgentRequestDraft> getRequest(int id) => throw UnimplementedError();

  @override
  Future<AgentSessionDetail> getSession(int id) => throw UnimplementedError();

  @override
  Future<AgentAuthorization> inspectAuthorization(String userCode) =>
      throw UnimplementedError();

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
