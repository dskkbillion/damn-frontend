import 'package:equatable/equatable.dart';

import '../../domain/entities/credit_store_product.dart';

enum CreditsPurchaseStatus {
  initial,
  loading,
  ready,
  purchasing,
  processing,
  confirmed,
  cancelled,
  pending,
  delayed,
  unavailable,
  failure,
}

enum CreditsPurchaseMessage {
  pendingDetected,
  serverPending,
  noProducts,
  loadFailed,
  balancePreflightFailed,
  cancelled,
  storePending,
  submitted,
  networkAmbiguous,
  storeAmbiguous,
  purchaseFailed,
  unsafeReconciliation,
  checkingAgain,
  balanceUpdatedGuarded,
  confirmed,
  reversed,
  delayed,
  unavailable,
}

class CreditsPurchaseState extends Equatable {
  const CreditsPurchaseState({
    this.status = CreditsPurchaseStatus.initial,
    this.products = const [],
    this.message,
    this.activePackageIdentifier,
    this.baselineBalance,
    this.expectedCredits,
    this.confirmedBalance,
  });

  final CreditsPurchaseStatus status;
  final List<CreditStoreProduct> products;
  final CreditsPurchaseMessage? message;
  final String? activePackageIdentifier;
  final double? baselineBalance;
  final int? expectedCredits;
  final double? confirmedBalance;

  bool get blocksNewPurchase =>
      status == CreditsPurchaseStatus.loading ||
      status == CreditsPurchaseStatus.purchasing ||
      status == CreditsPurchaseStatus.processing ||
      status == CreditsPurchaseStatus.pending ||
      status == CreditsPurchaseStatus.delayed;

  CreditsPurchaseState copyWith({
    CreditsPurchaseStatus? status,
    List<CreditStoreProduct>? products,
    CreditsPurchaseMessage? message,
    bool clearMessage = false,
    String? activePackageIdentifier,
    bool clearActivePackageIdentifier = false,
    double? baselineBalance,
    int? expectedCredits,
    double? confirmedBalance,
    bool clearConfirmedBalance = false,
  }) {
    return CreditsPurchaseState(
      status: status ?? this.status,
      products: products ?? this.products,
      message: clearMessage ? null : message ?? this.message,
      activePackageIdentifier: clearActivePackageIdentifier
          ? null
          : activePackageIdentifier ?? this.activePackageIdentifier,
      baselineBalance: baselineBalance ?? this.baselineBalance,
      expectedCredits: expectedCredits ?? this.expectedCredits,
      confirmedBalance: clearConfirmedBalance
          ? null
          : confirmedBalance ?? this.confirmedBalance,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        message,
        activePackageIdentifier,
        baselineBalance,
        expectedCredits,
        confirmedBalance,
      ];
}
