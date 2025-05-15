import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/generated/l10n.dart'; // 导入国际化资源

// Import necessary Bloc (which exports State, Event, and Entities it imports)
import '../bloc/ai_chat/ai_chat_bloc.dart';
// Remove direct imports of part files
// import '../bloc/ai_chat/ai_chat_state.dart';
// import '../bloc/ai_chat/ai_chat_event.dart';
// import '../../../domain/entities/ai_conversation_entity.dart'; // No longer needed here

class ConversationSidebar extends StatelessWidget {
  const ConversationSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context); // 获取国际化资源
    
    // Wrap the content in SafeArea to avoid status bar overlap
    return SafeArea(
      child: Container(
        // Removed fixed width to allow Drawer to manage it
        // width: 250, 
        decoration: BoxDecoration(
          color: Colors.grey[100],
          // Drawer usually handles its own borders/shadows
          // border: Border(right: BorderSide(color: Colors.grey[300]!))
        ),
        // Use BlocBuilder to react to state changes concerning the conversation list
        child: BlocBuilder<AiChatBloc, AiChatState>(
          // Optional: buildWhen to only rebuild when conversation list related state changes
          buildWhen: (previous, current) => 
               previous.conversationsStatus != current.conversationsStatus ||
               previous.conversations != current.conversations ||
               previous.selectedConversationId != current.selectedConversationId,
          builder: (context, state) {
            return Column(
              children: [
                // --- New Chat Button ---
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle_outline),
                    label: Text(s.ai_docs_new_chat), // 使用国际化文本
                    style: ElevatedButton.styleFrom(
                       minimumSize: const Size(double.infinity, 40), 
                    ),
                    // Disable button if list is currently loading/error?
                    onPressed: state.conversationsStatus == ConversationsStatus.loading 
                               ? null 
                               : () {
                                   context.read<AiChatBloc>().add(CreateNewConversation());
                                   Navigator.pop(context); // Close drawer after event dispatch
                                 },
                  ),
                ),
                const Divider(height: 1),
                // --- Conversation List Area ---
                Expanded(
                  child: _buildConversationList(context, state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Helper method to build the list based on status
  Widget _buildConversationList(BuildContext context, AiChatState state) {
     final s = S.of(context); // 获取国际化资源
     
     switch (state.conversationsStatus) {
       case ConversationsStatus.loading:
       // Show loading indicator only if list is initially empty
         if (state.conversations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
         } 
         // Otherwise, show the list potentially with a subtle loading indicator on top?
         // For now, just show the list while loading updates.
         return _buildList(context, state.conversations, state.selectedConversationId);
       case ConversationsStatus.error:
         return Center(
           child: Padding(
             padding: const EdgeInsets.all(16.0),
             child: Column(
               mainAxisSize: MainAxisSize.min,
               children: [
                 const Icon(Icons.error_outline, color: Colors.red, size: 32),
                 const SizedBox(height: 8),
                 Text(
                   state.conversationListErrorMessage ?? s.ai_docs_load_conversations_failed, // 使用国际化文本
                   textAlign: TextAlign.center,
                   style: const TextStyle(color: Colors.red)
                 ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                     icon: const Icon(Icons.refresh), 
                     label: Text(s.ai_docs_retry), // 使用国际化文本
                     onPressed: () => context.read<AiChatBloc>().add(LoadConversations()),
                  )
               ],
             ),
           ),
         );
        case ConversationsStatus.loaded:
        case ConversationsStatus.initial: // Treat initial as loaded (or show loading initially)
        default:
          if (state.conversations.isEmpty) {
             return Center(child: Text(s.ai_docs_no_conversations)); // 使用国际化文本
          }
          return _buildList(context, state.conversations, state.selectedConversationId);
     }
  }

  // Helper method to build the actual ListView
  Widget _buildList(BuildContext context, List<AiConversationEntity> conversations, int? selectedId) {
    final s = S.of(context); // 获取国际化资源
    
    return ListView.builder(
       itemCount: conversations.length,
       itemBuilder: (context, index) {
          final conv = conversations[index];
          return ListTile(
              title: Text(
                  conv.title?.isNotEmpty ?? false ? conv.title! : s.ai_docs_unnamed_conversation, // 使用国际化文本
                  overflow: TextOverflow.ellipsis,
              ),
              // 移除ID展示
              // subtitle: Text(
              //     'ID: ${conv.id}', 
              //      overflow: TextOverflow.ellipsis,
              // ),
              selected: selectedId == conv.id,
              selectedTileColor: Colors.blue.withOpacity(0.1),
              onTap: () {
                if (selectedId != conv.id) {
                  context.read<AiChatBloc>().add(SelectConversation(conv.id));
                }
                Navigator.pop(context); // Close drawer after selecting
              },
              // Add delete button
               trailing: IconButton(
                 icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey), // Subtle color
                 tooltip: s.ai_docs_delete_conversation_tooltip, // 使用国际化文本
                 onPressed: () => _confirmDelete(context, conv.id), // Show confirmation
               ),
            );
       }
    );
  }

  // Helper method to show delete confirmation dialog
  Future<void> _confirmDelete(BuildContext context, int conversationId) async {
     final s = S.of(context); // 获取国际化资源
     
     final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text(s.ai_docs_delete_conversation_title), // 使用国际化文本
            content: Text(s.ai_docs_delete_conversation_content), // 使用国际化文本
            actions: <Widget>[
              TextButton(
                child: Text(s.ai_docs_cancel), // 使用国际化文本
                onPressed: () => Navigator.of(dialogContext).pop(false), // Return false
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(s.ai_docs_delete), // 使用国际化文本
                onPressed: () => Navigator.of(dialogContext).pop(true), // Return true
              ),
            ],
          );
        },
      );

      // If user confirmed, dispatch the delete event
      // Note: This deletes the currently selected conversation in the Bloc,
      // which might not be the one the user clicked delete on if selection changed fast.
      // A safer approach might be to pass the ID to the delete event.
      if (confirm == true) {
        // Check if the one to be deleted is currently selected before dispatching
        final currentState = context.read<AiChatBloc>().state;
        if (currentState.selectedConversationId == conversationId) {
           context.read<AiChatBloc>().add(DeleteSelectedConversation());
        } else {
           // TODO: Implement deleting a non-selected conversation?
           // Maybe add DeleteConversationById(id) event?
           print("Deletion requested for non-selected conversation ID: $conversationId. Ignoring for now.");
           ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(s.ai_docs_please_select_conversation_to_delete)), // 使用国际化文本
           );
        }
      }
  }
} 