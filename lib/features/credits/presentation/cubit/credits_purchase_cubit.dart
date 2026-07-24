import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../profile/domain/repositories/i_wallet_repository.dart';
import '../../domain/credit_purchase_exception.dart';
import '../../domain/entities/credit_pending_purchase.dart';
import '../../domain/entities/credit_purchase_result.dart';
import '../../domain/entities/credit_purchase_server_status.dart';
import '../../domain/repositories/i_credit_purchase_repository.dart';
import 'credits_purchase_state.dart';

typedef CreditPollDelay = Future<void> Function(Duration duration);

class CreditsPurchaseCubit extends Cubit<CreditsPurchaseState> {
  CreditsPurchaseCubit({
    required ICreditPurchaseRepository purchaseRepository,
    required IWalletRepository walletRepository,
    Duration pollInterval = const Duration(seconds: 2),
    int maxPollAttempts = 8,
    CreditPollDelay? pollDelay,
  })  : _purchaseRepository = purchaseRepository,
        _walletRepository = walletRepository,
        _pollInterval = pollInterval,
        _maxPollAttempts = maxPollAttempts,
        _pollDelay =
            pollDelay ?? ((duration) => Future<void>.delayed(duration)),
        super(const CreditsPurchaseState());

  final ICreditPurchaseRepository _purchaseRepository;
  final IWalletRepository _walletRepository;
  final Duration _pollInterval;
  final int _maxPollAttempts;
  final CreditPollDelay _pollDelay;

