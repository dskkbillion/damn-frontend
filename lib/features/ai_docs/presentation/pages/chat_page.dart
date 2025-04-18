import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:get_it/get_it.dart'; // Import GetIt
import 'package:collection/collection.dart'; // Import collection package

// Import Bloc and State/Event files
import '../bloc/ai_chat/ai_chat_bloc.dart';
import '../widgets/chat_message_widget.dart';

// Import domain interfaces and usecases (needed for manual creation)
import '../../domain/repositories/i_ai_chat_repository.dart';
import '../../domain/repositories/i_file_upload_repository.dart';
import '../../domain/usecases/load_history_usecase.dart';
import '../../domain/usecases/stream_chat_completion_usecase.dart';
import '../../domain/usecases/upload_file_usecase.dart';
import '../../domain/usecases/transcribe_audio_usecase.dart';
import '../../domain/usecases/get_related_services_usecase.dart';
import '../../domain/usecases/allocate_chat_resource_usecase.dart';

// Import data layer implementations (needed for manual creation)
import '../../data/repositories/ai_chat_repository_impl.dart';
import '../../data/repositories/file_upload_repository_impl.dart';
import '../../data/datasources/mocks/mock_ai_chat_remote_data_source.dart';
import '../../data/datasources/mocks/mock_file_upload_data_source.dart';
// TODO: Import actual datasources and HTTP client when moving away from mocks

// Import Custom Widgets
import '../widgets/chat_input_field.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/conversation_sidebar.dart';
import '../widgets/service_card.dart'; // Import the new card widget

// Get the GetIt instance
final getIt = GetIt.instance; 

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Dispatch the event to load conversations when the page initializes
    // Ensure BlocProvider is available above this widget in the tree
    WidgetsBinding.instance.addPostFrameCallback((_) { 
      if (mounted) { // Check if the state is still mounted
        context.read<AiChatBloc>().add(LoadConversations());
        print("[ChatPage] Dispatched LoadConversations event.");
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add a drawer for the conversation sidebar
      drawer: const Drawer(
         // Setting width might be necessary depending on content
         // width: MediaQuery.of(context).size.width * 0.75, 
         child: ConversationSidebar(),
      ),
      appBar: AppBar(
         // Add a leading button to open the drawer
         leading: Builder(
           builder: (context) => IconButton(
             icon: const Icon(Icons.menu),
             tooltip: 'Conversations',
             onPressed: () => Scaffold.of(context).openDrawer(),
           ),
         ),
        title: BlocBuilder<AiChatBloc, AiChatState>(
           // Rebuild title when selected ID or conversations list changes
           buildWhen: (previous, current) => 
                previous.selectedConversationId != current.selectedConversationId ||
                previous.conversations != current.conversations,
           builder: (context, state) {
              final selectedId = state.selectedConversationId;
              String title = 'AI Chat'; // Default title
              if (selectedId != null) {
                // Use firstWhereOrNull from collection package
                final selectedConversation = state.conversations.firstWhereOrNull(
                  (conv) => conv.id == selectedId,
                );
                if (selectedConversation != null) {
                   // Use ?? to provide default if title is null
                  title = selectedConversation.title ?? 'Conversation $selectedId';
                } else {
                  // Conversation ID exists but object not found yet (list updating?)
                  title = 'Loading...'; // Or keep 'Conversation $selectedId'
                }
              }
              return Text(title);
           },
        ),
         // Add the dispatch/recommendation button to actions
         actions: [
           // Replace IconButton with a TextButton
           Padding(
             // Add some padding to align with other AppBar elements
             padding: const EdgeInsets.only(right: 8.0), 
             child: TextButton(
               style: TextButton.styleFrom(
                 // Use primary color from the theme for the text
                 foregroundColor: Theme.of(context).colorScheme.primary, 
                 // Adjust padding inside the button if needed
                 // padding: EdgeInsets.symmetric(horizontal: 12.0), 
               ),
               onPressed: () {
                  // Dispatch event to fetch recommendations first
                  // Ensure a conversation is selected before fetching
                  final bloc = context.read<AiChatBloc>();
                  if (bloc.state.selectedConversationId != null) {
                    bloc.add(FetchRecommendations());
                  } else {
                     // Optionally show a message if no conversation is selected
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Please select a conversation first.')),
                     );
                     return; // Don't show bottom sheet if no conversation
                  }
                  // Then show the bottom sheet (it will initially show loading)
                  _showRecommendationsBottomSheet(context);
               },
               child: const Text(
                  '匹配', // Set the text to "匹配"
                  style: TextStyle(
                     fontWeight: FontWeight.bold, // Make text bold
                     fontSize: 16, // Adjust font size if needed
                  ),
               ),
             ),
           ),
            // IconButton(
            //    icon: const Icon(Icons.recommend_outlined), 
            //    tooltip: 'Recommend/Dispatch', 
            //    onPressed: () {
            //       _showRecommendationsBottomSheet(context);
            //    },
            // ),
         ],
      ),
      // The body is now just the chat area (Column)
      body: Column(
         children: [
           // Message List Area
           const Expanded(
             child: ChatMessageList(),
           ),
           // Input Field Area
           ChatInputField(
             textController: _textController,
             onSendMessage: _sendMessage,
           ),
         ],
       ),
    );
  }

  void _sendMessage(String message) {
    // Check if there's text OR pending images in the Bloc state
    // final hasPendingImages = context.read<AiChatBloc>().state.pendingImageFiles?.isNotEmpty ?? false;

    // --- Updated Logic: Require text to send --- 
    if (message.trim().isNotEmpty) {
       // Dispatch SendMessage event with ONLY the message text
       // The Bloc will handle merging with any uploadedImageUrls from the state.
       context.read<AiChatBloc>().add(SendMessage(message: message.trim()));
      _textController.clear(); 
    } else {
       // If message is empty, do not send, even if there are pending images.
       // Optionally provide feedback to the user.
       print("Send button pressed, but message text is empty. Not sending.");
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Please enter a message to send with the image(s).')),
       );
    }
  }

  // TODO: Implement voice recording logic and dispatch SendVoiceMessage
  // void _startRecording() { ... }
  // void _stopRecording() { ... }

  // --- Method to show the Bottom Sheet ---
  void _showRecommendationsBottomSheet(BuildContext pageContext) {
     // Use the Bloc context from the page
     final aiChatBloc = BlocProvider.of<AiChatBloc>(pageContext);

    showModalBottomSheet(
      context: pageContext, 
      // Make it scrollable if the list can be long
      isScrollControlled: true, 
      // Use a fraction of the screen height
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(pageContext).size.height * 0.6, 
      ),
      builder: (BuildContext bottomSheetContext) {
        // Provide the existing Bloc instance to the bottom sheet content
        return BlocProvider.value(
           value: aiChatBloc,
           // Create a dedicated widget for the bottom sheet content
           child: const RecommendationBottomSheetContent(), 
        );
      },
    );
  }
}

