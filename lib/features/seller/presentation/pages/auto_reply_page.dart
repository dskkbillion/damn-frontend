import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/widgets/loading_indicator.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/auto_reply_settings.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/blocs/auto_reply/auto_reply_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';

/// 自动回复设置页面
class AutoReplyPage extends StatelessWidget {
  /// 路由名称
  static const routeName = '/seller/profile/auto-reply';

  /// 构造函数
  const AutoReplyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AutoReplyBloc>(
      create: (context) {
        final bloc = GetIt.I<AutoReplyBloc>();
        bloc.add(LoadAutoReplySettings());
        return bloc;
      },
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).auto_reply_title ?? 'Auto Reply Settings'),
          ),
          body: const AutoReplyBody(),
        ),
      ),
    );
  }
}

/// 自动回复设置页面主体
class AutoReplyBody extends StatefulWidget {
  /// 构造函数
  const AutoReplyBody({super.key});

  @override
  State<AutoReplyBody> createState() => _AutoReplyBodyState();
}

class _AutoReplyBodyState extends State<AutoReplyBody> {
  final TextEditingController _contentController = TextEditingController();
  bool _isContentDirty = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AutoReplyBloc, AutoReplyState>(
      listener: (context, state) {
        if (state is AutoReplyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          // 保存失败时，重置dirty状态
          setState(() {
            _isContentDirty = true;
          });
        } else if (state is AutoReplySaveSuccess) {
          // #218 SELL-10: 给"保存成功"更明显的反馈(default 4s 太短不易察觉)
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context).auto_reply_settings_saved ?? 'Settings Saved'),
                  ],
                ),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
        } else if (state is AutoReplyLoaded) {
          // 更新文本控制器和状态
          _contentController.text = state.settings.content ?? '';

          // 重置dirty状态
          setState(() {
            _isContentDirty = false;
          });
        }
      },
      builder: (context, state) {
        if (state is AutoReplyLoading) {
          return const Center(child: LoadingIndicator());
        }

        if (state is AutoReplyLoaded || state is AutoReplyUpdating) {
          final settings = state is AutoReplyLoaded
              ? state.settings
              : (state as AutoReplyUpdating).settings;

          final isUpdating = state is AutoReplyUpdating;

          return _buildContent(context, settings, isUpdating);
        }

        if (state is AutoReplyError && state.previousSettings != null) {
          return _buildContent(context, state.previousSettings!, false);
        }

        return Center(child: Text(AppLocalizations.of(context).auto_reply_load_failed ?? 'Load failed, please try again'));
      },
    );
  }

  /// 构建页面内容
  Widget _buildContent(BuildContext context, AutoReplySettings settings, bool isUpdating) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 自动回复开关卡片
          _buildAutoReplySwitch(context, settings, isUpdating),
          
          const SizedBox(height: 16),
          
          // 自动回复内容卡片，仅在启用时显示
          if (settings.isEnabled)
            _buildAutoReplyContent(context, settings, isUpdating),
          
          const Spacer(),
          
          // 保存按钮
          _buildSaveButton(context, settings, isUpdating),
        ],
      ),
    );
  }

  /// 构建自动回复开关部分
  Widget _buildAutoReplySwitch(BuildContext context, AutoReplySettings settings, bool isUpdating) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context).auto_reply_enable ?? 'Auto Reply',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Switch(
              value: settings.isEnabled,
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return Theme.of(context).colorScheme.primary;
                return null;
              }),
              onChanged: isUpdating 
                  ? null 
                  : (value) {
                      context.read<AutoReplyBloc>().add(UpdateAutoReplyEnabled(value));
                    },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建自动回复内容部分
  Widget _buildAutoReplyContent(BuildContext context, AutoReplySettings settings, bool isUpdating) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).auto_reply_content ?? 'Reply Content',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 2,
              ),
            ),
            
            const SizedBox(height: 8),
            
            TextField(
              controller: _contentController,
              enabled: !isUpdating,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).auto_reply_content_hint ?? 'Please enter auto reply content',
                border: const OutlineInputBorder(),
              ),
              maxLines: 5,
              minLines: 3,
              onChanged: (value) {
                setState(() {
                  _isContentDirty = true;
                });
              },
            ),
            
            const SizedBox(height: 12),
            
            Text(
              AppLocalizations.of(context).auto_reply_content_description ?? 'When customers send messages, the system will automatically reply with this content',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建保存按钮
  Widget _buildSaveButton(BuildContext context, AutoReplySettings settings, bool isUpdating) {
    return ElevatedButton(
      onPressed: isUpdating || !settings.isEnabled ? null : () {
        if (_isContentDirty) {
          // 保存内容
          final content = _contentController.text.trim();
          if (content.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context).auto_reply_content_required ?? 'Reply content cannot be empty')),
            );
            return;
          }
          
          context.read<AutoReplyBloc>().add(UpdateAutoReplyContent(content));
          // 不要立即设置 _isContentDirty = false，等待保存完成
        } else {
          // 如果内容没有变化，显示提示
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).auto_reply_settings_saved ?? 'Settings Saved')),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.success,
        padding: const EdgeInsets.symmetric(vertical: 12),
        disabledBackgroundColor: AppColors.success.withValues(alpha: 0.5),
      ),
      child: Text(
        AppLocalizations.of(context).auto_reply_save_settings ?? 'Save Settings',
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.onPrimary,
        ),
      ),
    );
  }
} 