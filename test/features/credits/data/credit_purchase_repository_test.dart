import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dskk_flutter_refactor/features/credits/data/credit_pending_purchase_store.dart';
import 'package:dskk_flutter_refactor/features/credits/data/credit_purchase_identity_data_source.dart';
import 'package:dskk_flutter_refactor/features/credits/data/credit_purchase_repository.dart';
import 'package:dskk_flutter_refactor/features/credits/data/revenue_cat_gateway.dart';
import 'package:dskk_flutter_refactor/features/credits/data/revenue_cat_public_api_key_provider.dart';
import 'package:dskk_flutter_refactor/features/credits/domain/credit_purchase_exception.dart';
import 'package:dskk_flutter_refactor/features/credits/domain/entities/credit_purchase_bootstrap.dart';
import 'package:dskk_flutter_refactor/features/credits/domain/entities/credit_pending_purchase.dart';
import 'package:dskk_flutter_refactor/features/credits/domain/entities/credit_purchase_result.dart';
import 'package:dskk_flutter_refactor/features/credits/domain/entities/credit_purchase_server_status.dart';
import 'package:dskk_flutter_refactor/features/credits/domain/entities/credit_store_product.dart';

const _catalog = [
  CreditProductCatalogEntry(
    packId: 'starter',
    store: CreditStore.appStore,
    productId: 'ios.credits.100',
    packageId: 'credits_100',
    credits: 100,
  ),
  CreditProductCatalogEntry(
    packId: 'value',
    store: CreditStore.appStore,
    productId: 'ios.credits.500',
    packageId: 'credits_500',
    credits: 500,
  ),
  CreditProductCatalogEntry(
    packId: 'max',
    store: CreditStore.appStore,
    productId: 'ios.credits.1200',
    packageId: 'credits_1200',
    credits: 1200,
  ),
  CreditProductCatalogEntry(
    packId: 'starter',
    store: CreditStore.playStore,
    productId: 'android.credits.100',
    packageId: 'credits_100',
    credits: 100,
  ),
  CreditProductCatalogEntry(
    packId: 'value',
    store: CreditStore.playStore,
    productId: 'android.credits.500',
    packageId: 'credits_500',
    credits: 500,
  ),
  CreditProductCatalogEntry(
    packId: 'max',
    store: CreditStore.playStore,
    productId: 'android.credits.1200',
    packageId: 'credits_1200',
    credits: 1200,
  ),
];

CreditPurchaseBootstrap _bootstrap(
  String appUserId, {
  bool enabled = true,
  String offeringId = 'credits_v1',
}) {
  return CreditPurchaseBootstrap(
    appUserId: appUserId,
    purchasesEnabled: enabled,
    hasPendingFulfillment: false,
    offeringId: offeringId,
    products: _catalog,
  );
}

Map<String, Object> _bootstrapResponse(
  String appUserId, {
  bool enabled = true,
  String offeringId = 'credits_v1',
}) {
  return {
    'code': 200,
    'data': {
      'appUserId': appUserId,
      'purchasesEnabled': enabled,
      'hasPendingFulfillment': false,
      'offeringId': offeringId,
      'products': _catalog
          .map(
            (product) => {
              'packId': product.packId,
              'store': product.store == CreditStore.appStore
                  ? 'APP_STORE'
                  : 'PLAY_STORE',
              'productId': product.productId,
              'packageId': product.packageId,
              'credits': product.credits,
            },
          )
          .toList(),
    },
  };
}

Map<String, Object> _statusResponse({
  bool hasPendingFulfillment = false,
  String? transactionRef,
}) {
  return {
    'code': 200,
    'data': {
      'hasPendingFulfillment': hasPendingFulfillment,
      'purchases': [
        {
          'purchaseId': 41,
          'packId': 'starter',
          'productId': 'ios.credits.100',
          'credits': 100,
          'store': 'APP_STORE',
          'environment': 'SANDBOX',
          'status': 'GRANTED',
          'purchasedAtMs': 1784880000000,
          'grantedAtMs': 1784880001000,
          'reversedAtMs': null,
          'restoredAtMs': null,
          'transactionRef': transactionRef,
        },
      ],
    },
  };
}

