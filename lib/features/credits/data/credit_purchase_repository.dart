import 'dart:async';

import '../domain/credit_purchase_exception.dart';
import '../domain/entities/credit_purchase_bootstrap.dart';
import '../domain/entities/credit_pending_purchase.dart';
import '../domain/entities/credit_purchase_result.dart';
import '../domain/entities/credit_purchase_server_status.dart';
import '../domain/entities/credit_store_product.dart';
import '../domain/repositories/i_credit_purchase_repository.dart';
import 'credit_purchase_identity_data_source.dart';
import 'credit_pending_purchase_store.dart';
import 'revenue_cat_gateway.dart';
import 'revenue_cat_public_api_key_provider.dart';

class CreditPurchaseRepository implements ICreditPurchaseRepository {
  CreditPurchaseRepository({
    required CreditPurchaseIdentityDataSource identityDataSource,
    required CreditPendingPurchaseStore pendingPurchaseStore,
    required RevenueCatGateway gateway,
    required RevenueCatPublicApiKeyProvider apiKeyProvider,
  })  : _identityDataSource = identityDataSource,
        _pendingPurchaseStore = pendingPurchaseStore,
        _gateway = gateway,
        _apiKeyProvider = apiKeyProvider;

  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  final CreditPurchaseIdentityDataSource _identityDataSource;
  final CreditPendingPurchaseStore _pendingPurchaseStore;
  final RevenueCatGateway _gateway;
  final RevenueCatPublicApiKeyProvider _apiKeyProvider;

  Future<void> _operationQueue = Future<void>.value();
  int _bindingEpoch = 0;
  String? _boundAppUserId;
  String? _boundOfferingId;
  bool _boundHasPendingFulfillment = false;
  List<CreditProductCatalogEntry> _boundCatalog = const [];

  @override
  bool get isBound => _boundAppUserId != null;

  @override
  Future<void> bindAuthenticatedUser() {
    final epoch = ++_bindingEpoch;
    _boundAppUserId = null;
    _boundOfferingId = null;
    _boundHasPendingFulfillment = false;
    _boundCatalog = const [];
    _gateway.clearProducts();

    return _serialize(() => _bindAuthenticatedUser(epoch));
  }

  Future<void> _bindAuthenticatedUser(int epoch) async {
    if (!_apiKeyProvider.iapEnabled) {
      throw const CreditPurchaseUnavailableException('移动端积分购买暂未开放');
    }
    final publicApiKey = _apiKeyProvider.forCurrentPlatform();
    final configuredOfferingId = _apiKeyProvider.offeringId;
    final currentStore = _apiKeyProvider.currentStore;
    if (publicApiKey == null ||
        configuredOfferingId == null ||
        currentStore == null) {
      throw const CreditPurchaseUnavailableException(
        '当前平台尚未配置积分购买',
      );
    }

    final bootstrap = await _identityDataSource.getBootstrap();
    if (!bootstrap.purchasesEnabled) {
      throw const CreditPurchaseUnavailableException('移动端积分购买暂未开放');
    }
    if (bootstrap.offeringId != configuredOfferingId) {
      throw const CreditPurchaseUnavailableException('移动端购买配置不一致');
    }
    final catalog = bootstrap.products
        .where((product) => product.store == currentStore)
        .toList(growable: false);
    if (catalog.length != 3) {
      throw const CreditPurchaseUnavailableException('移动端购买配置无效');
    }

    // Never derive an App User ID from member.id. Preserve the backend opaque
    // ID byte-for-byte because RevenueCat IDs are case-sensitive.
    final appUserId = bootstrap.appUserId;
    if (!_isValidOpaqueAppUserId(appUserId)) {
      throw const CreditPurchaseNotBoundException(
        '购买身份格式无效，请重新登录后重试',
      );
    }
    if (epoch != _bindingEpoch) {
      throw const CreditPurchaseNotBoundException('登录状态已变化，请重试');
    }

    if (!await _gateway.isConfigured) {
      await _gateway.configure(
        publicApiKey: publicApiKey,
        appUserId: appUserId,
      );
    } else {
      final currentAppUserId = await _gateway.currentAppUserId;
      if (currentAppUserId != appUserId) {
        await _gateway.logIn(appUserId);
      }
    }

    if (epoch != _bindingEpoch) {
      throw const CreditPurchaseNotBoundException('登录状态已变化，请重试');
    }

    final confirmedAppUserId = await _gateway.currentAppUserId;
    if (confirmedAppUserId != appUserId) {
      throw const CreditPurchaseNotBoundException('购买身份绑定失败，请重新登录');
    }
    _boundAppUserId = appUserId;
    _boundOfferingId = configuredOfferingId;
    _boundHasPendingFulfillment = bootstrap.hasPendingFulfillment;
    _boundCatalog = catalog;
  }

  bool _isValidOpaqueAppUserId(String? value) {
    if (value == null ||
        value.isEmpty ||
        value.length > 100 ||
        value.contains('/')) {
      return false;
    }
    return _uuidPattern.hasMatch(value);
  }

