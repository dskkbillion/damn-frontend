import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:get_it/get_it.dart'; // Import GetIt
import 'package:collection/collection.dart'; // Import collection package
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 添加FlutterSecureStorage导入
import 'package:dskk_flutter_refactor/generated/app_localizations.dart'; // 导入国际化资源

// Import Bloc and State/Event files
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/bloc/ai_chat/ai_chat_bloc.dart'; // Use package import
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/widgets/chat_message_widget.dart'; // Use package import
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/widgets/animated_allocation_button.dart'; // 导入动画按钮组件
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/widgets/service_allocation_buttons.dart'; // 🆕 导入新的分配按钮组件

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

// Import Custom Widgets (Use package imports)
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/widgets/chat_input_field.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/widgets/chat_message_list.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/widgets/conversation_sidebar.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/widgets/service_card.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/widgets/chat_page_title.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/widgets/rate_limit_indicator.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/widgets/rate_limit_warning.dart';

// Import chat module components for navigation
import 'package:dskk_flutter_refactor/features/chat/presentation/bloc/chat_messages/chat_messages_bloc.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/pages/chat_room_page.dart';

// Get the GetIt instance
final getIt = GetIt.instance; 

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  
  // 🔥 添加状态来控制推荐次数提示框的显示
  bool _isRateLimitWarningDismissed = false;

  @override
  void initState() {
    super.initState();
    // Dispatch the event to load conversations when the page initializes
    // Ensure BlocProvider is available above this widget in the tree
    WidgetsBinding.instance.addPostFrameCallback((_) async { 
      if (mounted) { // Check if the state is still mounted
        final bloc = context.read<AiChatBloc>();
        bloc.add(LoadConversations());
        
        // 获取真实用户ID并加载频率限制状态
        try {
          // 从存储中获取用户ID
          final storage = const FlutterSecureStorage();
          final commonUserIdString = await storage.read(key: 'common_user_id');
          final userId = int.tryParse(commonUserIdString ?? '');
          
          if (userId != null) {
            bloc.add(FetchRateLimitStatus(userId: userId));
            print("[ChatPage] Dispatched FetchRateLimitStatus with userId: $userId");
          } else {
            print("[ChatPage] Warning: Could not get valid user ID for rate limit status");
          }
        } catch (e) {
          print("[ChatPage] Error getting user ID: $e");
        }
        
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
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context)!;
    
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
             tooltip: appLocalizations.ai_docs_conversation_list, // 使用国际化文本
             onPressed: () => Scaffold.of(context).openDrawer(),
           ),
         ),
        title: const ChatPageTitle(),
         // Add the dispatch/recommendation button to actions
         actions: [
           // 频率限制指示器
           const RateLimitIndicator(),
           // Replace IconButton with a TextButton - wrapped with BlocBuilder to check generation status
           BlocBuilder<AiChatBloc, AiChatState>(
             buildWhen: (previous, current) =>
               previous.status != current.status ||
               previous.messages.length != current.messages.length,
             builder: (context, state) {
               // 检查是否正在生成阶段
               final isGenerating = state.status == AiChatStatus.sendingMessage ||
                   state.status == AiChatStatus.waitingForResponse ||
                   state.status == AiChatStatus.streamingResponse ||
                   state.status == AiChatStatus.transcribingAudio;

               // 检查是否有消息（推荐需要基于现有对话内容）
               final hasMessages = state.messages.isNotEmpty;

               return Padding(
                 // Add some padding to align with other AppBar elements
                 padding: const EdgeInsets.only(right: 8.0),
                 child: TextButton(
                   style: TextButton.styleFrom(
                     // Use primary color from the theme for the text, gray when disabled
                     foregroundColor: (isGenerating || !hasMessages)
                         ? Colors.grey
                         : Theme.of(context).colorScheme.primary,
                     // Adjust padding inside the button if needed
                     // padding: EdgeInsets.symmetric(horizontal: 12.0),
                   ),
                   onPressed: (isGenerating || !hasMessages) ? null : () {
                      // Dispatch event to fetch recommendations first
                      // Ensure a conversation is selected before fetching
                      final bloc = context.read<AiChatBloc>();
                      if (bloc.state.selectedConversationId != null) {
                        bloc.add(FetchRecommendations());
                      } else {
                         // Optionally show a message if no conversation is selected
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text(appLocalizations.ai_docs_select_conversation_first)), // 使用国际化文本
                         );
                         return; // Don't show bottom sheet if no conversation
                      }
                      // Then show the bottom sheet (it will initially show loading)
                      _showRecommendationsBottomSheet(context);
                   },
                   child: Text(
                      appLocalizations.ai_docs_match_button, // 使用国际化文本
                      style: const TextStyle(
                         fontWeight: FontWeight.bold, // Make text bold
                         fontSize: 16, // Adjust font size if needed
                      ),
                   ),
                 ),
               );
             },
           ),
         ],
      ),
      // The body is now just the chat area (Column)
      body: Column(
         children: [
           // 🔥 频率限制警告横幅 - 修复关闭功能
           BlocBuilder<AiChatBloc, AiChatState>(
             buildWhen: (previous, current) =>
                 previous.conversationRateLimit != current.conversationRateLimit,
             builder: (context, state) {
               final rateLimit = state.conversationRateLimit;
               // 如果没有频率限制数据或者用户已经关闭了警告，则不显示
               if (rateLimit == null || _isRateLimitWarningDismissed) {
                 return const SizedBox.shrink();
               }
               
               return RateLimitWarningBanner(
                 remaining: rateLimit.remaining,
                 resetInSeconds: rateLimit.resetInSeconds,
                 onDismiss: () {
                   // 🔥 实现关闭逻辑：设置状态为已关闭
                   setState(() {
                     _isRateLimitWarningDismissed = true;
                   });
                   print("[ChatPage] 推荐次数提示框已关闭");
                 },
               );
             },
           ),
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
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context)!;
    
    // 检查消息是否为空
    if (message.trim().isNotEmpty) {
      // 获取当前AI聊天Bloc状态
      final aiChatBloc = context.read<AiChatBloc>();
      final currentState = aiChatBloc.state;
      
      // 检查是否已选择对话，如果没有选择，先创建新对话
      if (currentState.selectedConversationId == null) {
        // 先创建新对话，再发送消息
        print("[ChatPage] ${appLocalizations.ai_docs_auto_create_text}");
        aiChatBloc.add(CreateNewConversationAndSendMessage(message: message.trim()));
      } else {
        // 已有对话，直接发送消息
        aiChatBloc.add(SendMessage(message: message.trim()));
      }
      
      // 发送消息后触发滚动到底部
      aiChatBloc.add(const ScrollToBottom());
      _textController.clear();
    } else {
      // 消息为空，显示提示
      print("Send button pressed, but message text is empty. Not sending.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appLocalizations.ai_docs_please_enter_message)), // 使用国际化文本
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
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context)!;
    
    // 移除不需要的BlocListener，不显示SnackBar提示
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
                    appLocalizations.ai_docs_recommended_services, // 使用国际化文本
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // 添加关闭按钮
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
           ),
            Divider(height: 1, color: Colors.grey[200]),

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
                            appLocalizations.ai_docs_recommendations_error(state.recommendationsErrorMessage ?? ''), // 使用国际化文本
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                 }
                  
                  // 空状态
                 if (state.recommendations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inbox, color: Colors.grey, size: 48),
                          const SizedBox(height: 16),
                          Text(appLocalizations.ai_docs_no_recommendations, style: const TextStyle(color: Colors.grey)), // 使用国际化文本
                        ],
                      ),
                    );
                   }

                  // 服务列表 - 保持不变
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
                       // 使用独立Widget而不是直接调用方法
                       return ServiceGridItem(
                       service: service,
                       onTap: () {
                          print('[点击分发] ==========');
                          print('[点击分发] 服务名称: ${service.title}');
                          print('[点击分发] 服务ID: ${service.id}');
                          print('[点击分发] 商家ID(tenantId): ${service.tenantId}');
                          print('[点击分发] 价格: ${service.price}');

                          final itemData = {
                            'id': service.id.toString(), // 转换为字符串类型
                            'name': service.title,
                            'description': '推荐服务: ${service.title}，价格: ￥${service.price}',
                          };
                          print('[点击分发] 构造的itemData: $itemData');
                          print('[点击分发] 准备触发TriggerOptimizedAllocation事件...');

                          context.read<AiChatBloc>().add(TriggerOptimizedAllocation(
                             item: itemData,
                               merchantId: service.tenantId, // 使用服务的实际商家ID
                               serviceId: service.id, // 添加服务ID用于状态追踪
                          ));

                          print('[点击分发] TriggerOptimizedAllocation事件已触发');
                          print('[点击分发] ==========');
                            // 移除Navigator.pop，让底部弹窗保持打开状态，用户可以看到按钮状态变化
                            // Navigator.pop(context);
                       },
                       onEnterChat: () {
                         // 处理进入聊天的逻辑
                         try {
                           final bloc = context.read<AiChatBloc>();
                           final chatRoomId = bloc.state.createdChatRoomId;
                           print('尝试进入聊天室，chatRoomId: $chatRoomId');
                           
                           if (chatRoomId != null) {
                             print('开始导航到聊天室: $chatRoomId');
                             Navigator.pop(context); // 关闭底部弹窗
                             
                             // 尝试创建ChatMessagesBloc
                             try {
                               final chatMessagesBloc = getIt<ChatMessagesBloc>(param1: chatRoomId);
                               print('成功创建ChatMessagesBloc: $chatMessagesBloc');
                               
                               // 导航到聊天室页面
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(
                                   builder: (context) => BlocProvider.value(
                                     value: chatMessagesBloc,
                                     child: ChatRoomPage(chatId: chatRoomId),
                                   ),
                                 ),
                               ).then((result) {
                                 print('聊天室页面返回结果: $result');
                               }).catchError((error) {
                                 print('导航到聊天室页面时发生错误: $error');
                               });
                             } catch (e) {
                               print('创建ChatMessagesBloc时发生错误: $e');
                               // 显示错误提示
                               ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(content: Text('无法创建聊天会话: $e')),
                               );
                             }
                           } else {
                             print('聊天室ID为空，无法进入聊天');
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(content: Text('聊天室ID为空，无法进入聊天')),
                             );
                           }
                         } catch (e) {
                           print('进入聊天时发生未知错误: $e');
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text('进入聊天时发生错误: $e')),
                           );
                         }
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

