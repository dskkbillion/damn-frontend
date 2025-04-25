import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/core/widgets/loading_indicator.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/auto_reply_settings.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/blocs/auto_reply/auto_reply_bloc.dart';
import 'package:get_it/get_it.dart';

/// 自动回复设置页面
class AutoReplyPage extends StatelessWidget {
  /// 路由名称
  static const routeName = '/seller/profile/auto-reply';

  /// 构造函数
  const AutoReplyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<AutoReplyBloc>()..add(LoadAutoReplySettings()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('自动回复设置'),
        ),
        body: const AutoReplyBody(),
      ),
    );
  }
}

/// 自动回复设置页面主体
class AutoReplyBody extends StatefulWidget {
  /// 构造函数
  const AutoReplyBody({Key? key}) : super(key: key);

  @override
  State<AutoReplyBody> createState() => _AutoReplyBodyState();
}

class _AutoReplyBodyState extends State<AutoReplyBody> {
  final TextEditingController _contentController = TextEditingController();
  bool _isContentDirty = false;

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
        } else if (state is AutoReplyLoaded && !_isContentDirty) {
          // 只有在首次加载或重置状态时才更新文本控制器
          _contentController.text = state.settings.content ?? '';
        }
      },
      builder: (context, state) {
        if (state is AutoReplyLoading) {
          return const Center(child: LoadingIndicator());
        }

        if (state is AutoReplyLoaded || state is AutoReplyUpdating) {
          final settings = state is AutoReplyLoaded 
              ? (state as AutoReplyLoaded).settings
              : (state as AutoReplyUpdating).settings;
          
          final isUpdating = state is AutoReplyUpdating;
          
          return _buildContent(context, settings, isUpdating);
        }

        return const Center(child: Text('加载失败，请重试'));
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
            const Text(
              '自动回复',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Switch(
              value: settings.isEnabled,
              activeColor: Colors.green,
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
            const Text(
              '回复内容',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 2,
              ),
            ),
            
            const SizedBox(height: 8),
            
            TextField(
              controller: _contentController,
              enabled: !isUpdating,
              decoration: const InputDecoration(
                hintText: '请输入自动回复内容',
                border: OutlineInputBorder(),
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
            
            const Text(
              '当客户发送消息时，系统会自动回复此内容',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
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
              const SnackBar(content: Text('回复内容不能为空')),
            );
            return;
          }
          
          context.read<AutoReplyBloc>().add(UpdateAutoReplyContent(content));
          setState(() {
            _isContentDirty = false;
          });
        } else {
          // 如果内容没有变化，显示提示
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('设置已保存')),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 12),
        disabledBackgroundColor: Colors.green.withOpacity(0.5),
      ),
      child: const Text(
        '保存设置',
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }
} 