  @override
  Future<void> unbind() {
    ++_bindingEpoch;
    _boundAppUserId = null;
    _boundOfferingId = null;
    _boundHasPendingFulfillment = false;
    _boundCatalog = const [];
    _gateway.clearProducts();

    return _serialize(() async {
      // Deliberately do not call Purchases.logOut(): RevenueCat would create an
      // anonymous App User ID. Local state is enough to prohibit purchases.
      _boundAppUserId = null;
      _boundOfferingId = null;
      _boundHasPendingFulfillment = false;
      _boundCatalog = const [];
      _gateway.clearProducts();
    });
  }

  @override
  Future<List<CreditStoreProduct>> getProducts() async {
    final epoch = _bindingEpoch;
    _requireBound();
    if (_boundHasPendingFulfillment) {
      throw const CreditPurchaseUnavailableException(
        '已有一笔购买正在核对，请勿重复购买',
      );
    }
    final products = await _gateway.getProducts(
      offeringId: _boundOfferingId!,
      catalog: _boundCatalog,
    );
    if (epoch != _bindingEpoch || !isBound) {
      throw const CreditPurchaseNotBoundException('登录状态已变化，请重试');
    }
    return products;
  }

  @override
  Future<CreditPendingPurchase?> getPendingPurchase() async {
    final epoch = _bindingEpoch;
    final appUserId = _boundAppUserId;
    _requireBound();
    final pendingPurchase = await _pendingPurchaseStore.read(appUserId!);
    if (epoch != _bindingEpoch || appUserId != _boundAppUserId) {
      throw const CreditPurchaseNotBoundException('登录状态已变化，请重试');
    }
    return pendingPurchase;
  }

  @override
  Future<CreditPurchaseRecoveryStatus> getRecoveryStatus(
    CreditPendingPurchase? pendingPurchase,
  ) async {
    final epoch = _bindingEpoch;
    final appUserId = _boundAppUserId;
    _requireBound();

    if (pendingPurchase != null && pendingPurchase.appUserId != appUserId) {
      throw const CreditPurchaseNotBoundException('登录状态已变化，请重试');
    }
    final serverStatus = await _identityDataSource.getStatus();
    if (epoch != _bindingEpoch || appUserId != _boundAppUserId) {
      throw const CreditPurchaseNotBoundException('登录状态已变化，请重试');
    }

    _boundHasPendingFulfillment = serverStatus.hasPendingFulfillment;
    if (serverStatus.hasPendingFulfillment) {
      return const CreditPurchaseRecoveryStatus(
        CreditPurchaseRecoveryState.pending,
      );
    }
    if (pendingPurchase == null) {
      return const CreditPurchaseRecoveryStatus(
        CreditPurchaseRecoveryState.clear,
      );
    }

    final catalogMatches = _boundCatalog
        .where(
          (product) =>
              product.packageId == pendingPurchase.packageIdentifier &&
              product.credits == pendingPurchase.expectedCredits,
        )
        .toList(growable: false);
    if (catalogMatches.length != 1) {
      return const CreditPurchaseRecoveryStatus(
        CreditPurchaseRecoveryState.unresolved,
      );
    }
    final catalogProduct = catalogMatches.single;
    final startedAt = DateTime.fromMillisecondsSinceEpoch(
      pendingPurchase.startedAtEpochMilliseconds,
    ).toUtc();
    final transactionRef = pendingPurchase.transactionRef;
    final matchingPurchases = serverStatus.purchases.where((purchase) {
      final sameProduct = purchase.store == catalogProduct.store &&
          purchase.packId == catalogProduct.packId &&
          purchase.productId == catalogProduct.productId &&
          purchase.credits == catalogProduct.credits;
      if (!sameProduct) return false;
      if (transactionRef != null) {
        return purchase.transactionRef == transactionRef;
      }
      return !purchase.purchasedAt.toUtc().isBefore(startedAt);
    }).toList(growable: false)
      ..sort((left, right) {
        final byTime = right.purchasedAt.compareTo(left.purchasedAt);
        return byTime != 0
            ? byTime
            : right.purchaseId.compareTo(left.purchaseId);
      });
    if (matchingPurchases.isEmpty) {
      return const CreditPurchaseRecoveryStatus(
        CreditPurchaseRecoveryState.unresolved,
      );
    }

    return CreditPurchaseRecoveryStatus(
      switch (matchingPurchases.first.status) {
        CreditPurchaseSettlementStatus.granted =>
          CreditPurchaseRecoveryState.granted,
        CreditPurchaseSettlementStatus.reversed =>
          CreditPurchaseRecoveryState.reversed,
        CreditPurchaseSettlementStatus.restored =>
          CreditPurchaseRecoveryState.restored,
      },
    );
  }