// 独立的服务网格项Widget
class ServiceGridItem extends StatelessWidget {
  final RelatedServiceEntity service;
  final VoidCallback onTap;
  final VoidCallback onEnterChat;

  const ServiceGridItem({
    Key? key,
    required this.service,
    required this.onTap,
    required this.onEnterChat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context)!;
    
    // 使用BlocBuilder来监听状态变化，确保按钮状态能被正确更新
    return BlocBuilder<AiChatBloc, AiChatState>(
      buildWhen: (previous, current) =>
        // 只有在服务分配状态变化或总体状态变化时才重建
        previous.serviceAllocationStatus[service.id] != current.serviceAllocationStatus[service.id] ||
        (previous.status != current.status && 
         (current.status == AiChatStatus.allocatingResource || 
          current.status == AiChatStatus.allocationSuccess || 
          current.status == AiChatStatus.allocationFailure)),
      builder: (context, state) {
        // 获取当前服务的分配状态
        final allocationStatus = state.serviceAllocationStatus[service.id] ?? AllocationStatus.initial;

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
          onTap: allocationStatus == AllocationStatus.loading || allocationStatus == AllocationStatus.success 
              ? null // 加载中或已分发状态禁用点击
              : onTap,
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
                
                    // 🆕 使用新的按钮组件替换AnimatedAllocationButton
                    ServiceAllocationButtons(
                      service: service,
                      onTap: onTap,
                      onEnterChat: onEnterChat,
                ),
              ],
            ),
          ),
        ),
      ),
        );
      },
    );
  }
}
