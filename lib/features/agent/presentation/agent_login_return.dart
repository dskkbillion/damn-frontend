/// Holds a short-lived, in-process Agent route while the user signs in.
///
/// Agent Device Flow codes must not be copied into the login URL because route
/// URLs can be collected by analytics and diagnostic logging. Only the two
/// Agent hand-off routes are accepted here, and every value is canonicalized
/// before it is retained.
class AgentLoginReturn {
  AgentLoginReturn._();

  static const Duration _maxAge = Duration(minutes: 10);
  static final RegExp _userCodePattern = RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{4}$');
  static final RegExp _requestReviewPathPattern =
      RegExp(r'^/requests/([1-9][0-9]*)/review$');

  static String? _pendingDestination;
  static DateTime? _capturedAt;

  /// Captures an allow-listed Agent route and strips every unsupported value.
  ///
  /// An invalid Device Flow code is intentionally discarded while preserving
  /// `/agent/connect`, so the user can enter a code manually after login.
  static bool capture(Uri uri, {DateTime? now}) {
    final destination = sanitize(uri);
    if (destination == null) return false;

    _pendingDestination = destination;
    _capturedAt = now ?? DateTime.now();
    return true;
  }

  /// Captures a route already matched by GoRouter from an internal route, the
  /// official HTTPS origin, or the authority-free app scheme. The matched path
  /// is still checked against the same strict Agent allow-list in [capture].
  static bool captureMatchedRoute({
    required String matchedLocation,
    required Uri sourceUri,
    DateTime? now,
  }) {
    if (!_isTrustedSource(sourceUri)) return false;

    return capture(
      Uri(
        path: matchedLocation,
        queryParameters: sourceUri.queryParametersAll,
      ),
      now: now,
    );
  }

  static bool _isTrustedSource(Uri uri) {
    if (!uri.hasScheme && !uri.hasAuthority) return true;

    if (uri.scheme.toLowerCase() == 'https') {
      return uri.host.toLowerCase() == 'deep-stream.ai' &&
          uri.userInfo.isEmpty &&
          (!uri.hasPort || uri.port == 443);
    }

    return uri.scheme.toLowerCase() == 'dskkapp' &&
        uri.host.isEmpty &&
        uri.userInfo.isEmpty &&
        !uri.hasPort;
  }

  /// Returns and clears a valid pending route.
  static String? consume({DateTime? now}) {
    if (!hasPending(now: now)) return null;
    final destination = _pendingDestination;
    clear();
    return destination;
  }

  static bool hasPending({DateTime? now}) {
    final destination = _pendingDestination;
    final capturedAt = _capturedAt;
    if (destination == null || capturedAt == null) return false;

    final age = (now ?? DateTime.now()).difference(capturedAt);
    if (age.isNegative || age >= _maxAge) {
      clear();
      return false;
    }
    return true;
  }

  static void clear() {
    _pendingDestination = null;
    _capturedAt = null;
  }

  static String? sanitize(Uri uri) {
    if (uri.hasScheme || uri.hasAuthority || uri.fragment.isNotEmpty) {
      return null;
    }

    if (uri.path == '/agent/connect') {
      if (uri.queryParametersAll.keys.any((key) => key != 'code')) {
        return '/agent/connect';
      }
      final rawCodes = uri.queryParametersAll['code'];
      if (rawCodes == null || rawCodes.isEmpty) return '/agent/connect';
      if (rawCodes.length != 1) return '/agent/connect';

      final code = rawCodes.single.trim().toUpperCase();
      if (!_userCodePattern.hasMatch(code)) return '/agent/connect';
      return Uri(
        path: '/agent/connect',
        queryParameters: {'code': code},
      ).toString();
    }

    if (_requestReviewPathPattern.hasMatch(uri.path)) {
      return uri.path;
    }

    return null;
  }
}
