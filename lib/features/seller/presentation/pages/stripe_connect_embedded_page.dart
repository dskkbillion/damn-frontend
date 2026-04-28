import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Stripe Connect 嵌入式 Onboarding 页面
/// 使用 Connect.js Embedded Components 在 App 内完成 Onboarding
class StripeConnectEmbeddedPage extends StatefulWidget {
  final String clientSecret;
  const StripeConnectEmbeddedPage({super.key, required this.clientSecret});

  @override
  State<StripeConnectEmbeddedPage> createState() =>
      _StripeConnectEmbeddedPageState();
}

class _StripeConnectEmbeddedPageState extends State<StripeConnectEmbeddedPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isHandlingResult = false;
  late final String _backendHost;

  /// 嵌入式 Onboarding 域名白名单
  bool _isAllowedDomain(String host) {
    return host.endsWith('.stripe.com') ||
        host == 'stripe.com' ||
        host.endsWith('.duoshaokankan.com') ||
        host == 'duoshaokankan.com' ||
        // 后端域名（动态，支持 staging/prod）
        host == _backendHost ||
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
    final backendBaseUrl = dotenv.env['BACKEND_BASE_URL'] ?? '';
    _backendHost = Uri.tryParse(backendBaseUrl)?.host ?? '';
    final url = '$backendBaseUrl/api/stripe-connect/onboarding-page'
        '?secret=${Uri.encodeComponent(widget.clientSecret)}';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      // 注册 JavaScriptChannel 接收 onboarding 回调
      ..addJavaScriptChannel(
        'FlutterBridge',
        onMessageReceived: (JavaScriptMessage message) {
          AppLogger.d('[EmbeddedOnboarding] JS message: ${message.message}');
          if (message.message == 'onboarding_exited') {
            _handleExit();
          } else if (message.message.startsWith('error:')) {
            AppLogger.d('[EmbeddedOnboarding] JS error: ${message.message}');
            // 不自动关闭，HTML 中有重试按钮
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) setState(() => _isLoading = false);
          },
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (WebResourceError error) {
            AppLogger.d(
                '[EmbeddedOnboarding] 加载错误: ${error.description}');
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.prevent;

            // 1. localhost 允许任意 scheme（本地调试）
            if (uri.host == 'localhost') {
              return NavigationDecision.navigate;
            }
            // 2. 非 HTTPS 一律阻止
            if (uri.scheme != 'https') {
              AppLogger.d(
                  '[EmbeddedOnboarding] 阻止非 HTTPS: ${uri.scheme}://${uri.host}');
              return NavigationDecision.prevent;
            }
            // 3. 仅允许白名单域名
            if (!_isAllowedDomain(uri.host)) {
              AppLogger.d(
                  '[EmbeddedOnboarding] 阻止非白名单: ${uri.host}');
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  /// 用户退出 onboarding（可能完成也可能中途退出）
  /// 统一返回 true 触发状态刷新，由服务端判断实际进度
  void _handleExit() {
    if (!mounted || _isHandlingResult) return;
    _isHandlingResult = true;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('账户认证'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
