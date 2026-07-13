import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart'; // Import GetIt
// Import collection package
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 添加FlutterSecureStorage导入
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart'; // 导入国际化资源

// Import Bloc and State/Event files
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/bloc/ai_chat/ai_chat_bloc.dart'; // Use package import
// Use package import
// 导入动画按钮组件
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/widgets/service_allocation_buttons.dart'; // 🆕 导入新的分配按钮组件

// Import domain interfaces and usecases (Use package imports)

// Import data layer implementations (Use package imports)

// Import Custom Widgets (Use package imports)
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/widgets/chat_input_field.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/widgets/chat_message_list.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/widgets/conversation_sidebar.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/widgets/rate_limit_warning.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/widgets/dispatch_history_bottom_sheet.dart';

// Import chat module components for navigation
import 'package:dskk_flutter_refactor/features/chat/presentation/bloc/chat_messages/chat_messages_bloc.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/pages/chat_room_page.dart';
import 'package:dskk_flutter_refactor/core/widgets/app_network_image.dart';

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
      if (mounted) {
        // Check if the state is still mounted
        final bloc = context.read<AiChatBloc>();
        bloc.add(const LoadConversations());

        // 频率限制接口使用 member.id，不是 common_user_id
        try {
          const storage = FlutterSecureStorage();
          final memberUserIdString = await storage.read(key: 'user_id');
          final userId = int.tryParse(memberUserIdString ?? '');

          if (userId != null) {
            bloc.add(FetchRateLimitStatus(userId: userId));
            AppLogger.d(
                "[ChatPage] Dispatched FetchRateLimitStatus with userId: $userId");
          } else {
            AppLogger.d(
                "[ChatPage] Warning: Could not get valid member user ID for rate limit status");
          }
        } catch (e) {
          AppLogger.d("[ChatPage] Error getting user ID: $e");
        }

        AppLogger.d("[ChatPage] Dispatched LoadConversations event.");
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
    final appLocalizations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        forceMaterialTransparency: true,
        elevation: 0,
        leadingWidth: 64,
        titleSpacing: 0,
        // Add a leading button to open the drawer
        leading: Builder(
          builder: (context) => _GlassHeaderIconButton(
            icon: Icons.menu_rounded,
            tooltip: appLocalizations.ai_docs_conversation_list,
            onPressed: _openConversationPanel,
          ),
        ),
        // Add the dispatch/recommendation button to actions
        actions: [
          // 已分发服务追溯入口 (#347):点开看本会话历史分发记录
          BlocBuilder<AiChatBloc, AiChatState>(
            buildWhen: (previous, current) =>
                previous.dispatchHistory != current.dispatchHistory ||
                previous.dispatchHistoryStatus !=
                    current.dispatchHistoryStatus ||
                previous.selectedConversationId !=
                    current.selectedConversationId,
            builder: (context, state) {
              final hasHistory = (state.dispatchHistory?.isNotEmpty ?? false);
              return _GlassHeaderIconButton(
                tooltip: '已分发服务',
                icon: Icons.history,
                color: hasHistory
                    ? Theme.of(context).colorScheme.primary
                    : AppColors.textTertiary,
                onPressed: hasHistory
                    ? () => _showDispatchHistoryBottomSheet(context)
                    : null,
              );
            },
          ),
          // Replace IconButton with a TextButton - wrapped with BlocBuilder to check generation status
          BlocBuilder<AiChatBloc, AiChatState>(
            buildWhen: (previous, current) =>
                previous.status != current.status ||
                previous.messages.length != current.messages.length,
            builder: (context, state) {
              // 检查是否正在生成阶段
              final isGenerating =
                  state.status == AiChatStatus.sendingMessage ||
                      state.status == AiChatStatus.waitingForResponse ||
                      state.status == AiChatStatus.streamingResponse ||
                      state.status == AiChatStatus.transcribingAudio;

              // 检查是否有消息（推荐需要基于现有对话内容）
              final hasMessages = state.messages.isNotEmpty;

              return _GlassHeaderIconButton(
                tooltip: appLocalizations.ai_docs_match_button,
                icon: Icons.auto_awesome_rounded,
                color: (isGenerating || !hasMessages)
                    ? AppColors.textTertiary
                    : Theme.of(context).colorScheme.primary,
                onPressed: (isGenerating || !hasMessages)
                    ? null
                    : () {
                        // Dispatch event to fetch recommendations first
                        // Ensure a conversation is selected before fetching
                        final bloc = context.read<AiChatBloc>();
                        if (bloc.state.selectedConversationId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(appLocalizations
                                    .ai_docs_select_conversation_first)),
                          );
                          return;
                        }
                        // #327 已有缓存(同 conversation 未发新消息)直接打开 bottom sheet
                        // 失效点已在切会话/新发消息处把 recommendations 清空,这里只判 status+非空
                        final hasCached = bloc.state.recommendationsStatus ==
                                RecommendationsStatus.loaded &&
                            bloc.state.recommendations.isNotEmpty;
                        if (!hasCached) {
                          bloc.add(FetchRecommendations());
                        }
                        _showRecommendationsBottomSheet(context);
                      },
              );
            },
          ),
        ],
      ),
      body: GlassBackdrop(
        atmosphereIntensity: 0.4,
        child: Padding(
          // 内层 Scaffold 的可用高度已经扣除了部分导航区域；只补齐
          // Home Indicator 与一档呼吸距离，避免输入舱和导航重叠。
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top + kToolbarHeight,
            bottom:
                MediaQuery.paddingOf(context).bottom + AppDimensions.spacingLg,
          ),
          child: Column(
            children: [
              // 🔥 频率限制警告横幅 - 修复关闭功能
              BlocBuilder<AiChatBloc, AiChatState>(
                buildWhen: (previous, current) =>
                    previous.conversationRateLimit !=
                    current.conversationRateLimit,
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
                      AppLogger.d("[ChatPage] 推荐次数提示框已关闭");
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
        ),
      ),
    );
  }

  void _openConversationPanel() {
    final aiChatBloc = context.read<AiChatBloc>();

    showGeneralDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: AppColors.textPrimary.withValues(alpha: 0.22),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, _, __) {
        final panelWidth = (MediaQuery.sizeOf(dialogContext).width * 0.84)
            .clamp(286.0, 380.0)
            .toDouble();

        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(
                    dialogContext,
                    rootNavigator: true,
                  ).pop(),
                  child: const SizedBox.expand(),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
              width: panelWidth,
              height: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(AppDimensions.radiusXl),
                  bottomRight: Radius.circular(AppDimensions.radiusXl),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.backgroundCard.withValues(alpha: 0.78),
                          AppColors.backgroundSecondary.withValues(alpha: 0.64),
                        ],
                      ),
                      border: Border(
                        right: BorderSide(
                          color: Colors.white.withValues(alpha: 0.82),
                        ),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: BlocProvider.value(
                        value: aiChatBloc,
                        child: ConversationSidebar(
                          onClose: () => Navigator.of(
                            dialogContext,
                            rootNavigator: true,
                          ).pop(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final scale = Tween<double>(begin: 0.96, end: 1).animate(curved);

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            alignment: Alignment.centerLeft,
            scale: scale,
            child: child,
          ),
        );
      },
    );
  }

  void _sendMessage(String message) {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context);

    // 检查消息是否为空
    if (message.trim().isNotEmpty) {
      // 获取当前AI聊天Bloc状态
      final aiChatBloc = context.read<AiChatBloc>();
      final currentState = aiChatBloc.state;

      // 检查是否已选择对话，如果没有选择，先创建新对话
      if (currentState.selectedConversationId == null) {
        // 先创建新对话，再发送消息
        AppLogger.d("[ChatPage] ${appLocalizations.ai_docs_auto_create_text}");
        aiChatBloc
            .add(CreateNewConversationAndSendMessage(message: message.trim()));
      } else {
        // 已有对话，直接发送消息
        aiChatBloc.add(SendMessage(message: message.trim()));
      }

      // 发送消息后触发滚动到底部
      aiChatBloc.add(const ScrollToBottom());
      _textController.clear();
    } else {
      // 消息为空，显示提示
      AppLogger.d(
          "Send button pressed, but message text is empty. Not sending.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(appLocalizations.ai_docs_please_enter_message)), // 使用国际化文本
      );
    }
  }

  // TODO: Implement voice recording logic and dispatch SendVoiceMessage
  // void _startRecording() { ... }
  // void _stopRecording() { ... }

  // --- Method to show the Bottom Sheet ---
  void _showRecommendationsBottomSheet(BuildContext pageContext) {
    // Use the Bloc context from the page. The sheet itself is mounted on the
    // root navigator so it always sits above the floating application shell.
    final aiChatBloc = BlocProvider.of<AiChatBloc>(pageContext);

    showModalBottomSheet(
      context: pageContext,
      useRootNavigator: true,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      showDragHandle: false,
      builder: (BuildContext bottomSheetContext) {
        return BlocProvider.value(
          value: aiChatBloc,
          child: DraggableScrollableSheet(
            initialChildSize: 0.90,
            minChildSize: 0.54,
            maxChildSize: 0.96,
            expand: false,
            builder: (context, scrollController) =>
                RecommendationBottomSheetContent(
              scrollController: scrollController,
            ),
          ),
        );
      },
    );
  }

  /// 已分发服务历史弹窗 (#347)。
  void _showDispatchHistoryBottomSheet(BuildContext pageContext) {
    final aiChatBloc = BlocProvider.of<AiChatBloc>(pageContext);
    showModalBottomSheet(
      context: pageContext,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(pageContext).size.height * 0.6,
      ),
      builder: (BuildContext bottomSheetContext) {
        return BlocProvider.value(
          value: aiChatBloc,
          child: const DispatchHistoryBottomSheetContent(),
        );
      },
    );
  }
}