CreditPurchaseRecord _purchaseRecord({
  required int purchaseId,
  required DateTime purchasedAt,
  String? transactionRef,
  CreditPurchaseSettlementStatus status =
      CreditPurchaseSettlementStatus.granted,
}) {
  return CreditPurchaseRecord(
    purchaseId: purchaseId,
    packId: 'starter',
    productId: 'ios.credits.100',
    credits: 100,
    store: CreditStore.appStore,
    environment: 'SANDBOX',
    status: status,
    purchasedAt: purchasedAt,
    transactionRef: transactionRef,
  );
}

class _FakeIdentityDataSource implements CreditPurchaseIdentityDataSource {
  _FakeIdentityDataSource(this.bootstrap);

  CreditPurchaseBootstrap bootstrap;
  CreditPurchaseServerStatus serverStatus = const CreditPurchaseServerStatus(
    hasPendingFulfillment: false,
    purchases: [],
  );
  int calls = 0;
  int statusCalls = 0;

  @override
  Future<CreditPurchaseBootstrap> getBootstrap() async {
    calls++;
    return bootstrap;
  }

  @override
  Future<CreditPurchaseServerStatus> getStatus() async {
    statusCalls++;
    return serverStatus;
  }
}

class _FakePendingPurchaseStore implements CreditPendingPurchaseStore {
  final Map<String, CreditPendingPurchase> records = {};

  @override
  Future<CreditPendingPurchase?> read(String appUserId) async =>
      records[appUserId];

  @override
  Future<void> write(CreditPendingPurchase pendingPurchase) async {
    records[pendingPurchase.appUserId] = pendingPurchase;
  }

  @override
  Future<void> clear(String appUserId) async {
    records.remove(appUserId);
  }
}

class _FakeApiKeyProvider extends RevenueCatPublicApiKeyProvider {
  const _FakeApiKeyProvider({
    this.key = 'public_test_key',
    this.enabled = true,
    this.configuredOfferingId = 'credits_v1',
    this.store = CreditStore.appStore,
  });

  final String? key;
  final bool enabled;
  final String? configuredOfferingId;
  final CreditStore? store;

  @override
  bool get iapEnabled => enabled;

  @override
  String? get offeringId => configuredOfferingId;

  @override
  CreditStore? get currentStore => store;

  @override
  String? forCurrentPlatform() => key;
}

class _FakeRevenueCatGateway implements RevenueCatGateway {
  bool configured = false;
  String appUserId = '';
  String? forcedReadbackId;
  final List<String> configuredIds = [];
  final List<String> loginIds = [];
  int purchaseCalls = 0;
  String? requestedOfferingId;
  List<CreditProductCatalogEntry>? requestedCatalog;
  Completer<CreditPurchaseResult>? purchaseCompleter;
  Completer<void>? purchaseStarted;
  Object? purchaseError;
  CreditPurchaseResult purchaseResult = const CreditPurchaseResult(
    outcome: CreditPurchaseOutcome.submitted,
  );

  @override
  Future<String> get currentAppUserId async => forcedReadbackId ?? appUserId;

  @override
  Future<bool> get isConfigured async => configured;

  @override
  Future<void> configure({
    required String publicApiKey,
    required String appUserId,
  }) async {
    configured = true;
    this.appUserId = appUserId;
    configuredIds.add(appUserId);
  }

  @override
  Future<void> logIn(String appUserId) async {
    this.appUserId = appUserId;
    loginIds.add(appUserId);
  }

  @override
  void clearProducts() {}

  @override
  Future<List<CreditStoreProduct>> getProducts({
    required String offeringId,
    required List<CreditProductCatalogEntry> catalog,
  }) async {
    requestedOfferingId = offeringId;
    requestedCatalog = catalog;
    return const [
      CreditStoreProduct(
        packId: 'starter',
        credits: 100,
        packageIdentifier: 'credits_100',
        productIdentifier: 'ios.credits.100',
        title: 'Store title must not define credits',
        description: 'Store description',
        localizedPrice: r'$4.99',
      ),
    ];
  }

