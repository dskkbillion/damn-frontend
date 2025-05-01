import 'package:flutter/material.dart';

/// Centralized application theme configuration.
class AppTheme {
  /// Defines the light theme for the application.
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFb66d0e), // Our primary seed color
      // Optionally, define specific colors if 'fromSeed' needs refinement:
      // primary: const Color(0xFFb66d0e),
      // secondary: Colors.someOtherColor, // Example
      // background: Colors.white,
      // error: Colors.red,
      // surface: Colors.grey[100],
    ),
    useMaterial3: true,

    // TODO: Define other theme aspects like text themes, button themes, etc.
    // textTheme: ...,
    // elevatedButtonTheme: ...,
    // outlinedButtonTheme: ...,
    // textButtonTheme: ...,
    // appBarTheme: ...,
    // tabBarTheme: ...,
  );

  /// Defines the dark theme for the application (placeholder).
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFb66d0e), // Use the same seed for consistency
      brightness: Brightness.dark, // Important hint for fromSeed in dark mode
    ),
    useMaterial3: true,
    // TODO: Define dark theme specific overrides if needed
  );

  // Private constructor to prevent instantiation
  AppTheme._();
} 