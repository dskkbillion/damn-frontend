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
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/bloc/ai_chat/ai_chat_bloc.dart'; // Use package import
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/widgets/chat_message_widget.dart'; // Use package import

// Import domain interfaces and usecases (Use package imports)
import 'package:dskk_flutter_refactor/features/ai_docs/domain/repositories/i_ai_chat_repository.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/repositories/i_file_upload_repository.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/load_history_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/stream_chat_completion_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/upload_file_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/transcribe_audio_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/get_related_services_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/allocate_chat_resource_usecase.dart';

// Import data layer implementations (Use package imports)
import 'package:dskk_flutter_refactor/features/ai_docs/data/repositories/ai_chat_repository_impl.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/data/repositories/file_upload_repository_impl.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/data/datasources/mocks/mock_ai_chat_remote_data_source.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/data/datasources/mocks/mock_file_upload_data_source.dart';
// TODO: Import actual datasources and HTTP client when moving away from mocks

// Import Custom Widgets (Use package imports)
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/widgets/chat_input_field.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/widgets/chat_message_list.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/widgets/conversation_sidebar.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/widgets/service_card.dart'; 

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
             tooltip: '会话列表',
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
              String title = 'AI 助手'; // Default title
              if (selectedId != null) {
                // Use firstWhereOrNull from collection package
                final selectedConversation = state.conversations.firstWhereOrNull(
                  (conv) => conv.id == selectedId,
                );
                if (selectedConversation != null) {
                   // Use ?? to provide default if title is null
                  title = selectedConversation.title ?? '未命名会话';
                } else {
                  // Conversation ID exists but object not found yet (list updating?)
                  title = '加载中...'; // Or keep 'Conversation $selectedId'
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
                       const SnackBar(content: Text('请先选择一个会话')),
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
         const SnackBar(content: Text('请输入消息内容')),
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
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8F0), // 米黄色底色
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
             '推荐服务', 
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
           ),
          const Divider(height: 1),
          
          // 内容区域
          Expanded( 
             child: BlocBuilder<AiChatBloc, AiChatState>(
               buildWhen: (prev, curr) => 
                   prev.recommendations != curr.recommendations || 
                   prev.recommendationsStatus != curr.recommendationsStatus, 
               builder: (context, state) {
                // 加载中状态
                 if (state.recommendationsStatus == RecommendationsStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                 }
                
                // 错误状态
                 if (state.recommendationsStatus == RecommendationsStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          "加载推荐服务失败: ${state.recommendationsErrorMessage ?? '未知错误'}",
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                 }
                
                // 空状态
                 if (state.recommendations.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, color: Colors.grey, size: 48),
                        SizedBox(height: 16),
                        Text('暂无推荐服务', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                // 服务列表 - 改为两列网格布局
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 两列布局
                    childAspectRatio: 0.6, // 进一步降低宽高比，让卡片更高
                    crossAxisSpacing: 12, // 水平间距
                    mainAxisSpacing: 12, // 垂直间距
                  ),
                   itemCount: state.recommendations.length,
                   itemBuilder: (context, index) {
                     final service = state.recommendations[index];
                    return _buildServiceGridItem(
                      context, 
                      service, 
                      () {
                        print('服务点击: ${service.title}');
                          final itemData = {
                            'name': service.title,
                            'description': '推荐服务: ${service.title}，价格: ￥${service.price}',
                          };
                          context.read<AiChatBloc>().add(TriggerAllocationAction(
                             item: itemData,
                          merchantId: 1, // 固定商家ID
                          ));
                          Navigator.pop(context);
                      }
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
  
  // 网格项构建方法
  Widget _buildServiceGridItem(BuildContext context, RelatedServiceEntity service, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 图片区域占据更多空间
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 1.0, // 保持正方形比例
                    child: Image.network(
                      service.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // 标题
                Text(
                  service.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15, // 增大字体
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 6),
                
                // 价格
                Text(
                  '￥${service.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14, // 增大字体
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // 按钮独占一行
                Container(
                  width: double.infinity, // 占满整行
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA86400), // 使用截图中的棕色按钮
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextButton(
                    onPressed: onTap,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      '让ta看看',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
