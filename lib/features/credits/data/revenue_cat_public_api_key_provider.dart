import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../domain/entities/credit_purchase_bootstrap.dart';

class RevenueCatPublicApiKeyProvider {
  const RevenueCatPublicApiKeyProvider();

  static const String _iosDartDefine = String.fromEnvironment(
    'REVENUECAT_IOS_PUBLIC_API_KEY',
  );
  static const String _androidDartDefine = String.fromEnvironment(
    'REVENUECAT_ANDROID_PUBLIC_API_KEY',
  );
  static const String _enabledDartDefine = String.fromEnvironment(
    'REVENUECAT_IAP_ENABLED',
  );
  static const String _offeringDartDefine = String.fromEnvironment(
    'REVENUECAT_OFFERING_ID',
  );

  bool get iapEnabled {
    final value = _read(
      dartDefineValue: _enabledDartDefine,
      envName: 'REVENUECAT_IAP_ENABLED',
    );
    return value?.toLowerCase() == 'true';
  }

  String? get offeringId => _read(
        dartDefineValue: _offeringDartDefine,
        envName: 'REVENUECAT_OFFERING_ID',
      );

  CreditStore? get currentStore {
    if (kIsWeb) return null;
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => CreditStore.appStore,
      TargetPlatform.android => CreditStore.playStore,
      _ => null,
    };
  }

  String? forCurrentPlatform() {
    return switch (currentStore) {
      CreditStore.appStore => _read(
          dartDefineValue: _iosDartDefine,
          envName: 'REVENUECAT_IOS_PUBLIC_API_KEY',
        ),
      CreditStore.playStore => _read(
          dartDefineValue: _androidDartDefine,
          envName: 'REVENUECAT_ANDROID_PUBLIC_API_KEY',
        ),
      _ => null,
    };
  }

  String? _read({
    required String dartDefineValue,
    required String envName,
  }) {
    final fromDefine = dartDefineValue.trim();
    if (fromDefine.isNotEmpty) return fromDefine;

    if (!dotenv.isInitialized) return null;
    final fromEnv = dotenv.maybeGet(envName)?.trim();
    return fromEnv == null || fromEnv.isEmpty ? null : fromEnv;
  }
}