  @override
  Future<void> clearPendingPurchase(
    CreditPendingPurchase expectedPendingPurchase,
  ) {
    final expectedEpoch = _bindingEpoch;
    final expectedAppUserId = _boundAppUserId;
    _requireBound();
    if (expectedPendingPurchase.appUserId != expectedAppUserId) {
      throw const CreditPurchaseNotBoundException('登录状态已变化，请重试');
    }
    return _serialize(() async {
      if (expectedEpoch != _bindingEpoch ||
          expectedAppUserId == null ||
          expectedAppUserId != _boundAppUserId) {
        throw const CreditPurchaseNotBoundException('登录状态已变化，请重试');
      }
      final currentPendingPurchase =
          await _pendingPurchaseStore.read(expectedAppUserId);
      if (currentPendingPurchase != expectedPendingPurchase) {
        throw const CreditPurchaseUnavailableException(
          '购买状态已变化，请重新核对',
        );
      }
      await _pendingPurchaseStore.clear(expectedAppUserId);
    });
  }

  @override
  Future<CreditPurchaseResult> purchase({
    required String packageIdentifier,
    required double baselineBalance,
    required int expectedCredits,
  }) async {
    _requireBound();
    final expectedEpoch = _bindingEpoch;
    final expectedAppUserId = _boundAppUserId;
    return _serialize(() async {
      if (expectedEpoch != _bindingEpoch ||
          expectedAppUserId == null ||
          expectedAppUserId != _boundAppUserId) {
        throw const CreditPurchaseNotBoundException('登录状态已变化，请重试');
      }
      await _assertPurchaseStillAuthorized(packageIdentifier);
      if (await _pendingPurchaseStore.read(expectedAppUserId) != null) {
        throw const CreditPurchaseUnavailableException(
          '已有一笔购买正在核对，请勿重复购买',
        );
      }
      final matches = _boundCatalog
          .where((product) => product.packageId == packageIdentifier)
          .toList(growable: false);
      if (matches.length != 1 ||
          matches.single.credits != expectedCredits ||
          !baselineBalance.isFinite) {
        throw const CreditPurchaseUnavailableException('积分包信息已失效，请刷新');
      }

      await _pendingPurchaseStore.write(
        CreditPendingPurchase(
          appUserId: expectedAppUserId,
          packageIdentifier: packageIdentifier,
          baselineBalance: baselineBalance,
          expectedCredits: expectedCredits,
          startedAtEpochMilliseconds: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      final result = await _gateway.purchase(packageIdentifier);
      if (result.outcome == CreditPurchaseOutcome.cancelled) {
        await _pendingPurchaseStore.clear(expectedAppUserId);
      } else if (result.outcome == CreditPurchaseOutcome.submitted &&
          result.transactionRef != null) {
        final pendingPurchase =
            await _pendingPurchaseStore.read(expectedAppUserId);
        if (pendingPurchase == null) {
          throw const CreditPurchaseUnavailableException(
            '购买记录无法安全核对，请联系客服',
          );
        }
        await _pendingPurchaseStore.write(
          pendingPurchase.copyWithTransactionRef(result.transactionRef!),
        );
      }
      // Submitted, pending, and every thrown/unknown native result retain the
      // durable guard. Only an explicit store cancellation proves no charge.
      return result;
    });
  }

  Future<void> _assertPurchaseStillAuthorized(
    String packageIdentifier,
  ) async {
    final configuredOfferingId = _apiKeyProvider.offeringId;
    final currentStore = _apiKeyProvider.currentStore;
    if (!_apiKeyProvider.iapEnabled ||
        configuredOfferingId == null ||
        configuredOfferingId != _boundOfferingId ||
        currentStore == null) {
      throw const CreditPurchaseUnavailableException('移动端积分购买暂未开放');
    }

    final bootstrap = await _identityDataSource.getBootstrap();
    final catalog = bootstrap.products
        .where((product) => product.store == currentStore)
        .toList(growable: false);
    if (!bootstrap.purchasesEnabled ||
        bootstrap.hasPendingFulfillment ||
        bootstrap.appUserId != _boundAppUserId ||
        bootstrap.offeringId != _boundOfferingId ||
        catalog.length != 3 ||
        catalog.toSet().length != _boundCatalog.toSet().length ||
        !catalog.toSet().containsAll(_boundCatalog) ||
        !catalog.any((product) => product.packageId == packageIdentifier)) {
      throw const CreditPurchaseUnavailableException('移动端积分购买暂未开放');
    }

    if (await _gateway.currentAppUserId != _boundAppUserId) {
      throw const CreditPurchaseNotBoundException('购买身份已变化，请重新登录');
    }
  }

  void _requireBound() {
    if (!isBound) {
      throw const CreditPurchaseNotBoundException();
    }
  }

  Future<T> _serialize<T>(Future<T> Function() operation) {
    final result =
        _operationQueue.catchError((Object _) {}).then((_) => operation());
    _operationQueue =
        result.then<void>((_) {}).catchError((Object _, StackTrace __) {});
    return result;
  }
}
