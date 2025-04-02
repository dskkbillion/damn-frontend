import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Remove direct import of MainShellPage, navigation is handled by router
// import 'package:dskk_flutter_refactor/app/widgets/main_shell_page.dart'; 

// Import the GoRouter provider
import 'package:dskk_flutter_refactor/app/navigation/app_router.dart';

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

      // Configure a basic light theme (Task 1.5.3)
      theme: ThemeData(
        brightness: Brightness.light, // Explicitly set light theme
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF5A623), // Example seed color (Orange-ish)
          // You might want to define specific colors later:
          // primary: const Color(0xFFF5A623),
          // secondary: ..., 
          // background: Colors.white, 
        ),
        useMaterial3: true,
        // TODO: Define text themes, button themes, etc. later in lib/core/theme
      ),
      // Consider adding darkTheme later if needed
      // darkTheme: ThemeData(...),
      // themeMode: ThemeMode.system, // Or ThemeMode.light, ThemeMode.dark

      // Remove the home property, router handles the initial route
      // home: const MainShellPage(), 
    );
  }
} 