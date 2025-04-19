import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:dskk_flutter_refactor/app/navigation/app_router.dart'; // Import the provider
import 'package:dskk_flutter_refactor/core/config/theme/app_theme.dart';

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

    // Use MaterialApp.router and provide the router configuration
    return MaterialApp.router(
      // Use the router instance obtained from the provider
      routerConfig: router, 

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