import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart'; // Import GetIt
import 'package:dskk_flutter_refactor/core/widgets/loading_indicator.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/time_settings.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/blocs/time_management/time_management_bloc.dart';

/// 卖家时间管理页面
class TimeManagementPage extends StatelessWidget {
  /// 路由名称 - This might be outdated or unused if GoRouter is primary
  static const routeName = '/seller/profile/time-management';

  /// 构造函数
  const TimeManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provide the Bloc here
    return BlocProvider<TimeManagementBloc>(
      create: (context) {
        // Use GetIt to get the instance and add the initial event
        final bloc = GetIt.I<TimeManagementBloc>();
        // Assuming LoadTimeSettings is the correct initial event based on previous code
        bloc.add(LoadTimeSettings()); 
        return bloc;
      },
      // Wrap the Scaffold with BlocProvider
      child: Scaffold(
        appBar: AppBar(
          title: const Text('时间管理'),
          // Optional: Add back button if needed, depends on navigation flow
          // leading: IconButton(
          //   icon: const Icon(Icons.arrow_back),
          //   onPressed: () => Navigator.of(context).pop(),
          // ),
        ),
        // Use the context provided by BlocProvider
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
    // BlocConsumer now uses the context provided by the BlocProvider in TimeManagementPage.build
    return BlocConsumer<TimeManagementBloc, TimeManagementState>(
      listener: (context, state) {
        if (state is TimeManagementError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        // Optional: Add listener for success state if needed
        // if (state is TimeManagementLoaded && state.justUpdated) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('设置已保存')),
        //   );
        // }
      },
      builder: (context, state) {
        if (state is TimeManagementInitial || state is TimeManagementLoading) { // Handle Initial state
          return const Center(child: LoadingIndicator());
        }

        if (state is TimeManagementLoaded || state is TimeManagementUpdating) {
          // No change needed here, state access is correct
          final settings = state is TimeManagementLoaded
              ? state.settings
              : (state as TimeManagementUpdating).settings;

          final isUpdating = state is TimeManagementUpdating;

          // Pass the context (which has Bloc access) down
          return _buildContent(context, settings, isUpdating);
        }
        
        if (state is TimeManagementError) { // Handle Error state more explicitly in builder
           return Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 const Text('加载失败'),
                 const SizedBox(height: 8),
                 Text(state.message, style: const TextStyle(color: Colors.red)),
                 const SizedBox(height: 16),
                 ElevatedButton(
                   onPressed: () => context.read<TimeManagementBloc>().add(LoadTimeSettings()),
                   child: const Text('重试'),
                 )
               ],
             ),
           );
        }

        // Fallback for any other unhandled state
        return const Center(child: Text('未知状态'));
      },
    );
  }

  /// 构建页面内容
  Widget _buildContent(BuildContext context, TimeSettings settings, bool isUpdating) {
    // Pass context down
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

          // 保存按钮 - Needs context for Bloc access
          _buildSaveButton(context, isUpdating),
        ],
      ),
    );
  }

  /// 构建在线状态切换部分
  Widget _buildOnlineStatusSection(BuildContext context, TimeSettings settings, bool isUpdating) {
    // No changes needed here, context.read will work correctly
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
                          // Context here has access to the Bloc
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
    // This widget doesn't need context for Bloc access
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
    // The StatefulBuilder's context might be different, but the parent context passed
    // to this method (`context`) still has access to the Bloc.
    // If TimeSlotSelector or Add Button need Bloc access, pass the main `context`.
    return StatefulBuilder(
      builder: (statefulBuilderContext, setState) { // Use a different name for this context
        // Check if availableTimeSlots is not null and not empty to determine if enabled
        bool autoOfflineEnabled = settings.availableTimeSlots != null && settings.availableTimeSlots!.isNotEmpty;
        // Get actual time slots from settings
        List<TimeSlot> currentTimeSlots = settings.availableTimeSlots ?? [];

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
                              // Optionally dispatch an event immediately, or wait for Save button
                              // context.read<TimeManagementBloc>().add(UpdateAutoOfflineEnabled(value));
                            },
                    ),
                  ],
                ),
                
                // 时间段设置（仅在启用时显示）
                if (autoOfflineEnabled) ...[
                  const SizedBox(height: 16),
                  // Pass the main context if this widget needs Bloc access
                  _buildTimeSlotSelector(context, settings, isUpdating),
                  
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  
                  // 添加新时间段按钮
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: isUpdating
                          ? null
                          : () {
                              // Pass the main context if Add logic needs Bloc access
                              // _showAddTimeSlotDialog(context);
                              print("Add time slot clicked"); // Placeholder
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
  
  /// 构建时间段选择器 (Placeholder - Needs actual implementation)
  Widget _buildTimeSlotSelector(BuildContext context, TimeSettings settings, bool isUpdating) {
     // TODO: Implement time slot display and editing based on settings.autoOfflineSchedule?.slots
     // This will likely involve iterating through slots and providing ways to modify/delete them.
     // It might need access to the Bloc via `context`.
     return Container(
       padding: const EdgeInsets.symmetric(vertical: 8.0),
       child: const Text(
         "时间段选择器 (待实现)",
         style: TextStyle(color: Colors.grey),
       ),
     );
  }
  
  /// 构建保存按钮
  Widget _buildSaveButton(BuildContext context, bool isUpdating) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        // Disable button if isUpdating
        onPressed: isUpdating ? null : () {
          // Dispatch Save event using the context with Bloc access
          // TODO: Gather the current state from the UI (online status, auto-offline settings)
          // and pass it to the SaveSettings event.
          // final currentSettings = gatherCurrentSettingsFromUI();
          // context.read<TimeManagementBloc>().add(SaveSettings(currentSettings));
          print("Save button clicked"); // Placeholder
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('保存功能待实现')),
           );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.deepPurple, // Or your theme's primary color
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        child: isUpdating
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text('保存设置'),
      ),
    );
  }
} 