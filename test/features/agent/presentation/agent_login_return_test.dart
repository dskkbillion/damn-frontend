import 'package:dskk_flutter_refactor/features/agent/presentation/agent_login_return.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final capturedAt = DateTime.utc(2026, 7, 19, 10);

  setUp(AgentLoginReturn.clear);
  tearDown(AgentLoginReturn.clear);

  test('retains a canonical Device Flow route without putting it in login URL',
      () {
    expect(
      AgentLoginReturn.capture(
        Uri.parse('/agent/connect?code=abcd-1234'),
        now: capturedAt,
      ),
      isTrue,
    );

    expect(
      AgentLoginReturn.consume(now: capturedAt.add(const Duration(minutes: 1))),
      '/agent/connect?code=ABCD-1234',
    );
    expect(AgentLoginReturn.consume(now: capturedAt), isNull);
  });

  test('captures a custom-scheme deep link through its matched app route', () {
    expect(
      AgentLoginReturn.captureMatchedRoute(
        matchedLocation: '/agent/connect',
        sourceUri: Uri.parse('dskkapp:///agent/connect?code=ABCD-1234'),
        now: capturedAt,
      ),
      isTrue,
    );

    expect(AgentLoginReturn.consume(now: capturedAt),
        '/agent/connect?code=ABCD-1234');
  });

  test('captures the official HTTPS app link', () {
    expect(
      AgentLoginReturn.captureMatchedRoute(
        matchedLocation: '/agent/connect',
        sourceUri:
            Uri.parse('https://deep-stream.ai/agent/connect?code=ABCD-1234'),
        now: capturedAt,
      ),
      isTrue,
    );

    expect(AgentLoginReturn.consume(now: capturedAt),
        '/agent/connect?code=ABCD-1234');
  });

  test('rejects matched routes originating from unknown schemes or hosts', () {
    for (final sourceUri in [
      Uri.parse('https://evil.example/agent/connect?code=ABCD-1234'),
      Uri.parse('https://deep-stream.ai:8443/agent/connect?code=ABCD-1234'),
      Uri.parse('evil:///agent/connect?code=ABCD-1234'),
      Uri.parse('dskkapp://evil.example/agent/connect?code=ABCD-1234'),
    ]) {
      expect(
        AgentLoginReturn.captureMatchedRoute(
          matchedLocation: '/agent/connect',
          sourceUri: sourceUri,
          now: capturedAt,
        ),
        isFalse,
      );
      expect(AgentLoginReturn.consume(now: capturedAt), isNull);
    }
  });

  test('drops malformed and duplicate Device Flow codes', () {
    for (final uri in [
      Uri.parse('/agent/connect?code=not-a-code'),
      Uri.parse('/agent/connect?code=ABCD-1234&code=WXYZ-9876'),
      Uri.parse('/agent/connect?code=ABCD-1234&redirect=https://evil.example'),
    ]) {
      AgentLoginReturn.capture(uri, now: capturedAt);
      expect(AgentLoginReturn.consume(now: capturedAt), '/agent/connect');
    }
  });

  test('accepts only positive numeric request review routes', () {
    expect(
      AgentLoginReturn.capture(Uri.parse('/requests/42/review'),
          now: capturedAt),
      isTrue,
    );
    expect(AgentLoginReturn.consume(now: capturedAt), '/requests/42/review');

    expect(
      AgentLoginReturn.capture(Uri.parse('/requests/0/review'),
          now: capturedAt),
      isFalse,
    );
    expect(
      AgentLoginReturn.capture(Uri.parse('/requests/1/review/extra'),
          now: capturedAt),
      isFalse,
    );
  });

  test('rejects external, protocol-relative, fragmented, and unrelated routes',
      () {
    for (final uri in [
      Uri.parse('https://evil.example/agent/connect?code=ABCD-1234'),
      Uri.parse('//evil.example/agent/connect?code=ABCD-1234'),
      Uri.parse('/agent/connect?code=ABCD-1234#fragment'),
      Uri.parse('/payment/result'),
    ]) {
      expect(AgentLoginReturn.capture(uri, now: capturedAt), isFalse);
    }
  });

  test('expires pending routes at the backend ten minute boundary', () {
    AgentLoginReturn.capture(
      Uri.parse('/agent/connect?code=ABCD-1234'),
      now: capturedAt,
    );

    expect(
      AgentLoginReturn.consume(
          now: capturedAt.add(const Duration(minutes: 10))),
      isNull,
    );
  });

  test('clearing an abandoned Agent login prevents a later ordinary return',
      () {
    AgentLoginReturn.capture(
      Uri.parse('/agent/connect?code=ABCD-1234'),
      now: capturedAt,
    );

    AgentLoginReturn.clear();

    expect(AgentLoginReturn.hasPending(now: capturedAt), isFalse);
    expect(AgentLoginReturn.consume(now: capturedAt), isNull);
  });

  test('strips query data from request review routes', () {
    AgentLoginReturn.capture(
      Uri.parse('/requests/42/review?redirect=https://evil.example'),
      now: capturedAt,
    );

    expect(AgentLoginReturn.consume(now: capturedAt), '/requests/42/review');
  });
}
