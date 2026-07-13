import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart'; // 导入国际化资源

// Import necessary Bloc (which exports State, Event, and Entities it imports)
import '../bloc/ai_chat/ai_chat_bloc.dart';

class ConversationSidebar extends StatefulWidget {
  final VoidCallback? onClose;

  const ConversationSidebar({super.key, this.onClose});

  @override
  State<ConversationSidebar> createState() => _ConversationSidebarState();
}

class _ConversationSidebarState extends State<ConversationSidebar> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    const threshold = 200.0; // 距离底部200像素时触发加载更多

    // 检查是否滚动到底部，触发加载更多对话
    if (maxScroll - currentScroll <= threshold &&
        !_scrollController.position.outOfRange) {
      final state = context.read<AiChatBloc>().state;
      if (state.conversationsHasMore &&
          !state.isLoadingMoreConversations &&
          state.conversations.isNotEmpty) {
        AppLogger.d("[ConversationSidebar] Triggering LoadMoreConversations");
        context.read<AiChatBloc>().add(const LoadMoreConversations());
      }
    }
  }

  void _closePanel() {
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context); // 获取国际化资源

    return BlocBuilder<AiChatBloc, AiChatState>(
      // Optional: buildWhen to only rebuild when conversation list related state changes
      buildWhen: (previous, current) =>
          previous.conversationsStatus != current.conversationsStatus ||
          previous.conversations != current.conversations ||
          previous.selectedConversationId != current.selectedConversationId ||
          previous.isLoadingMoreConversations !=
              current.isLoadingMoreConversations,
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Row(
                children: [
                  Text(
                    appLocalizations.ai_docs_conversation_list,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
              child: SizedBox(
                height: 46,
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text(appLocalizations.ai_docs_new_chat),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.92),
                    shape: const StadiumBorder(),
                  ),
                  onPressed:
                      state.conversationsStatus == ConversationsStatus.loading
                          ? null
                          : () {
                              context
                                  .read<AiChatBloc>()
                                  .add(const CreateNewConversation());
                              _closePanel();
                            },
                ),
              ),
            ),
            // --- Conversation List Area with Pull to Refresh ---
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<AiChatBloc>().add(const RefreshConversations());
                  // 等待刷新完成
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: _buildConversationList(context, state),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method to build the list based on status
  Widget _buildConversationList(BuildContext context, AiChatState state) {
    final appLocalizations = AppLocalizations.of(context); // 获取国际化资源

    switch (state.conversationsStatus) {
      case ConversationsStatus.loading:
        // Show loading indicator only if list is initially empty
        if (state.conversations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        // Otherwise, show the list potentially with a subtle loading indicator on top?
        // For now, just show the list while loading updates.
        return _buildList(
            context, state.conversations, state.selectedConversationId, state);
      case ConversationsStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.error, size: 32),
                const SizedBox(height: AppDimensions.spacingSm),
                Text(
                  state.conversationListErrorMessage ??
                      appLocalizations
                          .ai_docs_load_conversations_failed, // 使用国际化文本
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: Text(appLocalizations.ai_docs_retry), // 使用国际化文本
                  onPressed: () =>
                      context.read<AiChatBloc>().add(
                        const LoadConversations(forceRefresh: true),
                      ),
                )
              ],
            ),
          ),
        );
      case ConversationsStatus.loaded:
      case ConversationsStatus
            .initial: // Treat initial as loaded (or show loading initially)
      default:
        if (state.conversations.isEmpty) {
          return Center(
              child:
                  Text(appLocalizations.ai_docs_no_conversations)); // 使用国际化文本
        }
        return _buildList(
            context, state.conversations, state.selectedConversationId, state);
    }
  }

  // Helper method to build the actual ListView with pagination support
  Widget _buildList(
      BuildContext context,
      List<AiConversationEntity> conversations,
      int? selectedId,
      AiChatState state) {
    final appLocalizations = AppLocalizations.of(context); // 获取国际化资源

    return ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(), // 确保可以下拉刷新
        itemCount:
            conversations.length + (state.isLoadingMoreConversations ? 1 : 0),
        itemBuilder: (context, index) {
          // 显示加载更多指示器
          if (index == conversations.length &&
              state.isLoadingMoreConversations) {
            return Container(
              padding: const EdgeInsets.all(AppDimensions.spacingLg),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: AppDimensions.spacingSm),
                    Text('加载更多对话...',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            );
          }

          final conv = conversations[index];
          final isSelected = selectedId == conv.id;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                onTap: () {
                  if (selectedId != conv.id) {
                    context.read<AiChatBloc>().add(SelectConversation(conv.id));
                  }
                  _closePanel();
                },
                child: Container(
                  height: 62,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    border: isSelected
                        ? Border.all(
                            color: AppColors.primary.withValues(alpha: 0.16))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.14)
                              : AppColors.primaryLight.withValues(alpha: 0.36),
                        ),
                        child: Icon(
                          Icons.forum_outlined,
                          size: 18,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              conv.title?.isNotEmpty ?? false
                                  ? conv.title!
                                  : appLocalizations
                                      .ai_docs_unnamed_conversation,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _conversationSubtitle(context, conv),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        tooltip: appLocalizations
                            .ai_docs_delete_conversation_tooltip,
                        icon: const Icon(
                          Icons.more_horiz_rounded,
                          size: 20,
                          color: AppColors.textTertiary,
                        ),
                        padding: EdgeInsets.zero,
                        onSelected: (value) {
                          if (value == 'delete') {
                            _confirmDelete(context, conv.id);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Text(appLocalizations.ai_docs_delete),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  String _conversationSubtitle(
    BuildContext context,
    AiConversationEntity conversation,
  ) {
    final timestamp = conversation.updatedAt ?? conversation.createdAt;
    if (timestamp == null) {
      return 'AI';
    }

    final localizations = MaterialLocalizations.of(context);
    return '${localizations.formatShortDate(timestamp)} · '
        '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(timestamp))}';
  }

  // Helper method to show delete confirmation dialog
  Future<void> _confirmDelete(BuildContext context, int conversationId) async {
    final appLocalizations = AppLocalizations.of(context); // 获取国际化资源

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
              appLocalizations.ai_docs_delete_conversation_title), // 使用国际化文本
          content: Text(
              appLocalizations.ai_docs_delete_conversation_content), // 使用国际化文本
          actions: <Widget>[
            TextButton(
              child: Text(appLocalizations.ai_docs_cancel), // 使用国际化文本
              onPressed: () =>
                  Navigator.of(dialogContext).pop(false), // Return false
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(appLocalizations.ai_docs_delete), // 使用国际化文本
              onPressed: () =>
                  Navigator.of(dialogContext).pop(true), // Return true
            ),
          ],
        );
      },
    );

    // If user confirmed, dispatch the delete event with the specific conversationId
    if (confirm == true) {
      // 直接传递conversationId，不再需要检查是否选中
      context
          .read<AiChatBloc>()
          .add(DeleteSelectedConversation(conversationId: conversationId));
    }
  }
}
