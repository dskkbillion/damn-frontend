import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/core/widgets/loading_indicator.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/time_settings.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/blocs/time_management/time_management_bloc.dart';
import 'package:get_it/get_it.dart';

/// 卖家时间管理页面
class TimeManagementPage extends StatelessWidget {
  /// 路由名称
  static const routeName = '/seller/profile/time-management';

  /// 构造函数
  const TimeManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<TimeManagementBloc>()..add(LoadTimeSettings()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('时间管理'),
        ),
        body: const TimeManagementBody(),
      ),
    );
  }
}

/// 时间管理页面主体
class TimeManagementBody extends StatelessWidget {
  /// 构造函数
  const TimeManagementBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TimeManagementBloc, TimeManagementState>(
      listener: (context, state) {
        if (state is TimeManagementError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is TimeManagementLoading) {
          return const Center(child: LoadingIndicator());
        }

        if (state is TimeManagementLoaded || state is TimeManagementUpdating) {
          final settings = state is TimeManagementLoaded 
              ? (state as TimeManagementLoaded).settings
              : (state as TimeManagementUpdating).settings;
          
          final isUpdating = state is TimeManagementUpdating;
          
          return _buildContent(context, settings, isUpdating);
        }

        return const Center(child: Text('加载失败，请重试'));
      },
    );
  }

  /// 构建页面内容
  Widget _buildContent(BuildContext context, TimeSettings settings, bool isUpdating) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 在线状态切换
          _buildOnlineStatusSection(context, settings, isUpdating),
          
          const SizedBox(height: 24),
          
          // 状态说明
          _buildStatusDescription(settings.isOnline),
          
          const SizedBox(height: 24),
          
          // 自动离线设置
          _buildAutoOfflineSection(context, settings, isUpdating),
          
          const SizedBox(height: 32),
          
          // 保存按钮
          _buildSaveButton(context, isUpdating),
        ],
      ),
    );
  }

  /// 构建在线状态切换部分
  Widget _buildOnlineStatusSection(BuildContext context, TimeSettings settings, bool isUpdating) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '当前状态',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                Text(
                  settings.isOnline ? '在线' : '离线',
                  style: TextStyle(
                    color: settings.isOnline ? Colors.green : Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Switch(
                  value: settings.isOnline,
                  activeColor: Colors.green,
                  onChanged: isUpdating 
                      ? null 
                      : (value) {
                          context.read<TimeManagementBloc>().add(UpdateOnlineStatus(value));
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建状态说明部分
  Widget _buildStatusDescription(bool isOnline) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isOnline ? '在线状态说明' : '离线状态说明',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isOnline 
                  ? '您当前处于在线状态，买家可以向您发送消息，您将收到新消息的通知。请确保及时回复买家消息，保持良好的响应率有助于提高您的服务质量评分。'
                  : '您当前处于离线状态，买家仍然可以向您发送消息，但系统会告知买家您暂时不在线。您仍然会收到新消息的通知，但可能无法立即回复。长时间保持离线状态可能会影响您的接单效率。',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建自动离线设置部分
  Widget _buildAutoOfflineSection(BuildContext context, TimeSettings settings, bool isUpdating) {
    // 注意：这里使用了StatefulBuilder来管理本地状态
    return StatefulBuilder(
      builder: (context, setState) {
        // 本地状态，表示是否启用自动离线
        bool autoOfflineEnabled = false;
        
        return Card(
          elevation: 1,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '可用时间设置',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                
                // 自动离线开关
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '设置可用时间段',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    Switch(
                      value: autoOfflineEnabled,
                      activeColor: Colors.green,
                      onChanged: isUpdating 
                          ? null 
                          : (value) {
                              setState(() {
                                autoOfflineEnabled = value;
                              });
                            },
                    ),
                  ],
                ),
                
                // 时间段设置（仅在启用时显示）
                if (autoOfflineEnabled) ...[
                  const SizedBox(height: 16),
                  _buildTimeSlotSelector(context, isUpdating),
                  
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  
                  // 添加新时间段按钮
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: isUpdating 
                          ? null 
                          : () {
                              // 添加新时间段的逻辑
                            },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('添加时间段'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 说明文字
                  const Text(
                    '注意：时间段设置将决定您每天对客户的可见状态。在设置的时间段内，您将被显示为在线状态，否则显示为离线状态。',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }
    );
  }
  
  /// 构建时间段选择器
  Widget _buildTimeSlotSelector(BuildContext context, bool isUpdating) {
    // 默认显示周一的时间段
    final weekDay = WeekDay.monday;
    String startTime = '09:00';
    String endTime = '18:00';
    
    return Column(
      children: [
        // 星期选择
        DropdownButtonFormField<WeekDay>(
          value: weekDay,
          decoration: const InputDecoration(
            labelText: '选择星期',
            border: OutlineInputBorder(),
          ),
          items: WeekDay.values.map((day) {
            return DropdownMenuItem<WeekDay>(
              value: day,
              child: Text(day.displayName),
            );
          }).toList(),
          onChanged: isUpdating ? null : (value) {
            // 更新选中的星期几
          },
        ),
        
        const SizedBox(height: 16),
        
        // 时间选择
        Row(
          children: [
            // 开始时间
            Expanded(
              child: TextFormField(
                initialValue: startTime,
                decoration: const InputDecoration(
                  labelText: '开始时间',
                  hintText: 'HH:MM',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: isUpdating 
                    ? null 
                    : () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: int.parse(startTime.split(':')[0]), 
                            minute: int.parse(startTime.split(':')[1]),
                          ),
                        );
                        if (picked != null) {
                          // 更新开始时间
                          startTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                        }
                      },
              ),
            ),
            
            const SizedBox(width: 16),
            
            // 结束时间
            Expanded(
              child: TextFormField(
                initialValue: endTime,
                decoration: const InputDecoration(
                  labelText: '结束时间',
                  hintText: 'HH:MM',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: isUpdating 
                    ? null 
                    : () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: int.parse(endTime.split(':')[0]), 
                            minute: int.parse(endTime.split(':')[1]),
                          ),
                        );
                        if (picked != null) {
                          // 更新结束时间
                          endTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                        }
                      },
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  /// 构建保存按钮
  Widget _buildSaveButton(BuildContext context, bool isUpdating) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isUpdating 
            ? null 
            : () {
                // 保存所有设置
                // 目前只实现了在线状态的更新，时间段设置还需要API支持
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('设置已保存')),
                );
              },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: Colors.green,
          disabledBackgroundColor: Colors.green.withOpacity(0.5),
        ),
        child: const Text(
          '保存设置',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
} 