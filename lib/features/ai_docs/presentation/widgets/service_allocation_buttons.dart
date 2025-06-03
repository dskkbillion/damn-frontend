import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/ai_chat/ai_chat_bloc.dart';
import '../../domain/entities/related_service_entity.dart';
import 'package:dskk_flutter_refactor/generated/l10n.dart';

class ServiceAllocationButtons extends StatelessWidget {
  final RelatedServiceEntity service;
  final VoidCallback onTap;
  final VoidCallback onEnterChat;

  const ServiceAllocationButtons({
    super.key,
    required this.service,
    required this.onTap,
    required this.onEnterChat,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    
    return BlocBuilder<AiChatBloc, AiChatState>(
      buildWhen: (previous, current) =>
        previous.serviceAllocationStatus[service.id] != current.serviceAllocationStatus[service.id] ||
        previous.createdChatRoomId != current.createdChatRoomId,
      builder: (context, state) {
        final allocationStatus = state.serviceAllocationStatus[service.id] ?? AllocationStatus.initial;
        final hasActiveChat = state.createdChatRoomId != null;

        // 🆕 根据不同状态显示不同的按钮布局
        if (service.allocationStatusRecorded || allocationStatus == AllocationStatus.success) {
          // 已分发状态 - 显示并列的两个按钮
          return _buildTwoButtonLayout(context, s, hasActiveChat);
        } else {
          // 未分发状态 - 显示单个按钮
          return _buildSingleButton(context, s, allocationStatus);
        }
      },
    );
  }

  // 单个按钮布局（首次状态）
  Widget _buildSingleButton(BuildContext context, S s, AllocationStatus status) {
    String buttonText;
    bool isLoading = false;
    bool isDisabled = false;

    switch (status) {
      case AllocationStatus.initial:
        buttonText = s.ai_docs_let_them_see; // "让ta看看"
        break;
      case AllocationStatus.loading:
        buttonText = s.allocating_step1; // "分发中"
        isLoading = true;
        isDisabled = true;
        break;
      case AllocationStatus.failure:
        buttonText = s.ai_docs_retry; // "重试"
        break;
      default:
        buttonText = s.ai_docs_let_them_see;
    }

    return SizedBox(
      width: double.infinity,
      height: 32,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA86400),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
        ),
        child: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                buttonText,
                style: const TextStyle(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
      ),
    );
  }

  // 🆕 两个按钮并列布局（已分发状态）
  Widget _buildTwoButtonLayout(BuildContext context, S s, bool hasActiveChat) {
    return Row(
      children: [
        // 左侧 - 进入聊天按钮
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 32,
            child: ElevatedButton(
              onPressed: hasActiveChat ? onEnterChat : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50), // 绿色
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                s.ai_docs_enter_chat, // "进入聊天"
                style: const TextStyle(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 8), // 间距
        
        // 右侧 - 再分发按钮（🔄 图标）
        SizedBox(
          width: 32,
          height: 32,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA86400), // 橙色
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.zero,
            ),
            child: const Icon(
              Icons.refresh, // 🔄 刷新图标
              size: 16,
            ),
          ),
        ),
      ],
    );
  }
} 