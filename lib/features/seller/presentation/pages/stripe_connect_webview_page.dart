import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Stripe Connect Onboarding WebView 结果
enum ConnectWebViewResult {
  success,
  refresh,
  cancelled,
}

/// Stripe Connect Onboarding WebView 页面
/// 用于在应用内完成 Stripe Connect Express 账户认证
class StripeConnectWebViewPage extends StatefulWidget {
  final String onboardingUrl;

  const StripeConnectWebViewPage({
    super.key,
    required this.onboardingUrl,
  });

  @override
  State<StripeConnectWebViewPage> createState() => _StripeConnectWebViewPageState();
}

class _StripeConnectWebViewPageState extends State<StripeConnectWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isHandlingResult = false;

  /// Onboarding 域名白名单
  bool _isAllowedDomain(String host) {
    return host.endsWith('.stripe.com') ||
        host == 'stripe.com' ||
        host.endsWith('.stripe.network') ||
        host == 'stripe.network' ||
        host.endsWith('.stripecdn.com') ||
        host == 'stripecdn.com' ||
        host.endsWith('.duoshaokankan.com') ||
        host == 'duoshaokankan.com' ||
        // Stripe 人机验证
        host.endsWith('.hcaptcha.com') ||
        host == 'hcaptcha.com' ||
        // Stripe KYC 第三方验证服务
        host.endsWith('.veriff.com') ||
        host.endsWith('.jumio.com') ||
        host.endsWith('.onfido.com');
  }

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() => _isLoading = false);
            }
          },
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            _checkUrl(url);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            _checkUrl(url);
          },
          onWebResourceError: (WebResourceError error) {
            AppLogger.d('[StripeConnectWebView] 加载错误: ${error.description}');
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            final uri = Uri.tryParse(request.url);
            // HTTPS-only 策略
            if (uri != null && uri.scheme != 'https') {
              AppLogger.d('[StripeConnectWebView] 已阻止非 HTTPS 请求: ${uri.scheme}');
              return NavigationDecision.prevent;
            }
            if (uri != null && !_isAllowedDomain(uri.host)) {
              AppLogger.d('[StripeConnectWebView] 已阻止非白名单域名: ${uri.host}');
              return NavigationDecision.prevent;
            }
            _checkUrl(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.onboardingUrl));
  }

  void _checkUrl(String url) {
    // 检查 onboarding return URL（成功完成）
    if (url.contains('stripe/connect/return')) {
      AppLogger.d('[StripeConnectWebView] 检测到 Onboarding 完成回调');
      _handleResult(ConnectWebViewResult.success);
      return;
    }
    // 检查 refresh URL（链接过期，需要重新获取）
    if (url.contains('stripe/connect/refresh')) {
      AppLogger.d('[StripeConnectWebView] 检测到链接刷新回调');
      _handleResult(ConnectWebViewResult.refresh);
      return;
    }
  }

  void _handleResult(ConnectWebViewResult result) {
    if (!mounted || _isHandlingResult) return;
    _isHandlingResult = true;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      Navigator.of(context).pop(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('账户认证'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(ConnectWebViewResult.cancelled),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
