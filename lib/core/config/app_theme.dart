import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue, // Or your primary color
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.grey[100], // Light background
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.blue, // Example AppBar color
        foregroundColor: Colors.white, // AppBar text/icon color
      ),
      colorScheme: const ColorScheme.light(
        primary: Colors.blue,
        secondary: Colors.blueAccent,
        // You can define more colors here
      ),
      // Define other theme properties like text themes, button themes, etc.
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black54),
        // Define other text styles
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: Colors.blue, // Keep the same primary or choose a dark variant
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.grey[900], // Dark background
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.grey[850], // Example dark AppBar color
        foregroundColor: Colors.white, // AppBar text/icon color
      ),
      colorScheme: ColorScheme.dark(
        primary: Colors.blue[300]!, // Lighter primary for dark theme
        secondary: Colors.blueAccent[100]!,
        // Define more colors here
      ),
      // Define other theme properties for dark mode
      textTheme: const TextTheme(
         bodyLarge: TextStyle(color: Colors.white70),
         bodyMedium: TextStyle(color: Colors.white60),
         // Define other text styles
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
} 