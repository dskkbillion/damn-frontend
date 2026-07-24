import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/credit_purchase_exception.dart';
import '../domain/entities/credit_pending_purchase.dart';

abstract class CreditPendingPurchaseStore {
  Future<CreditPendingPurchase?> read(String appUserId);

  Future<void> write(CreditPendingPurchase pendingPurchase);

  Future<void> clear(String appUserId);
}

class SharedPreferencesCreditPendingPurchaseStore
    implements CreditPendingPurchaseStore {
  SharedPreferencesCreditPendingPurchaseStore(this._preferences);

  static const String _keyPrefix = 'credits_iap_pending_v1_';
  static final RegExp _transactionRefPattern = RegExp(r'^[0-9a-f]{64}$');

  final SharedPreferences _preferences;

  @override
  Future<CreditPendingPurchase?> read(String appUserId) async {
    final raw = _preferences.getString(_key(appUserId));
    if (raw == null) return null;

    try {
      final json = jsonDecode(raw);
      if (json is! Map ||
          json['appUserId'] != appUserId ||
          json['packageIdentifier'] is! String ||
          json['baselineBalance'] is! num ||
          json['expectedCredits'] is! int ||
          json['startedAtEpochMilliseconds'] is! int) {
        throw const FormatException();
      }
      final expectedCredits = json['expectedCredits'] as int;
      if (expectedCredits <= 0) throw const FormatException();
      final transactionRef = json['transactionRef'];
      if (transactionRef != null &&
          (transactionRef is! String ||
              !_transactionRefPattern.hasMatch(transactionRef))) {
        throw const FormatException();
      }

      return CreditPendingPurchase(
        appUserId: appUserId,
        packageIdentifier: json['packageIdentifier'] as String,
        baselineBalance: (json['baselineBalance'] as num).toDouble(),
        expectedCredits: expectedCredits,
        startedAtEpochMilliseconds: json['startedAtEpochMilliseconds'] as int,
        transactionRef: transactionRef as String?,
      );
    } catch (_) {
      // A corrupt guard must fail closed. Silently deleting it could expose the
      // user to a second charge after an ambiguous first purchase.
      throw const CreditPurchaseUnavailableException(
        '存在待核对的购买记录，请联系客服处理',
      );
    }
  }

  @override
  Future<void> write(CreditPendingPurchase pendingPurchase) async {
    final saved = await _preferences.setString(
      _key(pendingPurchase.appUserId),
      jsonEncode({
        'appUserId': pendingPurchase.appUserId,
        'packageIdentifier': pendingPurchase.packageIdentifier,
        'baselineBalance': pendingPurchase.baselineBalance,
        'expectedCredits': pendingPurchase.expectedCredits,
        'startedAtEpochMilliseconds':
            pendingPurchase.startedAtEpochMilliseconds,
        if (pendingPurchase.transactionRef != null)
          'transactionRef': pendingPurchase.transactionRef,
      }),
    );
    if (!saved) {
      throw const CreditPurchaseUnavailableException(
        '无法安全记录购买状态，请稍后重试',
      );
    }
  }

  @override
  Future<void> clear(String appUserId) async {
    final removed = await _preferences.remove(_key(appUserId));
    if (!removed && _preferences.containsKey(_key(appUserId))) {
      throw const CreditPurchaseUnavailableException(
        '无法清除已完成的购买状态，请稍后重试',
      );
    }
  }

  String _key(String appUserId) => '$_keyPrefix$appUserId';
}
