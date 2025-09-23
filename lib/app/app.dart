import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:dskk_flutter_refactor/app/navigation/app_router.dart'; // Import the provider
import 'package:dskk_flutter_refactor/core/config/theme/app_theme.dart';
import 'package:dskk_flutter_refactor/core/widgets/global_message_notification.dart'; // 导入全局消息通知组件
import 'package:dskk_flutter_refactor/core/widgets/mode_flip_transition_overlay.dart'; // 导入翻转动画覆盖层
import 'package:dskk_flutter_refactor/core/config/locale_provider.dart'; // 导入语言提供者
import 'package:dskk_flutter_refactor/generated/l10n.dart'; // 导入生成的国际化类

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

    // 使用GlobalMessageNotification和ModeFlipTransitionOverlay包装MaterialApp
    return GlobalMessageNotification(
      child: ModeFlipTransitionOverlay(
        child: MaterialApp.router(
          // Use the router instance obtained from the provider
          routerConfig: router, 

        title: 'DSKK Flutter Refactor',

        // Use the centralized light theme
        theme: AppTheme.lightTheme,

        // 添加国际化配置
        localizationsDelegates: const [
          S.delegate, // 使用S.delegate
          S.delegate, // 保留旧的S.delegate以兼容
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('zh'), // 中文
          Locale('en'), // 英文
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
        ),
      ),
    );
  }
} 