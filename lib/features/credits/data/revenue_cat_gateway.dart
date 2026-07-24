import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../domain/credit_purchase_exception.dart';
import '../domain/entities/credit_purchase_bootstrap.dart';
import '../domain/entities/credit_purchase_result.dart';
import '../domain/entities/credit_store_product.dart';

String? hashStoreTransactionIdentifier(String transactionIdentifier) {
  if (transactionIdentifier.isEmpty) return null;
  return sha256.convert(utf8.encode(transactionIdentifier)).toString();
}

abstract class RevenueCatGateway {
  Future<bool> get isConfigured;

  Future<String> get currentAppUserId;

  Future<void> configure({
    required String publicApiKey,
    required String appUserId,
  });

  Future<void> logIn(String appUserId);

  Future<List<CreditStoreProduct>> getProducts({
    required String offeringId,
    required List<CreditProductCatalogEntry> catalog,
  });

  Future<CreditPurchaseResult> purchase(String packageIdentifier);

  void clearProducts();
}

class RevenueCatGatewayImpl implements RevenueCatGateway {
  final Map<String, Package> _packagesByIdentifier = {};

  @override
  Future<bool> get isConfigured => Purchases.isConfigured;

  @override
  Future<String> get currentAppUserId => Purchases.appUserID;

  @override
  Future<void> configure({
    required String publicApiKey,
    required String appUserId,
  }) {
    final configuration = PurchasesConfiguration(publicApiKey)
      ..appUserID = appUserId;
    return Purchases.configure(configuration);
  }

  @override
  Future<void> logIn(String appUserId) async {
    await Purchases.logIn(appUserId);
  }

  @override
  Future<List<CreditStoreProduct>> getProducts({
    required String offeringId,
    required List<CreditProductCatalogEntry> catalog,
  }) async {
    final offerings = await Purchases.getOfferings();
    final offering = offerings.getOffering(offeringId);
    if (offering == null || catalog.length != 3) {
      throw const CreditPurchaseUnavailableException(
        '积分包目录与商店配置不一致',
      );
    }
    final packages = offering.availablePackages;

    final matchedPackages =
        <({CreditProductCatalogEntry entry, Package package})>[];
    for (final entry in catalog) {
      final matches = packages
          .where(
            (package) =>
                package.identifier == entry.packageId &&
                package.storeProduct.identifier == entry.productId,
          )
          .toList(growable: false);
      if (matches.length != 1) {
        clearProducts();
        throw const CreditPurchaseUnavailableException(
          '积分包目录与商店配置不一致',
        );
      }
      matchedPackages.add((entry: entry, package: matches.single));
    }

    _packagesByIdentifier
      ..clear()
      ..addEntries(
        matchedPackages.map(
          (match) => MapEntry(match.package.identifier, match.package),
        ),
      );
    if (_packagesByIdentifier.length != 3) {
      clearProducts();
      throw const CreditPurchaseUnavailableException(
        '积分包目录与商店配置不一致',
      );
    }

    return matchedPackages.map((match) {
      final product = match.package.storeProduct;
      return CreditStoreProduct(
        packId: match.entry.packId,
        credits: match.entry.credits,
        packageIdentifier: match.package.identifier,
        productIdentifier: product.identifier,
        title: product.title,
        description: product.description,
        localizedPrice: product.priceString,
      );
    }).toList(growable: false);
  }

  @override
  Future<CreditPurchaseResult> purchase(String packageIdentifier) async {
    final package = _packagesByIdentifier[packageIdentifier];
    if (package == null) {
      throw const CreditPurchaseUnavailableException(
        '积分包信息已失效，请刷新后重试',
      );
    }

    try {
      final purchaseResult =
          await Purchases.purchase(PurchaseParams.package(package));
      final transactionIdentifier =
          purchaseResult.storeTransaction.transactionIdentifier;
      return CreditPurchaseResult(
        outcome: CreditPurchaseOutcome.submitted,
        transactionRef: hashStoreTransactionIdentifier(transactionIdentifier),
      );
    } on PlatformException catch (error) {
      final code = PurchasesErrorHelper.getErrorCode(error);
      return switch (code) {
        PurchasesErrorCode.purchaseCancelledError => const CreditPurchaseResult(
            outcome: CreditPurchaseOutcome.cancelled,
          ),
        PurchasesErrorCode.paymentPendingError => const CreditPurchaseResult(
            outcome: CreditPurchaseOutcome.pending,
          ),
        PurchasesErrorCode.networkError ||
        PurchasesErrorCode.offlineConnectionError =>
          throw const CreditPurchaseNetworkException(),
        PurchasesErrorCode.operationAlreadyInProgressError =>
          throw const CreditPurchaseUnavailableException('已有购买正在处理中，请稍后再试'),
        PurchasesErrorCode.purchaseNotAllowedError =>
          throw const CreditPurchaseUnavailableException('当前商店账户不允许购买'),
        PurchasesErrorCode.productNotAvailableForPurchaseError =>
          throw const CreditPurchaseUnavailableException('该积分包当前不可购买'),
        _ => throw const CreditPurchaseUnavailableException(
            '商店购买失败，请稍后重试',
          ),
      };
    }
  }

  @override
  void clearProducts() {
    _packagesByIdentifier.clear();
  }
}
