import 'package:dskk_flutter_refactor/features/ai_docs/presentation/bloc/ai_chat/ai_chat_bloc.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/pages/chat_page.dart';
import 'package:dskk_flutter_refactor/injection.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// No need to import injectable here if not using Environment constants directly
// import 'package:injectable/injectable.dart'; 

// Temporary entry point for previewing the AI Docs Chat module.
// Run this file directly to see the ChatPage with mock data.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Remove the environment parameter, injectable handles this during build
  await di.configureDependencies(); 
  runApp(const AiDocsPreviewApp());
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
