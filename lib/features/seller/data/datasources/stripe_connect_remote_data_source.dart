import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dskk_flutter_refactor/core/error/exceptions.dart';

/// Stripe Connect 账户状态
enum ConnectStatus {
  /// 未创建账户
  notCreated,
  /// 已创建但未完成 onboarding
  pendingOnboarding,
  /// onboarding 完成，等待 Stripe 审核
  pendingVerification,
  /// 审核通过，可收款+可提款
  active,
  /// 受限制（部分功能不可用）
  restricted,
}

/// Stripe Connect 账户状态模型
class ConnectAccountStatus {
  final ConnectStatus status;
  final bool chargesEnabled;
  final bool payoutsEnabled;
  final bool detailsSubmitted;
  final String? accountId;
  final String? errorMessage;

  const ConnectAccountStatus({
    required this.status,
    this.chargesEnabled = false,
    this.payoutsEnabled = false,
    this.detailsSubmitted = false,
    this.accountId,
    this.errorMessage,
  });

  factory ConnectAccountStatus.fromJson(Map<String, dynamic> json) {
    final chargesEnabled = json['chargesEnabled'] == true;
    final payoutsEnabled = json['payoutsEnabled'] == true;
    final detailsSubmitted = json['detailsSubmitted'] == true;

    ConnectStatus status;
    if (chargesEnabled && payoutsEnabled) {
      status = ConnectStatus.active;
    } else if (detailsSubmitted) {
      status = ConnectStatus.pendingVerification;
    } else if (json['accountId'] != null) {
      status = ConnectStatus.pendingOnboarding;
    } else {
      status = ConnectStatus.notCreated;
    }

    return ConnectAccountStatus(
      status: status,
      chargesEnabled: chargesEnabled,
      payoutsEnabled: payoutsEnabled,
      detailsSubmitted: detailsSubmitted,
      accountId: json['accountId']?.toString(),
    );
  }

  factory ConnectAccountStatus.notCreated() {
    return const ConnectAccountStatus(status: ConnectStatus.notCreated);
  }
}

/// Stripe Connect 远程数据源接口
abstract class IStripeConnectRemoteDataSource {
  /// 创建 Connect 账户
  Future<ConnectAccountStatus> createConnectAccount();

  /// 获取 Onboarding 链接
  Future<String> getOnboardingLink();

  /// 查询账户状态（可选主动刷新）
  Future<ConnectAccountStatus> getAccountStatus({bool refresh = false});

  /// 创建 Account Session（用于嵌入式 Onboarding）
  Future<String> createAccountSession();
}

/// Stripe Connect 远程数据源实现
class StripeConnectRemoteDataSourceImpl implements IStripeConnectRemoteDataSource {
  final Dio _dio;

  StripeConnectRemoteDataSourceImpl(this._dio);

  @override
  Future<ConnectAccountStatus> createConnectAccount() async {
    try {
      AppLogger.d('[StripeConnect] 创建 Connect 账户');
      final response = await _dio.post('/api/stripe-connect/create-account');
      _checkResponse(response);

      final data = response.data['data'];
      if (data == null || data is! Map<String, dynamic>) {
        throw ServerException(message: '创建账户返回数据格式异常');
      }

      return ConnectAccountStatus.fromJson(data);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<String> getOnboardingLink() async {
    try {
      AppLogger.d('[StripeConnect] 获取 Onboarding 链接');
      final response = await _dio.post('/api/stripe-connect/onboarding-link');
      _checkResponse(response);

      final data = response.data['data'];
      final url = data is Map ? data['url'] : data?.toString();
      if (url == null || url.toString().isEmpty) {
        throw ServerException(message: '未获取到 Onboarding 链接');
      }

      AppLogger.d('[StripeConnect] 成功获取 Onboarding 链接');
      return url.toString();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<ConnectAccountStatus> getAccountStatus({bool refresh = false}) async {
    try {
      AppLogger.d('[StripeConnect] 查询账户状态 (refresh=$refresh)');
      final response = await _dio.get(
        '/api/stripe-connect/account-status',
        queryParameters: refresh ? {'refresh': 'true'} : null,
      );
      _checkResponse(response);

      final data = response.data['data'];
      if (data == null || data is! Map<String, dynamic>) {
        // 无账户数据 → 未创建
        return ConnectAccountStatus.notCreated();
      }

      return ConnectAccountStatus.fromJson(data);
    } catch (e) {
      // 如果是 404 或特定错误码，表示尚未创建账户
      if (e is DioException && e.response?.statusCode == 404) {
        return ConnectAccountStatus.notCreated();
      }
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<String> createAccountSession() async {
    try {
      AppLogger.d('[StripeConnect] 创建 Account Session');
      final response = await _dio.post('/api/stripe-connect/account-session');
      _checkResponse(response);

      final data = response.data['data'];
      final clientSecret = data is Map ? data['clientSecret'] : null;
      if (clientSecret == null || clientSecret.toString().isEmpty) {
        throw ServerException(message: '未获取到 Account Session');
      }

      return clientSecret.toString();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  void _checkResponse(Response response) {
    final data = response.data;
    if (data == null) {
      throw ServerException(message: '服务器返回空数据');
    }
    final int? code = data['code'];
    if (code != 200) {
      final String message = data['msg'] ?? '未知错误';
      throw ServerException(message: message);
    }
  }

  void _handleError(dynamic error) {
    if (error is DioException) {
      final message = error.response?.data?['msg'] ?? error.message ?? '网络错误';
      throw ServerException(message: message);
    } else if (error is! ServerException) {
      throw ServerException(message: error.toString());
    }
  }
}