class _GlassHeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;

  const _GlassHeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final iconColor = color ?? AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Opacity(
        opacity: enabled ? 1 : 0.48,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.backgroundCard.withValues(alpha: 0.66),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.86)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, size: 21, color: iconColor),
            tooltip: tooltip,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}

// --- Separate Widget for Bottom Sheet Content ---

class RecommendationBottomSheetContent extends StatelessWidget {
  final ScrollController scrollController;

  const RecommendationBottomSheetContent({
    required this.scrollController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context);

    // 推荐内容本身已经是密集的卡片网格。面板底色保持实色，避免和
    // 卡片/导航的毛玻璃层叠加，减少合成开销也让信息更清晰。
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusLg),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.backgroundSecondary,
          border: Border(
            top: BorderSide(color: AppColors.borderPrimary),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 4),
              child: Center(
                child: SizedBox(
                  width: 38,
                  height: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary,
                      borderRadius: BorderRadius.all(Radius.circular(99)),
                    ),
                  ),
                ),
              ),
            ),
            // 标题栏
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spacingLg,
                AppDimensions.spacingLg,
                AppDimensions.spacingLg,
                AppDimensions.spacingSm,
              ),
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
            const Divider(height: 1, color: AppColors.borderPrimary),

            // 内容区域
            Expanded(
              child: BlocBuilder<AiChatBloc, AiChatState>(
                buildWhen: (prev, curr) =>
                    prev.recommendations != curr.recommendations ||
                    prev.recommendationsStatus != curr.recommendationsStatus,
                builder: (context, state) {
                  // 加载中状态
                  if (state.recommendationsStatus ==
                      RecommendationsStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // 错误状态
                  if (state.recommendationsStatus ==
                      RecommendationsStatus.error) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.error, size: 48),
                          const SizedBox(height: AppDimensions.spacingLg),
                          Text(
                            appLocalizations.ai_docs_recommendations_error(
                                state.recommendationsErrorMessage ??
                                    ''), // 使用国际化文本
                            style: const TextStyle(color: AppColors.error),
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
                          const Icon(Icons.inbox,
                              color: AppColors.textTertiary, size: 48),
                          const SizedBox(height: AppDimensions.spacingLg),
                          Text(appLocalizations.ai_docs_no_recommendations,
                              style: const TextStyle(
                                  color: AppColors.textSecondary)), // 使用国际化文本
                        ],
                      ),
                    );
                  }

                  // 服务列表 - 保持不变
                  return GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(AppDimensions.spacingLg),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                          AppLogger.d('[点击分发] ==========');
                          AppLogger.d('[点击分发] 服务名称: ${service.title}');
                          AppLogger.d('[点击分发] 服务ID: ${service.id}');
                          AppLogger.d(
                              '[点击分发] 商家ID(tenantId): ${service.tenantId}');
                          AppLogger.d('[点击分发] 价格: ${service.price}');

                          final itemData = {
                            'id': service.id.toString(), // 转换为字符串类型
                            'name': service.title,
                            'description':
                                '推荐服务: ${service.title}，价格: ￥${service.price}',
                          };
                          AppLogger.d('[点击分发] 构造的itemData: $itemData');
                          AppLogger.d(
                              '[点击分发] 准备触发TriggerOptimizedAllocation事件...');

                          context
                              .read<AiChatBloc>()
                              .add(TriggerOptimizedAllocation(
                                item: itemData,
                                merchantId: service.tenantId, // 使用服务的实际商家ID
                                serviceId: service.id, // 添加服务ID用于状态追踪
                              ));

                          AppLogger.d('[点击分发] TriggerOptimizedAllocation事件已触发');
                          AppLogger.d('[点击分发] ==========');
                          // 移除Navigator.pop，让底部弹窗保持打开状态，用户可以看到按钮状态变化
                          // Navigator.pop(context);
                        },
                        onEnterChat: () {
                          // 处理进入聊天的逻辑
                          try {
                            final bloc = context.read<AiChatBloc>();
                            final chatRoomId = bloc.state.createdChatRoomId;
                            AppLogger.d('尝试进入聊天室，chatRoomId: $chatRoomId');

                            if (chatRoomId != null) {
                              AppLogger.d('开始导航到聊天室: $chatRoomId');
                              Navigator.pop(context); // 关闭底部弹窗

                              // 尝试创建ChatMessagesBloc
                              try {
                                final chatMessagesBloc =
                                    getIt<ChatMessagesBloc>(param1: chatRoomId);
                                AppLogger.d(
                                    '成功创建ChatMessagesBloc: $chatMessagesBloc');

                                // TODO(Step1.4): 待路由注册后迁移到 GoRouter
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
                                  AppLogger.d('聊天室页面返回结果: $result');
                                }).catchError((error) {
                                  AppLogger.d('导航到聊天室页面时发生错误: $error');
                                });
                              } catch (e) {
                                AppLogger.d('创建ChatMessagesBloc时发生错误: $e');
                                // 显示错误提示
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('无法创建聊天会话: $e')),
                                );
                              }
                            } else {
                              AppLogger.d('聊天室ID为空，无法进入聊天');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('聊天室ID为空，无法进入聊天')),
                              );
                            }
                          } catch (e) {
                            AppLogger.d('进入聊天时发生未知错误: $e');
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
    super.key,
    required this.service,
    required this.onTap,
    required this.onEnterChat,
  });

  @override
  Widget build(BuildContext context) {
    // 使用BlocBuilder来监听状态变化，确保按钮状态能被正确更新
    return BlocBuilder<AiChatBloc, AiChatState>(
      buildWhen: (previous, current) =>
          // 只有在服务分配状态变化或总体状态变化时才重建
          previous.serviceAllocationStatus[service.id] !=
              current.serviceAllocationStatus[service.id] ||
          (previous.status != current.status &&
              (current.status == AiChatStatus.allocatingResource ||
                  current.status == AiChatStatus.allocationSuccess ||
                  current.status == AiChatStatus.allocationFailure)),
      builder: (context, state) {
        // 获取当前服务的分配状态
        final allocationStatus = state.serviceAllocationStatus[service.id] ??
            AllocationStatus.initial;

        return GlassCard(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          tintOpacity: 0.62,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: allocationStatus == AllocationStatus.loading ||
                      allocationStatus == AllocationStatus.success
                  ? null // 加载中或已分发状态禁用点击
                  : onTap,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 图片区域占据更多空间
                    AspectRatio(
                      aspectRatio: 1.0, // 保持正方形比例
                      child: AppNetworkImage(
                        imageUrl: service.imageUrl,
                        fit: BoxFit.cover,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.spacingSm),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingSm),

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

                    const SizedBox(height: AppDimensions.spacingSm),

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
