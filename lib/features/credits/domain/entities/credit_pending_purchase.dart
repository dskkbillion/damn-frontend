import 'package:equatable/equatable.dart';

class CreditPendingPurchase extends Equatable {
  const CreditPendingPurchase({
    required this.appUserId,
    required this.packageIdentifier,
    required this.baselineBalance,
    required this.expectedCredits,
    required this.startedAtEpochMilliseconds,
    this.transactionRef,
  });

  final String appUserId;
  final String packageIdentifier;
  final double baselineBalance;
  final int expectedCredits;
  final int startedAtEpochMilliseconds;
  final String? transactionRef;

  CreditPendingPurchase copyWithTransactionRef(String value) {
    return CreditPendingPurchase(
      appUserId: appUserId,
      packageIdentifier: packageIdentifier,
      baselineBalance: baselineBalance,
      expectedCredits: expectedCredits,
      startedAtEpochMilliseconds: startedAtEpochMilliseconds,
      transactionRef: value,
    );
  }

  @override
  List<Object?> get props => [
        appUserId,
        packageIdentifier,
        baselineBalance,
        expectedCredits,
        startedAtEpochMilliseconds,
        transactionRef,
      ];
}
