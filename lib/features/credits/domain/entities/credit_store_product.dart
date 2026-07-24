import 'package:equatable/equatable.dart';

/// A consumable credit package as described by the active app store.
///
/// [localizedPrice] is provided by StoreKit or Google Play Billing and is the
/// only price text the client should show.
class CreditStoreProduct extends Equatable {
  const CreditStoreProduct({
    required this.packId,
    required this.credits,
    required this.packageIdentifier,
    required this.productIdentifier,
    required this.title,
    required this.description,
    required this.localizedPrice,
  });

  final String packId;
  final int credits;
  final String packageIdentifier;
  final String productIdentifier;
  final String title;
  final String description;
  final String localizedPrice;

  @override
  List<Object?> get props => [
        packId,
        credits,
        packageIdentifier,
        productIdentifier,
        title,
        description,
        localizedPrice,
      ];
}
