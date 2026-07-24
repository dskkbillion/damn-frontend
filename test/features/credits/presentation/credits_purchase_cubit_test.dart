import 'dart:async';
import 'dart:collection';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/credits/domain/credit_purchase_exception.dart';
import 'package:dskk_flutter_refactor/features/credits/domain/entities/credit_pending_purchase.dart';
import 'package:dskk_flutter_refactor/features/credits/domain/entities/credit_purchase_result.dart';
import 'package:dskk_flutter_refactor/features/credits/domain/entities/credit_purchase_server_status.dart';
import 'package:dskk_flutter_refactor/features/credits/domain/entities/credit_store_product.dart';
import 'package:dskk_flutter_refactor/features/credits/domain/repositories/i_credit_purchase_repository.dart';
import 'package:dskk_flutter_refactor/features/credits/presentation/cubit/credits_purchase_cubit.dart';
import 'package:dskk_flutter_refactor/features/credits/presentation/cubit/credits_purchase_state.dart';
import 'package:dskk_flutter_refactor/features/profile/data/models/transaction_dto.dart';
import 'package:dskk_flutter_refactor/features/profile/domain/entities/wallet_summary.dart';
import 'package:dskk_flutter_refactor/features/profile/domain/repositories/i_wallet_repository.dart';

const _product = CreditStoreProduct(
  packId: 'starter',
  credits: 100,
  packageIdentifier: r'$rc_credits_100',
  productIdentifier: 'credits_100',
  title: '100 Credits',
  description: 'Use inside DeepStream',
  localizedPrice: r'$4.99',
);

class _FakePurchaseRepository implements ICreditPurchaseRepository {
  bool bound = false;
  List<CreditStoreProduct> products = const [_product];
  CreditPurchaseOutcome outcome = CreditPurchaseOutcome.submitted;
  CreditPurchaseException? purchaseError;
  int bindCalls = 0;
  int getProductsCalls = 0;
  int purchaseCalls = 0;
  int clearPendingCalls = 0;
  CreditPendingPurchase? pendingPurchase;
  final Queue<CreditPurchaseRecoveryStatus> recoveryStatuses = Queue();
  Completer<CreditPurchaseRecoveryStatus>? recoveryCompleter;
  Completer<void>? recoveryStarted;

  @override
  bool get isBound => bound;

  @override
  Future<void> bindAuthenticatedUser() async {
    bindCalls++;
    bound = true;
  }

  @override
  Future<List<CreditStoreProduct>> getProducts() async {
    getProductsCalls++;
    return products;
  }

  @override
  Future<CreditPurchaseResult> purchase({
    required String packageIdentifier,
    required double baselineBalance,
    required int expectedCredits,
  }) async {
    purchaseCalls++;
    pendingPurchase = CreditPendingPurchase(
      appUserId: '12345678-1234-1234-1234-1234567890ab',
      packageIdentifier: packageIdentifier,
      baselineBalance: baselineBalance,
      expectedCredits: expectedCredits,
      startedAtEpochMilliseconds: 1,
    );
    final error = purchaseError;
    if (error != null) throw error;
    if (outcome == CreditPurchaseOutcome.cancelled) {
      pendingPurchase = null;
    }
    return CreditPurchaseResult(outcome: outcome);
  }

  @override
  Future<CreditPendingPurchase?> getPendingPurchase() async => pendingPurchase;

  @override
  Future<CreditPurchaseRecoveryStatus> getRecoveryStatus(
    CreditPendingPurchase? pendingPurchase,
  ) async {
    if (recoveryStarted != null && !recoveryStarted!.isCompleted) {
      recoveryStarted!.complete();
    }
    final completer = recoveryCompleter;
    if (completer != null) return completer.future;
    if (recoveryStatuses.isNotEmpty) {
      return recoveryStatuses.removeFirst();
    }
    if (pendingPurchase != null) {
      throw const CreditPurchaseNetworkException();
    }
    return const CreditPurchaseRecoveryStatus(
      CreditPurchaseRecoveryState.clear,
    );
  }

  @override
  Future<void> clearPendingPurchase(
    CreditPendingPurchase expectedPendingPurchase,
  ) async {
    clearPendingCalls++;
    if (pendingPurchase != expectedPendingPurchase) {
      throw const CreditPurchaseUnavailableException(
        'pending purchase changed',
      );
    }
    pendingPurchase = null;
  }

