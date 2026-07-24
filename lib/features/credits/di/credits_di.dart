import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/domain/repositories/i_auth_repository.dart';
import '../../profile/domain/repositories/i_wallet_repository.dart';
import '../application/revenue_cat_auth_coordinator.dart';
import '../data/credit_purchase_identity_data_source.dart';
import '../data/credit_pending_purchase_store.dart';
import '../data/credit_purchase_repository.dart';
import '../data/revenue_cat_gateway.dart';
import '../data/revenue_cat_public_api_key_provider.dart';
import '../domain/repositories/i_credit_purchase_repository.dart';
import '../presentation/cubit/credits_purchase_cubit.dart';

class CreditsDI {
  const CreditsDI._();

  static Future<void> init(GetIt locator) async {
    if (!locator.isRegistered<RevenueCatGateway>()) {
      locator.registerLazySingleton<RevenueCatGateway>(
        RevenueCatGatewayImpl.new,
      );
    }
    if (!locator.isRegistered<RevenueCatPublicApiKeyProvider>()) {
      locator.registerLazySingleton<RevenueCatPublicApiKeyProvider>(
        RevenueCatPublicApiKeyProvider.new,
      );
    }
    if (!locator.isRegistered<CreditPurchaseIdentityDataSource>()) {
      locator.registerLazySingleton<CreditPurchaseIdentityDataSource>(
        () => CreditPurchaseIdentityDataSourceImpl(locator<Dio>()),
      );
    }
    if (!locator.isRegistered<CreditPendingPurchaseStore>()) {
      locator.registerLazySingleton<CreditPendingPurchaseStore>(
        () => SharedPreferencesCreditPendingPurchaseStore(
          locator<SharedPreferences>(),
        ),
      );
    }
    if (!locator.isRegistered<ICreditPurchaseRepository>()) {
      locator.registerLazySingleton<ICreditPurchaseRepository>(
        () => CreditPurchaseRepository(
          identityDataSource: locator<CreditPurchaseIdentityDataSource>(),
          pendingPurchaseStore: locator<CreditPendingPurchaseStore>(),
          gateway: locator<RevenueCatGateway>(),
          apiKeyProvider: locator<RevenueCatPublicApiKeyProvider>(),
        ),
      );
    }
    if (!locator.isRegistered<RevenueCatAuthCoordinator>()) {
      locator.registerLazySingleton<RevenueCatAuthCoordinator>(
        () => RevenueCatAuthCoordinator(
          authRepository: locator<IAuthRepository>(),
          purchaseRepository: locator<ICreditPurchaseRepository>(),
        ),
      );
    }
    if (!locator.isRegistered<CreditsPurchaseCubit>()) {
      locator.registerFactory<CreditsPurchaseCubit>(
        () => CreditsPurchaseCubit(
          purchaseRepository: locator<ICreditPurchaseRepository>(),
          walletRepository: locator<IWalletRepository>(),
        ),
      );
    }

    locator<RevenueCatAuthCoordinator>().start();
  }
}
