import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod

// Import the root App Widget
import 'package:dskk_flutter_refactor/app/app.dart';
// Import the DI configuration function
import 'package:dskk_flutter_refactor/app/di/injection_container.dart';

Future<void> main() async { // Make main async
  // Ensure Flutter binding is initialized (required for async operations before runApp)
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  // Initialize dependencies
  await configureDependencies(); // Assuming configureDependencies handles environment based on some logic or default

  runApp(
    // Wrap the entire application in a ProviderScope to enable Riverpod
    const ProviderScope(
      child: MyApp(), // This now correctly refers to the MyApp in lib/app/app.dart
    ),
  );
}