  @override
  Future<void> unbind() async {
    bound = false;
  }
}

class _FakeWalletRepository implements IWalletRepository {
  final Queue<Either<Failure, WalletSummary>> summaries = Queue();
  int summaryCalls = 0;

  @override
  Future<Either<Failure, WalletSummary>> getWalletSummary() async {
    summaryCalls++;
    if (summaries.isEmpty) {
      return const Left(NetworkFailure(message: 'no fixture'));
    }
    return summaries.removeFirst();
  }

  @override
  Future<Either<Failure, List<TransactionDto>>> getWalletTransactions({
    required int page,
    required int pageSize,
    String? startDate,
    String? endDate,
    required String transactionType,
  }) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, void>> submitWithdrawal({
    required double amount,
    required String idempotencyToken,
  }) async {
    return const Right(null);
  }
}

CreditsPurchaseCubit _buildCubit(
  _FakePurchaseRepository purchaseRepository,
  _FakeWalletRepository walletRepository, {
  int maxPollAttempts = 2,
}) {
  return CreditsPurchaseCubit(
    purchaseRepository: purchaseRepository,
    walletRepository: walletRepository,
    pollInterval: Duration.zero,
    maxPollAttempts: maxPollAttempts,
    pollDelay: (_) async {},
  );
}

void main() {
  group('CreditsPurchaseCubit', () {
    late _FakePurchaseRepository purchaseRepository;
    late _FakeWalletRepository walletRepository;

    setUp(() {
      purchaseRepository = _FakePurchaseRepository();
      walletRepository = _FakeWalletRepository();
    });

    blocTest<CreditsPurchaseCubit, CreditsPurchaseState>(
      'should bind before loading products and preserve the store-localized price',
      build: () => _buildCubit(purchaseRepository, walletRepository),
      act: (cubit) => cubit.loadProducts(),
      expect: () => [
        const CreditsPurchaseState(status: CreditsPurchaseStatus.loading),
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.ready,
          products: [_product],
        ),
      ],
      verify: (_) {
        expect(purchaseRepository.bindCalls, 1);
      },
    );

    blocTest<CreditsPurchaseCubit, CreditsPurchaseState>(
      'should block products when the authenticated backend has pending fulfillment',
      build: () {
        purchaseRepository.recoveryStatuses.add(
          const CreditPurchaseRecoveryStatus(
            CreditPurchaseRecoveryState.pending,
          ),
        );
        return _buildCubit(purchaseRepository, walletRepository);
      },
      act: (cubit) => cubit.loadProducts(),
      expect: () => [
        const CreditsPurchaseState(status: CreditsPurchaseStatus.loading),
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.delayed,
          message: CreditsPurchaseMessage.serverPending,
        ),
      ],
      verify: (_) {
        expect(purchaseRepository.getProductsCalls, 0);
        expect(walletRepository.summaryCalls, 0);
      },
    );

    blocTest<CreditsPurchaseCubit, CreditsPurchaseState>(
      'should trust a matching server grant before the balance fallback',
      build: () {
        purchaseRepository.pendingPurchase = const CreditPendingPurchase(
          appUserId: '12345678-1234-1234-1234-1234567890ab',
          packageIdentifier: r'$rc_credits_100',
          baselineBalance: 100,
          expectedCredits: 100,
          startedAtEpochMilliseconds: 1,
          transactionRef:
              'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        );
        purchaseRepository.recoveryStatuses.add(
          const CreditPurchaseRecoveryStatus(
            CreditPurchaseRecoveryState.granted,
          ),
        );
        return _buildCubit(purchaseRepository, walletRepository);
      },
      act: (cubit) => cubit.loadProducts(),
      expect: () => [
        const CreditsPurchaseState(status: CreditsPurchaseStatus.loading),
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.processing,
          message: CreditsPurchaseMessage.pendingDetected,
          baselineBalance: 100,
          expectedCredits: 100,
        ),
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.confirmed,
          message: CreditsPurchaseMessage.confirmed,
          baselineBalance: 100,
          expectedCredits: 100,
        ),
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.ready,
          products: [_product],
        ),
      ],
      verify: (_) {
        expect(purchaseRepository.clearPendingCalls, 1);
        expect(walletRepository.summaryCalls, 0);
      },
    );

    blocTest<CreditsPurchaseCubit, CreditsPurchaseState>(
      'should never clear a hashed guard from an unrelated high balance',
      build: () {
        purchaseRepository.pendingPurchase = const CreditPendingPurchase(
          appUserId: '12345678-1234-1234-1234-1234567890ab',
          packageIdentifier: r'$rc_credits_100',
          baselineBalance: 100,
          expectedCredits: 100,
          startedAtEpochMilliseconds: 1,
          transactionRef:
              'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        );
        purchaseRepository.recoveryStatuses.add(
          const CreditPurchaseRecoveryStatus(
            CreditPurchaseRecoveryState.unresolved,
          ),
        );
        walletRepository.summaries
            .add(const Right(WalletSummary(balance: 1000)));
        return _buildCubit(
          purchaseRepository,
          walletRepository,
          maxPollAttempts: 1,
        );
      },
      act: (cubit) => cubit.loadProducts(),
      expect: () => [
        const CreditsPurchaseState(status: CreditsPurchaseStatus.loading),
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.processing,
          message: CreditsPurchaseMessage.pendingDetected,
          baselineBalance: 100,
          expectedCredits: 100,
        ),
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.delayed,
          message: CreditsPurchaseMessage.delayed,
          baselineBalance: 100,
          expectedCredits: 100,
        ),
      ],
      verify: (_) {
        expect(purchaseRepository.clearPendingCalls, 0);
        expect(walletRepository.summaryCalls, 0);
        expect(purchaseRepository.pendingPurchase, isNotNull);
      },
    );

    blocTest<CreditsPurchaseCubit, CreditsPurchaseState>(
      'should stop reconciliation when the authenticated identity changes',
      build: () {
        purchaseRepository.pendingPurchase = const CreditPendingPurchase(
          appUserId: '12345678-1234-1234-1234-1234567890ab',
          packageIdentifier: r'$rc_credits_100',
          baselineBalance: 100,
          expectedCredits: 100,
          startedAtEpochMilliseconds: 1,
        );
        purchaseRepository.recoveryCompleter =
            Completer<CreditPurchaseRecoveryStatus>();
        purchaseRepository.recoveryStarted = Completer<void>();
        walletRepository.summaries
            .add(const Right(WalletSummary(balance: 1000)));
        return _buildCubit(
          purchaseRepository,
          walletRepository,
          maxPollAttempts: 1,
        );
      },
      act: (cubit) async {
        final load = cubit.loadProducts();
        await purchaseRepository.recoveryStarted!.future;
        purchaseRepository.pendingPurchase = const CreditPendingPurchase(
          appUserId: '87654321-4321-4321-4321-ba0987654321',
          packageIdentifier: r'$rc_credits_500',
          baselineBalance: 900,
          expectedCredits: 500,
          startedAtEpochMilliseconds: 2,
        );
        purchaseRepository.recoveryCompleter!.completeError(
          const CreditPurchaseNotBoundException(),
        );
        await load;
      },
      expect: () => [
        const CreditsPurchaseState(status: CreditsPurchaseStatus.loading),
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.processing,
          message: CreditsPurchaseMessage.pendingDetected,
          baselineBalance: 100,
          expectedCredits: 100,
        ),
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.delayed,
          message: CreditsPurchaseMessage.unsafeReconciliation,
          baselineBalance: 100,
          expectedCredits: 100,
        ),
      ],
      verify: (_) {
        expect(purchaseRepository.clearPendingCalls, 0);
        expect(walletRepository.summaryCalls, 0);
        expect(
          purchaseRepository.pendingPurchase?.appUserId,
          '87654321-4321-4321-4321-ba0987654321',
        );
      },
    );

    blocTest<CreditsPurchaseCubit, CreditsPurchaseState>(
      'should keep purchases blocked after restart while a durable guard is unresolved',
      build: () {
        purchaseRepository.pendingPurchase = const CreditPendingPurchase(
          appUserId: '12345678-1234-1234-1234-1234567890ab',
          packageIdentifier: r'$rc_credits_100',
          baselineBalance: 100,
          expectedCredits: 100,
          startedAtEpochMilliseconds: 1,
        );
        walletRepository.summaries
          ..add(const Right(WalletSummary(balance: 101)))
          ..add(const Right(WalletSummary(balance: 150)));
        return _buildCubit(purchaseRepository, walletRepository);
      },
      act: (cubit) => cubit.loadProducts(),
      expect: () => [
        const CreditsPurchaseState(status: CreditsPurchaseStatus.loading),
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.processing,
          message: CreditsPurchaseMessage.pendingDetected,
          baselineBalance: 100,
          expectedCredits: 100,
        ),
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.delayed,
          message: CreditsPurchaseMessage.delayed,
          baselineBalance: 100,
          expectedCredits: 100,
        ),
      ],
      verify: (cubit) {
        expect(cubit.state.blocksNewPurchase, isTrue);
        expect(purchaseRepository.getProductsCalls, 0);
        expect(purchaseRepository.clearPendingCalls, 0);
      },
    );

    blocTest<CreditsPurchaseCubit, CreditsPurchaseState>(
      'should clear a restored guard only after the expected backend credits appear',
      build: () {
        purchaseRepository.pendingPurchase = const CreditPendingPurchase(
          appUserId: '12345678-1234-1234-1234-1234567890ab',
          packageIdentifier: r'$rc_credits_100',
          baselineBalance: 100,
          expectedCredits: 100,
          startedAtEpochMilliseconds: 1,
        );
        walletRepository.summaries
            .add(const Right(WalletSummary(balance: 200)));
        return _buildCubit(
          purchaseRepository,
          walletRepository,
          maxPollAttempts: 1,
        );
      },
      act: (cubit) => cubit.loadProducts(),
      expect: () => [
        const CreditsPurchaseState(status: CreditsPurchaseStatus.loading),
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.processing,
          message: CreditsPurchaseMessage.pendingDetected,
          baselineBalance: 100,
          expectedCredits: 100,
        ),
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.confirmed,
          message: CreditsPurchaseMessage.confirmed,
          baselineBalance: 100,
          expectedCredits: 100,
          confirmedBalance: 200,
        ),
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.ready,
          products: [_product],
        ),
      ],
      verify: (_) {
        expect(purchaseRepository.clearPendingCalls, 1);
        expect(purchaseRepository.getProductsCalls, 1);
      },
    );

    blocTest<CreditsPurchaseCubit, CreditsPurchaseState>(
      'should treat cancellation as non-billing and avoid wallet polling',
      build: () {
        purchaseRepository.outcome = CreditPurchaseOutcome.cancelled;
        walletRepository.summaries
            .add(const Right(WalletSummary(balance: 100)));
        return _buildCubit(purchaseRepository, walletRepository);
      },
      seed: () => const CreditsPurchaseState(
        status: CreditsPurchaseStatus.ready,
        products: [_product],
      ),
      act: (cubit) => cubit.purchase(
        packageIdentifier: _product.packageIdentifier,
        currentBalance: 100,
      ),
      expect: () => [
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.purchasing,
          products: [_product],
          activePackageIdentifier: r'$rc_credits_100',
          baselineBalance: 100,
          expectedCredits: 100,
        ),
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.cancelled,
          products: [_product],
          message: CreditsPurchaseMessage.cancelled,
          baselineBalance: 100,
          expectedCredits: 100,
        ),
      ],
      verify: (_) {
        expect(walletRepository.summaryCalls, 1);
      },
    );

    blocTest<CreditsPurchaseCubit, CreditsPurchaseState>(
      'should keep a pending store payment distinct from success',
      build: () {
        purchaseRepository.outcome = CreditPurchaseOutcome.pending;
        walletRepository.summaries
            .add(const Right(WalletSummary(balance: 100)));
        return _buildCubit(purchaseRepository, walletRepository);
      },
      seed: () => const CreditsPurchaseState(
        status: CreditsPurchaseStatus.ready,
        products: [_product],
      ),
      act: (cubit) => cubit.purchase(
        packageIdentifier: _product.packageIdentifier,
        currentBalance: 100,
      ),
      expect: () => [
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.purchasing,
          products: [_product],
          activePackageIdentifier: r'$rc_credits_100',
          baselineBalance: 100,
          expectedCredits: 100,
        ),
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.pending,
          products: [_product],
          message: CreditsPurchaseMessage.storePending,
          baselineBalance: 100,
          expectedCredits: 100,
        ),
      ],
      verify: (_) {
        expect(walletRepository.summaryCalls, 1);
      },
    );

    blocTest<CreditsPurchaseCubit, CreditsPurchaseState>(
      'should confirm only after the backend balance reaches the expected credits',
      build: () {
        walletRepository.summaries
          ..add(const Right(WalletSummary(balance: 100)))
          ..add(const Right(WalletSummary(balance: 101)))
          ..add(const Right(WalletSummary(balance: 200)));
        return _buildCubit(
          purchaseRepository,
          walletRepository,
          maxPollAttempts: 3,
        );
      },
      seed: () => const CreditsPurchaseState(
        status: CreditsPurchaseStatus.ready,
        products: [_product],
      ),
      act: (cubit) => cubit.purchase(
        packageIdentifier: _product.packageIdentifier,
        currentBalance: 100,
      ),
      expect: () => [
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.purchasing,
          products: [_product],
          activePackageIdentifier: r'$rc_credits_100',
          baselineBalance: 100,
          expectedCredits: 100,
        ),
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.processing,
          products: [_product],
          message: CreditsPurchaseMessage.submitted,
          baselineBalance: 100,
          expectedCredits: 100,
        ),
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.confirmed,
          products: [_product],
          message: CreditsPurchaseMessage.confirmed,
          baselineBalance: 100,
          expectedCredits: 100,
          confirmedBalance: 200,
        ),
      ],
      verify: (_) {
        expect(walletRepository.summaryCalls, 3);
      },
    );

    blocTest<CreditsPurchaseCubit, CreditsPurchaseState>(
      'should replace the rendered balance with a fresh backend baseline before purchase',
      build: () {
        walletRepository.summaries
          ..add(const Right(WalletSummary(balance: 200)))
          ..add(const Right(WalletSummary(balance: 250)))
          ..add(const Right(WalletSummary(balance: 300)));
        return _buildCubit(purchaseRepository, walletRepository);
      },
      seed: () => const CreditsPurchaseState(
        status: CreditsPurchaseStatus.ready,
        products: [_product],
      ),
      act: (cubit) => cubit.purchase(
        packageIdentifier: _product.packageIdentifier,
        currentBalance: 100,
      ),
      expect: () => [
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.purchasing,
          products: [_product],
          activePackageIdentifier: r'$rc_credits_100',
          baselineBalance: 100,
          expectedCredits: 100,
        ),
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.purchasing,
          products: [_product],
          activePackageIdentifier: r'$rc_credits_100',
          baselineBalance: 200,
          expectedCredits: 100,
        ),
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.processing,
          products: [_product],
          message: CreditsPurchaseMessage.submitted,
          baselineBalance: 200,
          expectedCredits: 100,
        ),
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.confirmed,
          products: [_product],
          message: CreditsPurchaseMessage.confirmed,
          baselineBalance: 200,
          expectedCredits: 100,
          confirmedBalance: 300,
        ),
      ],
      verify: (_) {
        expect(walletRepository.summaryCalls, 3);
        expect(purchaseRepository.clearPendingCalls, 1);
      },
    );

    blocTest<CreditsPurchaseCubit, CreditsPurchaseState>(
      'should reconcile an interrupted purchase instead of allowing an immediate retry',
      build: () {
        purchaseRepository.purchaseError =
            const CreditPurchaseNetworkException();
        walletRepository.summaries
          ..add(const Right(WalletSummary(balance: 100)))
          ..add(const Right(WalletSummary(balance: 100)));
        return _buildCubit(purchaseRepository, walletRepository);
      },
      seed: () => const CreditsPurchaseState(
        status: CreditsPurchaseStatus.ready,
        products: [_product],
      ),
      act: (cubit) => cubit.purchase(
        packageIdentifier: _product.packageIdentifier,
        currentBalance: 100,
      ),
      expect: () => [
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.purchasing,
          products: [_product],
          activePackageIdentifier: r'$rc_credits_100',
          baselineBalance: 100,
          expectedCredits: 100,
        ),
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.processing,
          products: [_product],
          message: CreditsPurchaseMessage.networkAmbiguous,
          baselineBalance: 100,
          expectedCredits: 100,
        ),
        const CreditsPurchaseState(
          status: CreditsPurchaseStatus.delayed,
          products: [_product],
          message: CreditsPurchaseMessage.delayed,
          baselineBalance: 100,
          expectedCredits: 100,
        ),
      ],
      verify: (cubit) async {
        expect(cubit.state.blocksNewPurchase, isTrue);
        await cubit.purchase(
          packageIdentifier: _product.packageIdentifier,
          currentBalance: 100,
        );
        expect(purchaseRepository.purchaseCalls, 1);
      },
    );
  });
}
