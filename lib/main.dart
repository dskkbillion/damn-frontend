import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import ProviderScope
import 'package:dskk_flutter_refactor/app/di/injection_container.dart'; // Import DI config
// import 'package:dskk_flutter_refactor/app/view/app.dart'; // Import your App widget -> Incorrect path
import 'package:dskk_flutter_refactor/app/app.dart'; // Corrected import path for the root App widget
// Import necessary for accessing the repository interface
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  String? backendBaseUrl;
  try {
     await dotenv.load(fileName: ".env");
     backendBaseUrl = dotenv.env['BACKEND_BASE_URL']; // Get URL after loading
     print('.env file loaded successfully. Base URL: $backendBaseUrl');
     if (backendBaseUrl == null || backendBaseUrl.isEmpty) {
       print('WARNING: BACKEND_BASE_URL is empty or not found in .env file.');
       // Handle missing URL if necessary, e.g., use a default or throw
       backendBaseUrl = 'https://app.duoshaokankan.com/prod-api'; // Fallback
       print('Using fallback Base URL: $backendBaseUrl');
     }
  } catch (e) {
    print('Error loading .env file: $e. Ensure it exists in the project root.');
    // Decide if you want to proceed with default/placeholder values or exit
    backendBaseUrl = 'https://app.duoshaokankan.com/prod-api'; // Fallback on error
    print('Using fallback Base URL due to error: $backendBaseUrl');
  }

  // Configure dependencies using GetIt + injectable, passing the Base URL
  await configureDependencies(backendBaseUrl: backendBaseUrl!); // Pass the non-null URL
  print('Dependency injection configured.');

  // --- TEMPORARY DEBUGGING CODE: Force logout on startup ---
  // This ensures you always start from the login page during development.
  // REMOVE THIS before final merge or release!
  try {
    final authRepository = getIt<IAuthRepository>();
    print('DEBUG: Forcing logout on startup...');
    await authRepository.logout();
    print('DEBUG: Logout completed.');
  } catch (e) {
    print('DEBUG: Error during forced logout: $e');
  }
  // --- END TEMPORARY DEBUGGING CODE ---

  // Run the application, wrapped in ProviderScope
  runApp(
    ProviderScope( // Wrap the root widget with ProviderScope
      child: const MyApp(), // Use MyApp as the root widget name
    ),
  );
}
