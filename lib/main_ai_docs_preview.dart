import 'package:dskk_flutter_refactor/features/ai_docs/presentation/bloc/ai_chat/ai_chat_bloc.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/pages/chat_page.dart';
import 'package:dskk_flutter_refactor/app/di/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io'; // Import dart:io for FileSystemException
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'features/ai_docs/presentation/routes/ai_docs_routes.dart';
// import 'core/config/theme/app_theme.dart'; // Remove import for non-existent file

// No need to import injectable here if not using Environment constants directly
// import 'package:injectable/injectable.dart'; 

// GetIt instance
final getIt = GetIt.instance;

// Temporary entry point for previewing the AI Docs Chat module.
Future<void> main() async {
  // 1. Ensure WidgetsBinding initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load .env file BEFORE configuring dependencies
  String? backendBaseUrl; // Declare variable to hold the URL
  try {
    // Try explicitly using the default filename again
    await dotenv.load(fileName: ".env"); 
    print(".env file loaded successfully.");
    backendBaseUrl = dotenv.env['BACKEND_BASE_URL']; // Assign loaded value
    print("MODEL_BASE_URL from env: ${dotenv.env['MODEL_BASE_URL']}");
    print("BACKEND_BASE_URL from env: $backendBaseUrl");

    // Add fallback logic
    if (backendBaseUrl == null || backendBaseUrl.isEmpty) {
      print('WARNING: BACKEND_BASE_URL is empty or not found in .env file.');
      backendBaseUrl = 'https://app.duoshaokankan.com/prod-api'; // Fallback
      print('Using fallback Base URL: $backendBaseUrl');
    }

  } catch (e) {
      print("Error loading .env file: $e");
      // Add more details about the error type
      print("Error type: ${e.runtimeType}");
      if (e is FileSystemException) {
        print("FileSystemException Path: ${e.path}");
        print("FileSystemException OS Error: ${e.osError}");
      }
      // Apply fallback on error too
      backendBaseUrl = 'https://app.duoshaokankan.com/prod-api'; // Fallback
      print('Using fallback Base URL due to error: $backendBaseUrl');
  }

  // 3. Configure dependencies AFTER loading .env
  // Pass the required backendBaseUrl
  await di.configureDependencies(backendBaseUrl: backendBaseUrl!); 
  print("Dependencies configured.");

  // 4. Run the app
  runApp(const AiDocsPreviewApp());
  print("App running.");
}

// --- GoRouter instance specifically for this preview ---
final GoRouter _previewRouter = GoRouter(
  initialLocation: '/ai_chat', // Start directly at the AI chat page
  debugLogDiagnostics: true,
  routes: [
    // Only include routes from the AiDocs module for this preview
    ...AiDocsRoutes.routes,
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Preview Error')),
    body: Center(child: Text('Error loading preview route: ${state.error}')),
  ),
);
// ----------------------------------------------------

class AiDocsPreviewApp extends StatelessWidget {
  const AiDocsPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use MaterialApp.router with the preview-specific router
    return MaterialApp.router(
      title: 'AI Docs Preview',
      // Use default light theme as AppTheme is not found in this branch
      theme: ThemeData.light(useMaterial3: true),
      routerConfig: _previewRouter, // Use the preview router
    );
  }
}
