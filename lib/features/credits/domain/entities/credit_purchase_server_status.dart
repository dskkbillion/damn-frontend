import 'package:equatable/equatable.dart';

import 'credit_purchase_bootstrap.dart';

enum CreditPurchaseSettlementStatus {
  granted,
  reversed,
  restored,
}

class CreditPurchaseRecord extends Equatable {
  const CreditPurchaseRecord({
    required this.purchaseId,
    required this.packId,
    required this.productId,
    required this.credits,
    required this.store,
    required this.environment,
    required this.status,
    required this.purchasedAt,
    this.transactionRef,
    this.grantedAt,
    this.reversedAt,
    this.restoredAt,
  });

  final int purchaseId;
  final String packId;
  final String productId;
  final int credits;
  final CreditStore store;
  final String environment;
  final CreditPurchaseSettlementStatus status;
  final DateTime purchasedAt;
  final String? transactionRef;
  final DateTime? grantedAt;
  final DateTime? reversedAt;
  final DateTime? restoredAt;

  @override
  List<Object?> get props => [
        purchaseId,
        packId,
        productId,
        credits,
        store,
        environment,
        status,
        purchasedAt,
        transactionRef,
        grantedAt,
        reversedAt,
        restoredAt,
      ];
}

class CreditPurchaseServerStatus extends Equatable {
  const CreditPurchaseServerStatus({
    required this.hasPendingFulfillment,
    required this.purchases,
  });

  final bool hasPendingFulfillment;
  final List<CreditPurchaseRecord> purchases;

  @override
  List<Object?> get props => [hasPendingFulfillment, purchases];
}

enum CreditPurchaseRecoveryState {
  clear,
  pending,
  granted,
  reversed,
  restored,
  unresolved,
}

class CreditPurchaseRecoveryStatus extends Equatable {
  const CreditPurchaseRecoveryStatus(this.state);

  final CreditPurchaseRecoveryState state;

  @override
  List<Object?> get props => [state];
}
