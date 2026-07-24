import 'package:equatable/equatable.dart';

enum CreditStore {
  appStore,
  playStore,
}

class CreditProductCatalogEntry extends Equatable {
  const CreditProductCatalogEntry({
    required this.packId,
    required this.store,
    required this.productId,
    required this.packageId,
    required this.credits,
  });

  final String packId;
  final CreditStore store;
  final String productId;
  final String packageId;
  final int credits;

  @override
  List<Object?> get props => [
        packId,
        store,
        productId,
        packageId,
        credits,
      ];
}

class CreditPurchaseBootstrap extends Equatable {
  const CreditPurchaseBootstrap({
    required this.appUserId,
    required this.purchasesEnabled,
    required this.hasPendingFulfillment,
    required this.offeringId,
    required this.products,
  });

  final String appUserId;
  final bool purchasesEnabled;
  final bool hasPendingFulfillment;
  final String offeringId;
  final List<CreditProductCatalogEntry> products;

  @override
  List<Object?> get props => [
        appUserId,
        purchasesEnabled,
        hasPendingFulfillment,
        offeringId,
        products,
      ];
}