  Future<void> loadProducts() async {
    if (isClosed) return;
    emit(
      state.copyWith(
        status: CreditsPurchaseStatus.loading,
        clearMessage: true,
        clearActivePackageIdentifier: true,
      ),
    );

    try {
      await _purchaseRepository.bindAuthenticatedUser();
      if (isClosed) return;
      final pendingPurchase = await _purchaseRepository.getPendingPurchase();
      if (isClosed) return;
      if (pendingPurchase != null) {
        await _reconcilePendingPurchase(
          pendingPurchase,
          message: CreditsPurchaseMessage.pendingDetected,
        );
        if (isClosed) return;
        if (state.status != CreditsPurchaseStatus.confirmed &&
            state.message != CreditsPurchaseMessage.reversed) {
          return;
        }
      } else {
        final recoveryStatus =
            await _purchaseRepository.getRecoveryStatus(null);
        if (isClosed) return;
        if (recoveryStatus.state == CreditPurchaseRecoveryState.pending) {
          emit(
            state.copyWith(
              status: CreditsPurchaseStatus.delayed,
              message: CreditsPurchaseMessage.serverPending,
              clearActivePackageIdentifier: true,
            ),
          );
          return;
        }
      }

      final products = await _purchaseRepository.getProducts();
      if (isClosed) return;
      if (products.isEmpty) {
        emit(
          state.copyWith(
            status: CreditsPurchaseStatus.unavailable,
            products: products,
            message: CreditsPurchaseMessage.noProducts,
          ),
        );
        return;
      }

      emit(
        CreditsPurchaseState(
          status: CreditsPurchaseStatus.ready,
          products: products,
        ),
      );
    } on CreditPurchaseException {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: CreditsPurchaseStatus.unavailable,
          message: CreditsPurchaseMessage.unavailable,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: CreditsPurchaseStatus.unavailable,
          message: CreditsPurchaseMessage.loadFailed,
        ),
      );
    }
  }

  Future<void> purchase({
    required String packageIdentifier,
    required double currentBalance,
  }) async {
    if (isClosed || state.blocksNewPurchase) {
      return;
    }
    final matchingProducts = state.products
        .where((product) => product.packageIdentifier == packageIdentifier)
        .toList(growable: false);
    if (matchingProducts.length != 1) return;
    final expectedCredits = matchingProducts.single.credits;

    emit(
      state.copyWith(
        status: CreditsPurchaseStatus.purchasing,
        activePackageIdentifier: packageIdentifier,
        baselineBalance: currentBalance,
        expectedCredits: expectedCredits,
        clearMessage: true,
        clearConfirmedBalance: true,
      ),
    );

    double? freshBaseline;
    try {
      final balanceResult = await _walletRepository.getWalletSummary();
      if (isClosed) return;
      balanceResult.fold(
        (_) {},
        (summary) => freshBaseline = summary.balance,
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: CreditsPurchaseStatus.failure,
          message: CreditsPurchaseMessage.balancePreflightFailed,
          clearActivePackageIdentifier: true,
        ),
      );
      return;
    }
    if (freshBaseline == null) {
      emit(
        state.copyWith(
          status: CreditsPurchaseStatus.failure,
          message: CreditsPurchaseMessage.balancePreflightFailed,
          clearActivePackageIdentifier: true,
        ),
      );
      return;
    }
    final purchaseBaseline = freshBaseline!;
    emit(state.copyWith(baselineBalance: purchaseBaseline));

    try {
      final result = await _purchaseRepository.purchase(
        packageIdentifier: packageIdentifier,
        baselineBalance: purchaseBaseline,
        expectedCredits: expectedCredits,
      );
      if (isClosed) return;
      switch (result.outcome) {
        case CreditPurchaseOutcome.cancelled:
          emit(
            state.copyWith(
              status: CreditsPurchaseStatus.cancelled,
              message: CreditsPurchaseMessage.cancelled,
              clearActivePackageIdentifier: true,
            ),
          );
          return;
        case CreditPurchaseOutcome.pending:
          emit(
            state.copyWith(
              status: CreditsPurchaseStatus.pending,
              message: CreditsPurchaseMessage.storePending,
              clearActivePackageIdentifier: true,
            ),
          );
          return;
        case CreditPurchaseOutcome.submitted:
          final pendingPurchase =
              await _purchaseRepository.getPendingPurchase();
          if (isClosed) return;
          if (pendingPurchase == null) {
            emit(
              state.copyWith(
                status: CreditsPurchaseStatus.delayed,
                message: CreditsPurchaseMessage.unsafeReconciliation,
                clearActivePackageIdentifier: true,
              ),
            );
            return;
          }
          await _reconcilePendingPurchase(
            pendingPurchase,
            message: CreditsPurchaseMessage.submitted,
          );
      }
    } on CreditPurchaseNetworkException {
      if (isClosed) return;
      await _handlePossibleAmbiguousPurchase(
        noGuardMessage: CreditsPurchaseMessage.networkAmbiguous,
        guardedMessage: CreditsPurchaseMessage.networkAmbiguous,
      );
    } on CreditPurchaseException {
      if (isClosed) return;
      await _handlePossibleAmbiguousPurchase(
        noGuardMessage: CreditsPurchaseMessage.purchaseFailed,
        guardedMessage: CreditsPurchaseMessage.storeAmbiguous,
      );
    } catch (_) {
      if (isClosed) return;
      await _handlePossibleAmbiguousPurchase(
        noGuardMessage: CreditsPurchaseMessage.purchaseFailed,
        guardedMessage: CreditsPurchaseMessage.storeAmbiguous,
      );
    }
  }

  Future<void> _handlePossibleAmbiguousPurchase({
    required CreditsPurchaseMessage noGuardMessage,
    required CreditsPurchaseMessage guardedMessage,
  }) async {
    if (isClosed) return;
    try {
      final pendingPurchase = await _purchaseRepository.getPendingPurchase();
      if (isClosed) return;
      if (pendingPurchase != null) {
        await _reconcilePendingPurchase(
          pendingPurchase,
          message: guardedMessage,
        );
        return;
      }
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: CreditsPurchaseStatus.delayed,
          message: CreditsPurchaseMessage.unsafeReconciliation,
          clearActivePackageIdentifier: true,
        ),
      );
      return;
    }

    if (isClosed) return;
    emit(
      state.copyWith(
        status: CreditsPurchaseStatus.failure,
        message: noGuardMessage,
        clearActivePackageIdentifier: true,
      ),
    );
  }

  Future<void> retryBalanceCheck() async {
    if (isClosed) return;
    if (state.status != CreditsPurchaseStatus.delayed &&
        state.status != CreditsPurchaseStatus.pending) {
      return;
    }

    try {
      final pendingPurchase = await _purchaseRepository.getPendingPurchase();
      if (isClosed) return;
      if (pendingPurchase == null) {
        await loadProducts();
        return;
      }
      await _reconcilePendingPurchase(
        pendingPurchase,
        message: CreditsPurchaseMessage.checkingAgain,
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: CreditsPurchaseStatus.delayed,
          message: CreditsPurchaseMessage.unsafeReconciliation,
          clearActivePackageIdentifier: true,
        ),
      );
    }
  }

  Future<void> _reconcilePendingPurchase(
    CreditPendingPurchase pendingPurchase, {
    required CreditsPurchaseMessage message,
  }) async {
    if (isClosed) return;
    final baselineBalance = pendingPurchase.baselineBalance;
    final expectedCredits = pendingPurchase.expectedCredits;
    emit(
      state.copyWith(
        status: CreditsPurchaseStatus.processing,
        message: message,
        baselineBalance: baselineBalance,
        expectedCredits: expectedCredits,
        clearActivePackageIdentifier: true,
      ),
    );

    for (var attempt = 0; attempt < _maxPollAttempts; attempt++) {
      if (attempt > 0) {
        await _pollDelay(_pollInterval);
      }
      if (isClosed) return;

      CreditPurchaseRecoveryStatus? recoveryStatus;
      var statusRequestFailed = false;
      try {
        recoveryStatus =
            await _purchaseRepository.getRecoveryStatus(pendingPurchase);
        if (isClosed) return;
      } on CreditPurchaseNotBoundException {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: CreditsPurchaseStatus.delayed,
            message: CreditsPurchaseMessage.unsafeReconciliation,
            clearActivePackageIdentifier: true,
          ),
        );
        return;
      } catch (_) {
        if (isClosed) return;
        statusRequestFailed = true;
        // The authenticated status endpoint is authoritative when available.
        // Only a legacy guard without a transaction hash may use the weaker
        // wallet threshold when that endpoint itself is unavailable.
      }

      switch (recoveryStatus?.state) {
        case CreditPurchaseRecoveryState.pending:
          continue;
        case CreditPurchaseRecoveryState.granted:
        case CreditPurchaseRecoveryState.restored:
          try {
            await _purchaseRepository.clearPendingPurchase(pendingPurchase);
            if (isClosed) return;
          } catch (_) {
            if (isClosed) return;
            emit(
              state.copyWith(
                status: CreditsPurchaseStatus.delayed,
                message: CreditsPurchaseMessage.balanceUpdatedGuarded,
              ),
            );
            return;
          }
          emit(
            state.copyWith(
              status: CreditsPurchaseStatus.confirmed,
              message: CreditsPurchaseMessage.confirmed,
            ),
          );
          return;
        case CreditPurchaseRecoveryState.reversed:
          try {
            await _purchaseRepository.clearPendingPurchase(pendingPurchase);
            if (isClosed) return;
          } catch (_) {
            if (isClosed) return;
            emit(
              state.copyWith(
                status: CreditsPurchaseStatus.delayed,
                message: CreditsPurchaseMessage.balanceUpdatedGuarded,
              ),
            );
            return;
          }
          emit(
            state.copyWith(
              status: CreditsPurchaseStatus.failure,
              message: CreditsPurchaseMessage.reversed,
            ),
          );
          return;
        case CreditPurchaseRecoveryState.clear:
        case CreditPurchaseRecoveryState.unresolved:
          continue;
        case null:
          if (!statusRequestFailed || pendingPurchase.transactionRef != null) {
            continue;
          }
      }

      double? latestBalance;
      try {
        final result = await _walletRepository.getWalletSummary();
        if (isClosed) return;
        result.fold(
          (_) {},
          (summary) => latestBalance = summary.balance,
        );
      } catch (_) {
        if (isClosed) return;
        continue;
      }

      final expectedBalance = baselineBalance + expectedCredits;
      if (latestBalance != null && latestBalance! >= expectedBalance) {
        try {
          await _purchaseRepository.clearPendingPurchase(pendingPurchase);
          if (isClosed) return;
        } catch (_) {
          if (isClosed) return;
          emit(
            state.copyWith(
              status: CreditsPurchaseStatus.delayed,
              message: CreditsPurchaseMessage.balanceUpdatedGuarded,
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            status: CreditsPurchaseStatus.confirmed,
            message: CreditsPurchaseMessage.confirmed,
            confirmedBalance: latestBalance,
          ),
        );
        return;
      }
    }

    if (isClosed) return;
    emit(
      state.copyWith(
        status: CreditsPurchaseStatus.delayed,
        message: CreditsPurchaseMessage.delayed,
      ),
    );
  }
}
