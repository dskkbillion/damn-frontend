import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Stripe支付WebView页面
/// 在应用内打开Stripe支付链接，监听URL变化以拦截支付结果
class StripePaymentWebViewPage extends StatefulWidget {
  final String paymentUrl;
  final String orderId;
  final String successUrlPattern;
  final String? cancelUrlPattern;
  final String? failureUrlPattern;

  const StripePaymentWebViewPage({
    super.key,
    required this.paymentUrl,
    required this.orderId,
    this.successUrlPattern = 'stripe/callback/success',
    this.cancelUrlPattern = 'stripe/callback/cancel',
    this.failureUrlPattern = 'stripe/callback/failure',
  });

  @override
  State<StripePaymentWebViewPage> createState() => _StripePaymentWebViewPageState();
}

class _StripePaymentWebViewPageState extends State<StripePaymentWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _currentUrl;
  bool _isHandlingResult = false; // 添加标志位防止重复处理

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
              setState(() {
                _isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {
            AppLogger.d('[StripePaymentWebView] 页面开始加载: ${_sanitizeUrl(url)}');
            setState(() {
              _isLoading = true;
              _currentUrl = url;
            });
            _checkUrl(url);
          },
          onPageFinished: (String url) {
            AppLogger.d('[StripePaymentWebView] 页面加载完成: ${_sanitizeUrl(url)}');
            setState(() {
              _isLoading = false;
              _currentUrl = url;
            });
            _checkUrl(url);
          },
          onWebResourceError: (WebResourceError error) {
            AppLogger.d('[StripePaymentWebView] 加载错误: ${error.description}');
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            final uri = Uri.tryParse(request.url);
            if (uri != null && !_isAllowedDomain(uri.host)) {
              AppLogger.d('[StripePaymentWebView] 已阻止非白名单域名: ${uri.host}');
              return NavigationDecision.prevent;
            }
            AppLogger.d('[StripePaymentWebView] 导航请求: ${uri?.host ?? "unknown"}');
            _checkUrl(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  /// 检查域名是否在白名单内
  bool _isAllowedDomain(String host) {
    return host.endsWith('.stripe.com') ||
        host == 'stripe.com' ||
        host.endsWith('.duoshaokankan.com') ||
        host == 'duoshaokankan.com';
  }

  /// 从URL中提取域名用于安全日志
  String _sanitizeUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null ? '${uri.scheme}://${uri.host}/***' : '[invalid-url]';
  }

  /// 检查URL是否匹配成功/取消/失败模式
  void _checkUrl(String url) {

    // 检查是否为支付成功URL
    if (url.contains(widget.successUrlPattern)) {
      AppLogger.d('[StripePaymentWebView] 检测到支付成功URL');
      _handlePaymentResult(PaymentWebViewResult.success, url);
      return;
    }

    // 检查是否为支付取消URL
    if (widget.cancelUrlPattern != null && url.contains(widget.cancelUrlPattern!)) {
      AppLogger.d('[StripePaymentWebView] 检测到支付取消URL');
      _handlePaymentResult(PaymentWebViewResult.cancelled, url);
      return;
    }

    // 检查是否为支付失败URL
    if (widget.failureUrlPattern != null && url.contains(widget.failureUrlPattern!)) {
      AppLogger.d('[StripePaymentWebView] 检测到支付失败URL');
      _handlePaymentResult(PaymentWebViewResult.failed, url);
      return;
    }
  }

  /// 处理支付结果
  void _handlePaymentResult(PaymentWebViewResult result, String url) {
    // 避免重复处理
    if (!mounted || _isHandlingResult) return;

    // 设置标志位，防止重复处理
    _isHandlingResult = true;
    AppLogger.d('[StripePaymentWebView] 开始处理支付结果: ${result.name}');

    // 延迟一下确保页面完全加载
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      AppLogger.d('[StripePaymentWebView] 关闭WebView并返回结果');
      Navigator.of(context).pop({
        'result': result,
        'orderId': widget.orderId,
        'url': url,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('支付'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop({
              'result': PaymentWebViewResult.cancelled,
              'orderId': widget.orderId,
              'url': _currentUrl,
            });
          },
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
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

/// 支付WebView结果枚举
enum PaymentWebViewResult {
  success,
  failed,
  cancelled,
}
