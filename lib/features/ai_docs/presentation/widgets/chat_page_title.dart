import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/bloc/ai_chat/ai_chat_bloc.dart';

/// 聊天页面的可交互标题组件
/// 支持点击编辑标题和AI生成标题功能
class ChatPageTitle extends StatelessWidget {
  const ChatPageTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    
    return BlocBuilder<AiChatBloc, AiChatState>(
      buildWhen: (previous, current) => 
        previous.selectedConversationId != current.selectedConversationId ||
        previous.conversations != current.conversations ||
        previous.messages != current.messages ||
        previous.titleStatus != current.titleStatus,
      builder: (context, state) {
        final selectedId = state.selectedConversationId;
        
        // 如果没有选中会话，显示默认标题
        if (selectedId == null) {
          return Text(appLocalizations.ai_docs_assistant_title);
        }
        
        // 查找选中的会话
        final selectedConversation = state.conversations.firstWhereOrNull(
          (conv) => conv.id == selectedId,
        );
        
        if (selectedConversation == null) {
          return Text(appLocalizations.ai_docs_loading);
        }
        
        final title = selectedConversation.title ?? appLocalizations.ai_docs_unnamed_conversation;
        final shouldShowAIGenerate = _shouldShowAIGenerateButton(state, selectedConversation, title, appLocalizations.ai_docs_unnamed_conversation);
        
        return Row(
          children: [
            // 可点击的标题
            Expanded(
              child: GestureDetector(
                onTap: () => _showTitleEditDialog(context, selectedConversation),
                child: Text(
                  title,
                  style: Theme.of(context).appBarTheme.titleTextStyle ?? 
                         Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            
            // AI生成标题按钮（条件显示）
            if (shouldShowAIGenerate) ...[
              const SizedBox(width: 8),
              BlocBuilder<AiChatBloc, AiChatState>(
                buildWhen: (previous, current) => 
                  previous.conversationTitleStatus != current.conversationTitleStatus ||
                  previous.titleStatus != current.titleStatus,
                builder: (context, state) {
                  final titleStatus = state.conversationTitleStatus[selectedId] ?? TitleStatus.initial;
                  final isGenerating = titleStatus == TitleStatus.generating;
                  
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: InkWell(
                      onTap: isGenerating ? null : () => _generateTitle(context, selectedId),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isGenerating)
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )
                            else
                              Icon(
                                Icons.auto_awesome,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            const SizedBox(width: 4),
                            Text(
                              isGenerating ? appLocalizations.ai_docs_generating_title : appLocalizations.ai_docs_generate_title,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }

  /// 判断是否应该显示AI生成标题按钮
  bool _shouldShowAIGenerateButton(
    AiChatState state,
    AiConversationEntity conversation,
    String title,
    String unnamedConversationTitle
  ) {
    // 1. 检查是否为默认标题
    final isDefaultTitle = title == unnamedConversationTitle ||
                          title.isEmpty ||
                          title.trim().isEmpty;
    
    // 2. 检查用户消息轮次（用户消息数量 >= 3）
    final userMessageCount = state.messages
        .where((msg) => msg.sender == MessageSender.user)
        .length;
    
    // 3. 检查当前是否正在生成或更新标题
    final titleStatus = state.conversationTitleStatus[conversation.id] ?? TitleStatus.initial;
    final isProcessing = titleStatus == TitleStatus.generating || titleStatus == TitleStatus.updating;
    
    return isDefaultTitle && userMessageCount >= 3 && !isProcessing;
  }

  /// 显示标题编辑对话框
  void _showTitleEditDialog(BuildContext context, AiConversationEntity conversation) {
    final aiChatBloc = context.read<AiChatBloc>(); // 获取当前的BLoC实例
    
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: aiChatBloc, // 传递BLoC实例到对话框
        child: _TitleEditDialog(
          conversation: conversation,
          pageContext: context,
        ),
      ),
    );
  }

  /// 生成标题
  void _generateTitle(BuildContext context, int conversationId) {
    context.read<AiChatBloc>().add(
      GenerateConversationTitle(conversationId: conversationId),
    );
  }
}

/// 独立的标题编辑对话框组件，用于管理TextEditingController的生命周期
class _TitleEditDialog extends StatefulWidget {
  final AiConversationEntity conversation;
  final BuildContext pageContext;

  const _TitleEditDialog({
    required this.conversation,
    required this.pageContext,
  });

  @override
  State<_TitleEditDialog> createState() => _TitleEditDialogState();
}

class _TitleEditDialogState extends State<_TitleEditDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.conversation.title);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    
    return AlertDialog(
      title: Text(appLocalizations.ai_docs_edit_title),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: appLocalizations.ai_docs_edit_title_hint,
          counterText: '',
          border: const OutlineInputBorder(),
        ),
        maxLength: 50,
        autofocus: true,
        onSubmitted: (_) => _updateTitle(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(appLocalizations.ai_docs_cancel),
        ),
        BlocBuilder<AiChatBloc, AiChatState>(
          buildWhen: (previous, current) => 
            previous.conversationTitleStatus != current.conversationTitleStatus,
          builder: (dialogBuilderContext, state) {
            final titleStatus = state.conversationTitleStatus[widget.conversation.id] ?? TitleStatus.initial;
            final isUpdating = titleStatus == TitleStatus.updating;
            
            return TextButton(
              onPressed: isUpdating ? null : _updateTitle,
              child: isUpdating 
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(dialogBuilderContext).colorScheme.primary,
                    ),
                  )
                : Text(appLocalizations.profile_save),
            );
          },
        ),
      ],
    );
  }

  /// 更新标题
  void _updateTitle() {
    final newTitle = _controller.text.trim();
    
    // 简单的客户端验证，不显示提示
    if (newTitle.isEmpty || newTitle.length > 50) {
      return;
    }
    
    // 先关闭对话框
    Navigator.pop(context);
    
    // 然后在页面上下文中触发更新标题事件
    widget.pageContext.read<AiChatBloc>().add(
      UpdateConversationTitle(
        conversationId: widget.conversation.id,
        title: newTitle,
      ),
    );
  }
} 