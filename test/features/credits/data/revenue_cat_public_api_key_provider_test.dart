import 'package:dskk_flutter_refactor/features/credits/data/revenue_cat_public_api_key_provider.dart';
import 'package:dskk_flutter_refactor/features/credits/domain/entities/credit_purchase_bootstrap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const provider = RevenueCatPublicApiKeyProvider();

  test('selects the App Store catalog on iOS', () {
    final previous = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = previous);

    expect(provider.currentStore, CreditStore.appStore);
  });

  test('selects the Play Store catalog on Android', () {
    final previous = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = previous);

    expect(provider.currentStore, CreditStore.playStore);
  });

  test('does not expose a mobile store catalog on desktop platforms', () {
    final previous = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = previous);

    expect(provider.currentStore, isNull);
  });
}