// --- Separate Widget for Bottom Sheet Content ---

class RecommendationBottomSheetContent extends StatelessWidget {
  const RecommendationBottomSheetContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
             'Related Services', 
             style: Theme.of(context).textTheme.titleLarge,
           ),
          const SizedBox(height: 16),
          Expanded( 
             child: BlocBuilder<AiChatBloc, AiChatState>(
               // Add recommendationsStatus to buildWhen
               buildWhen: (prev, curr) => 
                   prev.recommendations != curr.recommendations || 
                   prev.recommendationsStatus != curr.recommendationsStatus, 
               builder: (context, state) {
                 // Handle Loading state
                 if (state.recommendationsStatus == RecommendationsStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                 }
                 // Handle Error state
                 if (state.recommendationsStatus == RecommendationsStatus.error) {
                   return Center(child: Text(
                     "Error loading recommendations: ${state.recommendationsErrorMessage ?? 'Unknown error'}", 
                     style: const TextStyle(color: Colors.red)
                   ));
                 }
                 // Handle Empty state
                 if (state.recommendations.isEmpty) {
                   return const Center(child: Text('No recommendations available.'));
                 }

                 // Display the list using ServiceCard
                 return ListView.builder( // Use ListView.builder for potentially long lists
                   itemCount: state.recommendations.length,
                   itemBuilder: (context, index) {
                     final service = state.recommendations[index];
                     // Use ServiceCard instead of ListTile
                     return ServiceCard(
                       service: service,
                       onTap: () {
                          print('Recommendation card tapped: ${service.title}');
                          final itemData = {
                            'id': service.id,
                            'title': service.title,
                            'image_url': service.imageUrl,
                            'price': service.price,
                          };
                          context.read<AiChatBloc>().add(TriggerAllocationAction(
                             item: itemData,
                          ));
                          Navigator.pop(context);
                       },
                     );
                   },
                 );
               },
             ),
           ),
        ],
      ),
    );
  }
}
