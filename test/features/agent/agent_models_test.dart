import 'package:dskk_flutter_refactor/features/agent/domain/agent_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses paged Agent sessions', () {
    final page = AgentSessionPage.fromJson({
      'items': [
        {
          'id': 22,
          'clientId': 11,
          'clientName': 'Codex',
          'scopes': ['services:read'],
          'status': 'ACTIVE',
        }
      ],
      'hasMore': true,
      'nextCursor': 22,
      'limit': 20,
    });

    expect(page.items.single.clientName, 'Codex');
    expect(page.hasMore, isTrue);
    expect(page.nextCursor, 22);
    expect(page.limit, 20);
  });

  test('parses session detail without exposing token fields', () {
    final detail = AgentSessionDetail.fromJson({
      'session': {
        'id': 7,
        'clientId': 2,
        'clientName': 'Codex',
        'clientType': 'CLI',
        'deviceName': 'Studio Mac',
        'platform': 'macOS',
        'cliVersion': '0.1.0',
        'scopes': ['services:read'],
        'status': 'ACTIVE',
        'accessExpiresAt': '2026-07-19T12:00:00',
      },
      'recentSecurityEvents': [
        {
          'action': 'TOKEN_ISSUED',
          'result': 'SUCCESS',
          'createdAt': '2026-07-19 10:00:00',
        }
      ],
      'accessToken': 'must-not-be-modeled',
    });

    expect(detail.session.id, 7);
    expect(detail.session.scopes, {'services:read'});
    expect(detail.session.deviceName, 'Studio Mac');
    expect(detail.session.cliVersion, '0.1.0');
    expect(detail.events.single.action, 'TOKEN_ISSUED');
  });

  test('parses App-reviewed request draft', () {
    final draft = AgentRequestDraft.fromJson({
      'id': 9,
      'taskTraceId': 'ttr_1234567890abcdef',
      'version': 3,
      'serviceId': 42,
      'title': 'Need a logo',
      'brief': 'Minimal blue identity',
      'status': 'AWAITING_APP_REVIEW',
      'appReviewUrl': '/requests/9/review',
      'providerMemberId': 23,
      'chatId': 81,
      'initialMessageId': 95,
      'submittedAt': '2026-07-21 10:00:00',
      'providerRespondedAt': '2026-07-21 10:05:00',
    });

    expect(draft.serviceId, 42);
    expect(draft.taskTraceId, 'ttr_1234567890abcdef');
    expect(draft.version, 3);
    expect(draft.status, 'AWAITING_APP_REVIEW');
    expect(draft.appReviewUrl, '/requests/9/review');
    expect(draft.providerMemberId, 23);
    expect(draft.chatId, 81);
    expect(draft.initialMessageId, 95);
    expect(draft.submittedAt, isNotNull);
    expect(draft.providerRespondedAt, isNotNull);
  });
}
