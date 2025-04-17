import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dskk_flutter_refactor/app/navigation/app_router.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_theme.dart';

// Remove direct import of MainShellPage, navigation is handled by router
// import 'package:dskk_flutter_refactor/app/widgets/main_shell_page.dart'; 

// Import the GoRouter provider
// import 'package:dskk_flutter_refactor/app/navigation/app_router.dart';

// This is the root widget of the application.
// It extends ConsumerWidget to enable Riverpod integration.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the GoRouter instance from the provider
    final goRouter = ref.watch(goRouterProvider); 

    // Use MaterialApp.router and provide the router configuration
    return MaterialApp.router(
      routerConfig: goRouter, 

      title: 'DSKK Flutter Refactor',

      // Use the centralized light theme
      theme: AppTheme.lightTheme,

      // Optionally configure dark theme and theme mode
      // darkTheme: AppTheme.darkTheme,
      // themeMode: ThemeMode.system, // Or ThemeMode.light, ThemeMode.dark

      // Remove the home property, router handles the initial route
      // home: const MainShellPage(), 
    );
  }
} 