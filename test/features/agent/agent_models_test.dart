import 'package:dskk_flutter_refactor/features/agent/domain/agent_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
      'serviceId': 42,
      'title': 'Need a logo',
      'brief': 'Minimal blue identity',
      'status': 'AWAITING_APP_REVIEW',
      'appReviewUrl': '/requests/9/review',
    });

    expect(draft.serviceId, 42);
    expect(draft.status, 'AWAITING_APP_REVIEW');
    expect(draft.appReviewUrl, '/requests/9/review');
  });
}
