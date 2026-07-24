import 'package:equatable/equatable.dart';

enum CreditPurchaseOutcome {
  submitted,
  cancelled,
  pending,
}

class CreditPurchaseResult extends Equatable {
  const CreditPurchaseResult({
    required this.outcome,
    this.transactionRef,
  });

  final CreditPurchaseOutcome outcome;

  /// SHA-256 of the store transaction identifier.
  ///
  /// The raw store identifier must never leave the native gateway, be logged,
  /// or be persisted by the app.
  final String? transactionRef;

  @override
  List<Object?> get props => [outcome, transactionRef];
}
