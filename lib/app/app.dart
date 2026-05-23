import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:dskk_flutter_refactor/core/currency/presentation/cubit/currency_cubit.dart';
import 'package:dskk_flutter_refactor/core/currency/domain/entities/currency.dart';
import 'package:dskk_flutter_refactor/app/navigation/app_router.dart'; // Import the provider
import 'package:dskk_flutter_refactor/core/config/theme/app_theme.dart';
import 'package:dskk_flutter_refactor/core/widgets/global_message_notification.dart'; // 导入全局消息通知组件
import 'package:dskk_flutter_refactor/core/widgets/mode_flip_transition_overlay.dart'; // 导入翻转动画覆盖层
import 'package:dskk_flutter_refactor/core/config/locale_provider.dart'; // 导入语言提供者
import 'package:dskk_flutter_refactor/generated/app_localizations.dart'; // 导入生成的国际化类

// Remove direct import of MainShellPage, navigation is handled by router
// import 'package:dskk_flutter_refactor/app/widgets/main_shell_page.dart';

// Import the GoRouter provider - not needed anymore
// import 'package:dskk_flutter_refactor/app/navigation/app_router.dart';

// This is the root widget of the application.
// Change back to ConsumerWidget to access the provider
class MyApp extends ConsumerWidget { // Changed to ConsumerWidget
  const MyApp({super.key});

  @override
  // Add WidgetRef ref back to build method
  Widget build(BuildContext context, WidgetRef ref) { 
    // Get the GoRouter instance from the provider
    final router = ref.watch(goRouterProvider); // Use ref.watch
    // 获取语言设置
    final locale = ref.watch(localeProvider);

    // MaterialApp 创建 Overlay，所以 GlobalMessageNotification 需要在其内部
    return MaterialApp.router(
      // Use the router instance obtained from the provider
      routerConfig: router,

      title: 'DSKK Flutter Refactor',

      // Use the centralized light theme
      theme: AppTheme.lightTheme,

      // 添加国际化配置
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh'), // 中文
        Locale('en'), // 英文
        Locale('ja'), // 日本語
        Locale('ko'), // 한국어
        Locale('vi'), // Tiếng Việt
      ],
      locale: locale, // 用户设置的语言
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (locale != null) {
          return locale; // 如果用户设置了语言，使用用户设置
        }
        // 否则尝试使用设备语言，如不支持则使用中文
        if (deviceLocale != null) {
          for (final supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == deviceLocale.languageCode) {
              return deviceLocale;
            }
          }
        }
        return const Locale('zh'); // 默认使用中文
      },

      // 使用 builder 将 GlobalMessageNotification 和 ModeFlipTransitionOverlay 放在 MaterialApp 内部
      // 这样它们可以访问 Overlay 和路由信息
      builder: (context, child) {
        // #348 根注入 CurrencyCubit，全 app 共享一份汇率状态。
        // 按用户 locale 推断默认副币种，启动即触发双显折算。
        return BlocProvider<CurrencyCubit>(
          create: (_) {
            final cubit = GetIt.I<CurrencyCubit>();
            final secondary = _secondaryCurrencyForLocale(locale);
            if (secondary != null) {
              cubit.selectCurrency(secondary);
            }
            return cubit;
          },
          child: GlobalMessageNotification(
            child: ModeFlipTransitionOverlay(
              child: child!,
            ),
          ),
        );
      },
    );
  }

  /// #348 按 locale 推断双显副币种。
  /// 存储恒 USD；英文用户主用 USD，无需双显（返回 null → PriceDisplayWidget 仅主行）。
  Currency? _secondaryCurrencyForLocale(Locale? locale) {
    switch (locale?.languageCode) {
      case 'vi':
        return Currency.vnd;
      case 'zh':
        return Currency.cny;
      case 'ja':
        return Currency.jpy;
      case 'ko':
        return Currency.krw;
      case 'en':
      default:
        return null;
    }
  }
}