import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import '../bloc/ai_chat/ai_chat_bloc.dart';
import '../../domain/entities/related_service_entity.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

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
    final appLocalizations = AppLocalizations.of(context)!;

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
          return _buildTwoButtonLayout(context, appLocalizations, hasActiveChat);
        } else {
          // 未分发状态 - 显示单个按钮
          return _buildSingleButton(context, appLocalizations, allocationStatus);
        }
      },
    );
  }

  // 单个按钮布局（首次状态）
  Widget _buildSingleButton(BuildContext context, AppLocalizations appLocalizations, AllocationStatus status) {
    String buttonText;
    bool isLoading = false;
    bool isDisabled = false;

    switch (status) {
      case AllocationStatus.initial:
        buttonText = appLocalizations.ai_docs_let_them_see; // "让ta看看"
        break;
      case AllocationStatus.loading:
        buttonText = appLocalizations.allocating_step1; // "分发中"
        isLoading = true;
        isDisabled = true;
        break;
      case AllocationStatus.failure:
        buttonText = appLocalizations.ai_docs_retry; // "重试"
        break;
      default:
        buttonText = appLocalizations.ai_docs_let_them_see;
    }

    return SizedBox(
      width: double.infinity,
      height: 32,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
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
  Widget _buildTwoButtonLayout(BuildContext context, AppLocalizations appLocalizations, bool hasActiveChat) {
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
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                appLocalizations.ai_docs_enter_chat, // "进入聊天"
                style: const TextStyle(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),

        const SizedBox(width: AppDimensions.spacingSm), // 间距

        // 右侧 - 再分发按钮（🔄 图标）
        SizedBox(
          width: 32,
          height: 32,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
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
