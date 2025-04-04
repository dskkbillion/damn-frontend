import 'package:dskk_flutter_refactor/features/ai_docs/presentation/bloc/ai_chat/ai_chat_bloc.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/pages/chat_page.dart';
import 'package:dskk_flutter_refactor/app/di/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io'; // Import dart:io for FileSystemException
// No need to import injectable here if not using Environment constants directly
// import 'package:injectable/injectable.dart'; 

// Temporary entry point for previewing the AI Docs Chat module.
void main() async {
  // 1. Ensure WidgetsBinding initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load .env file BEFORE configuring dependencies
  try {
    // Try explicitly using the default filename again
    await dotenv.load(fileName: ".env"); 
    print(".env file loaded successfully.");
    print("MODEL_BASE_URL from env: ${dotenv.env['MODEL_BASE_URL']}");
    print("BACKEND_BASE_URL from env: ${dotenv.env['BACKEND_BASE_URL']}");
  } catch (e) {
      print("Error loading .env file: $e");
      // Add more details about the error type
      print("Error type: ${e.runtimeType}");
      if (e is FileSystemException) {
        print("FileSystemException Path: ${e.path}");
        print("FileSystemException OS Error: ${e.osError}");
      }
  }

  // 3. Configure dependencies AFTER loading .env
  await di.configureDependencies(); 
  print("Dependencies configured.");

  // 4. Run the app
  runApp(const AiDocsPreviewApp());
  print("App running.");
}

class AiDocsPreviewApp extends StatelessWidget {
  const AiDocsPreviewApp({super.key});

  // Restore the custom primary color
  static const Color primaryColor = Color(0xFFB66D0E);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Docs Preview',
      theme: ThemeData(
        // Restore using ColorScheme.fromSeed with the primary color
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        // Ensure Material 3 is enabled
        useMaterial3: true, 
        // Remove primarySwatch and visualDensity as they are less relevant with M3
        // primarySwatch: Colors.blue,
        // visualDensity: VisualDensity.adaptivePlatformDensity, 
      ),
      home: BlocProvider(
        create: (_) => di.getIt<AiChatBloc>()..add(LoadConversations()),
        child: const ChatPage(),
      ),
    );
  }
}
