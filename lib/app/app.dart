import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart'; // Keep commented out
import 'package:dskk_flutter_refactor/app/navigation/app_router.dart'; // Import the goRouter instance directly
import 'package:dskk_flutter_refactor/core/config/theme/app_theme.dart';

// Remove direct import of MainShellPage, navigation is handled by router
// import 'package:dskk_flutter_refactor/app/widgets/main_shell_page.dart';

// Import the GoRouter provider - not needed anymore
// import 'package:dskk_flutter_refactor/app/navigation/app_router.dart';

// This is the root widget of the application.
// Change from ConsumerWidget to StatelessWidget as Riverpod is not used here.
class MyApp extends StatelessWidget { // Changed to StatelessWidget
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) { // Removed WidgetRef ref
    // Get the GoRouter instance directly (it's now a top-level final variable)
    // final goRouter = ref.watch(goRouterProvider); // Remove ref.watch

    // Use MaterialApp.router and provide the router configuration
    return MaterialApp.router(
      // Use the directly imported goRouter instance
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