  @override
  Future<CreditPurchaseResult> purchase(String packageIdentifier) async {
    purchaseCalls++;
    if (purchaseStarted != null && !purchaseStarted!.isCompleted) {
      purchaseStarted!.complete();
    }
    final error = purchaseError;
    if (error != null) throw error;
    final completer = purchaseCompleter;
    if (completer != null) return completer.future;
    return purchaseResult;
  }
}

void main() {
  group('RevenueCat transaction reference', () {
    test('should match the backend SHA-256 fixed vector', () {
      expect(
        hashStoreTransactionIdentifier('store-transaction-123'),
        '94149e08ae76765c3b755fbd6fabf0c11ae8291688d6c9d467a76d4991278b44',
      );
      expect(hashStoreTransactionIdentifier(''), isNull);
    });
  });

  group('CreditPurchaseIdentityDataSource', () {
    test('should read the complete bootstrap only from data', () async {
      const expectedId = 'A2345678-1234-1234-1234-1234567890AB';
      final response = _bootstrapResponse(expectedId)
        ..['appUserId'] = 'root-field-must-not-be-used';
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response<Object>(
                  requestOptions: options,
                  statusCode: 200,
                  data: response,
                ),
              );
            },
          ),
        );

      final dataSource = CreditPurchaseIdentityDataSourceImpl(dio);
      final bootstrap = await dataSource.getBootstrap();

      expect(bootstrap.appUserId, expectedId);
      expect(bootstrap.offeringId, 'credits_v1');
      expect(bootstrap.products, hasLength(6));
    });

    test('should reject a response without data.appUserId', () async {
      final response = _bootstrapResponse('temporary');
      (response['data']! as Map<String, Object>).remove('appUserId');
      response['appUserId'] = '123';
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response<Object>(
                  requestOptions: options,
                  statusCode: 200,
                  data: response,
                ),
              );
            },
          ),
        );

      final dataSource = CreditPurchaseIdentityDataSourceImpl(dio);

      await expectLater(
        dataSource.getBootstrap(),
        throwsA(isA<CreditPurchaseUnavailableException>()),
      );
    });

    test('should reject duplicate product mappings', () async {
      final response = _bootstrapResponse(
        '12345678-1234-1234-1234-1234567890ab',
      );
      final data = response['data']! as Map<String, Object>;
      final products = data['products']! as List<Map<String, Object>>;
      products[1]['packageId'] = products[0]['packageId']!;
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response<Object>(
                  requestOptions: options,
                  statusCode: 200,
                  data: response,
                ),
              );
            },
          ),
        );

      final dataSource = CreditPurchaseIdentityDataSourceImpl(dio);

      await expectLater(
        dataSource.getBootstrap(),
        throwsA(isA<CreditPurchaseUnavailableException>()),
      );
    });

    test('should parse the authenticated status transaction reference',
        () async {
      const transactionRef =
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response<Object>(
                  requestOptions: options,
                  statusCode: 200,
                  data: _statusResponse(transactionRef: transactionRef),
                ),
              );
            },
          ),
        );

      final status =
          await CreditPurchaseIdentityDataSourceImpl(dio).getStatus();

      expect(status.hasPendingFulfillment, isFalse);
      expect(status.purchases.single.transactionRef, transactionRef);
      expect(status.purchases.single.purchasedAt.isUtc, isTrue);
      expect(
        status.purchases.single.purchasedAt.millisecondsSinceEpoch,
        1784880000000,
      );
      expect(
        status.purchases.single.status,
        CreditPurchaseSettlementStatus.granted,
      );
    });

    test('should reject the old timezone-ambiguous status timestamp', () async {
      final response = _statusResponse();
      final purchase =
          ((response['data']! as Map<String, Object>)['purchases']! as List)
              .single as Map<String, Object?>;
      purchase
        ..remove('purchasedAtMs')
        ..['purchasedAt'] = '2026-07-24T16:00:00';
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response<Object>(
                  requestOptions: options,
                  statusCode: 200,
                  data: response,
                ),
              );
            },
          ),
        );

      await expectLater(
        CreditPurchaseIdentityDataSourceImpl(dio).getStatus(),
        throwsA(isA<CreditPurchaseUnavailableException>()),
      );
    });

    test('should reject a non-lowercase status transaction reference',
        () async {
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response<Object>(
                  requestOptions: options,
                  statusCode: 200,
                  data: _statusResponse(
                    transactionRef:
                        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
                  ),
                ),
              );
            },
          ),
        );

      await expectLater(
        CreditPurchaseIdentityDataSourceImpl(dio).getStatus(),
        throwsA(isA<CreditPurchaseUnavailableException>()),
      );
    });
  });

  group('SharedPreferencesCreditPendingPurchaseStore', () {
    test('should restore a per-user pending guard after store recreation',
        () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final firstStore =
          SharedPreferencesCreditPendingPurchaseStore(preferences);
      const pendingPurchase = CreditPendingPurchase(
        appUserId: '12345678-1234-1234-1234-1234567890ab',
        packageIdentifier: 'credits_100',
        baselineBalance: 100,
        expectedCredits: 100,
        startedAtEpochMilliseconds: 1234,
      );

      await firstStore.write(pendingPurchase);
      final recreatedStore =
          SharedPreferencesCreditPendingPurchaseStore(preferences);

      expect(
        await recreatedStore.read(pendingPurchase.appUserId),
        pendingPurchase,
      );
    });

    test('should persist only the hashed transaction reference', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      const transactionRef =
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
      const pendingPurchase = CreditPendingPurchase(
        appUserId: '12345678-1234-1234-1234-1234567890ab',
        packageIdentifier: 'credits_100',
        baselineBalance: 100,
        expectedCredits: 100,
        startedAtEpochMilliseconds: 1234,
        transactionRef: transactionRef,
      );

      final store = SharedPreferencesCreditPendingPurchaseStore(preferences);
      await store.write(pendingPurchase);

      expect(
        (await store.read(pendingPurchase.appUserId))?.transactionRef,
        transactionRef,
      );
      expect(
        preferences
            .getString(
              'credits_iap_pending_v1_${pendingPurchase.appUserId}',
            )
            ?.contains('store-transaction-id'),
        isFalse,
      );
    });
  });

  group('CreditPurchaseRepository', () {
    test('should preserve the opaque ID case when configuring RevenueCat',
        () async {
      const opaqueId = 'A2345678-1234-1234-1234-1234567890AB';
      final identity = _FakeIdentityDataSource(_bootstrap(opaqueId));
      final gateway = _FakeRevenueCatGateway();
      final repository = CreditPurchaseRepository(
        identityDataSource: identity,
        pendingPurchaseStore: _FakePendingPurchaseStore(),
        gateway: gateway,
        apiKeyProvider: const _FakeApiKeyProvider(),
      );

      await repository.bindAuthenticatedUser();

      expect(repository.isBound, isTrue);
      expect(gateway.configuredIds, const [opaqueId]);
      expect(gateway.loginIds, isEmpty);
    });

    test(
        'should switch custom users with logIn and never create an anonymous ID',
        () async {
      const firstId = '12345678-1234-1234-1234-1234567890ab';
      const secondId = '87654321-4321-4321-4321-ba0987654321';
      final identity = _FakeIdentityDataSource(_bootstrap(firstId));
      final gateway = _FakeRevenueCatGateway();
      final repository = CreditPurchaseRepository(
        identityDataSource: identity,
        pendingPurchaseStore: _FakePendingPurchaseStore(),
        gateway: gateway,
        apiKeyProvider: const _FakeApiKeyProvider(),
      );

      await repository.bindAuthenticatedUser();
      await repository.unbind();

      expect(repository.isBound, isFalse);
      await expectLater(
        repository.purchase(
          packageIdentifier: 'credits_100',
          baselineBalance: 100,
          expectedCredits: 100,
        ),
        throwsA(isA<CreditPurchaseNotBoundException>()),
      );
      expect(gateway.purchaseCalls, 0);

      identity.bootstrap = _bootstrap(secondId);
      await repository.bindAuthenticatedUser();

      expect(gateway.configuredIds, const [firstId]);
      expect(gateway.loginIds, const [secondId]);
      expect(gateway.appUserId, secondId);
    });

    test('should reject a guessable member ID before configuring RevenueCat',
        () async {
      final identity = _FakeIdentityDataSource(_bootstrap('42'));
      final gateway = _FakeRevenueCatGateway();
      final repository = CreditPurchaseRepository(
        identityDataSource: identity,
        pendingPurchaseStore: _FakePendingPurchaseStore(),
        gateway: gateway,
        apiKeyProvider: const _FakeApiKeyProvider(),
      );

      await expectLater(
        repository.bindAuthenticatedUser(),
        throwsA(isA<CreditPurchaseNotBoundException>()),
      );

      expect(repository.isBound, isFalse);
      expect(gateway.configuredIds, isEmpty);
      expect(gateway.loginIds, isEmpty);
    });

    test('should stop before bootstrap when the client kill switch is off',
        () async {
      final identity = _FakeIdentityDataSource(
        _bootstrap('12345678-1234-1234-1234-1234567890ab'),
      );
      final gateway = _FakeRevenueCatGateway();
      final repository = CreditPurchaseRepository(
        identityDataSource: identity,
        pendingPurchaseStore: _FakePendingPurchaseStore(),
        gateway: gateway,
        apiKeyProvider: const _FakeApiKeyProvider(enabled: false),
      );

      await expectLater(
        repository.bindAuthenticatedUser(),
        throwsA(isA<CreditPurchaseUnavailableException>()),
      );

      expect(identity.calls, 0);
      expect(gateway.configuredIds, isEmpty);
    });

    test('should stop before bootstrap when required client config is missing',
        () async {
      for (final provider in const [
        _FakeApiKeyProvider(key: null),
        _FakeApiKeyProvider(configuredOfferingId: null),
      ]) {
        final identity = _FakeIdentityDataSource(
          _bootstrap('12345678-1234-1234-1234-1234567890ab'),
        );
        final gateway = _FakeRevenueCatGateway();
        final repository = CreditPurchaseRepository(
          identityDataSource: identity,
          pendingPurchaseStore: _FakePendingPurchaseStore(),
          gateway: gateway,
          apiKeyProvider: provider,
        );

        await expectLater(
          repository.bindAuthenticatedUser(),
          throwsA(isA<CreditPurchaseUnavailableException>()),
        );

        expect(identity.calls, 0);
        expect(gateway.configuredIds, isEmpty);
      }
    });

    test('should stop before configuring when the remote kill switch is off',
        () async {
      final identity = _FakeIdentityDataSource(
        _bootstrap(
          '12345678-1234-1234-1234-1234567890ab',
          enabled: false,
        ),
      );
      final gateway = _FakeRevenueCatGateway();
      final repository = CreditPurchaseRepository(
        identityDataSource: identity,
        pendingPurchaseStore: _FakePendingPurchaseStore(),
        gateway: gateway,
        apiKeyProvider: const _FakeApiKeyProvider(),
      );

      await expectLater(
        repository.bindAuthenticatedUser(),
        throwsA(isA<CreditPurchaseUnavailableException>()),
      );

      expect(gateway.configuredIds, isEmpty);
    });

    test('should reject an offering ID mismatch before configuring', () async {
      final identity = _FakeIdentityDataSource(
        _bootstrap(
          '12345678-1234-1234-1234-1234567890ab',
          offeringId: 'unexpected',
        ),
      );
      final gateway = _FakeRevenueCatGateway();
      final repository = CreditPurchaseRepository(
        identityDataSource: identity,
        pendingPurchaseStore: _FakePendingPurchaseStore(),
        gateway: gateway,
        apiKeyProvider: const _FakeApiKeyProvider(),
      );

      await expectLater(
        repository.bindAuthenticatedUser(),
        throwsA(isA<CreditPurchaseUnavailableException>()),
      );

      expect(gateway.configuredIds, isEmpty);
    });

    test('should require an exact SDK app user ID readback', () async {
      const opaqueId = '12345678-1234-1234-1234-1234567890ab';
      final identity = _FakeIdentityDataSource(_bootstrap(opaqueId));
      final gateway = _FakeRevenueCatGateway()
        ..forcedReadbackId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
      final repository = CreditPurchaseRepository(
        identityDataSource: identity,
        pendingPurchaseStore: _FakePendingPurchaseStore(),
        gateway: gateway,
        apiKeyProvider: const _FakeApiKeyProvider(),
      );

      await expectLater(
        repository.bindAuthenticatedUser(),
        throwsA(isA<CreditPurchaseNotBoundException>()),
      );

      expect(repository.isBound, isFalse);
    });

    test('should pass only the current store catalog to the named offering',
        () async {
      final identity = _FakeIdentityDataSource(
        _bootstrap('12345678-1234-1234-1234-1234567890ab'),
      );
      final gateway = _FakeRevenueCatGateway();
      final repository = CreditPurchaseRepository(
        identityDataSource: identity,
        pendingPurchaseStore: _FakePendingPurchaseStore(),
        gateway: gateway,
        apiKeyProvider: const _FakeApiKeyProvider(
          store: CreditStore.playStore,
        ),
      );

      await repository.bindAuthenticatedUser();
      final products = await repository.getProducts();

      expect(products.single.credits, 100);
      expect(gateway.requestedOfferingId, 'credits_v1');
      expect(gateway.requestedCatalog, hasLength(3));
      expect(
        gateway.requestedCatalog!.every(
          (product) => product.store == CreditStore.playStore,
        ),
        isTrue,
      );
    });

    test('should recheck the remote kill switch immediately before purchase',
        () async {
      const opaqueId = '12345678-1234-1234-1234-1234567890ab';
      final identity = _FakeIdentityDataSource(_bootstrap(opaqueId));
      final gateway = _FakeRevenueCatGateway();
      final repository = CreditPurchaseRepository(
        identityDataSource: identity,
        pendingPurchaseStore: _FakePendingPurchaseStore(),
        gateway: gateway,
        apiKeyProvider: const _FakeApiKeyProvider(),
      );

      await repository.bindAuthenticatedUser();
      identity.bootstrap = _bootstrap(opaqueId, enabled: false);

      await expectLater(
        repository.purchase(
          packageIdentifier: 'credits_100',
          baselineBalance: 100,
          expectedCredits: 100,
        ),
        throwsA(isA<CreditPurchaseUnavailableException>()),
      );

      expect(identity.calls, 2);
      expect(gateway.purchaseCalls, 0);
    });

    test('should keep account switching queued until native purchase completes',
        () async {
      const firstId = '12345678-1234-1234-1234-1234567890ab';
      const secondId = '87654321-4321-4321-4321-ba0987654321';
      final identity = _FakeIdentityDataSource(_bootstrap(firstId));
      final pendingStore = _FakePendingPurchaseStore();
      final purchaseStarted = Completer<void>();
      final nativePurchase = Completer<CreditPurchaseResult>();
      final gateway = _FakeRevenueCatGateway()
        ..purchaseStarted = purchaseStarted
        ..purchaseCompleter = nativePurchase;
      final repository = CreditPurchaseRepository(
        identityDataSource: identity,
        pendingPurchaseStore: pendingStore,
        gateway: gateway,
        apiKeyProvider: const _FakeApiKeyProvider(),
      );
      await repository.bindAuthenticatedUser();

      final purchase = repository.purchase(
        packageIdentifier: 'credits_100',
        baselineBalance: 100,
        expectedCredits: 100,
      );
      await purchaseStarted.future;

      identity.bootstrap = _bootstrap(secondId);
      final switchUser = repository.bindAuthenticatedUser();
      await Future<void>.delayed(Duration.zero);
      expect(gateway.loginIds, isEmpty);

      nativePurchase.complete(
        const CreditPurchaseResult(
          outcome: CreditPurchaseOutcome.pending,
        ),
      );
      expect(
        (await purchase).outcome,
        CreditPurchaseOutcome.pending,
      );
      await switchUser;

      expect(gateway.loginIds, const [secondId]);
      expect(gateway.appUserId, secondId);
      expect(await pendingStore.read(firstId), isNotNull);
    });

    test('should persist the submitted transaction hash in the durable guard',
        () async {
      const opaqueId = '12345678-1234-1234-1234-1234567890ab';
      const transactionRef =
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
      final pendingStore = _FakePendingPurchaseStore();
      final gateway = _FakeRevenueCatGateway()
        ..purchaseResult = const CreditPurchaseResult(
          outcome: CreditPurchaseOutcome.submitted,
          transactionRef: transactionRef,
        );
      final repository = CreditPurchaseRepository(
        identityDataSource: _FakeIdentityDataSource(_bootstrap(opaqueId)),
        pendingPurchaseStore: pendingStore,
        gateway: gateway,
        apiKeyProvider: const _FakeApiKeyProvider(),
      );
      await repository.bindAuthenticatedUser();

      final result = await repository.purchase(
        packageIdentifier: 'credits_100',
        baselineBalance: 100,
        expectedCredits: 100,
      );

      expect(result.transactionRef, transactionRef);
      expect(
        (await pendingStore.read(opaqueId))?.transactionRef,
        transactionRef,
      );
    });

    test(
        'should use an exact transaction hash and never fall back when present',
        () async {
      const opaqueId = '12345678-1234-1234-1234-1234567890ab';
      const expectedRef =
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
      const otherRef =
          'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';
      final identity = _FakeIdentityDataSource(_bootstrap(opaqueId));
      final repository = CreditPurchaseRepository(
        identityDataSource: identity,
        pendingPurchaseStore: _FakePendingPurchaseStore(),
        gateway: _FakeRevenueCatGateway(),
        apiKeyProvider: const _FakeApiKeyProvider(),
      );
      await repository.bindAuthenticatedUser();
      final startedAt = DateTime.parse('2026-07-24T08:00:00Z');
      final pendingPurchase = CreditPendingPurchase(
        appUserId: opaqueId,
        packageIdentifier: 'credits_100',
        baselineBalance: 100,
        expectedCredits: 100,
        startedAtEpochMilliseconds: startedAt.millisecondsSinceEpoch,
        transactionRef: expectedRef,
      );
      identity.serverStatus = CreditPurchaseServerStatus(
        hasPendingFulfillment: false,
        purchases: [
          _purchaseRecord(
            purchaseId: 1,
            purchasedAt: startedAt.add(const Duration(seconds: 1)),
            transactionRef: otherRef,
          ),
        ],
      );

      expect(
        await repository.getRecoveryStatus(pendingPurchase),
        const CreditPurchaseRecoveryStatus(
          CreditPurchaseRecoveryState.unresolved,
        ),
      );

      identity.serverStatus = CreditPurchaseServerStatus(
        hasPendingFulfillment: false,
        purchases: [
          _purchaseRecord(
            purchaseId: 2,
            purchasedAt: startedAt.add(const Duration(seconds: 2)),
            transactionRef: expectedRef,
          ),
        ],
      );
      expect(
        await repository.getRecoveryStatus(pendingPurchase),
        const CreditPurchaseRecoveryStatus(
          CreditPurchaseRecoveryState.granted,
        ),
      );
    });

    test('should conservatively match a legacy guard by product and start time',
        () async {
      const opaqueId = '12345678-1234-1234-1234-1234567890ab';
      final identity = _FakeIdentityDataSource(_bootstrap(opaqueId));
      final repository = CreditPurchaseRepository(
        identityDataSource: identity,
        pendingPurchaseStore: _FakePendingPurchaseStore(),
        gateway: _FakeRevenueCatGateway(),
        apiKeyProvider: const _FakeApiKeyProvider(),
      );
      await repository.bindAuthenticatedUser();
      final startedAt = DateTime.parse('2026-07-24T08:00:00Z');
      final pendingPurchase = CreditPendingPurchase(
        appUserId: opaqueId,
        packageIdentifier: 'credits_100',
        baselineBalance: 100,
        expectedCredits: 100,
        startedAtEpochMilliseconds: startedAt.millisecondsSinceEpoch,
      );
      identity.serverStatus = CreditPurchaseServerStatus(
        hasPendingFulfillment: false,
        purchases: [
          _purchaseRecord(
            purchaseId: 3,
            purchasedAt: startedAt.add(const Duration(seconds: 1)),
          ),
        ],
      );

      expect(
        await repository.getRecoveryStatus(pendingPurchase),
        const CreditPurchaseRecoveryStatus(
          CreditPurchaseRecoveryState.granted,
        ),
      );
    });

    test('should never clear another account guard after an account switch',
        () async {
      const firstId = '12345678-1234-1234-1234-1234567890ab';
      const secondId = '87654321-4321-4321-4321-ba0987654321';
      const firstPending = CreditPendingPurchase(
        appUserId: firstId,
        packageIdentifier: 'credits_100',
        baselineBalance: 100,
        expectedCredits: 100,
        startedAtEpochMilliseconds: 1,
      );
      const secondPending = CreditPendingPurchase(
        appUserId: secondId,
        packageIdentifier: 'credits_500',
        baselineBalance: 900,
        expectedCredits: 500,
        startedAtEpochMilliseconds: 2,
      );
      final identity = _FakeIdentityDataSource(_bootstrap(firstId));
      final pendingStore = _FakePendingPurchaseStore()
        ..records[firstId] = firstPending
        ..records[secondId] = secondPending;
      final repository = CreditPurchaseRepository(
        identityDataSource: identity,
        pendingPurchaseStore: pendingStore,
        gateway: _FakeRevenueCatGateway(),
        apiKeyProvider: const _FakeApiKeyProvider(),
      );
      await repository.bindAuthenticatedUser();
      identity.bootstrap = _bootstrap(secondId);
      await repository.bindAuthenticatedUser();

      await expectLater(
        Future<void>.sync(
          () => repository.clearPendingPurchase(firstPending),
        ),
        throwsA(isA<CreditPurchaseNotBoundException>()),
      );

      expect(await pendingStore.read(firstId), firstPending);
      expect(await pendingStore.read(secondId), secondPending);
    });

    test('should retain the guard after every thrown native purchase result',
        () async {
      const opaqueId = '12345678-1234-1234-1234-1234567890ab';
      final identity = _FakeIdentityDataSource(_bootstrap(opaqueId));
      final pendingStore = _FakePendingPurchaseStore();
      final gateway = _FakeRevenueCatGateway()
        ..purchaseError =
            const CreditPurchaseUnavailableException('unknown native result');
      final repository = CreditPurchaseRepository(
        identityDataSource: identity,
        pendingPurchaseStore: pendingStore,
        gateway: gateway,
        apiKeyProvider: const _FakeApiKeyProvider(),
      );
      await repository.bindAuthenticatedUser();

      await expectLater(
        repository.purchase(
          packageIdentifier: 'credits_100',
          baselineBalance: 100,
          expectedCredits: 100,
        ),
        throwsA(isA<CreditPurchaseUnavailableException>()),
      );

      expect(await pendingStore.read(opaqueId), isNotNull);
      await expectLater(
        repository.purchase(
          packageIdentifier: 'credits_100',
          baselineBalance: 100,
          expectedCredits: 100,
        ),
        throwsA(isA<CreditPurchaseUnavailableException>()),
      );
      expect(gateway.purchaseCalls, 1);
    });
  });
}
