import '../entities/credit_store_product.dart';
import '../entities/credit_pending_purchase.dart';
import '../entities/credit_purchase_result.dart';
import '../entities/credit_purchase_server_status.dart';

abstract class ICreditPurchaseRepository {
  bool get isBound;

  /// Fetches the authenticated user's opaque RevenueCat identity from the
  /// backend and binds the SDK. This must never fall back to an anonymous ID.
  Future<void> bindAuthenticatedUser();

  /// Prevents further purchases locally.
  ///
  /// RevenueCat's `logOut` must not be called because it creates an anonymous
  /// App User ID. The SDK may remain configured with the previous custom ID
  /// until the next authenticated user is bound with `logIn`.
  Future<void> unbind();

  Future<List<CreditStoreProduct>> getProducts();

  Future<CreditPendingPurchase?> getPendingPurchase();

  /// Reads the authenticated backend's fulfillment truth and matches it to
  /// the local durable guard. This is read-only and never grants credits.
  Future<CreditPurchaseRecoveryStatus> getRecoveryStatus(
    CreditPendingPurchase? pendingPurchase,
  );

  /// Clears a durable guard only when the currently stored value still equals
  /// [expectedPendingPurchase].
  Future<void> clearPendingPurchase(
    CreditPendingPurchase expectedPendingPurchase,
  );

  Future<CreditPurchaseResult> purchase({
    required String packageIdentifier,
    required double baselineBalance,
    required int expectedCredits,
  });
}
