import 'dart:async';

import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_status.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';

import '../domain/repositories/i_credit_purchase_repository.dart';

/// Keeps RevenueCat aligned with the app's authenticated session.
///
/// Transitions are serialized so an account switch always completes in order.
/// Logout only removes the local binding; it never asks RevenueCat to create an
/// anonymous user.
class RevenueCatAuthCoordinator {
  RevenueCatAuthCoordinator({
    required IAuthRepository authRepository,
    required ICreditPurchaseRepository purchaseRepository,
  })  : _authRepository = authRepository,
        _purchaseRepository = purchaseRepository;

  final IAuthRepository _authRepository;
  final ICreditPurchaseRepository _purchaseRepository;

  StreamSubscription<AuthStatus>? _subscription;
  Future<void> _transition = Future<void>.value();

  void start() {
    if (_subscription != null) return;

    _subscription = _authRepository.authStatus.listen(
      _enqueue,
      onError: (Object error, StackTrace stackTrace) {
        AppLogger.d('[RevenueCatAuth] Auth status stream failed');
      },
    );

    final currentUser =
        _authRepository.getLoggedInUserSync().fold((_) => null, (user) => user);
    _enqueue(
      currentUser == null
          ? const Unauthenticated()
          : Authenticated(currentUser),
    );
  }

  void _enqueue(AuthStatus status) {
    _transition = _transition
        .catchError((Object _) {})
        .then((_) => _apply(status))
        .catchError((Object error, StackTrace stackTrace) {
      // Missing store configuration or a temporarily unavailable identity
      // endpoint must not prevent the app from starting.
      AppLogger.d(
        '[RevenueCatAuth] Purchase identity is not ready: '
        '${error.runtimeType}: $error',
      );
    });
  }

  Future<void> _apply(AuthStatus status) async {
    if (status is Authenticated) {
      await _purchaseRepository.bindAuthenticatedUser();
    } else if (status is Unauthenticated) {
      await _purchaseRepository.unbind();
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
