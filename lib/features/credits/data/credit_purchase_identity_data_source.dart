import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';

import '../domain/credit_purchase_exception.dart';
import '../domain/entities/credit_purchase_bootstrap.dart';
import '../domain/entities/credit_purchase_server_status.dart';

abstract class CreditPurchaseIdentityDataSource {
  Future<CreditPurchaseBootstrap> getBootstrap();

  Future<CreditPurchaseServerStatus> getStatus();
}

class CreditPurchaseIdentityDataSourceImpl
    implements CreditPurchaseIdentityDataSource {
  CreditPurchaseIdentityDataSourceImpl(this._dio);

  static final RegExp _transactionRefPattern = RegExp(r'^[0-9a-f]{64}$');

  final Dio _dio;

  @override
  Future<CreditPurchaseBootstrap> getBootstrap() async {
    final response = await _dio.get<Object>(
      '/api/member/credits/iap/identity',
    );
    final responseBody = response.data;
    if (response.statusCode != 200 ||
        responseBody is! Map ||
        responseBody['code'] != 200) {
      throw const CreditPurchaseNotBoundException();
    }

    final payload = responseBody['data'];
    if (payload is! Map) {
      throw const CreditPurchaseUnavailableException('移动端购买配置无效');
    }

    // Never accept an ID or catalog from sibling fields and never derive either
    // on-device. The authenticated bootstrap object is the sole source.
    final appUserId = payload['appUserId'];
    final purchasesEnabled = payload['purchasesEnabled'];
    final hasPendingFulfillment = payload['hasPendingFulfillment'];
    final offeringId = payload['offeringId'];
    final rawEnabledStores = payload['enabledStores'];
    final rawProducts = payload['products'];
    AppLogger.d(
      '[RevenueCatBootstrap] enabled=$purchasesEnabled, '
      'pending=$hasPendingFulfillment, offering=$offeringId, '
      'stores=$rawEnabledStores, '
      'productCount=${rawProducts is List ? rawProducts.length : 'invalid'}',
    );
    if (appUserId is! String ||
        purchasesEnabled is! bool ||
        hasPendingFulfillment is! bool ||
        offeringId is! String ||
        offeringId.isEmpty ||
        rawEnabledStores is! List ||
        rawProducts is! List) {
      throw const CreditPurchaseUnavailableException('移动端购买配置无效');
    }

    final enabledStores =
        rawEnabledStores.map(_parseEnabledStore).toList(growable: false);
    if (enabledStores.length > CreditStore.values.length ||
        !_allUnique(enabledStores)) {
      throw const CreditPurchaseUnavailableException('移动端购买配置无效');
    }
    if (purchasesEnabled && enabledStores.isEmpty) {
      throw const CreditPurchaseUnavailableException('移动端购买配置无效');
    }
    final products = rawProducts.map(_parseProduct).toList(growable: false);
    _validateCatalog(enabledStores, products);

    return CreditPurchaseBootstrap(
      appUserId: appUserId,
      purchasesEnabled: purchasesEnabled,
      hasPendingFulfillment: hasPendingFulfillment,
      offeringId: offeringId,
      enabledStores: enabledStores,
      products: products,
    );
  }

  @override
  Future<CreditPurchaseServerStatus> getStatus() async {
    final response = await _dio.get<Object>(
      '/api/member/credits/iap/status',
    );
    final responseBody = response.data;
    if (response.statusCode != 200 ||
        responseBody is! Map ||
        responseBody['code'] != 200) {
      throw const CreditPurchaseNotBoundException();
    }

    final payload = responseBody['data'];
    if (payload is! Map) {
      throw const CreditPurchaseUnavailableException('移动端购买状态无效');
    }
    final hasPendingFulfillment = payload['hasPendingFulfillment'];
    final rawPurchases = payload['purchases'];
    if (hasPendingFulfillment is! bool ||
        rawPurchases is! List ||
        rawPurchases.length > 20) {
      throw const CreditPurchaseUnavailableException('移动端购买状态无效');
    }

    final purchases = rawPurchases.map(_parsePurchase).toList(growable: false);
    if (!_allUnique(purchases.map((purchase) => purchase.purchaseId))) {
      throw const CreditPurchaseUnavailableException('移动端购买状态无效');
    }
    return CreditPurchaseServerStatus(
      hasPendingFulfillment: hasPendingFulfillment,
      purchases: purchases,
    );
  }

  CreditPurchaseRecord _parsePurchase(Object? rawPurchase) {
    if (rawPurchase is! Map) {
      throw const CreditPurchaseUnavailableException('移动端购买状态无效');
    }
    final purchaseId = rawPurchase['purchaseId'];
    final packId = rawPurchase['packId'];
    final productId = rawPurchase['productId'];
    final credits = rawPurchase['credits'];
    final environment = rawPurchase['environment'];
    final transactionRef = rawPurchase['transactionRef'];
    final purchasedAt = _parseRequiredEpochMillis(
      rawPurchase['purchasedAtMs'],
    );
    if (purchaseId is! int ||
        purchaseId <= 0 ||
        packId is! String ||
        packId.isEmpty ||
        productId is! String ||
        productId.isEmpty ||
        credits is! int ||
        credits <= 0 ||
        environment is! String ||
        environment.isEmpty ||
        (transactionRef != null &&
            (transactionRef is! String ||
                !_transactionRefPattern.hasMatch(transactionRef)))) {
      throw const CreditPurchaseUnavailableException('移动端购买状态无效');
    }

    final store = switch (rawPurchase['store']) {
      'APP_STORE' => CreditStore.appStore,
      'PLAY_STORE' => CreditStore.playStore,
      _ => throw const CreditPurchaseUnavailableException('移动端购买状态无效'),
    };
    final status = switch (rawPurchase['status']) {
      'GRANTED' => CreditPurchaseSettlementStatus.granted,
      'REVERSED' => CreditPurchaseSettlementStatus.reversed,
      'RESTORED' => CreditPurchaseSettlementStatus.restored,
      _ => throw const CreditPurchaseUnavailableException('移动端购买状态无效'),
    };

    return CreditPurchaseRecord(
      purchaseId: purchaseId,
      packId: packId,
      productId: productId,
      credits: credits,
      store: store,
      environment: environment,
      status: status,
      purchasedAt: purchasedAt,
      transactionRef: transactionRef as String?,
      grantedAt: _parseOptionalEpochMillis(rawPurchase['grantedAtMs']),
      reversedAt: _parseOptionalEpochMillis(rawPurchase['reversedAtMs']),
      restoredAt: _parseOptionalEpochMillis(rawPurchase['restoredAtMs']),
    );
  }

  DateTime _parseRequiredEpochMillis(Object? rawValue) {
    final value = _parseOptionalEpochMillis(rawValue);
    if (value == null) {
      throw const CreditPurchaseUnavailableException('移动端购买状态无效');
    }
    return value;
  }

  DateTime? _parseOptionalEpochMillis(Object? rawValue) {
    if (rawValue == null) return null;
    if (rawValue is! int || rawValue <= 0) {
      throw const CreditPurchaseUnavailableException('移动端购买状态无效');
    }
    return DateTime.fromMillisecondsSinceEpoch(rawValue, isUtc: true);
  }

  CreditProductCatalogEntry _parseProduct(Object? rawProduct) {
    if (rawProduct is! Map) {
      throw const CreditPurchaseUnavailableException('移动端购买配置无效');
    }

    final packId = rawProduct['packId'];
    final storeName = rawProduct['store'];
    final productId = rawProduct['productId'];
    final packageId = rawProduct['packageId'];
    final credits = rawProduct['credits'];
    if (packId is! String ||
        packId.isEmpty ||
        productId is! String ||
        productId.isEmpty ||
        packageId is! String ||
        packageId.isEmpty ||
        credits is! int ||
        credits <= 0) {
      throw const CreditPurchaseUnavailableException('移动端购买配置无效');
    }

    final store = switch (storeName) {
      'APP_STORE' => CreditStore.appStore,
      'PLAY_STORE' => CreditStore.playStore,
      _ => throw const CreditPurchaseUnavailableException('移动端购买配置无效'),
    };
    return CreditProductCatalogEntry(
      packId: packId,
      store: store,
      productId: productId,
      packageId: packageId,
      credits: credits,
    );
  }

  CreditStore _parseEnabledStore(Object? rawStore) {
    return switch (rawStore) {
      'APP_STORE' => CreditStore.appStore,
      'PLAY_STORE' => CreditStore.playStore,
      _ => throw const CreditPurchaseUnavailableException('移动端购买配置无效'),
    };
  }

  void _validateCatalog(
    List<CreditStore> enabledStores,
    List<CreditProductCatalogEntry> products,
  ) {
    if (enabledStores.isEmpty) {
      if (products.isEmpty) {
        return;
      }
      throw const CreditPurchaseUnavailableException('移动端购买配置无效');
    }
    if (products.length != enabledStores.length * 3 ||
        products.any((product) => !enabledStores.contains(product.store))) {
      throw const CreditPurchaseUnavailableException('移动端购买配置无效');
    }

    for (final store in enabledStores) {
      final storeProducts =
          products.where((product) => product.store == store).toList();
      if (storeProducts.length != 3 ||
          !_allUnique(storeProducts.map((product) => product.packId)) ||
          !_allUnique(storeProducts.map((product) => product.productId)) ||
          !_allUnique(storeProducts.map((product) => product.packageId)) ||
          !_allUnique(storeProducts.map((product) => product.credits))) {
        throw const CreditPurchaseUnavailableException('移动端购买配置无效');
      }
    }

    final packIds = products.map((product) => product.packId).toSet();
    if (packIds.length != 3) {
      throw const CreditPurchaseUnavailableException('移动端购买配置无效');
    }
    for (final packId in packIds) {
      final variants =
          products.where((product) => product.packId == packId).toList();
      if (variants.length != enabledStores.length ||
          variants.map((product) => product.store).toSet().length !=
              enabledStores.length ||
          variants.map((product) => product.credits).toSet().length != 1) {
        throw const CreditPurchaseUnavailableException('移动端购买配置无效');
      }
    }
  }

  bool _allUnique(Iterable<Object> values) {
    final list = values.toList();
    return list.toSet().length == list.length;
  }
}
