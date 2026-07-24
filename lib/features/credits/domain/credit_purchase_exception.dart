class CreditPurchaseException implements Exception {
  const CreditPurchaseException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CreditPurchaseNotBoundException extends CreditPurchaseException {
  const CreditPurchaseNotBoundException([
    super.message = '购买身份尚未就绪，请重新登录后重试',
  ]);
}

class CreditPurchaseUnavailableException extends CreditPurchaseException {
  const CreditPurchaseUnavailableException(super.message);
}

/// A purchase may already have reached the store before connectivity failed.
///
/// Callers must reconcile against the backend wallet instead of immediately
/// inviting the user to pay again.
class CreditPurchaseNetworkException extends CreditPurchaseException {
  const CreditPurchaseNetworkException([
    super.message = '网络连接中断，正在核对积分到账状态',
  ]);
}
