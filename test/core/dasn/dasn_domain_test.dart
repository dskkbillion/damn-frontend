import 'package:dskk_flutter_refactor/core/dasn/domain/dasn_domain.dart';
import 'package:flutter_test/flutter_test.dart';

TaskProjection _projection({
  String lifecycle = 'RUNNING',
  String responsibility = 'NONE',
  String sync = 'SYNCED',
  String? waitingOn,
  List<Map<String, dynamic>>? nextActions,
}) {
  return TaskProjection.fromJson({
    'taskLifecycle': lifecycle,
    'responsibilityAction': responsibility,
    'syncStatus': sync,
    if (waitingOn != null) 'waitingOn': waitingOn,
    if (nextActions != null) 'nextActions': nextActions,
  });
}

void main() {
  group('TaskProjection parsing', () {
    test('requires all three state axes', () {
      for (final missing in <String>[
        'taskLifecycle',
        'responsibilityAction',
        'syncStatus',
      ]) {
        final json = <String, dynamic>{
          'taskLifecycle': 'RUNNING',
          'responsibilityAction': 'NONE',
          'syncStatus': 'SYNCED',
        }..remove(missing);

        expect(
          () => TaskProjection.fromJson(json),
          throwsA(isA<DasnProjectionFormatException>()),
          reason: 'missing $missing must fail closed',
        );
      }
    });

    test('rejects null and non-string required axes', () {
      expect(
        () => TaskProjection.fromJson({
          'taskLifecycle': null,
          'responsibilityAction': 'NONE',
          'syncStatus': 'SYNCED',
        }),
        throwsA(isA<DasnProjectionFormatException>()),
      );
      expect(
        () => TaskProjection.fromJson({
          'taskLifecycle': 'RUNNING',
          'responsibilityAction': 2,
          'syncStatus': 'SYNCED',
        }),
        throwsA(isA<DasnProjectionFormatException>()),
      );
    });

    test('maps unknown wire states to fail-closed values', () {
      final projection = _projection(
        lifecycle: 'SERVER_ADDED_LIFECYCLE',
        responsibility: 'SERVER_ADDED_ACTION',
        sync: 'SERVER_ADDED_SYNC',
      );

      expect(projection.taskLifecycle, TaskLifecycle.unknown);
      expect(projection.responsibilityAction, ResponsibilityAction.unknown);
      expect(projection.syncStatus, SyncStatus.unknown);
    });

    test('does not treat an unknown responsibility state as a known action',
        () {
      final action = reduceDasnNextAction(
        _projection(responsibility: 'SERVER_ADDED_ACTION'),
      );

      expect(action.kind, NextActionKind.unknown);
      expect(action.isSafeForAutomaticExecution, isFalse);
    });

    test('parses and round-trips next actions without trusting extra fields',
        () {
      final projection = _projection(
        waitingOn: 'COUNTERPARTY',
        nextActions: [
          {
            'type': 'HUMAN_CONFIRMATION',
            'appUrl': 'https://deep-stream.ai/tasks/t-1',
            'ignoredFutureField': true,
          },
        ],
      );

      expect(projection.waitingOn, WaitingOn.counterparty);
      expect(projection.nextActions.single.type, 'HUMAN_CONFIRMATION');
      expect(projection.nextActions.single.kind,
          NextActionKind.reviewResponsibility);
      expect(
        projection.nextActions.single.appUrl,
        Uri.parse('https://deep-stream.ai/tasks/t-1'),
      );
      expect(projection.toJson()['nextActions'], isNotEmpty);
    });

    test('rejects malformed next action entries', () {
      expect(
        () => _projection(nextActions: [{}]),
        throwsA(isA<DasnProjectionFormatException>()),
      );
      expect(
        () => _projection(
          nextActions: [
            {'type': 'VIEW_PROGRESS', 'appUrl': 'not a uri'},
          ],
        ),
        throwsA(isA<DasnProjectionFormatException>()),
      );
      expect(
        () => TaskProjection.fromJson({
          'taskLifecycle': 'RUNNING',
          'responsibilityAction': 'NONE',
          'syncStatus': 'SYNCED',
          'nextActions': [
            <dynamic, dynamic>{'type': 'VIEW_PROGRESS', 1: 'bad-key'},
          ],
        }),
        throwsA(isA<DasnProjectionFormatException>()),
      );
    });
  });

  group('DasnNextActionReducer', () {
    test('uses unknown result before every other action', () {
      final action = reduceDasnNextAction(
        _projection(
          sync: 'UNKNOWN',
          responsibility: 'PENDING',
          waitingOn: 'COUNTERPARTY',
          lifecycle: 'COMPLETED',
        ),
      );

      expect(action.kind, NextActionKind.recoverOperation);
      expect(action.isSafeForAutomaticExecution, isTrue);
    });

    test('uses stale projection before pending responsibility', () {
      final action = reduceDasnNextAction(
        _projection(sync: 'STALE', responsibility: 'PENDING'),
      );

      expect(action.kind, NextActionKind.recoverTask);
    });

    test('uses pending responsibility before waiting target', () {
      final action = reduceDasnNextAction(
        _projection(responsibility: 'PENDING', waitingOn: 'COUNTERPARTY'),
      );

      expect(action.kind, NextActionKind.reviewResponsibility);
    });

    test('selects counterparty, system, and terminal record in order', () {
      expect(
        reduceDasnNextAction(_projection(waitingOn: 'COUNTERPARTY')).kind,
        NextActionKind.viewProgress,
      );
      expect(
        reduceDasnNextAction(_projection(waitingOn: 'SYSTEM')).kind,
        NextActionKind.viewSystemStatus,
      );
      expect(
        reduceDasnNextAction(_projection(lifecycle: 'COMPLETED')).kind,
        NextActionKind.viewRecord,
      );
    });

    test('returns a known domain action and fails closed for an unknown one',
        () {
      expect(
        reduceDasnNextAction(
          _projection(nextActions: [
            {'type': 'REFRESH_AND_CONFIRM'},
          ]),
        ).kind,
        NextActionKind.domain,
      );
      expect(
        reduceDasnNextAction(
          _projection(nextActions: [
            {'type': 'FUTURE_UNRECOGNISED_ACTION'},
          ]),
        ).kind,
        NextActionKind.unknown,
      );
    });
  });
}
